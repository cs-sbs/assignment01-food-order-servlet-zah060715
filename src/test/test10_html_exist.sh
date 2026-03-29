#!/bin/bash

if [ -f src/main/webapp/order.html ]; then
  echo "PASS: html page exists"
  exit 0
else
  echo "FAIL: html page missing"
  exit 1
fi
