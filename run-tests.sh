#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"

echo "======================================"
echo " EON Marketing — API Test Suite"
echo "======================================"

# Install deps if needed
if [ ! -d "$BACKEND_DIR/node_modules/jest" ]; then
  echo ""
  echo "Installing test dependencies..."
  cd "$BACKEND_DIR" && npm install
fi

cd "$BACKEND_DIR"

# Parse flags
COVERAGE=false
WATCH=false
FILTER=""

for arg in "$@"; do
  case $arg in
    --coverage|-c) COVERAGE=true ;;
    --watch|-w)    WATCH=true ;;
    --*)           ;;
    *)             FILTER="$arg" ;;
  esac
done

echo ""
if [ -n "$FILTER" ]; then
  echo "Running tests matching: $FILTER"
else
  echo "Running all tests..."
fi
echo ""

if $WATCH; then
  npx jest --watch --forceExit ${FILTER:+--testPathPattern="$FILTER"}
elif $COVERAGE; then
  npx jest --coverage --forceExit --detectOpenHandles ${FILTER:+--testPathPattern="$FILTER"}
else
  npx jest --forceExit --detectOpenHandles ${FILTER:+--testPathPattern="$FILTER"}
fi
