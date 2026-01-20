#!/bin/bash

# iOS App Debug Monitor Script
# Monitors app launch, collects logs, and detects crashes

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/AIReference/debug_logs"
REPORT_DIR="$PROJECT_ROOT/AIReference/debug_reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SESSION_LOG="$LOG_DIR/session_$TIMESTAMP.log"
DEVICE_ID="${DEVICE_ID:-}"  # Can be set as environment variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create directories
mkdir -p "$LOG_DIR"
mkdir -p "$REPORT_DIR"

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

log_warn() {
    log "WARN" "${YELLOW}$@${NC}"
}

log_error() {
    log "ERROR" "${RED}$@${NC}"
}

log_debug() {
    log "DEBUG" "${BLUE}$@${NC}"
}

# Check if device is connected
check_device() {
    log_info "Checking for connected iOS devices..."
    
    local devices=$(flutter devices 2>/dev/null | grep -A 5 "iOS" | grep -E "^[A-Za-z0-9]{8}" | head -1)
    
    if [ -z "$devices" ]; then
        log_error "No iOS device found. Please connect an iOS device."
        exit 1
    fi
    
    # Extract device ID
    DEVICE_ID=$(echo "$devices" | awk '{print $1}')
    DEVICE_NAME=$(echo "$devices" | awk '{for(i=2;i<=NF;i++) printf $i" "; print ""}' | sed 's/[[:space:]]*$//')
    
    log_info "Found device: $DEVICE_NAME (ID: $DEVICE_ID)"
    
    # Save device info
    echo "$DEVICE_ID" > "$LOG_DIR/device_id.txt"
    echo "$DEVICE_NAME" > "$LOG_DIR/device_name.txt"
}

# Get iOS system log path
get_ios_log_path() {
    local log_path="$LOG_DIR/ios_log_$TIMESTAMP.log"
    echo "$log_path"
}

# Get Flutter log path
get_flutter_log_path() {
    local log_path="$LOG_DIR/flutter_log_$TIMESTAMP.log"
    echo "$log_path"
}

# Start log collectors
start_log_collectors() {
    log_info "Starting log collectors..."
    
    # Start iOS system log collector
    log_debug "Starting iOS system log collector..."
    local ios_log_path=$(get_ios_log_path)
    touch "$ios_log_path"
    
    # Use xcrun to stream iOS logs
    xcrun devicectl log stream \
        --device "$DEVICE_ID" \
        --predicate 'process == "Runner" OR (eventMessage CONTAINS "resonate")' \
        --level debug \
        --style compact \
        > "$ios_log_path" 2>&1 &
    
    IOS_LOG_PID=$!
    log_info "iOS log collector started (PID: $IOS_LOG_PID)"
    
    # Start Flutter log collector
    log_debug "Starting Flutter log collector..."
    local flutter_log_path=$(get_flutter_log_path)
    touch "$flutter_log_path"
    
    # Flutter logs will be captured when app is launched
    flutter logs -d "$DEVICE_ID" > "$flutter_log_path" 2>&1 &
    
    FLUTTER_LOG_PID=$!
    log_info "Flutter log collector started (PID: $FLUTTER_LOG_PID)"
    
    # Wait a moment for log collectors to initialize
    sleep 2
}

# Stop log collectors
stop_log_collectors() {
    log_info "Stopping log collectors..."
    
    if [ ! -z "$IOS_LOG_PID" ]; then
        kill $IOS_LOG_PID 2>/dev/null || true
        log_debug "iOS log collector stopped"
    fi
    
    if [ ! -z "$FLUTTER_LOG_PID" ]; then
        kill $FLUTTER_LOG_PID 2>/dev/null || true
        log_debug "Flutter log collector stopped"
    fi
}

# Launch app
launch_app() {
    log_info "Launching app..."
    
    # Build and launch app
    cd "$PROJECT_ROOT"
    
    # Run app in background and capture output
    flutter run -d "$DEVICE_ID" --verbose > "$LOG_DIR/build_$TIMESTAMP.log" 2>&1 &
    FLUTTER_RUN_PID=$!
    
    log_info "App launch started (PID: $FLUTTER_RUN_PID)"
    log_debug "Build log: $LOG_DIR/build_$TIMESTAMP.log"
}

