@echo off
cd /d "%~dp0"
echo [*] Dang cap nhat giao dien...
del index.html
ren index_new.html index.html
echo [+] Hoan tat! Giao dien moi da duoc cap nhat.
echo.
echo Chay: npm start
pause
