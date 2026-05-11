#!/bin/bash

# Deploy script for lab9 to Nginx
# Usage: bash deploy.sh [domain] [path]
# Example: bash deploy.sh tomlynh.io.vn /var/www/tomlynh.io.vn/lab9

DOMAIN="${1:-tomlynh.io.vn}"
WEB_ROOT="${2:-/var/www/tomlynh.io.vn/lab9}"
REPO_URL="https://github.com/KietTom223195/lab9.git"
WEB_USER="www-data"
WEB_GROUP="www-data"

echo "=========================================="
echo "Deploy Script for lab9"
echo "Domain: $DOMAIN"
echo "Web Root: $WEB_ROOT"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
   echo "Lỗi: phải chạy script với quyền root (sudo)"
   exit 1
fi

# Step 1: Update system packages
echo "[1/6] Cập nhật package manager..."
if command -v apt &> /dev/null; then
    apt update -qq
elif command -v yum &> /dev/null; then
    yum update -y -q
else
    echo "Cảnh báo: không thể cập nhật package manager"
fi

# Step 2: Install git and nginx
echo "[2/6] Cài đặt git và nginx..."
if command -v apt &> /dev/null; then
    apt install -y git nginx
    WEB_USER="www-data"
    WEB_GROUP="www-data"
elif command -v yum &> /dev/null; then
    yum install -y git nginx
    WEB_USER="nginx"
    WEB_GROUP="nginx"
else
    echo "Cảnh báo: không thể cài đặt git/nginx"
fi

# Step 3: Create web directory and clone repo
echo "[3/6] Tạo thư mục và clone repo từ GitHub..."
mkdir -p "$(dirname "$WEB_ROOT")"
if [ -d "$WEB_ROOT/.git" ]; then
    echo "Thư mục đã có .git, cập nhật từ remote..."
    cd "$WEB_ROOT"
    git fetch origin main
    git reset --hard origin/main
else
    echo "Clone repo mới vào $WEB_ROOT..."
    git clone "$REPO_URL" "$WEB_ROOT"
    cd "$WEB_ROOT"
    git checkout main
fi

# Step 4: Set permissions
echo "[4/6] Chỉnh quyền file/thư mục..."
chown -R "$WEB_USER:$WEB_GROUP" "$WEB_ROOT"
chmod -R 755 "$WEB_ROOT"
find "$WEB_ROOT" -type f -exec chmod 644 {} \;

# Step 5: Create/Update Nginx config
echo "[5/6] Cấu hình Nginx..."
NGINX_CONFIG="/etc/nginx/sites-available/$DOMAIN"
if [ ! -f "$NGINX_CONFIG" ]; then
    # Tạo file config mới cho domain
    cat > "$NGINX_CONFIG" <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root /var/www/$DOMAIN;

    # Location cho lab9
    location /lab9/ {
        alias $WEB_ROOT/;
        index index.html;
        try_files \$uri \$uri/ =404;
        
        # Hỗ trợ Web Crypto API
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Content-Type' always;
    }

    # Redirect http -> https (nếu có SSL cert)
    # return 301 https://\$server_name\$request_uri;

    access_log /var/log/nginx/${DOMAIN}.access.log;
    error_log  /var/log/nginx/${DOMAIN}.error.log;
}
EOF
    echo "Tạo config: $NGINX_CONFIG"
else
    echo "Config đã tồn tại: $NGINX_CONFIG (không ghi đè)"
fi

# Enable site (Debian style)
if [ ! -L "/etc/nginx/sites-enabled/$DOMAIN" ] && command -v a2ensite &> /dev/null; then
    a2ensite "$DOMAIN"
elif [ ! -L "/etc/nginx/sites-enabled/$DOMAIN" ] && [ -d "/etc/nginx/sites-enabled" ]; then
    ln -sf "$NGINX_CONFIG" "/etc/nginx/sites-enabled/$DOMAIN"
    echo "Enable site: $DOMAIN"
fi

# Step 6: Test and reload Nginx
echo "[6/6] Kiểm tra và reload Nginx..."
if nginx -t 2>&1 | grep -q "successful"; then
    systemctl reload nginx || service nginx reload
    echo "✓ Nginx reloaded thành công"
else
    echo "✗ Lỗi cấu hình Nginx! Kiểm tra lại."
    nginx -t
    exit 1
fi

echo ""
echo "=========================================="
echo "✓ Deploy hoàn tất!"
echo "=========================================="
echo "Truy cập: http://$DOMAIN/lab9/"
echo "Web Root: $WEB_ROOT"
echo ""
echo "Nếu muốn cập nhật lần tới, chạy:"
echo "  cd $WEB_ROOT && git pull"
echo ""
