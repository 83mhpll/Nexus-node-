#!/bin/bash

# Nexus Node Performance Optimization Script
# This script optimizes system performance for Nexus nodes

echo "🔧 Optimizing system performance for Nexus nodes..."

# CPU Performance
echo "⚡ Optimizing CPU performance..."
echo 'performance' > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null || echo "CPU governor not available"

# Memory Performance
echo "🧠 Optimizing memory performance..."
echo 'vm.swappiness=1' >> /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf
echo 'vm.dirty_ratio=15' >> /etc/sysctl.conf
echo 'vm.dirty_background_ratio=5' >> /etc/sysctl.conf

# Network Performance
echo "🌐 Optimizing network performance..."
echo 'net.core.rmem_max=134217728' >> /etc/sysctl.conf
echo 'net.core.wmem_max=134217728' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem=4096 65536 134217728' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem=4096 65536 134217728' >> /etc/sysctl.conf

# Apply settings
sysctl -p

# Process Priority
echo "⚡ Optimizing process priority..."
echo '* soft nofile 65536' >> /etc/security/limits.conf
echo '* hard nofile 65536' >> /etc/security/limits.conf
echo '* soft nproc 32768' >> /etc/security/limits.conf
echo '* hard nproc 32768' >> /etc/security/limits.conf

echo "✅ Performance optimization completed!"
echo "🔄 Please reboot the system to apply all changes"
