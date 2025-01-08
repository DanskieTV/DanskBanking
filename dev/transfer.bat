@echo off
setlocal enabledelayedexpansion

:: Configuration
set "SERVER_PATH=C:\path\to\your\server\resources\danskiebankingv2"
set "DEV_PATH=%~dp0.."
set "BACKUP_PATH=%DEV_PATH%\backups"

:: Colors for output
set "GREEN=[32m"
set "YELLOW=[33m"
set "RED=[31m"
set "NC=[0m"

echo %YELLOW%Starting transfer process...%NC%

:: Create backup folder if it doesn't exist
if not exist "%BACKUP_PATH%" mkdir "%BACKUP_PATH%"

:: Create backup with timestamp
set "timestamp=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=!timestamp: =0!"
set "BACKUP_NAME=backup_!timestamp!"

echo %YELLOW%Creating backup...%NC%
xcopy "%SERVER_PATH%\web\build\*" "%BACKUP_PATH%\%BACKUP_NAME%\" /E /I /Y

:: Build the project
echo %YELLOW%Building project...%NC%
cd "%DEV_PATH%"
call build.bat

:: Transfer files
echo %YELLOW%Transferring files to server...%NC%
xcopy "%DEV_PATH%\web\build\*" "%SERVER_PATH%\web\build\" /E /I /Y

echo %GREEN%Transfer complete!%NC%
echo Backup saved to: %BACKUP_PATH%\%BACKUP_NAME%

pause 