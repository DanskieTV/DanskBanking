@echo off
setlocal

:: Colors for output
set "GREEN=[32m"
set "YELLOW=[33m"
set "RED=[31m"
set "NC=[0m"

:: Check for Node.js
echo %YELLOW%Checking for Node.js...%NC%
node --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo %RED%Node.js is not installed! Please install from https://nodejs.org/%NC%
    pause
    exit /b 1
)

:: Create development folders
echo %YELLOW%Creating development environment...%NC%
mkdir dev 2>nul
mkdir backups 2>nul
mkdir web\src\components 2>nul
mkdir web\src\assets 2>nul
mkdir web\src\store 2>nul
mkdir web\src\utils 2>nul

:: Create config file
echo %YELLOW%Creating config file...%NC%
(
echo {
echo   "serverPath": "C:/path/to/your/server/resources/danskiebankingv2",
echo   "devPath": "%~dp0..",
echo   "backupEnabled": true,
echo   "autoRestart": false
echo }
) > dev\config.json

:: Install dependencies
echo %YELLOW%Installing dependencies...%NC%
cd web
call npm install

echo %GREEN%Development environment setup complete!%NC%
echo.
echo %YELLOW%Please edit dev\config.json with your server path%NC%
echo.
pause 