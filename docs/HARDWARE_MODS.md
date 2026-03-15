# Hardware Modifications for Archer AX1500

Hardware mods and UART installation guide.

## ⚠️ Warning

**Opening your router voids the warranty.**

- Risk of permanent damage
- ESD can destroy components
- Proceed at your own risk

---

## UART Serial Console

### Required Tools

- Soldering iron (fine tip)
- Solder
- USB to UART adapter (3.3V)
- Tweezers
- Magnifying glass (optional)
- Multimeter (optional)

### UART Adapter

Recommended adapters:
- **CP2102** (3.3V-5V selectable)
- **FTDI FT232RL** (3.3V-5V selectable)
- **CH340** (cheap, works)

**Important**: Set adapter to **3.3V**, NOT 5V!

### Pinout

Router PCB (top view, ports facing down):

```
        ┌─────────────────┐
        │   TP-Link       │
        │  Archer AX1500  │
        │                 │
UART →  [● ● ● ●]         │  ← Power
        GND TX  RX  VCC   │
                          │
        ┌───────────────┐ │
        │ WAN  LAN LAN  │ │
        │      LAN LAN  │ │
        └───────────────┘ │
        └─────────────────┘
```

| Pin | Name | Connect To | Color (typical) |
|-----|------|------------|-----------------|
| 1 | GND | GND | Black |
| 2 | TX | RX | Green |
| 3 | RX | TX | White |
| 4 | VCC | **NOT CONNECTED** | - |

### Connection Diagram

```
Archer AX1500          USB-UART Adapter
    GND  ──────────────── GND (Black)
    TX   ──────────────── RX  (Green)
    RX   ──────────────── TX  (White)
    VCC  ──────────────── (Not connected)
```

### Step-by-Step Installation

#### Step 1: Open Router

```
1. Remove rubber feet (4 screws underneath)
2. Remove all visible screws
3. Use plastic pry tool to separate case
4. Carefully lift top cover
5. Disconnect any cables (LEDs, buttons)
```

#### Step 2: Locate UART Pads

Look for 4 unpopulated holes labeled:
- TX
- RX
- GND
- VCC (or 3.3V)

Usually located near the edge of the PCB.

#### Step 3: Solder Headers

```
1. Tin the pads with small amount of solder
2. Insert header pins from component side
3. Solder from bottom side
4. Trim excess pin length
5. Check for solder bridges
```

#### Step 4: Connect Adapter

```
1. Set adapter voltage jumper to 3.3V
2. Connect wires according to pinout
3. Double-check connections
4. Don't connect VCC!
```

#### Step 5: Test Connection

```bash
# Connect USB adapter to PC
# Find device name:
# Linux: ls /dev/ttyUSB*  → /dev/ttyUSB0
# Windows: Device Manager → Ports → COMx

# Linux (screen):
screen /dev/ttyUSB0 115200

# Linux (minicom):
minicom -D /dev/ttyUSB0 -b 115200

# Windows (PuTTY):
# Connection type: Serial
# Serial line: COM3 (or your port)
# Speed: 115200
```

#### Step 6: Power On Router

```
1. Open terminal
2. Power on router
3. Should see U-Boot output

Example output:
U-Boot 2013.07 (May 20 2022 - 14:30:00)

Board: TP-Link Archer AX1500 v1
SoC:   Broadcom BCM6750 A1
CPU:   ARM Cortex-A7 @ 1500MHz
DRAM:  256 MiB
...
```

### UART Settings

| Setting | Value |
|---------|-------|
| Baud Rate | 115200 |
| Data Bits | 8 |
| Parity | None |
| Stop Bits | 1 |
| Flow Control | None |

---

## NAND Flash Backup

### Why Backup?

- Recovery from bricks
- Restore stock firmware
- Experiment safely

### Backup via UART

```bash
# Interrupt U-Boot (press any key during boot)
U-Boot> printenv

# Backup MTD partitions
U-Boot> nand read 0x82000000 0x0 0x100000
U-Boot> tftpboot 0x82000000 mtd0.bin

# Repeat for each partition
```

### Backup via Telnet (after rooting)

