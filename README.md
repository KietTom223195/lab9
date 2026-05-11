# RSA Lab — Chữ Ký Số với OpenSSL

## Sinh viên
- Phạm Tuấn Kiệt — MSSV: 1874010152
- Lê Thị Vân Anh — MSSV: 1871020049

## Yêu cầu
```bash
sudo apt install libssl-dev g++
```

## Biên dịch
```bash
make all
# hoặc từng chương trình
g++ -o generate_keys   generate_keys.cpp   -lssl -lcrypto
g++ -o sign_message    sign_message.cpp    -lssl -lcrypto
g++ -o verify_signature verify_signature.cpp -lssl -lcrypto
```

## Sử dụng

### Bài 1 — Tạo cặp khóa RSA-2048
```bash
./generate_keys
# → public_key.pem, private_key.pem
```

### Bài 2 — Ký thông điệp
```bash
echo "Hello World!" > message.txt
./sign_message message.txt private_key.pem signature.bin
# → signature.bin
```

### Bài 3 — Xác minh chữ ký
```bash
# Xác minh hợp lệ
./verify_signature message.txt public_key.pem signature.bin

# Kiểm tra giả mạo
echo "Fake message" > fake.txt
./verify_signature fake.txt public_key.pem signature.bin
```

### Chạy toàn bộ demo
```bash
make demo
```

## Web App
Mở `index.html` trực tiếp trong trình duyệt (không cần server).

## Demo giao diện
Ảnh demo giao diện được đính kèm bên dưới. Để hiển thị trong `README`, đặt file ảnh vào `assets/demo.png` trong thư mục dự án (nếu bạn đang sử dụng GitHub, commit file ảnh cùng README):

![Demo giao diện](assets/demo.png)

Nếu bạn muốn, tôi có thể thêm file ảnh trực tiếp vào repo — upload ảnh ở đây hoặc cho tôi đường dẫn tới file và tôi sẽ commit giúp.
