# TP-Link Archer AX1500/AX10 - Complete Technical Specifications

Comprehensive hardware and firmware documentation for Archer AX1500 v1.0 and AX10 v1.0 routers.

---

## Hardware Specifications

### System-on-Chip (SoC)

| Component | Specification |
|-----------|--------------|
| **CPU** | Broadcom BCM6750 |
| **Architecture** | ARM Cortex-A7 |
| **Cores** | 3 (Triple-core) |
| **Clock Speed** | 1.5 GHz |
| **Process** | 28nm |
| **Integrated** | 2.4GHz WiFi, 5GHz WiFi, Switch |

### Memory

| Type | Chip | Capacity | Speed |
|------|------|----------|-------|
| **RAM** | Samsung K4B2G1646F-BYMA | 256 MiB DDR3 | 1333 MHz |
| **Flash** | Winbond W25Q128JVSQ | 16 MiB SPI NOR | QSPI |

### Wireless

#### 5 GHz Band
| Specification | Value |
|--------------|-------|
| **Chip** | Broadcom BCM6750 (integrated) |
| **Standard** | 802.11ax/ac/n (WiFi 6) |
| **MIMO** | 2x2:2 |
| **Max Speed** | 1201 Mbps |
| **Channel Width** | 20/40/80 MHz |
| **Modulation** | 1024-QAM (HE) |

#### 2.4 GHz Band
| Specification | Value |
|--------------|-------|
| **Chip** | Broadcom BCM43217 |
| **Standard** | 802.11b/g/n/ax |
| **MIMO** | 2x2:2 |
| **Max Speed** | 300 Mbps |
| **Channel Width** | 20/40 MHz |
| **Modulation** | 256-QAM |

### Ethernet

| Port | Count | Speed | PHY |
|------|-------|-------|-----|
| **WAN** | 1 | 10/100/1000 Mbps | Integrated BCM6750 |
| **LAN** | 4 | 10/100/1000 Mbps | Integrated BCM6750 |

**Switch Features:**
- IEEE 802.3az Energy Efficient Ethernet
- IEEE 802.3x Flow Control
- VLAN support (802.1Q)

### Physical

| Specification | Value |
|--------------|-------|
| **Power Input** | 12V DC, 1A |
| **Connector** | Barrel (5.5mm x 2.1mm) |
| **Dimensions** | 260.2 × 135 × 38.6 mm |
| **Weight** | ~450g |
| **Antennas** | 4x Internal (non-removable) |
| **LEDs** | Power, Internet, 2.4GHz, 5GHz, WPS |

---

## UART Console

### Pinout

Located on PCB near CPU (top view, ports facing down):

```
        ┌─────────────────┐
        │   TP-Link       │
        │  Archer AX1500  │
        │                 │
UART →  [● ● ● ●]         │
        GND TX  RX  VCC   │
```

| Pin | Name | Voltage | Connect To |
|-----|------|---------|------------|
| 1 | GND | 0V | GND (Black) |
| 2 | TX | 3.3V | RX (Green) |
| 3 | RX | 3.3V | TX (White) |
| 4 | VCC | 3.3V | **NOT CONNECTED** |

### Settings

| Parameter | Value |
|-----------|-------|
| **Baud Rate** | 115200 |
| **Data Bits** | 8 |
| **Parity** | None |
| **Stop Bits** | 1 |
| **Flow Control** | None |
| **Voltage** | 3.3V (DO NOT USE 5V) |

### Boot Log Example

```
U-Boot 2013.07 (May 20 2022 - 14:30:00)

Board: TP-Link Archer AX1500 v1
SoC:   Broadcom BCM6750 A1
CPU:   ARM Cortex-A7 @ 1500MHz
DRAM:  256 MiB
NAND:  16 MiB
...
```

---

## Memory Map (MTD Partitions)

Typical flash layout:

| Partition | Device | Size | Content |
|-----------|--------|------|---------|
| **mtd0** | /dev/mtdblock0 | 256 KB | U-Boot bootloader |
| **mtd1** | /dev/mtdblock1 | 128 KB | U-Boot environment |
| **mtd2** | /dev/mtdblock2 | 4 MB | Linux kernel |
| **mtd3** | /dev/mtdblock3 | ~11 MB | Root filesystem (SquashFS) |
| **mtd4** | /dev/mtdblock4 | 16 MB | Full firmware backup |

