#!/bin/bash

# Nexus Node VPS Setup Script
# This script sets up the Nexus node environment on a VPS

echo "🚀 Setting up Nexus Node on VPS..."

# Create nexus user if it doesn't exist
if ! id "nexus" &>/dev/null; then
    echo "👤 Creating nexus user..."
    useradd -m -s /bin/bash nexus
    usermod -aG sudo nexus
    echo "✅ nexus user created"
else
    echo "✅ nexus user already exists"
fi

# Create nexus-node directory
echo "📁 Creating nexus-node directory..."
mkdir -p /home/nexus/nexus-node
cd /home/nexus/nexus-node

# Download nexus-cli
echo "⬇️ Downloading nexus-cli..."
curl -L https://github.com/nexus-xyz/nexus-cli/releases/latest/download/nexus-cli -o nexus-cli
chmod +x nexus-cli

# Create logs directory
mkdir -p logs

# Set up systemd service
echo "🔧 Setting up systemd service..."
cat > /etc/systemd/system/nexus-node.service << 'EOF'
[Unit]
Description=Nexus Node Service
After=network.target

[Service]
Type=simple
User=nexus
WorkingDirectory=/home/nexus/nexus-node
ExecStart=/home/nexus/nexus-node/nexus-cli start --node-id 36443260 --headless --max-difficulty extra_large
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable nexus-node.service

echo "✅ Nexus Node setup completed!"
echo "🎯 To start the service: systemctl start nexus-node.service"
echo "📊 To check status: systemctl status nexus-node.service"
echo "📋 To view logs: journalctl -u nexus-node.service -f"
