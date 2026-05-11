# 🚀 RSA LAB - HƯỚNG DẪN CHẠY TOÀN BỘ

## ⚙️ Yêu cầu

- **Node.js** (v14+) - [Tải tại đây](https://nodejs.org)
- **npm** (đi kèm Node.js)
- **g++ & OpenSSL** (nếu dùng C++ programs)

## 🎯 Cách 1: Chạy Script (Dễ Nhất)

### Windows
1. Nhấp đúp file: **`run_all.bat`**
2. Chờ script tự động cài dependencies
3. Server sẽ chạy tự động tại `http://localhost:3000`
4. Mở trình duyệt → **`http://localhost:3000`**

### macOS/Linux
```bash
bash run_all.sh
```

## 🎯 Cách 2: Chạy Thủ Công

### Step 1: Mở Command Prompt (cmd)
```bash
cd c:\Users\Tom\Desktop\rsa_lab\rsa_webapp
```

### Step 2: Cài Dependencies
```bash
npm install
```

### Step 3: Chạy Server
```bash
npm start
```

### Step 4: Mở Trình Duyệt
- URL: `http://localhost:3000`
- Bạn sẽ thấy giao diện CYBERPUNK đẹp lung linh!

---

## 🌐 Kết Nối Đa Máy

### Máy A (Server - Chạy npm start)
- IP: `192.168.1.100` (hoặc IP thực của máy)

### Máy B (Client)
1. Mở browser
2. Nhập: `http://192.168.1.100:3000`
3. Nhấn "🔌 CONNECT" → Nhập IP + Port 3000

---

## 📝 Các Tính Năng

### 🔐 Key Genesis
- Tạo cặp khóa RSA-2048
- Download public/private keys

### ✍ Sign Message  
- Ký thông điệp bằng private key
- Download chữ ký

### 🔍 Verify Sig
- Xác minh chữ ký bằng public key
- Test giả mạo

### 🌐 Network Relay
- Kết nối qua mạng
- Gửi/nhận thông điệp có ký
- Giao tiếp 2 chiều

---

## 🆘 Gặp Lỗi?

### ❌ "npm: command not found"
→ Cài Node.js từ https://nodejs.org

### ❌ "Port 3000 already in use"
→ Đổi port hoặc kill process cũ:
```bash
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### ❌ "Socket.io connection refused"
→ Kiểm tra firewall hoặc IP address

---

## 📊 Kiến Trúc

```
┌─────────────────────────────────────────────┐
│     Browser (Port 3000)                     │
│  ┌─────────────────────────────────────┐   │
│  │  RSA Lab - Cyberpunk UI             │   │
│  │  - Key Generation                   │   │
│  │  - Sign/Verify                      │   │
│  │  - Network Chat                     │   │
│  └─────────────────────────────────────┘   │
└──────────────┬──────────────────────────────┘
               │ WebSocket
               ▼
┌─────────────────────────────────────────────┐
│   Node.js Server (Express + Socket.io)      │
│  - Port 3000: HTTP/WebSocket                │
│  - Port 5000: TCP Socket                    │
└──────────────┬──────────────────────────────┘
               │
               ▼
   C++ Programs (OpenSSL)
   - generate_keys
   - sign_message
   - verify_signature
```

---

## 🎮 Sử Dụng

### Máy A (Người Gửi):
1. Tạo khóa RSA: **⚡ Generate**
2. Nhập thông điệp
3. Ký thông điệp: **✍ SIGN**
4. Kết nối: **🔌 CONNECT** (localhost:3000)
5. Gửi: **✈ SEND** hoặc **✍ SIGN+SEND**

### Máy B (Người Nhận):
1. Kết nối: **🔌 CONNECT** (192.168.1.100:3000)
2. Nhận thông điệp → Hiển thị tự động
3. Xác minh: Dán vào tab **Verify Sig** → **🔍 VERIFY**

---

## 🎨 Giao Diện

- **Cyberpunk Theme**: Neon colors, grid background, animations
- **Responsive**: Mobile, tablet, desktop
- **Real-time**: WebSocket communication
- **Modern UI**: Glassmorphism, glitch effects

---

**Bất kỳ câu hỏi? Cứ hỏi! 🚀**
