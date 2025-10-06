#!/bin/bash

echo "🚀 Starting Improved Nexus Node..."
echo "Node ID: 36443260"
echo "Wallet: 0xadbA787A3Dc59139C02516ECA5C5863E7D05Ac6F"
echo "Starting at: $(date)"
echo "================================"

echo "🧹 Cleaning up existing processes..."
pkill -f nexus-cli 2>/dev/null || true
sleep 2

rm -f nexus-node.pid

if ! command -v nexus-cli &> /dev/null; then
    echo "❌ nexus-cli not found in PATH"
    echo "Trying alternative path..."
    if [ -f "/Users/mk83/.nexus/bin/nexus-cli" ]; then
        NEXUS_CMD="/Users/mk83/.nexus/bin/nexus-cli"
        echo "✅ Found nexus-cli at: $NEXUS_CMD"
    else
        echo "❌ nexus-cli not found. Please check installation."
        exit 1
    fi
else
    NEXUS_CMD="nexus-cli"
    echo "✅ Found nexus-cli in PATH"
fi

mkdir -p logs
LOG_FILE="logs/nexus-node-$(date +%Y%m%d-%H%M%S).log"

echo "📝 Log file: $LOG_FILE"

echo "🔄 Starting node with improved configuration..."

nohup $NEXUS_CMD start --node-id 36443260 --headless > "$LOG_FILE" 2>&1 &
NEXUS_PID=$!

sleep 3

if ps -p $NEXUS_PID > /dev/null 2>&1; then
    echo "✅ Nexus Node started successfully!"
    echo "Process ID: $NEXUS_PID"
    echo "Log file: $LOG_FILE"
    
    echo $NEXUS_PID > nexus-node.pid
    echo "📄 PID saved to nexus-node.pid"
    
    ln -sf "$LOG_FILE" nexus-node.log
    
    echo "================================"
    echo "🎯 Node is running in background!"
    echo "📊 To check status: ./improved-check-status.sh"
    echo "🛑 To stop node: ./stop-node.sh"
    echo "📋 To view logs: tail -f $LOG_FILE"
    echo "================================"
    
    echo "📋 Initial log output:"
    tail -10 "$LOG_FILE" 2>/dev/null || echo "Log file not ready yet"
    
else
    echo "❌ Failed to start Nexus Node"
    echo "📋 Error log:"
    cat "$LOG_FILE" 2>/dev/null || echo "No log file created"
    exit 1
fi