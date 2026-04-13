#!/bin/bash
set -euo pipefail

if [ ! -f ".env" ]; then
  echo "No .env file found"
  exit 1
fi

source .env

curl -s -X GET "http://$EC2_IP:8000/notes"
