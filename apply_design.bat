@echo off
cd /d "%~dp0"
echo [+] Applying CYBERPUNK design...
del index.html 2>nul
ren index_new.html index.html
echo [OK] UI updated successfully!
echo.
echo Run: npm start
pause
