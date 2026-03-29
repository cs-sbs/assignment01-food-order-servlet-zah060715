#!/bin/bash

BASE_URL="http://localhost:8080"

# Function to check if server is up
check_server() {
  curl -s --connect-timeout 2 "$BASE_URL" > /dev/null
  return $?
}

echo "Checking if server is running at $BASE_URL..."
if ! check_server; then
  echo "Server is not running. Please start it first (e.g., run start.bat)."
  echo "Attempting to wait for 10 seconds in case it's starting..."
  for i in {1..10}; do
    sleep 1
    if check_server; then
      echo "Server is now up!"
      break
    fi
    echo "Still waiting... ($i/10)"
  done
fi

if ! check_server; then
  echo "Error: Server is still not reachable at $BASE_URL. Aborting tests."
  exit 1
fi

score=0
failed=0

run_test () {
  echo "Running $1..."
  bash "$1"
  if [ $? -eq 0 ]; then
    score=$((score+10))
  else
    echo "  -> FAILED"
    failed=$((failed+1))
  fi
}

run_test src/test/test1_menu.sh
run_test src/test/test2_search.sh
run_test src/test/test3_empty_search.sh
run_test src/test/test4_create_order.sh
run_test src/test/test5_missing_param.sh
run_test src/test/test6_invalid_quantity.sh
run_test src/test/test7_order_detail.sh
run_test src/test/test8_order_not_found.sh
run_test src/test/test9_create_then_query.sh
run_test src/test/test10_html_exist.sh

echo "================================="
echo "TOTAL SCORE: $score / 100"
echo "================================="

if [ $failed -ne 0 ]; then
  exit 1
fi