### View Partitions

```bash
# On router (via telnet)
cat /proc/mtd
```

Example output:
```
dev:    size   erasesize  name
mtd0: 00040000 00010000 "u-boot"
mtd1: 00020000 00010000 "u-boot-env"
mtd2: 00400000 00010000 "kernel"
mtd3: 00b80000 00010000 "rootfs"
mtd4: 01000000 00010000 "firmware"
```

---

## Firmware Information

### Stock Firmware

| Attribute | Value |
|-----------|-------|
| **Base** | Modified OpenWRT 14.07 |
| **Kernel** | Linux 3.x (Broadcom BSP) |
| **Init System** | Procd |
| **Web Interface** | TP-Link proprietary |
| **Config Format** | XML (encrypted) |

### Firmware Versions

| Version | Build Date | CVE Status |
|---------|------------|------------|
| **1.0.x** | 2020xxxx | All vulnerable |
| **1.1.x** | 2020xxxx | All vulnerable |
| **1.2.x** | 2021xxxx | All vulnerable |
| **1.3.1** | 20220401 | CVE-2022-30075 ✅ |
| **1.4.x+** | 20220701+ | CVE-2022-30075 patched |
| **1.2.1** (AX10) | 20221103 | CVE-2022-40486 patched |
| **1.3.11** (AX1500) | 20250601 | CVE-2025-9961 patched |

### Download Firmware

- **Official:** https://www.tp-link.com/us/support/download/archer-ax1500/#Firmware
- **Archive:** https://web.archive.org/web/*/https://www.tp-link.com/*/support/download/archer-ax1500/

---

## Vulnerabilities

### CVE-2022-30075

| Attribute | Value |
|-----------|-------|
| **Severity** | High (7.5 CVSS) |
| **Type** | Improper input validation |
| **Vector** | Config file upload + WPS button |
| **Impact** | Root shell via telnet |
| **Patched** | July 2022 |

**Exploit:**
```bash
# 1. Modify config XML
# 2. Upload to router
# 3. Press WPS button
# 4. telnet 192.168.0.1
```

### CVE-2022-40486

| Attribute | Value |
|-----------|-------|
| **Severity** | High (8.1 CVSS) |
| **Type** | XML injection |
| **Vector** | DDNS service config |
| **Impact** | Command execution |
| **Patched** | November 2022 |

### CVE-2025-9961 ⚠️ NEW

| Attribute | Value |
|-----------|-------|
| **Severity** | Critical (9.8 CVSS estimated) |
| **Type** | Stack-based buffer overflow |
| **Binary** | CWMP (CPE WAN Management Protocol) |
| **Vector** | Authenticated LAN attacker |
| **Impact** | Remote code execution as root |
| **Patched** | June 2025 |
| **Affected** | AX10 < 1.2.1, AX1500 < 1.3.11 |

**Exploit Overview:**
```
1. Authenticate to web interface
2. Send malformed CWMP request
3. Stack overflow in CWMP binary
4. Shellcode execution
5. Root shell obtained
```

**Mitigation:**
- Update to firmware ≥ 1.3.11 (AX1500) or ≥ 1.2.1 (AX10)
- Don't expose admin interface to WAN
- Use strong admin passwords
- Disable CWMP if not needed

---

## OpenWRT Support Status

### Current Status: ❌ NOT SUPPORTED

| Reason | Details |
|--------|---------|
| **Broadcom SoC** | Closed-source WiFi drivers |
| **Limited Flash** | 16MB (OpenWRT needs 8-16MB) |
| **No Community Interest** | Developers avoid Broadcom |
| **Better Alternatives** | MediaTek Filogic available |

### Why Broadcom is Problematic

1. **No Open-Source Drivers**
   - Broadcom doesn't release full specs
   - WiFi drivers are binary blobs
   - OpenWRT community doesn't support

2. **Limited Resources**
   - 16MB flash is tight fit
   - 256MB RAM is adequate but not great
   - No hardware encryption acceleration

