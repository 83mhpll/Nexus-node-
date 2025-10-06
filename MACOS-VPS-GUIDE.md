# 🍎 Nexus Node MacOS VPS Setup Guide

## 📋 ข้อมูล VPS
- **IP Address**: 38.54.117.251
- **Private IP**: 172.16.1.39
- **Hostname**: 202510654632446465
- **OS**: MacOS 14 (Sonoma)
- **Access**: Web interface at port 8006
- **Node ID**: 36443260
- **Wallet**: 0xadbA787A3Dc59139C02516ECA5C5863E7D05Ac6F

## 🌐 การเข้าถึง VPS

### 1. เข้าผ่าน Web Interface
```
http://38.54.117.251:8006
```

### 2. ใช้ Apple ID เข้าสู่ระบบ
- ใช้ Apple ID ของคุณ
- ต้องเป็น Apple ID ที่ใช้งานได้จริง

## 🚀 การติดตั้ง Nexus Node

### 1. เข้าไปใน VPS ผ่าน Web Interface
1. เปิดเบราว์เซอร์
2. ไปที่ `http://38.54.117.251:8006`
3. เข้าสู่ระบบด้วย Apple ID

### 2. เปิด Terminal
1. เปิด Terminal ใน VPS
2. รันคำสั่งต่อไปนี้:

```bash
# สร้างโฟลเดอร์สำหรับ nexus
sudo mkdir -p /Users/nexus/nexus-node
sudo chown nexus:staff /Users/nexus/nexus-node

# เข้าไปในโฟลเดอร์
cd /Users/nexus/nexus-node

# ดาวน์โหลด nexus-cli
curl -L -o nexus-cli https://github.com/nexus-network/nexus-cli/releases/latest/download/nexus-cli-darwin-x86_64
chmod +x nexus-cli
sudo mv nexus-cli /usr/local/bin/

# สร้างสคริปต์เริ่มโหนด
cat > start-node.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting Nexus Node on MacOS VPS..."
echo "Node ID: 36443260"
echo "Wallet: 0xadbA787A3Dc59139C02516ECA5C5863E7D05Ac6F"
echo "Starting at: $(date)"
echo "================================"

# Change to nexus directory
cd /Users/nexus/nexus-node

# Clean up existing processes
pkill -f nexus-cli 2>/dev/null || true
sleep 2

rm -f nexus-node.pid

# Create logs directory
mkdir -p logs
LOG_FILE="logs/nexus-node-$(date +%Y%m%d-%H%M%S).log"

echo "📝 Log file: $LOG_FILE"

# Start node
echo "🔄 Starting node..."
nohup nexus-cli start --node-id 36443260 --headless > "$LOG_FILE" 2>&1 &
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
    echo "📊 To check status: ./check-status.sh"
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
EOF

# สร้างสคริปต์ตรวจสอบสถานะ
cat > check-status.sh << 'EOF'
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
        ps -p $PID -o pid,ppid,etime,pcpu,pmem,command
        
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
EOF

# สร้างสคริปต์หยุดโหนด
cat > stop-node.sh << 'EOF'
#!/bin/bash

echo "🛑 Stopping Nexus Node..."
echo "================================"

# Stop nexus processes
pkill -f nexus-cli 2>/dev/null || true

# Clean up PID file
rm -f nexus-node.pid

echo "✅ Nexus Node stopped"
echo "================================"
EOF

# สร้างสคริปต์ auto-restart
cat > auto-restart.sh << 'EOF'
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
    
    ./start-node.sh
    
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
EOF

# ตั้งค่าสิทธิ์
chmod +x *.sh

echo "✅ สคริปต์สร้างเสร็จแล้ว!"
```

### 3. เริ่มโหนด
```bash
# เริ่มโหนด
./start-node.sh

# ตรวจสอบสถานะ
./check-status.sh

# เริ่ม auto-restart (ในหน้าต่างใหม่)
./auto-restart.sh &
```

## 📊 การจัดการโหนด

### คำสั่งพื้นฐาน
```bash
# เริ่มโหนด
./start-node.sh

# หยุดโหนด
./stop-node.sh

# ตรวจสอบสถานะ
./check-status.sh

# ดู logs
tail -f nexus-node.log
```

### การตั้งค่า Auto-Start
```bash
# สร้าง launchd service
sudo tee /Library/LaunchDaemons/com.nexus.node.plist > /dev/null << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.nexus.node</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/nexus/nexus-node/start-node.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>UserName</key>
    <string>nexus</string>
    <key>WorkingDirectory</key>
    <string>/Users/nexus/nexus-node</string>
</dict>
</plist>
EOF

# โหลด service
sudo launchctl load /Library/LaunchDaemons/com.nexus.node.plist
```

## 🔍 การตรวจสอบ

### ตรวจสอบสถานะ
```bash
# ตรวจสอบโหนด
./check-status.sh

# ตรวจสอบ launchd service
sudo launchctl list | grep nexus

# ดู logs
tail -f nexus-node.log
```

### ตรวจสอบทรัพยากร
```bash
# ดู CPU และ Memory
top -l 1

# ดู disk usage
df -h

# ดู network
netstat -an
```

## 🛠️ การแก้ไขปัญหา

### โหนดไม่เริ่ม
```bash
# ตรวจสอบ nexus-cli
which nexus-cli
nexus-cli --version

# เริ่มด้วยสคริปต์
./start-node.sh

# ดู error logs
cat nexus-node.log
```

### Auto-Restart ไม่ทำงาน
```bash
# ตรวจสอบ auto-restart
ps aux | grep auto-restart

# เริ่มใหม่
./auto-restart.sh &
```

## 📱 การติดตามระยะไกล

### ใช้ Screen
```bash
# ติดตั้ง screen
brew install screen

# สร้าง session
screen -S nexus-monitor

# ดู logs
tail -f nexus-node.log

# ออกจาก screen (Ctrl+A, D)
# กลับเข้า screen: screen -r nexus-monitor
```

## 🔐 ความปลอดภัย

### ตั้งค่า Firewall
```bash
# เปิด firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# อนุญาต SSH
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/sbin/sshd
```

## 📊 การตรวจสอบรายได้

### ตรวจสอบผ่าน Dashboard
1. เข้าไปที่ Nexus Dashboard
2. เชื่อมต่อ Wallet: `0xadbA787A3Dc59139C02516ECA5C5863E7D05Ac6F`
3. ตรวจสอบ Node ID: 36443260

## 🎯 คำแนะนำเพิ่มเติม

### การอัปเดต
```bash
# อัปเดตระบบ
sudo softwareupdate -i -a

# อัปเดต nexus-cli
cd /Users/nexus/nexus-node
curl -L -o nexus-cli https://github.com/nexus-network/nexus-cli/releases/latest/download/nexus-cli-darwin-x86_64
sudo mv nexus-cli /usr/local/bin/
```

### การสำรองข้อมูล
```bash
# สร้าง backup
cd /Users/nexus/nexus-node
tar -czf backup-$(date +%Y%m%d).tar.gz *.log logs/
```

---

**🎉 ยินดีด้วย! โหนดของคุณพร้อมทำงานบน MacOS VPS แล้ว!**
