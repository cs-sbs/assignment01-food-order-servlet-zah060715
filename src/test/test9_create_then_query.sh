#!/bin/bash

set -euo pipefail
BASE_URL="http://localhost:8080"

# Create order and capture response
tmp_create="$(mktemp)"
curl -s -X POST $BASE_URL/order \
  -d "customer=Charlie" \
  -d "food=Noodles" \
  -d "quantity=3" > "$tmp_create"
create_body="$(cat "$tmp_create")"
rm -f "$tmp_create"

tmp="$(mktemp)"
status=$(curl -s -o "$tmp" -w "%{http_code}" $BASE_URL/order/1003)
body="$(cat "$tmp")"
rm -f "$tmp"

if [[ "$status" == "200" ]] && [[ "$body" == *"Charlie"* ]]; then
  echo "PASS: create then query works"
  exit 0
else
  echo "FAIL: create then query failed. Status: $status, Body: $body"
  exit 1
fi
