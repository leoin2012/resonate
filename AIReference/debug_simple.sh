#!/bin/bash

# Simple iOS App Debug Script
# Simplified version for quick testing

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/AIReference/debug_logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SESSION_LOG="$LOG_DIR/session_$TIMESTAMP.log"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Create directories
mkdir -p "$LOG_DIR"

# Log function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] [$level] $message" | tee -a "$SESSION_LOG"
}

log_info() {
    log "INFO" "${GREEN}$@${NC}"
}

log_error() {
    log "ERROR" "${RED}$@${NC}"
}

# Main execution
log_info "========================================="
log_info "iOS App Debug - Simple Mode"
log_info "========================================="

# Get device
log_info "Getting available devices..."
DEVICES=$(flutter devices --machine 2>/dev/null | grep -A 5 '"type": "ios"' | head -1 | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

if [ -z "$DEVICES" ]; then
    log_error "No iOS device found"
    exit 1
fi

# Use first device
DEVICE_ID=$(echo "$DEVICES" | head -1)
log_info "Using device: $DEVICE_ID"

# Start Flutter run with logging
log_info "Starting app with verbose logging..."
FLUTTER_LOG="$LOG_DIR/flutter_run_$TIMESTAMP.log"

flutter run -d "$DEVICE_ID" --verbose 2>&1 | tee "$FLUTTER_LOG" &
FLUTTER_PID=$!

log_info "Flutter run started (PID: $FLUTTER_PID)"
log_info "Monitoring for 60 seconds..."

# Monitor for 60 seconds
for i in {1..30}; do
    sleep 2
    if ! ps -p $FLUTTER_PID > /dev/null 2>&1; then
        log_error "Flutter run process died"
        break
    fi
    echo -n "."
done
echo ""

# Stop Flutter
if ps -p $FLUTTER_PID > /dev/null 2>&1; then
    log_info "Stopping Flutter run..."
    kill $FLUTTER_PID 2>/dev/null || true
fi

# Analyze logs
log_info "Analyzing logs..."

ERROR_COUNT=$(grep -i "error\|exception\|failed" "$FLUTTER_LOG" | wc -l)
FATAL_COUNT=$(grep -i "fatal\|crash" "$FLUTTER_LOG" | wc -l)

log_info "Errors found: $ERROR_COUNT"
log_info "Fatal errors found: $FATAL_COUNT"

if [ $FATAL_COUNT -gt 0 ]; then
    log_error "❌ Detected fatal errors or crashes"
    log_info "Last 50 lines of log:"
    tail -50 "$FLUTTER_LOG"
elif [ $ERROR_COUNT -gt 0 ]; then
    log_info "⚠️  Found $ERROR_COUNT errors"
    log_info "Recent errors:"
    grep -i "error\|exception\|failed" "$FLUTTER_LOG" | tail -10
else
    log_info "✅ No critical errors detected"
fi

log_info "========================================="
log_info "Log file: $FLUTTER_LOG"
log_info "========================================="
