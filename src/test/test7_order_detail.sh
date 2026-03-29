#!/bin/bash

set -euo pipefail
BASE_URL="http://localhost:8080"

# create order
tmp_create="$(mktemp)"
curl -s -X POST $BASE_URL/order \
  -d "customer=Bob" \
  -d "food=Burger" \
  -d "quantity=1" > "$tmp_create"
create_body="$(cat "$tmp_create")"
rm -f "$tmp_create"

# Extract ID from response like "Order Created: 1001"
ORDER_ID=$(echo "$create_body" | grep -oE '[0-9]+')

if [ -z "$ORDER_ID" ]; then
  echo "FAIL: could not extract order ID from response: $create_body"
  exit 1
fi

tmp_query="$(mktemp)"
status=$(curl -s -o "$tmp_query" -w "%{http_code}" $BASE_URL/order/$ORDER_ID)
body="$(cat "$tmp_query")"
rm -f "$tmp_query"

if [[ "$status" == "200" ]] && [[ "$body" == *"Order"* ]]; then
  echo "PASS: order detail works"
  exit 0
else
  echo "FAIL: order detail not working. Status: $status, Body: $body"
  exit 1
fi