# Monitor app health
monitor_app() {
    log_info "Monitoring app health..."
    
    local app_running=true
    local monitoring_duration=60  # Monitor for 60 seconds
    local elapsed=0
    
    while [ $elapsed -lt $monitoring_duration ]; do
        # Check if Flutter run process is still running
        if ! ps -p $FLUTTER_RUN_PID > /dev/null 2>&1; then
            log_error "Flutter run process died!"
            app_running=false
            break
        fi
        
        # Check for crash indicators in logs
        local ios_log_path=$(get_ios_log_path)
        if [ -f "$ios_log_path" ] && grep -q "Exception\|Error\|Crash\|Fatal" "$ios_log_path" 2>/dev/null; then
            log_warn "Detected potential crash in iOS logs"
            app_running=false
            break
        fi
        
        # Check if app process is running
        if ! xcrun devicectl list processes --device "$DEVICE_ID" 2>/dev/null | grep -q "Runner"; then
            log_warn "App process not found on device"
            app_running=false
            break
        fi
        
        sleep 2
        elapsed=$((elapsed + 2))
        log_debug "Monitoring... ($elapsed/$monitoring_duration seconds)"
    done
    
    if $app_running; then
        log_info "✅ App appears to be running successfully"
    else
        log_error "❌ App crashed or failed to launch"
        analyze_crash
    fi
}

# Analyze crash
analyze_crash() {
    log_info "Analyzing crash..."
    
    local report_path="$REPORT_DIR/crash_report_$TIMESTAMP.md"
    
    cat > "$report_path" << EOF
# iOS App Crash Report

**Generated:** $(date)

## Device Information

- **Device ID:** $DEVICE_ID
- **Device Name:** $(cat "$LOG_DIR/device_name.txt" 2>/dev/null || echo "Unknown")

## Log Files

- **Session Log:** \`$SESSION_LOG\`
- **Build Log:** \`$LOG_DIR/build_$TIMESTAMP.log\`
- **iOS Log:** \`$(get_ios_log_path)\`
- **Flutter Log:** \`$(get_flutter_log_path)\`

## iOS System Log (Last 50 lines)

\`\`\`
$(tail -50 "$(get_ios_log_path)" 2>/dev/null || echo "No iOS log available")
\`\`\`

## Flutter Log (Last 50 lines)

\`\`\`
$(tail -50 "$(get_flutter_log_path)" 2>/dev/null || echo "No Flutter log available")
\`\`\`

## Build Log (Last 100 lines)

\`\`\`
$(tail -100 "$LOG_DIR/build_$TIMESTAMP.log" 2>/dev/null || echo "No build log available")
\`\`\`

## Analysis

EOF

    # Look for common error patterns
    local ios_log=$(get_ios_log_path)
    
    if grep -q "Could not build module" "$ios_log" 2>/dev/null; then
        echo "- **Xcode Module Error:** Detected Xcode module build failure" >> "$report_path"
        echo "  - Recommendation: Clean DerivedData: \`rm -rf ~/Library/Developer/Xcode/DerivedData\`" >> "$report_path"
        echo "  - Recommendation: Clean Flutter: \`flutter clean && flutter pub get\`" >> "$report_path"
    fi
    
    if grep -q "MissingPluginException" "$ios_log" 2>/dev/null; then
        echo "- **Plugin Error:** Missing or misconfigured Flutter plugin" >> "$report_path"
        echo "  - Recommendation: Check pubspec.yaml dependencies" >> "$report_path"
        echo "  - Recommendation: Run \`cd ios && pod install\`" >> "$report_path"
    fi
    
    if grep -q "Symbol not found" "$ios_log" 2>/dev/null; then
        echo "- **Linker Error:** Missing symbol" >> "$report_path"
        echo "  - Recommendation: Clean rebuild: \`flutter clean && flutter build ios\`" >> "$report_path"
    fi
    
    log_info "Crash report generated: $report_path"
    cat "$report_path"
}

# Main execution
main() {
    log_info "========================================="
    log_info "iOS App Debug Monitor Starting"
    log_info "========================================="
    
    # Check device
    check_device
    
    # Start log collectors
    start_log_collectors
    
    # Launch app
    launch_app
    
    # Monitor app
    monitor_app
    
    # Stop log collectors
    stop_log_collectors
    
    log_info "========================================="
    log_info "Debug Monitor Session Complete"
    log_info "Session log: $SESSION_LOG"
    log_info "========================================="
}

# Handle interrupt
trap 'log_warn "Interrupted..."; stop_log_collectors; exit 1' INT TERM

# Run main function
main