#!/bin/bash

AUTO_RESTART_PID_FILE="auto-restart.pid"

case "$1" in
    start)
        echo "🚀 Starting Auto Restart Monitor..."
        
        if [ -f "$AUTO_RESTART_PID_FILE" ]; then
            pid=$(cat "$AUTO_RESTART_PID_FILE")
            if ps -p $pid > /dev/null 2>&1; then
                echo "⚠️  Auto restart monitor is already running (PID: $pid)"
                exit 1
            else
                echo "🧹 Cleaning up stale PID file"
                rm -f "$AUTO_RESTART_PID_FILE"
            fi
        fi
        
        nohup ./auto-restart.sh > auto-restart.log 2>&1 &
        auto_restart_pid=$!
        
        echo $auto_restart_pid > "$AUTO_RESTART_PID_FILE"
        
        echo "✅ Auto restart monitor started (PID: $auto_restart_pid)"
        echo "📝 Log file: auto-restart.log"
        echo "🛑 To stop: ./manage-auto-restart.sh stop"
        ;;
        
    stop)
        echo "🛑 Stopping Auto Restart Monitor..."
        
        if [ -f "$AUTO_RESTART_PID_FILE" ]; then
            pid=$(cat "$AUTO_RESTART_PID_FILE")
            if ps -p $pid > /dev/null 2>&1; then
                kill $pid
                echo "✅ Auto restart monitor stopped"
            else
                echo "⚠️  Auto restart monitor was not running"
            fi
            rm -f "$AUTO_RESTART_PID_FILE"
        else
            echo "❌ No PID file found"
        fi
        
        pkill -f "auto-restart.sh" 2>/dev/null || true
        ;;
        
    status)
        echo "🔍 Auto Restart Monitor Status"
        echo "================================"
        
        if [ -f "$AUTO_RESTART_PID_FILE" ]; then
            pid=$(cat "$AUTO_RESTART_PID_FILE")
            if ps -p $pid > /dev/null 2>&1; then
                echo "✅ Auto restart monitor is RUNNING (PID: $pid)"
                echo "📊 Process info:"
                ps -p $pid -o pid,ppid,etime,pcpu,pmem,cmd
            else
                echo "❌ Auto restart monitor is NOT running"
                echo "🧹 Cleaning up stale PID file"
                rm -f "$AUTO_RESTART_PID_FILE"
            fi
        else
            echo "❌ Auto restart monitor is NOT running"
        fi
        
        echo ""
        echo "📋 Recent auto restart activity:"
        if [ -f "auto-restart.log" ]; then
            tail -10 auto-restart.log
        else
            echo "No log file found"
        fi
        ;;
        
    restart)
        echo "🔄 Restarting Auto Restart Monitor..."
        ./manage-auto-restart.sh stop
        sleep 2
        ./manage-auto-restart.sh start
        ;;
        
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        echo ""
        echo "Commands:"
        echo "  start   - Start auto restart monitor"
        echo "  stop    - Stop auto restart monitor"
        echo "  status  - Check auto restart monitor status"
        echo "  restart - Restart auto restart monitor"
        exit 1
        ;;
esac