3. **Better Options Exist**
   - MediaTek Filogic has full open drivers
   - Qualcomm ipq807x well supported
   - Community prefers supported hardware

### Alternative: Use GPL Sources

TP-Link provides GPL sources:
- Modified OpenWRT SDK
- Linux kernel with Broadcom patches
- Userspace packages

**Use Cases:**
- Build custom packages
- Study TP-Link modifications
- Create static binaries
- Research/educational purposes

---

## Recommended Alternatives

### Budget: MediaTek MT7981 (Filogic 820)

| Router | RAM/ROM | Price | WireGuard | Notes |
|--------|---------|-------|-----------|-------|
| **Xiaomi AX3000T** | 256/128MB | $35-50 | 525 Mb/s | Best budget |
| **Routerich AX3000** | 256/128MB | $45-55 | 525 Mb/s | OpenWRT pre-installed |
| **GL.iNet Beryl AX** | 512/256MB | $90-110 | 525 Mb/s | USB 3.0, travel |

### Flagship: MediaTek MT7986 (Filogic 830)

| Router | RAM/ROM | Price | WireGuard | Notes |
|--------|---------|-------|-----------|-------|
| **Xiaomi Redmi AX6000** | 512/128MB | $60-100 | 1.42 Gb/s | Best value |
| **Mercusys MR90X V1** | 512/128MB | $80-120 | 1.42 Gb/s | 2.5GbE port |
| **Asus TUF-AX4200** | 512/256MB | $130-140 | 1.42 Gb/s | USB 3.0 |
| **GL.iNet Flint 2** | 1GB/8GB | $165 | 1.42 Gb/s | 2x 2.5GbE, USB 3.0 |
| **Banana Pi BPI-R3** | 2GB/8GB | $100-140 | 1.42 Gb/s | SFP, NVMe |

### Performance Comparison

| Test | AX1500 (BCM6750) | MT7981 | MT7986 |
|------|------------------|--------|--------|
| **WireGuard** | ~200 Mb/s* | 525 Mb/s | 1.42 Gb/s |
| **OpenVPN** | ~50 Mb/s* | N/A | 110 Mb/s |
| **NAT Routing** | ~800 Mb/s | 1 Gb/s | 2+ Gb/s |
| **WiFi 5GHz** | 1201 Mbps | 1180 Mbps | 1550 Mbps |

*Estimated based on CPU performance

---

## Tools & Resources

### Essential Tools

| Tool | Purpose |
|------|---------|
| **USB-UART Adapter** | Serial console access (3.3V) |
| **Binwalk** | Firmware extraction |
| **CVE-2022-30075 PoC** | Root exploit |
| **Dropbear** | Lightweight SSH server |
| **OpenWRT SDK** | Package compilation |

### Useful Commands

```bash
# Backup firmware
dd if=/dev/mtdblock3 of=/tmp/rootfs.bin

# Check kernel version
cat /proc/version

# List running processes
ps

# View network config
ifconfig
netstat -tulpn

# Check disk space
df -h

# View logs
logread
dmesg
```

### Recovery Methods

#### TFTP Recovery
1. Set PC IP: 192.168.0.225
2. Place firmware as `tftpboot.bin`
3. Start TFTP server
4. Power on router (auto-recovers)

#### UART Recovery
1. Connect UART adapter
2. Interrupt U-Boot (press any key)
3. Use `tftp` or `loady` to download firmware
4. Flash with `nand write`

---

## References

- [TP-Link GPL Sources](https://www.tp-link.com/us/support/gpl-code/)
- [Broadcom BCM6750 Datasheet](https://www.broadcom.com/products/wireless-connectivity/wi-fi-routers-and-gateways/bcm6750)
- [OpenWRT Forum - AX1500](https://forum.openwrt.org/t/tp-link-archer-ax1500-70-802-11ax-router-support/48781)
- [CVE-2025-9961 Advisory](https://github.com/advisories/GHSA-mrm5-v7mh-6mmq)
- [WikiDevi - AX1500](https://wikidevi.wi-cat.ru/TP-LINK_Archer_AX1500)
- [TP-Link Security Advisory](https://www.tp-link.com/us/support/security-advisory/)

---

**Last Updated:** March 2026  
**Contributors:** Research based on community findings and official documentation
