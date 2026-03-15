# TP-Link Archer AX1500 WiFi 6 v1.0 - Custom Firmware

Complete custom firmware development environment for TP-Link Archer AX1500 (AX10) v1.0 router.

## ⚠️ Disclaimer

**WARNING:** This is for educational and research purposes only.

- Rooting your router **voids warranty**
- May **brick** your device permanently
- TP-Link will **not provide support**
- Use at your **own risk**
- **Do not expose** rooted router to internet

## Quick Start

### 1. Check Firmware Version

```bash
# Login to router web interface (192.168.0.1)
# Check: Advanced → System Tools → Firmware Version

# Exploitable versions:
# - v1.3.1 Build 20220401 or earlier (CVE-2022-30075)
# - v1.1.x Build 2021xxxx or earlier (unpatched)
```

### 2. Root Your Router

```bash
# Clone exploit repo
git clone https://github.com/aaronsvk/CVE-2022-30075.git
cd CVE-2022-30075

# Install dependencies
pip install requests pycryptodome

# Download config
python tplink.py -b -t 192.168.0.1 -p admin_password

# Modify config (see exploits/README.md)
# Upload config
python tplink.py -r <config_dir> -t 192.168.0.1 -p admin_password

# Press WPS button, then:
telnet 192.168.0.1
```

### 3. Build Custom Packages

```bash
# Using Docker build environment
cd docker
docker build -t ax1500-build .
docker run -it -v $(pwd)/../firmware:/router ax1500-build

# Inside container
cd /router
make menuconfig
make SHELL=/bin/bash V=s
```

## Repository Structure

```
archer-ax1500-custom/
├── README.md                 # This file
├── exploits/                 # Exploit scripts & configs
│   ├── cve-2022-30075/       # WPS button exploit
│   ├── cve-2025-9961/        # CWMP exploit (new)
│   └── config-templates/     # Modified XML configs
├── scripts/                  # Utility scripts
│   ├── root-router.sh        # One-click root script
│   ├── backup-firmware.sh    # Backup stock firmware
│   ├── install-packages.sh   # Package installer
│   └── persistent-root.sh    # Setup persistent access
├── docker/                   # Build environment
│   ├── Dockerfile            # Ubuntu 12.04 build env
│   └── docker-compose.yml    # Docker Compose config
├── firmware/                 # Firmware sources
│   ├── Iplatform/            # OpenWRT SDK
│   ├── dl/                   # Downloaded sources
│   └── patches/              # Custom patches
├── configs/                  # Configuration files
│   ├── telnetd.conf          # Telnet daemon config
│   ├── firewall.rules        # Custom iptables rules
│   └── startup.sh            # Auto-start script
├── docs/                     # Documentation
│   ├── EXPLOIT_GUIDE.md      # Detailed exploit guide
│   ├── BUILD_GUIDE.md        # Build custom packages
│   ├── HARDWARE_MODS.md      # Hardware modifications
│   └── TROUBLESHOOTING.md    # Common issues
├── patches/                  # Source patches
│   ├── router.patch          # Main source patch
│   └── luci-patch/           # LuCI web interface
└── tools/                    # Utilities
    ├── firmware-extractor.sh # Extract firmware
    ├── xml-modifier.py       # Modify config XML
    └── serial-console.sh     # UART helper
```

## Hardware Specifications

| Component | Specification |
|-----------|--------------|
| **Model** | TP-Link Archer AX1500 v1.0 / AX10 v1.0 |
| **FCC ID** | TE7AX1500 |
| **SoC** | Broadcom BCM6750 (ARM Cortex-A7) |
| **CPU** | 1.5 GHz Dual-Core |
| **RAM** | 256MB DDR3 |
| **Flash** | 16MB SPI NOR |
| **WiFi** | AX1500 (2.4GHz: 300Mbps, 5GHz: 1201Mbps) |
| **Ports** | 1x WAN, 4x LAN (Gigabit) |
| **USB** | 1x USB 2.0 |
| **UART** | Yes (3.3V, 115200 8N1) |

## Known Vulnerabilities

| CVE | Severity | Firmware | Status |
|-----|----------|----------|--------|
| **CVE-2022-30075** | High | < July 2022 | Patched |
| **CVE-2022-40486** | High | < Nov 2022 | Patched |
| **CVE-2025-9961** | Critical | < June 2025 | Patched |

## Exploits Available

### CVE-2022-30075 (WPS Button)

**Working firmware versions:**
- v1.3.1 Build 20220401 Rel. 57450(5553) ✅
- v1.2.x Build 2021xxxx ✅
- v1.1.x Build 2020xxxx ✅

**Method:** Modified XML config → WPS button → telnet

