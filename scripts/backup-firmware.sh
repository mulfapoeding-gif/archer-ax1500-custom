#!/bin/bash
# Backup stock firmware before rooting

set -e

ROUTER_IP="${1:-192.168.0.1}"
BACKUP_DIR="$HOME/archer-backups/$(date +%Y%m%d_%H%M%S)"

echo "========================================"
echo "  Archer AX1500 Firmware Backup"
echo "========================================"
echo ""

mkdir -p "$BACKUP_DIR"

echo "Router: $ROUTER_IP"
echo "Backup dir: $BACKUP_DIR"
echo ""

# Download firmware info
echo "Downloading firmware info..."
curl -s "http://$ROUTER_IP/" | grep -i firmware > "$BACKUP_DIR/firmware-info.html" 2>/dev/null || true

# Try to download firmware via web interface
echo "Attempting firmware download..."
curl -s -c cookies.txt -b cookies.txt "http://$ROUTER_IP/" > /dev/null

# Backup via telnet if available
if command -v telnet &> /dev/null; then
    echo ""
    echo "Checking telnet access..."
    if timeout 5 telnet "$ROUTER_IP" 2>/dev/null | grep -i "login" > /dev/null; then
        echo "Telnet is open!"
        echo ""
        echo "Manual backup commands (run via telnet):"
        echo "  cat /proc/mtd > /tmp/mtd.txt"
        echo "  cd /tmp"
        echo "  for i in 0 1 2 3; do dd if=/dev/mtdblock\$i of=mtd\$i.bin 2>/dev/null; done"
        echo "  tar -czf backup.tar.gz mtd*.bin"
        echo "  exit"
        echo ""
        echo "Then download: scp root@$ROUTER_IP:/tmp/backup.tar.gz $BACKUP_DIR/"
    else
        echo "Telnet not open (need to root first)"
    fi
fi

echo ""
echo "Backup info saved to: $BACKUP_DIR"
echo ""
echo "After rooting, run these commands on router:"
echo "  cd /tmp"
echo "  for i in 0 1 2 3; do dd if=/dev/mtdblock\$i of=mtd\$i.bin; done"
echo "  tar -czf firmware-backup.tar.gz mtd*.bin"
echo "  exit"
echo ""
echo "Then download from your PC:"
echo "  scp root@$ROUTER_IP:/tmp/firmware-backup.tar.gz $BACKUP_DIR/"
