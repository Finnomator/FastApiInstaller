#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="config.conf"

if [[ ! -f $CONFIG_FILE ]]; then
  echo "Configuration file not found."
  exit 1
fi

echo "Activating environment"
# shellcheck source=./config.conf
source "$SCRIPT_DIR/$CONFIG_FILE"
source "$SCRIPT_DIR/venv/bin/activate"
echo "Installing requirements"
pip3 install -r requirements.txt

echo "Starting service on port $PORT"
python3 -m uvicorn main:app --port "$PORT"
