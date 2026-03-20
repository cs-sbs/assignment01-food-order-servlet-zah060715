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

# Extract ID from response like "Order Created: 1003"
ORDER_ID=$(echo "$create_body" | grep -oE '[0-9]+')

if [ -z "$ORDER_ID" ]; then
  echo "FAIL: could not extract order ID from response: $create_body"
  exit 1
fi

tmp_query="$(mktemp)"
status=$(curl -s -o "$tmp_query" -w "%{http_code}" $BASE_URL/order/$ORDER_ID)
body="$(cat "$tmp_query")"
rm -f "$tmp_query"

if [[ "$status" == "200" ]] && [[ "$body" == *"Charlie"* ]]; then
  echo "PASS: create then query works"
  exit 0
else
  echo "FAIL: create then query failed. Status: $status, Body: $body"
  exit 1
fi
