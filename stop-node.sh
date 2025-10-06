#!/bin/bash

echo "🛑 Stopping Nexus Node System"
echo "Stopping at: $(date)"
echo "================================"

echo "🔄 Stopping auto restart monitor..."
./manage-auto-restart.sh stop

echo "🛑 Stopping nexus node..."
if [ -f nexus-node.pid ]; then
    pid=$(cat nexus-node.pid)
    echo "Stopping Node PID: $pid"
    
    if kill $pid 2>/dev/null; then
        echo "✅ Node stopped successfully"
    else
        echo "❌ Failed to stop node (process may already be dead)"
    fi
    
    rm -f nexus-node.pid
    echo "PID file removed"
else
    echo "❌ No PID file found"
    echo "Trying to kill any nexus processes..."
    pkill -f nexus-cli
fi

echo "🧹 Cleaning up any remaining nexus processes..."
pkill -f nexus-cli 2>/dev/null || true

echo "================================"
echo "✅ Nexus Node System stopped!"
echo "📋 To start again: ./improved-start-node.sh"
echo "🔄 To start with auto restart: ./manage-auto-restart.sh start"