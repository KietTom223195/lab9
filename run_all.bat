@echo off
chcp 65001 > nul
cls
title RSA LAB NASA - ULTIMATE CYBER INTERFACE
color 0A

echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                                                                              ║
echo ║                  🚀 RSA LAB - SPACE MISSION CONSOLE 🚀                       ║
echo ║                                                                              ║
echo ║              Ultimate Cyber Encryption & Network Communication               ║
echo ║                                                                              ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

echo.
echo ┌──────────────────────────────────────────────────────────────────────────────┐
echo │ [PHASE 1/5] Verifying System Requirements                                    │
echo └──────────────────────────────────────────────────────────────────────────────┘
echo.

echo  ⚙ Checking Node.js installation...
node --version >nul 2>&1
if errorlevel 1 (
    echo  ❌ ERROR: Node.js not found!
    echo  📥 Download from: https://nodejs.org
    echo.
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo  ✅ Node.js %NODE_VERSION% detected
echo.

echo  ⚙ Checking npm installation...
npm --version >nul 2>&1
if errorlevel 1 (
    echo  ❌ ERROR: npm not found!
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
echo  ✅ npm %NPM_VERSION% detected
echo.

echo.
echo ┌──────────────────────────────────────────────────────────────────────────────┐
echo │ [PHASE 2/5] Installing Dependencies                                          │
echo └──────────────────────────────────────────────────────────────────────────────┘
echo.

call npm install
if errorlevel 1 (
    echo  ❌ ERROR: npm install failed!
    pause
    exit /b 1
)
echo  ✅ Dependencies installed successfully
echo.

echo.
echo ┌──────────────────────────────────────────────────────────────────────────────┐
echo │ [PHASE 3/5] Building C++ Cryptography Programs                               │
echo └──────────────────────────────────────────────────────────────────────────────┘
echo.

echo  🔨 Compiling: generate_keys.cpp
g++ -o generate_keys generate_keys.cpp -lssl -lcrypto 2>nul
if errorlevel 1 (
    echo  ⚠ Warning: generate_keys build may have issues (g++/OpenSSL not installed)
) else (
    echo  ✅ generate_keys compiled successfully
)
echo.

echo  🔨 Compiling: sign_message.cpp
g++ -o sign_message sign_message.cpp -lssl -lcrypto 2>nul
if errorlevel 1 (
    echo  ⚠ Warning: sign_message build may have issues
) else (
    echo  ✅ sign_message compiled successfully
)
echo.

echo  🔨 Compiling: verify_signature.cpp
g++ -o verify_signature verify_signature.cpp -lssl -lcrypto 2>nul
if errorlevel 1 (
    echo  ⚠ Warning: verify_signature build may have issues
) else (
    echo  ✅ verify_signature compiled successfully
)
echo.

echo.
echo ┌──────────────────────────────────────────────────────────────────────────────┐
echo │ [PHASE 4/5] Finalizing Configuration                                         │
echo └──────────────────────────────────────────────────────────────────────────────┘
echo.

echo  📋 Project Structure:
echo     - index.html ..................... NASA-themed Cyber UI
echo     - server.js ...................... Express + Socket.io Server
echo     - package.json ................... Node dependencies
echo     - *.cpp .......................... C++ RSA Cryptography
echo.

echo  ✅ All systems ready for launch
echo.

echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                                                                              ║
echo ║                   [PHASE 5/5] LAUNCHING SERVER...                           ║
echo ║                                                                              ║
echo ║  🌍 Web Interface ........... http://localhost:3000                          ║
echo ║  🔌 WebSocket .............. ws://localhost:3000                             ║
echo ║  📡 TCP Connection ......... localhost:5000                                  ║
echo ║                                                                              ║
echo ║  ➤ Open your browser → http://localhost:3000                                ║
echo ║                                                                              ║
echo ║  🛑 Press Ctrl+C in terminal to stop server                                  ║
echo ║                                                                              ║
echo ║  💡 Features:                                                                ║
echo ║     • 🔐 RSA-2048 Key Generation                                             ║
echo ║     • ✍ Message Signing & Verification                                      ║
echo ║     • 🌐 Network Communication (LAN/IP)                                      ║
echo ║     • 🎨 Cyberpunk Space UI with Animations                                 ║
echo ║                                                                              ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo.

call npm start
pause
