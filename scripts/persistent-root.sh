#!/bin/bash
# Setup persistent root access on Archer AX1500

echo "========================================"
echo "  Persistent Root Access Setup"
echo "========================================"
echo ""
echo "This script runs on the ROUTER (via telnet)"
echo ""

# Create startup script
cat > /tmp/startup.sh << 'EOF'
#!/bin/sh
# Archer AX1500 Persistent Access Script

LOGFILE="/tmp/root-access.log"

log() {
    echo "$(date): $1" >> "$LOGFILE"
}

log "Starting startup script..."

# Start telnet on boot (insecure, use with caution)
# Uncomment only if you understand the risks
# /usr/sbin/telnetd -l /bin/sh &
# log "Telnet started"

# Alternative: Start dropbear SSH if available
if [ -f /usr/sbin/dropbear ]; then
    # Generate host keys if not exist
    if [ ! -f /etc/dropbear/dropbear_rsa_host_key ]; then
        mkdir -p /etc/dropbear
        dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key 2>/dev/null
    fi
    if [ ! -f /etc/dropbear/dropbear_ecdsa_host_key ]; then
        dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key 2>/dev/null
    fi
    
    # Start dropbear
    dropbear -p 22 &
    log "Dropbear SSH started"
fi

# Set root password
echo "root:your_secure_password" | chpasswd 2>/dev/null || true
log "Root password set"

# Keep script running
log "Startup complete"

EOF

chmod +x /tmp/startup.sh

echo "Created /tmp/startup.sh"
echo ""
echo "To make it run on boot, add to /etc/rc.local or crontab:"
echo ""
echo "@reboot /tmp/startup.sh"
echo ""
echo "⚠️ WARNING: This is temporary (RAM only)"
echo "For true persistence, you need to modify flash"
echo ""
echo "Current session will be lost on reboot!"
echo "Kill telnet when done: killall -9 telnetd"