```bash
# On router
cd /tmp
for i in 0 1 2 3; do
    dd if=/dev/mtdblock$i of=mtd$i.bin 2>/dev/null
done
tar -czf backup.tar.gz mtd*.bin

# Download to PC
scp root@192.168.0.1:/tmp/backup.tar.gz ~/
```

### MTD Partitions

Typical layout:

| Partition | Size | Content |
|-----------|------|---------|
| mtd0 | 256KB | U-Boot |
| mtd1 | 128KB | U-Boot config |
| mtd2 | 4MB | Kernel |
| mtd3 | 10MB+ | Root filesystem |

---

## External Storage

### USB Storage

```bash
# Connect USB drive to router USB port

# On router (via telnet)
fdisk -l              # List drives
mkfs.ext4 /dev/sda1   # Format (if needed)
mkdir /mnt/usb
mount /dev/sda1 /mnt/usb

# Auto-mount on boot
echo "/dev/sda1 /mnt/usb ext4 defaults 0 0" >> /etc/fstab
```

### Install Packages to USB

```bash
# Mount USB
mount /dev/sda1 /mnt/usb

# Create opkg directories
mkdir -p /mnt/usb/opkg
mkdir -p /mnt/usb/var/lock

# Install to USB
opkg install package.ipk -o /mnt/usb --force-space --nodeps
```

---

## LED Modifications

### LED Pinout

Common LED colors:
- **Red**: Power/WAN
- **Blue**: WiFi 2.4GHz
- **Green**: WiFi 5GHz
- **White**: Internet

### Control LEDs

```bash
# Find LED GPIOs
cat /sys/class/leds/*/brightness

# Control via sysfs
echo 1 > /sys/class/leds/tp-link:white:wlan/brightness
echo 0 > /sys/class/leds/tp-link:white:wlan/brightness

# Or via GPIO
echo out > /sys/class/gpio/gpioXX/direction
echo 1 > /sys/class/gpio/gpioXX/value
```

---

## Reset Button Mod

### Use Reset Button for Custom Action

```bash
# Map reset button to custom script
cat > /etc/button-reset.sh << 'EOF'
#!/bin/sh
# Custom reset button handler
echo "Reset button pressed!" >> /tmp/button.log
# Add your custom action here
EOF

chmod +x /etc/button-reset.sh

# Add to crontab or hotplug
```

---

## Power Mod (Advanced)

### External Power Supply

If modifying for automotive/mobile use:

| Input | Voltage | Current |
|-------|---------|---------|
| Stock | 12V DC | 1.5A |
| External | 9-12V DC | 2A+ |

**Warning**: Incorrect voltage will destroy router!

---

## Recovery from Brick

### UART Recovery

```bash
# Connect via UART
# Interrupt U-Boot
U-Boot> tftp 0x82000000 recovery.bin
U-Boot> nand erase 0x0 0x1000000
U-Boot> nand write 0x82000000 0x0 0x1000000
U-Boot> reset
```

### TFTP Recovery

```bash
# Set PC IP: 192.168.0.225
# Place firmware as tftpboot.bin
# Start TFTP server
# Power on router (auto-recovers in 5 seconds)
```

---

## Tools & Parts List

| Item | Purpose | Price |
|------|---------|-------|
| USB-UART adapter | Serial console | $3-10 |
| Soldering iron | Header installation | $10-30 |
| Header pins | UART connection | $1 |
| Screwdriver set | Case opening | $10 |
| Multimeter | Voltage testing | $15 |
| Heat gun | Case opening (optional) | $20 |

---

## Safety Tips

1. **Disconnect power** before opening
2. **Discharge capacitors** with resistor
3. **Use ESD strap** or touch grounded metal
4. **Don't connect VCC** to UART
5. **Double-check voltage** before powering
6. **Work in well-lit area**
7. **Take photos** during disassembly

---

## Resources

- [OpenWRT UART Guide](https://openwrt.org/docs/guide-developer/hardware/port.serial)
- [DD-WRT Serial Mod](https://wiki.dd-wrt.com/wiki/index.php/Serial_debricking)
- [Router Tech Database](https://wikidevi.wi-cat.ru/)
- [Broadcom BCM6750 Datasheet](https://www.broadcom.com/products/wireless-connectivity/wi-fi-routers-and-gateways/bcm6750)
