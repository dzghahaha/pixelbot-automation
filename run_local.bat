@echo off
setlocal enabledelayedexpansion

:: ── Detect Git Bash and add to PATH ──
set "GIT_BASH_PATH="
if exist "C:\Program Files\Git\bin\bash.exe" (
    set "GIT_BASH_PATH=C:\Program Files\Git\bin"
) else if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    set "GIT_BASH_PATH=C:\Program Files (x86)\Git\bin"
) else if exist "%USERPROFILE%\AppData\Local\Programs\Git\bin\bash.exe" (
    set "GIT_BASH_PATH=%USERPROFILE%\AppData\Local\Programs\Git\bin"
)

if not "%GIT_BASH_PATH%"=="" (
    set "PATH=%GIT_BASH_PATH%;%PATH%"
)

:: ── Copy api.env if it doesn't exist ──
if not exist "api.env" (
    if exist "api.env.example" (
        echo [INFO] Copying api.env.example to api.env ...
        copy api.env.example api.env > nul
    )
)

:: ── Print usage ──
if "%~1"=="" goto usage
if "%~1"=="help" goto usage
if "%~1"=="install" goto install
if "%~1"=="cli" goto run_cli
if "%~1"=="server" goto run_server
if "%~1"=="bot" goto run_bot

:usage
echo ======================================================================
echo  Gemini Pixel Offer Claim Bot - Local Run Helper
echo ======================================================================
echo Usage:
echo   run_local.bat install              - Install all Python dependencies
echo   run_local.bat cli [args...]        - Run automation script directly (CLI)
echo                                        E.g.: run_local.bat cli --gmail email---pass---2fa --adb-target 127.0.0.1:5554
echo   run_local.bat server               - Run the Worker API server locally
echo   run_local.bat bot                  - Run the Telegram Bot locally
echo ======================================================================
goto :eof

:install
echo [INFO] Installing Python dependencies...
python -m pip install -r requirements.txt
python -m pip install -r infra/requirements-android.txt
echo [INFO] Dependencies installation finished.
goto :eof

:run_cli
echo [INFO] Running automation script directly...
shift
python core/automation.py %*
goto :eof

:run_server
echo [INFO] Starting Local Worker API Server (FastAPI)...
:: Set default local worker API key for local testing
if "%ANDROID_WORKER_API_KEY%"=="" set "ANDROID_WORKER_API_KEY=local_test_key"
if "%API_KEY%"=="" set "API_KEY=local_test_key"
echo [INFO] Worker API Key set to: !ANDROID_WORKER_API_KEY!
python -m uvicorn bot.android_worker.api_server:app --host 127.0.0.1 --port 8800
goto :eof

:run_bot
echo [INFO] Starting Telegram Bot locally...
python main.py
goto :eof
