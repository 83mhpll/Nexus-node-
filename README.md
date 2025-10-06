# Nexus Node Management System

## 🎯 Overview
This repository contains scripts and configurations for managing multiple Nexus nodes on a VPS with performance optimization.

## 📊 Current Setup
- **6 Nodes Total**: 3 nodes per wallet
- **Wallet 1**:  (Node ID: 36443260)
- **Wallet 2**:  (Node ID: 36443261)

## 🚀 Features
- **Auto-restart functionality**
- **Performance optimization**
- **EXTRA_LARGE difficulty support**
- **System resource monitoring**
- **Multiple wallet support**

## 📁 File Structure
```
nexus-node/
├── improved-start-node.sh          # Start node with optimization
├── improved-check-status.sh         # Check node status
├── auto-restart.sh                 # Auto-restart monitoring
├── manage-auto-restart.sh          # Manage auto-restart service
├── stop-node.sh                    # Stop node
├── logs/                           # Log files directory
└── README.md                       # This file
```

## 🔧 Installation
1. Clone the repository
2. Set up SSH keys for VPS access
3. Run the setup scripts on your VPS
4. Configure your wallet addresses and node IDs

## 📈 Performance Optimizations
- CPU governor settings
- Memory optimization
- Network buffer tuning
- Process priority adjustments
- Enhanced auto-restart system

## 🎯 Usage
- Start nodes: `./improved-start-node.sh`
- Check status: `./improved-check-status.sh`
- Stop nodes: `./stop-node.sh`
- Manage auto-restart: `./manage-auto-restart.sh`

## 📊 Monitoring
- Real-time status monitoring
- System resource tracking
- Task completion logging
- Performance metrics

## 🔄 Auto-Restart
The system includes enhanced auto-restart functionality that:
- Monitors all 6 nodes continuously
- Restarts failed nodes automatically
- Optimizes for EXTRA_LARGE difficulty
- Maintains high performance settings

## 📝 Logs
All node activities are logged in the `logs/` directory with timestamps and detailed information.

## 🎉 Success Metrics
- **6 nodes running simultaneously**
- **EXTRA_LARGE difficulty support**
- **Automatic failover and recovery**
- **Optimized system performance**

---
*Last updated: October 6, 2025*
