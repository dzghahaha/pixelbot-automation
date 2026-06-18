#!/bin/bash

# ── Copy api.env if it doesn't exist ──
if [ ! -f "api.env" ]; then
    if [ -f "api.env.example" ]; then
        echo "[INFO] Copying api.env.example to api.env ..."
        cp api.env.example api.env
    fi
fi

show_usage() {
    echo "======================================================================"
    echo " Gemini Pixel Offer Claim Bot - Local Run Helper"
    echo "======================================================================"
    echo "Usage:"
    echo "  ./run_local.sh install              - Install all Python dependencies"
    echo "  ./run_local.sh cli [args...]        - Run automation script directly (CLI)"
    echo "                                        E.g.: ./run_local.sh cli --gmail email---pass---2fa --adb-target 127.0.0.1:5554"
    echo "  ./run_local.sh server               - Run the Worker API server locally"
    echo "  ./run_local.sh bot                  - Run the Telegram Bot locally"
    echo "======================================================================"
}

case "$1" in
    install)
        echo "[INFO] Installing Python dependencies..."
        python3 -m pip install -r requirements.txt
        python3 -m pip install -r infra/requirements-android.txt
        echo "[INFO] Dependencies installation finished."
        ;;
    cli)
        echo "[INFO] Running automation script directly..."
        shift
        python3 core/automation.py "$@"
        ;;
    server)
        echo "[INFO] Starting Local Worker API Server (FastAPI)..."
        # Set default local worker API key for local testing
        export ANDROID_WORKER_API_KEY="${ANDROID_WORKER_API_KEY:-local_test_key}"
        export API_KEY="${API_KEY:-local_test_key}"
        echo "[INFO] Worker API Key set to: $ANDROID_WORKER_API_KEY"
        python3 -m uvicorn bot.android_worker.api_server:app --host 127.0.0.1 --port 8800
        ;;
    bot)
        echo "[INFO] Starting Telegram Bot locally..."
        python3 main.py
        ;;
    *)
        show_usage
        ;;
esac
