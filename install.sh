#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="config.conf"

create_service_file() {
    echo "[Unit]
Description=$SERVICE_DESCRIPTION
After=network.target
StartLimitIntervalSec=0

[Service]
WorkingDirectory=$SCRIPT_DIR
Type=simple
Restart=always
RestartSec=10
User=$USER
ExecStart=/usr/bin/bash $SCRIPT_DIR/start_server.sh

[Install]
WantedBy=multi-user.target" | sudo tee "$SERVICE_FILE" > /dev/null
}

if [[ ! -f $CONFIG_FILE ]]; then
  echo "Configuration file not found"
  exit 1
fi

# Request root access
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

# shellcheck source=./config.conf
source "$SCRIPT_DIR/$CONFIG_FILE"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

echo "Service name: $SERVICE_NAME"
echo "Service description: $SERVICE_DESCRIPTION"

# Check if the service is already installed
if systemctl list-unit-files --type=service | grep -q "^$SERVICE_NAME.service"; then
    echo "Service $SERVICE_NAME is already installed"
    read -p "Do you want to reinstall the service? (y/n): " reinstall_response
    if [[ "$reinstall_response" != "y" ]]; then
        echo "Installation aborted"
        exit 0
    fi

    # Stop and disable the existing service before reinstalling
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    sudo rm "$SERVICE_FILE"
    sudo systemctl daemon-reload
fi

read -p "Enter the port number to use: " port
printf "\nPORT=%s" "$port" >> $CONFIG_FILE
echo "Port number $port has been saved to $CONFIG_FILE"

echo "Creating virtual environment"
python3 -m venv venv
source "$SCRIPT_DIR/venv/bin/activate"

echo "Installing requirements"
pip3 install -r "$SCRIPT_DIR/requirements.txt"

read -p "Do you want to create a '$SERVICE_NAME' systemctl service? It will automatically start the server when the system reboots. (y/n): " response

if [[ "$response" == "y" ]]; then
    create_service_file

    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_NAME"

    echo "Service $SERVICE_NAME has been installed"

    read -p "Do you want to start the service now? (y/n): " response

    if [[ "$response" == "y" ]]; then
      sudo systemctl start "$SERVICE_NAME"
      echo "Service started"
    fi

    echo "Done"
else
    echo "Installation aborted"
fi

echo "You can now start the server with ./start_server.sh"
