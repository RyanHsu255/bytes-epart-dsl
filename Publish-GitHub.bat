@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Publish-GitHub.ps1" %*
set "RESULT=%ERRORLEVEL%"
echo(
if "%RESULT%"=="0" (
    echo GitHub is up to date. https://github.com/RyanHsu255/bytes-epart-dsl
) else (
    echo GitHub update failed. Exit code: %RESULT%
)
pause
exit /b %RESULT%