### CVE-2025-9961 (CWMP Stack Overflow)

**Working firmware versions:**
- v1.5.x Build 20250xxx (unpatched) ⚠️

**Method:** CWMP binary exploitation → root RCE

## Installation Guide

### Step 1: Downgrade Firmware (if needed)

```bash
# Download old firmware from web archive
# https://web.archive.org/web/20220101000000*/https://www.tp-link.com/*/support/download/archer-ax1500/

# Upload via web interface
# System Tools → Firmware Upgrade → Choose File → Upgrade
```

### Step 2: Run Exploit

```bash
cd exploits/cve-2022-30075
./run-exploit.sh 192.168.0.1 admin_password
```

### Step 3: Verify Root Access

```bash
telnet 192.168.0.1
# Login: root (no password on some versions)
whoami  # Should return: root
```

### Step 4: Install Persistent Access

```bash
# On router
cd /tmp
wget http://your-pc/startup.sh
chmod +x startup.sh
./startup.sh
```

## Building Custom Packages

### Using Docker (Recommended)

```bash
# Build Docker image
cd docker
docker build -t ax1500-build .

# Run container
docker run -it -v $(pwd)/../firmware:/router ax1500-build

# Inside container
cd /router
make menuconfig
make package/youtubeUnblock/compile V=s
```

### Manual Build (Ubuntu 12.04)

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y build-essential libncurses5-dev gawk git subversion mercurial

# Clone sources
git clone <GPL-source-url>
cd Iplatform/build

# Build
make SHELL=/bin/bash V=s
```

## Installing Packages

```bash
# On router
cd /tmp

# Download package
wget http://your-pc/package.ipk

# Create lock directory
mkdir -p /tmp/var/lock

# Install
opkg install package.ipk -o /tmp --force-space --nodeps

# Run
./package_binary &
```

## UART Serial Console

### Pinout

```
Router PCB (top view, ports at bottom):

[ GND ] [ TX ] [ RX ] [ VCC ]
   1      2      3      4

Connect to USB-UART adapter:
- GND → GND
- TX → RX
- RX → TX
- VCC → (Not connected)
```

### Connection Settings

| Setting | Value |
|---------|-------|
| Baud | 115200 |
| Data | 8 |
| Parity | None |
| Stop | 1 |
| Flow Control | None |

### Connect

```bash
# Linux
screen /dev/ttyUSB0 115200

# Or
minicom -D /dev/ttyUSB0 -b 115200

# Windows (PuTTY)
# Connection type: Serial
# Serial line: COM3 (or your port)
# Speed: 115200
```

## Recommended Alternatives

If you want full OpenWRT support, consider:

| Router | Price | OpenWRT | Notes |
|--------|-------|---------|-------|
| **Xiaomi AX3000T** | $35-50 | ✅ Official | Best budget |
| **Xiaomi Redmi AX6000** | $60-100 | ✅ Official | Best value |
| **GL.iNet Flint 2** | $165 | ✅ Official | 2.5GbE, USB 3.0 |

## Security Best Practices

After rooting:

1. **Change root password:**
   ```bash
   passwd
   ```

2. **Disable WAN access:**
   ```bash
   iptables -A INPUT -i wan -j DROP
   ```

3. **Kill telnet when done:**
   ```bash
   killall -9 telnetd
   ```

4. **Monitor logs:**
   ```bash
   logread
   ```

5. **Update firewall:**
   ```bash
   /etc/init.d/firewall restart
   ```

## Resources

### Official
- [TP-Link GPL Sources](https://www.tp-link.com/us/support/gpl-code/)
- [Archer AX1500 Support](https://www.tp-link.com/us/support/download/archer-ax1500/)

### Exploits
- [CVE-2022-30075 PoC](https://github.com/aaronsvk/CVE-2022-30075)
- [AX10 Research](https://github.com/gscamelo/TP-Link-Archer-AX10-V1)

### Community
- [OpenWRT Forum](https://forum.openwrt.org/t/tp-link-archer-ax1500-70-802-11ax-router-support/48781)
- [OpenWRT TP-Link ToH](https://openwrt.org/toh/hwdata/tp-link/start)

## Contributing

Contributions welcome! Please:

1. Test on your device first
2. Document your changes
3. Submit via pull request
4. Include warnings/risks

## License

MIT License - Educational/Research purposes only

## Authors

- Based on research by @aaronsvk (CVE-2022-30075)
- GPL build utils by @Waujito
- Additional research by @gmaxus

## Support

For issues/discussion:
- GitHub Issues (this repo)
- OpenWRT Forum thread
- Telegram/Discord communities

---

**⚠️ Remember: With great power comes great responsibility. Use wisely!**
