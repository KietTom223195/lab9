@echo off
cd /d "%~dp0"
echo [*] Cai dat dependencies...
call npm install
echo.
echo [+] Khoi dong server RSA Lab...
echo [*] Mo http://localhost:3000 trong trinh duyet
echo.
call npm start
pause
