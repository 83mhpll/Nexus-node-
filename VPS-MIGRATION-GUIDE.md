# 🚀 Nexus Node VPS Migration Guide

## 📋 ข้อมูลสำคัญ
- **Node ID**: 36443260
- **Wallet**: 0xadbA787A3Dc59139C02516ECA5C5863E7D05Ac6F
- **VPS User**: nexus
- **Directory**: /home/nexus/nexus-node

## 🔧 ขั้นตอนการย้ายไป VPS

### 1. เตรียม VPS
```bash
# เชื่อมต่อ VPS
ssh root@your-vps-ip

# รันสคริปต์ setup
curl -fsSL https://raw.githubusercontent.com/your-repo/nexus-vps-setup.sh | bash
```

### 2. อัปโหลดไฟล์จากเครื่องเดิม
```bash
# สร้างไฟล์ tar จากเครื่องเดิม
cd "/Users/mk83/Crytro project /nexus-node"
tar -czf nexus-node-backup.tar.gz *.sh *.log logs/

# อัปโหลดไป VPS
scp nexus-node-backup.tar.gz root@your-vps-ip:/tmp/

# บน VPS
cd /home/nexus/nexus-node
tar -xzf /tmp/nexus-node-backup.tar.gz
```

### 3. เริ่มต้นโหนดบน VPS
```bash
# เริ่มโหนด
sudo systemctl start nexus-node

# เริ่ม auto-restart
sudo systemctl start nexus-auto-restart

# ตรวจสอบสถานะ
sudo systemctl status nexus-node
```

## 📊 การจัดการโหนดบน VPS

### คำสั่งพื้นฐาน
```bash
# เริ่มโหนด
sudo systemctl start nexus-node

# หยุดโหนด
sudo systemctl stop nexus-node

# รีสตาร์ทโหนด
sudo systemctl restart nexus-node

# ตรวจสอบสถานะ
sudo systemctl status nexus-node

# ดู logs
journalctl -u nexus-node -f
```

### การตรวจสอบด้วยสคริปต์
```bash
# เข้าไปในโฟลเดอร์ nexus
cd /home/nexus/nexus-node

# ตรวจสอบสถานะ
./check-status.sh

# เริ่มโหนดด้วยสคริปต์
./start-node.sh

# หยุดโหนด
./stop-node.sh
```

## 🔄 Auto-Restart บน VPS

### เริ่ม Auto-Restart
```bash
sudo systemctl start nexus-auto-restart
sudo systemctl enable nexus-auto-restart
```

### ตรวจสอบ Auto-Restart
```bash
sudo systemctl status nexus-auto-restart
journalctl -u nexus-auto-restart -f
```

## 📈 การตรวจสอบประสิทธิภาพ

### ตรวจสอบทรัพยากรระบบ
```bash
# ดู CPU และ Memory
htop

# ดู disk usage
df -h

# ดู network
netstat -tulpn
```

### ตรวจสอบโหนด
```bash
# เข้าไปในโฟลเดอร์
cd /home/nexus/nexus-node

# ตรวจสอบสถานะ
./check-status.sh

# ดู logs ล่าสุด
tail -f nexus-node.log
```

## 🛠️ การแก้ไขปัญหา

### โหนดไม่เริ่ม
```bash
# ตรวจสอบ logs
journalctl -u nexus-node -n 50

# ตรวจสอบ nexus-cli
which nexus-cli
nexus-cli --version

# เริ่มด้วยสคริปต์
cd /home/nexus/nexus-node
./start-node.sh
```

### Auto-Restart ไม่ทำงาน
```bash
# ตรวจสอบ auto-restart
sudo systemctl status nexus-auto-restart

# เริ่มใหม่
sudo systemctl restart nexus-auto-restart
```

### ตรวจสอบสิทธิ์
```bash
# ตรวจสอบสิทธิ์ไฟล์
ls -la /home/nexus/nexus-node/

# แก้ไขสิทธิ์
sudo chown -R nexus:nexus /home/nexus/nexus-node/
sudo chmod +x /home/nexus/nexus-node/*.sh
```

## 📱 การติดตามระยะไกล

### ตั้งค่า SSH Key
```bash
# สร้าง SSH key บนเครื่องเดิม
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# คัดลอก key ไป VPS
ssh-copy-id nexus@your-vps-ip
```

### ตั้งค่า Screen/Tmux
```bash
# ติดตั้ง screen
sudo apt install screen

# สร้าง session
screen -S nexus-monitor

# ดู logs
tail -f /home/nexus/nexus-node/nexus-node.log

# ออกจาก screen (Ctrl+A, D)
# กลับเข้า screen: screen -r nexus-monitor
```

## 🔐 ความปลอดภัย

### ตั้งค่า Firewall
```bash
# เปิด firewall
sudo ufw enable

# อนุญาต SSH
sudo ufw allow ssh

# อนุญาต HTTP/HTTPS (ถ้าต้องการ)
sudo ufw allow 80
sudo ufw allow 443
```

### ตั้งค่า Fail2Ban
```bash
# ติดตั้ง fail2ban
sudo apt install fail2ban

# เริ่มบริการ
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

## 📊 การตรวจสอบรายได้

### ตรวจสอบผ่าน API
```bash
# ใช้ API Key ที่สร้างไว้
curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://api.nexus.network/earnings
```

### ตรวจสอบผ่าน Dashboard
1. เข้าไปที่ Nexus Dashboard
2. เชื่อมต่อ Wallet: `0xadbA787A3Dc59139C02516ECA5C5863E7D05Ac6F`
3. ตรวจสอบ Node ID: 36443260

## 🎯 คำแนะนำเพิ่มเติม

### การอัปเดต
```bash
# อัปเดตระบบ
sudo apt update && sudo apt upgrade -y

# อัปเดต nexus-cli
cd /home/nexus/nexus-node
wget -O nexus-cli https://github.com/nexus-network/nexus-cli/releases/latest/download/nexus-cli-linux-x86_64
sudo mv nexus-cli /usr/local/bin/
```

### การสำรองข้อมูล
```bash
# สร้าง backup
cd /home/nexus/nexus-node
tar -czf backup-$(date +%Y%m%d).tar.gz *.log logs/

# อัปโหลดไป cloud storage
# (ใช้ rclone, aws cli, หรือ scp)
```

## 🆘 การติดต่อเมื่อมีปัญหา

1. **ตรวจสอบ logs**: `journalctl -u nexus-node -f`
2. **ตรวจสอบสถานะ**: `sudo systemctl status nexus-node`
3. **รีสตาร์ทบริการ**: `sudo systemctl restart nexus-node`
4. **ตรวจสอบทรัพยากร**: `htop`, `df -h`

---

**🎉 ยินดีด้วย! โหนดของคุณพร้อมทำงานบน VPS แล้ว!**
