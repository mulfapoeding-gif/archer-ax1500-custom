# Build Guide - Custom Packages for Archer AX1500

How to build custom packages and kernel modules using the GPL sources.

## Build Environment

### Option 1: Docker (Recommended)

```bash
cd docker
docker build -t ax1500-build .
docker run -it -v $(pwd)/../firmware:/router ax1500-build
```

### Option 2: Ubuntu 12.04 VM

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    libncurses5-dev \
    gawk \
    git \
    subversion \
    mercurial \
    wget \
    unzip \
    zlib1g-dev \
    libssl-dev \
    gettext \
    flex \
    bison \
    patch \
    binutils \
    cpio
```

## Setup GPL Sources

### Download Sources

1. Visit: https://www.tp-link.com/us/support/gpl-code/
2. Search: "Archer AX1500"
3. Download GPL source tarball

### Extract and Patch

```bash
# Extract
tar -xzf ArcherAX1500_GPL.tar.gz -C /router
cd /router

# Apply patches
patch -p1 < /router/patches/router.patch

# Update sources in dl directory
mkdir -p Iplatform/openwrt/dl
cd Iplatform/openwrt/dl

# Download missing sources
wget https://github.com/openwrt/openwrt/archive/refs/tags/v14.07.tar.gz -O openwrt-14.07.tar.gz
```

## Build System

### Enter Build Directory

```bash
cd /router/Iplatform/build
```

### Configure Build

```bash
make menuconfig
```

Navigate menu:
- Select target system (BCM947XX)
- Select subtarget (BCM47XX/ARM)
- Select packages to build

### Build Full System

```bash
make SHELL=/bin/bash V=s
```

Options:
- `V=s`: Verbose output
- `SHELL=/bin/bash`: Use bash (required)
- `-j4`: Parallel build (4 jobs)

### Build Individual Package

```bash
# Userspace package
make package/<package_name>/compile V=s

# Kernel module
make package/kmod-<module_name>/compile V=s
```

## Example: Build youtubeUnblock

### Setup Package

```bash
# Clone package repo
git clone https://github.com/Waujito/youtubeUnblock -b openwrt /router/youtubeUnblock
cd /router/youtubeUnblock
```

### Modify Makefile

Edit `youtubeUnblock/Makefile`:

```makefile
# Change from git source to tarball
PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Waujito/youtubeUnblock/archive/refs/tags
```

### Build

```bash
cd /router/Iplatform/build
make package/youtubeUnblock/compile V=s
```

### Output

```
/router/Iplatform/build/bin/model_brcm_bcm490x-/packages/youtubeUnblock_*.ipk
```

## Install on Router

### Transfer Package

```bash
# On your PC
python3 -m http.server 8000

# On router (via telnet)
cd /tmp
wget http://192.168.0.2:8000/youtubeUnblock.ipk
```

### Install

```bash
# Create lock directory
mkdir -p /tmp/var/lock

# Install with workarounds
opkg install youtubeUnblock.ipk -o /tmp --force-space --nodeps
```

### Run

```bash
# Userspace binary
/tmp/usr/bin/youtubeUnblock &

# Kernel module
insmod /tmp/lib/modules/kyoutubeUnblock.ko
```

## Common Issues

### Issue: Download Failed

**Error**: `Failed to download <package>`

**Solution**:
```bash
# Manually download to dl directory
cd /router/Iplatform/openwrt/dl
wget <url> -O <filename>.tar.gz

# Update Makefile to use local file
# PKG_SOURCE:=<filename>.tar.gz
# PKG_SOURCE_URL:=file:///router/Iplatform/openwrt/dl
```

### Issue: Checksum Mismatch

**Error**: `Checksum mismatch`

**Solution**:
```bash
# Find correct checksum
md5sum package.tar.gz

# Update Makefile
# PKG_MD5SUM:=correct_checksum_here
```

### Issue: Build Fails with Syntax Error

**Error**: `Syntax error in Makefile`

**Solution**:
```bash
# Old OpenWRT doesn't support git sources
# Change to tarball download

# BEFORE:
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/...

# AFTER:
PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/.../archive/refs/tags
```

### Issue: No Space Left on Device

**Error**: `Only have 0kb available on filesystem /tmp`

**Solution**:
```bash
# Install to /tmp with force-space
opkg install package.ipk -o /tmp --force-space --nodeps

# Or use USB storage if available
```

### Issue: Dependencies Not Satisfied

**Error**: `Cannot satisfy the following dependencies`

**Solution**:
```bash
# Skip dependency check
opkg install package.ipk -o /tmp --force-space --nodeps

# Or build dependencies first
make package/<dependency>/compile V=s
```

## Useful Packages

### Network Tools

```bash
# Build
make package/tcpdump/compile V=s
make package/nmap/compile V=s
make package/iptables/compile V=s

# Install
opkg install tcpdump -o /tmp --force-space --nodeps
```

### System Tools

```bash
# Build
make package/vim/compile V=s
make package/nano/compile V=s
make package/htop/compile V=s

# Install
opkg install vim -o /tmp --force-space --nodeps
```

### VPN Tools

```bash
# Build
make package/openvpn/compile V=s
make package/wireguard/compile V=s

# Install
opkg install openvpn -o /tmp --force-space --nodeps
```

## Kernel Module Development

### Create Module Source

```c
// hello.c
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("Hello World Module");

static int __init hello_init(void) {
    printk(KERN_INFO "Hello, Archer AX1500!\n");
    return 0;
}

static void __exit hello_exit(void) {
    printk(KERN_INFO "Goodbye!\n");
}

module_init(hello_init);
module_exit(hello_exit);
```

### Create Makefile

```makefile
obj-m += hello.o

KDIR := /router/Iplatform/openwrt/build_dir/target-arm_v7_uClibc-0.9.33.2_musl-1.1.15_eabi/linux-brcm47xx
PWD := $(shell pwd)

all:
    $(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
    $(MAKE) -C $(KDIR) M=$(PWD) clean
```

### Build Module

```bash
make -C /router/Iplatform/openwrt/build_dir/target-*/linux-brcm47xx M=$(pwd) modules
```

### Load Module

```bash
# On router
insmod /tmp/hello.ko

# Check
dmesg | tail
lsmod
```

## Tips

1. **Use Docker**: Avoids host system compatibility issues
2. **Build in RAM**: Use `/tmp` for installations
3. **Test locally**: Compile on PC, test on router
4. **Backup first**: Always backup before installing
5. **Static binaries**: Prefer static compilation for portability

## Resources

- [OpenWRT SDK Guide](https://openwrt.org/docs/guide-developer/toolchain/using_the_sdk)
- [OpenWRT Package Feed](https://openwrt.org/packages/start)
- [Kernel Module Packaging](https://openwrt.org/docs/guide-developer/kernel-module-packages)
- [Buildroot Documentation](https://buildroot.org/docs/manual/)
