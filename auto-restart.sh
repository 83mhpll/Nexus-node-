#!/bin/bash

echo "🔄 Nexus Node Auto Restart Monitor"
echo "Starting at: $(date)"
echo "================================"

NODE_ID="36443260"
CHECK_INTERVAL=30
MAX_RESTART_ATTEMPTS=5
RESTART_COOLDOWN=60

restart_count=0
last_restart_time=0

check_node_running() {
    if [ -f nexus-node.pid ]; then
        local pid=$(cat nexus-node.pid)
        if ps -p $pid > /dev/null 2>&1; then
            return 0
        else
            echo "⚠️  PID file exists but process not found"
            rm -f nexus-node.pid
            return 1
        fi
    else
        return 1
    fi
}

check_rate_limiting() {
    if [ -f nexus-node.log ]; then
        local rate_limit_count=$(tail -20 nexus-node.log | grep -c "Rate limit exceeded\|HTTP error with status 429")
        if [ $rate_limit_count -gt 0 ]; then
            echo "📊 Rate limiting detected - NOT restarting (node is still running)"
            return 0
        fi
    fi
    return 1
}

restart_node() {
    local current_time=$(date +%s)
    
    if [ $((current_time - last_restart_time)) -lt $RESTART_COOLDOWN ]; then
        echo "⏳ Still in cooldown period, skipping restart"
        return 1
    fi
    
    if [ $restart_count -ge $MAX_RESTART_ATTEMPTS ]; then
        echo "❌ Max restart attempts reached ($MAX_RESTART_ATTEMPTS)"
        echo "🛑 Stopping auto-restart monitor"
        exit 1
    fi
    
    echo "🔄 Restarting node (attempt $((restart_count + 1))/$MAX_RESTART_ATTEMPTS)"
    
    pkill -f nexus-cli 2>/dev/null || true
    sleep 2
    
    ./improved-start-node.sh
    
    if [ $? -eq 0 ]; then
        echo "✅ Node restarted successfully"
        restart_count=$((restart_count + 1))
        last_restart_time=$current_time
    else
        echo "❌ Failed to restart node"
    fi
}

echo "🎯 Starting monitoring loop (check every ${CHECK_INTERVAL}s)"
echo "📋 Node ID: $NODE_ID"
echo "🔄 Max restart attempts: $MAX_RESTART_ATTEMPTS"
echo "⏱️  Cooldown period: ${RESTART_COOLDOWN}s"
echo "================================"

while true; do
    current_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$current_time] Checking node status..."
    
    if check_node_running; then
        if check_rate_limiting; then
            echo "📊 Node running but experiencing rate limiting - monitoring..."
        else
            echo "✅ Node running normally"
        fi
    else
        echo "❌ Node is DOWN - attempting restart"
        restart_node
    fi
    
    echo "⏳ Waiting ${CHECK_INTERVAL} seconds..."
    sleep $CHECK_INTERVAL
done