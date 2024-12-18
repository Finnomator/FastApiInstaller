#!/bin/bash
cd "$(dirname "$0")" || exit
source config.conf
git pull
sudo systemctl restart "$SERVICE_NAME"
