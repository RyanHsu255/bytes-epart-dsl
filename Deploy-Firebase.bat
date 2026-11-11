@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Deploy-Firebase.ps1" %*
set "RESULT=%ERRORLEVEL%"
echo(
if "%RESULT%"=="0" (
    echo Deployment complete. https://tools.bytes.tw/
) else (
    echo Deployment failed. Exit code: %RESULT%
)
pause
exit /b %RESULT%
