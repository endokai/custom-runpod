#!/usr/bin/env bash

set -e

ORIGINAL_START="/start.sh"
CUSTOM_SCRIPT="/workspace/my-run.sh"

MODE="${RUNPOD_SCRIPT_MODE:-sequential}"
ENV_B64="${RUNPOD_BASH_B64:-}"

pids=()

echo "======================================"
echo "RunPod Custom Startup System v2"
echo "Mode: $MODE"
echo "Custom script: $CUSTOM_SCRIPT"
echo "Env B64 present: ${ENV_B64:+yes}"
echo "======================================"

terminate() {
    echo "Termination signal received"

    for pid in "${pids[@]}"; do
        kill -TERM "$pid" 2>/dev/null || true
    done

    wait
    exit 0
}

trap terminate SIGINT SIGTERM

run_env_command() {

    if [ -z "$ENV_B64" ]; then
        return
    fi

    if ! decoded=$(echo "$ENV_B64" | base64 -d 2>/dev/null); then
        echo "Invalid base64 in RUNPOD_BASH_B64"
        return
    fi

    echo "Executing ENV base64 command"

    if [ "$MODE" = "parallel" ]; then
        bash -c "$decoded" &
        pids+=($!)
    else
        bash -c "$decoded"
    fi
}

run_workspace_script() {

    if [ ! -f "$CUSTOM_SCRIPT" ]; then
        return
    fi

    echo "Executing /workspace/my-run.sh"

    chmod +x "$CUSTOM_SCRIPT"

    if [ "$MODE" = "parallel" ]; then
        "$CUSTOM_SCRIPT" &
        pids+=($!)
    else
        "$CUSTOM_SCRIPT"
    fi
}

run_original() {

    echo "Starting original start.sh"

    "$ORIGINAL_START" &
    pids+=($!)
}

if [ "$MODE" = "parallel" ]; then

    run_env_command
    run_workspace_script
    run_original

else

    run_env_command
    run_workspace_script
    run_original

fi

wait
