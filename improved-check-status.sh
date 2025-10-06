#!/bin/bash

echo "🔍 Nexus Node Status Checker"
echo "Checking at: $(date)"
echo "================================"

if [ -f nexus-node.pid ]; then
    PID=$(cat nexus-node.pid)
    echo "📄 Node PID: $PID"
    
    if ps -p $PID > /dev/null 2>&1; then
        echo "✅ Node is RUNNING"
        echo "📊 Process info:"
        ps -p $PID -o pid,ppid,etime,pcpu,pmem,cmd
        
        echo ""
        echo "📋 Recent activity (last 10 lines):"
        if [ -f nexus-node.log ]; then
            tail -10 nexus-node.log
        else
            echo "No log file found"
        fi
        
        echo ""
        echo "⚠️  Recent errors/warnings:"
        if [ -f nexus-node.log ]; then
            tail -50 nexus-node.log | grep -i "error\|warning\|failed" | tail -5 || echo "No recent errors found"
        fi
        
    else
        echo "❌ Node is NOT running"
        echo "PID file exists but process not found"
        echo "🧹 Cleaning up stale PID file..."
        rm -f nexus-node.pid
    fi
else
    echo "❌ No PID file found"
    echo "Node may not be started"
fi

echo ""
echo "🔍 All nexus processes:"
ps aux | grep nexus | grep -v grep || echo "No nexus processes found"

echo ""
echo "💻 System resources:"
echo "CPU usage: $(top -l 1 | grep "CPU usage" | awk '{print $3}')"
echo "Memory usage: $(top -l 1 | grep "PhysMem" | awk '{print $2}')"

echo "================================"