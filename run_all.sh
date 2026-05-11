#!/bin/bash

clear
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          🔐 RSA LAB - CYBER ENCRYPTION SYSTEM 🔐           ║"
echo "║                   INITIALIZING STARTUP                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"

echo "[1/4] Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found! Please install from https://nodejs.org"
    exit 1
fi
echo "✓ Node.js detected: $(node --version)"

echo ""
echo "[2/4] Installing dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "❌ npm install failed!"
    exit 1
fi
echo "✓ Dependencies installed"

echo ""
echo "[3/4] Building C++ programs..."
echo "Building: generate_keys.cpp"
g++ -o generate_keys generate_keys.cpp -lssl -lcrypto 2>/dev/null
if [ $? -ne 0 ]; then
    echo "⚠ Warning: C++ build may have issues (optional)"
fi

echo ""
echo "[4/4] Starting RSA Lab Server..."
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    SERVER RUNNING                          ║"
echo "║                                                            ║"
echo "║  🌐 Web Interface:  http://localhost:3000                  ║"
echo "║  🔌 WebSocket:      ws://localhost:3000                    ║"
echo "║  📡 TCP Server:     localhost:5000                         ║"
echo "║                                                            ║"
echo "║  Open browser → http://localhost:3000                      ║"
echo "║  Press Ctrl+C to stop server                               ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

npm start
