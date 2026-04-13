#!/bin/bash
set -euo pipefail

if [ ! -f ".env" ]; then
  echo "No .env file found"
  exit 1
fi

source .env

if [ -z "${1:-}" ]; then
  echo "Usage: $0 \"note text\" [YYYY-MM-DD]"
  exit 1
fi

TEXT="$1"
DATE="${2:-$(date +%F)}"

curl -s -X POST "http://$EC2_IP:8000/notes" \
  -H "Content-Type: application/json" \
  -d "{\"text\": \"$TEXT\", \"date\": \"$DATE\"}" | jq .
