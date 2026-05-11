const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const path = require('path');
const { exec } = require('child_process');
const net = require('net');
const fs = require('fs');

const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: { origin: "*", methods: ["GET", "POST"] }
});

const PORT = 3000;
const TCP_PORT = 5000;

// Middleware
app.use(express.static(__dirname));
app.use(express.json());

// Biến lưu trữ client kết nối
const clients = new Map();

// ========== Socket.io WebSocket ==========
io.on('connection', (socket) => {
  console.log(`[WebSocket] Client kết nối: ${socket.id}`);
  clients.set(socket.id, socket);

  // Gửi danh sách client
  io.emit('client-list', Array.from(clients.keys()));

  // Nhận thông điệp từ client
  socket.on('send-message', async (data) => {
    console.log(`[Message] Từ ${socket.id}:`, data);
    const { to, message, sign } = data;

    if (sign) {
      // Ký thông điệp
      try {
        const signed = await signMessage(message);
        if (signed) {
          io.to(to).emit('receive-message', {
            from: socket.id,
            message,
            signature: signed,
            timestamp: new Date().toLocaleString('vi-VN')
          });
          socket.emit('message-sent', { status: 'success' });
        }
      } catch (e) {
        socket.emit('message-sent', { status: 'error', error: e.message });
      }
    } else {
      // Gửi không ký
      io.to(to).emit('receive-message', {
        from: socket.id,
        message,
        signature: null,
        timestamp: new Date().toLocaleString('vi-VN')
      });
      socket.emit('message-sent', { status: 'success' });
    }
  });

  // Xác minh chữ ký
  socket.on('verify-message', async (data) => {
    const { message, signature } = data;
    try {
      const result = await verifySignature(message, signature);
      socket.emit('verify-result', { valid: result });
    } catch (e) {
      socket.emit('verify-result', { valid: false, error: e.message });
    }
  });

  socket.on('disconnect', () => {
    console.log(`[WebSocket] Client mất kết nối: ${socket.id}`);
    clients.delete(socket.id);
    io.emit('client-list', Array.from(clients.keys()));
  });
});

// ========== TCP Server (cho client khác) ==========
const tcpServer = net.createServer((socket) => {
  const remoteAddr = `${socket.remoteAddress}:${socket.remotePort}`;
  console.log(`[TCP] Client kết nối: ${remoteAddr}`);

  socket.on('data', (data) => {
    try {
      const message = JSON.parse(data.toString());
      console.log(`[TCP] Nhận:`, message);

      // Phát lại cho tất cả WebSocket client
      io.emit('tcp-message', {
        from: remoteAddr,
        message: message.message,
        signature: message.signature || null,
        timestamp: new Date().toLocaleString('vi-VN')
      });

      socket.write(JSON.stringify({ status: 'ok' }));
    } catch (e) {
      socket.write(JSON.stringify({ status: 'error', error: e.message }));
    }
  });

  socket.on('end', () => {
    console.log(`[TCP] Client ngắt kết nối: ${remoteAddr}`);
  });

  socket.on('error', (err) => {
    console.error(`[TCP] Lỗi: ${err}`);
  });
});

// ========== REST API ==========
app.get('/api/status', (req, res) => {
  res.json({
    status: 'ok',
    clients: clients.size,
    timestamp: new Date().toLocaleString('vi-VN')
  });
});

app.post('/api/sign', (req, res) => {
  const { message } = req.body;
  if (!message) {
    return res.status(400).json({ error: 'Message required' });
  }

  signMessage(message)
    .then(signature => res.json({ message, signature }))
    .catch(err => res.status(500).json({ error: err.message }));
});

app.post('/api/verify', (req, res) => {
  const { message, signature } = req.body;
  if (!message || !signature) {
    return res.status(400).json({ error: 'Message and signature required' });
  }

  verifySignature(message, signature)
    .then(valid => res.json({ message, valid }))
    .catch(err => res.status(500).json({ error: err.message }));
});

// ========== Hàm ký/xác minh ==========
function signMessage(message) {
  return new Promise((resolve, reject) => {
    // Lưu thông điệp vào file tạm
    const tempFile = path.join(__dirname, 'temp_message.txt');
    fs.writeFileSync(tempFile, message);

    // Gọi chương trình C++ ký
    exec(`${path.join(__dirname, 'sign_message')} ${tempFile} public_key.pem signature.bin`, (err) => {
      if (err) return reject(err);

      // Đọc chữ ký
      const sigFile = path.join(__dirname, 'signature.bin');
      if (fs.existsSync(sigFile)) {
        const sig = fs.readFileSync(sigFile, 'base64');
        fs.unlinkSync(tempFile);
        resolve(sig);
      } else {
        reject(new Error('Không tạo được chữ ký'));
      }
    });
  });
}

function verifySignature(message, signature) {
  return new Promise((resolve, reject) => {
    const tempFile = path.join(__dirname, 'temp_verify.txt');
    const sigFile = path.join(__dirname, 'temp_sig.bin');

    fs.writeFileSync(tempFile, message);
    fs.writeFileSync(sigFile, Buffer.from(signature, 'base64'));

    exec(`${path.join(__dirname, 'verify_signature')} ${tempFile} public_key.pem ${sigFile}`, (err) => {
      fs.unlinkSync(tempFile);
      fs.unlinkSync(sigFile);
      resolve(!err); // Nếu không lỗi = hợp lệ
    });
  });
}

// ========== Khởi động ==========
server.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ RSA Lab Server chạy tại http://localhost:${PORT}`);
  console.log(`✅ WebSocket bật tại ws://localhost:${PORT}`);
});

tcpServer.listen(TCP_PORT, '0.0.0.0', () => {
  console.log(`✅ TCP Server chạy tại 0.0.0.0:${TCP_PORT}`);
});

// Xử lý tắt server
process.on('SIGINT', () => {
  console.log('\n👋 Đóng server...');
  server.close();
  tcpServer.close();
  process.exit(0);
});
