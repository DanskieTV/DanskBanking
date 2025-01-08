@echo off
setlocal

:: Colors for output
set "GREEN=[32m"
set "YELLOW=[33m"
set "NC=[0m"

:: Navigate to web directory
cd web

:: Check if node_modules exists
if not exist node_modules\ (
    echo %YELLOW%Installing dependencies...%NC%
    call npm install
)

:: Build the project
echo %YELLOW%Building web interface...%NC%
call npm run build

:: Check if build was successful
if %ERRORLEVEL% EQU 0 (
    echo %GREEN%Build completed successfully!%NC%
) else (
    echo %RED%Build failed!%NC%
    exit /b 1
)

:: Create directories if they don't exist
if not exist build\assets mkdir build\assets

:: Copy additional assets if needed
if exist src\assets xcopy /s /y src\assets\* build\assets\

echo %GREEN%Build process completed!%NC% 