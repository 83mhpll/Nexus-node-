#!/bin/bash

# Deploy Nexus Node to VPS
# This script deploys the Nexus node system to a VPS

VPS_IP="38.60.200.117"
VPS_USER="root"
SSH_KEY="~/.ssh/nexus_vps_key"

echo "🚀 Deploying Nexus Node to VPS..."

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ SSH key not found: $SSH_KEY"
    echo "Please generate SSH key first"
    exit 1
fi

# Create deployment archive
echo "📦 Creating deployment archive..."
tar -czf nexus-node-deployment.tar.gz \
    improved-start-node.sh \
    improved-check-status.sh \
    auto-restart.sh \
    manage-auto-restart.sh \
    stop-node.sh \
    setup.sh \
    performance-optimization.sh \
    README.md \
    LICENSE \
    .gitignore

# Upload to VPS
echo "⬆️ Uploading to VPS..."
scp -i "$SSH_KEY" nexus-node-deployment.tar.gz "$VPS_USER@$VPS_IP:/tmp/"

# Deploy on VPS
echo "🔧 Deploying on VPS..."
ssh -i "$SSH_KEY" "$VPS_USER@$VPS_IP" << 'EOF'
cd /tmp
tar -xzf nexus-node-deployment.tar.gz
mkdir -p /home/nexus/nexus-node
mv *.sh /home/nexus/nexus-node/
mv README.md LICENSE .gitignore /home/nexus/nexus-node/
chmod +x /home/nexus/nexus-node/*.sh
chown -R nexus:nexus /home/nexus/nexus-node
rm nexus-node-deployment.tar.gz
echo "✅ Deployment completed on VPS"
EOF

# Clean up
rm nexus-node-deployment.tar.gz

echo "✅ Deployment completed!"
echo "🎯 VPS IP: $VPS_IP"
echo "📊 To check status: ssh -i $SSH_KEY $VPS_USER@$VPS_IP 'cd /home/nexus/nexus-node && ./improved-check-status.sh'"
