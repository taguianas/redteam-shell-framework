# 🟥 RedTeam Shell Framework

> ⚠️ **Project Status:** Under Active Development  
> This framework is currently evolving. Some modules may be placeholders or partially implemented, and features are subject to change.

---

## 🛡️ Overview

**RedTeam Shell Framework** is a lightweight, modular **Command & Control (C2) shell management framework** designed for **educational use** and **authorized security assessments**.

Unlike heavyweight, dependency-heavy C2 platforms, this framework prioritizes:

- **Minimalism**
- **Portability**
- **Transparency**

It leverages standard Unix tools such as `nc`, `socat`, `openssl`, and `rlwrap` to build **stable, logged, and optionally encrypted reverse shells** without relying on opaque or precompiled binaries.

🎯 **Primary Goal**  
To demonstrate:
- Shell handling mechanics  
- Traffic encryption concepts  
- Modular Bash scripting architecture  

All while remaining easy to audit, modify, and understand.

---

## 🚀 Features

### Phase 1 – Core Listeners
- **Smart Listener Mode**  
  Automatically wraps Netcat with `rlwrap` for line editing and command history.
- **Session Logging**  
  Captures all shell interactions with timestamps in the `logs/` directory.
- **Dependency Validation**  
  Detects required tools and prompts for installation if missing.

### Phase 2 – Payload Generation
- **Dynamic Payload Creation**  
  Generates payloads on demand using user-supplied `LHOST` and `LPORT`.
- **Multi-Language Support**
  - Bash (`/dev/tcp`)
  - Python3 (PTY-spawned)
  - Netcat (`mkfifo`)
  - PHP (`exec`)
- **Export Options**  
  Save generated payloads directly as executable files.

### Phase 3 – Encryption Layer
- **TLS Encapsulation**  
  Wraps shell traffic using `socat` and `OpenSSL`.
- **Automated Certificate Handling**  
  Generates ephemeral self-signed certificates (`.pem`) automatically.
- **Traffic Obfuscation**  
  Prevents cleartext inspection by encapsulating commands in SSL/TLS.

---

## 🏗️ Architecture

The framework follows a **Controller–Module design pattern**, ensuring maintainability and extensibility.

```text
redteam-shell-framework/
├── shellmaster.sh       # Controller: Main UI & event loop
├── modules/             # Logic layer (stateless modules)
│   ├── listeners.sh     # Netcat / rlwrap abstraction
│   ├── shells.sh        # Payload factory
│   ├── encrypt.sh       # OpenSSL / socat logic
│   ├── logger.sh        # Session logging
│   └── ...
├── logs/                # Session artifacts
└── setup_env.sh         # Environment bootstrapper
```

### Engineering Highlights

- **Separation of Concerns**  
  User interface logic (`shellmaster.sh`) is fully decoupled from execution logic (`modules/`), improving maintainability and extensibility.
- **Input Validation**  
  IP addresses and ports are sanitized before execution to reduce runtime errors and misuse.
- **Defensive Coding**  
  Uses safe module sourcing to prevent framework crashes if a module is missing or corrupted.

---

## 🛠️ Installation & Usage

### Prerequisites

The framework relies only on common Linux networking utilities:

- `netcat` (`nc`)
- `socat`
- `openssl`
- `rlwrap` *(optional but strongly recommended)*

---

### Quick Start

#### 1️⃣ Clone the Repository
```bash
git clone https://github.com/taguianas/redteam-shell-framework.git

cd redteam-shell-framework
```


#### 2️⃣ Initialize the Environment

Run the setup script to prepare directory structures and verify dependencies:

```bash
chmod +x setup_env.sh
./setup_env.sh
```

#### 3️⃣ Run the Framework

Start the main controller interface:

```bash
./shellmaster.sh
```


## 📖 Usage Guide

This section provides an overview of the primary operational workflows supported by the RedTeam Shell Framework.

---

### 1. Starting a Listener

Listeners are used to receive incoming reverse shell connections.

1. From the main menu, select **Option 1**.
2. Choose the desired listener type:

   - **Standard Listener**  
     Launches a raw Netcat listener.

   - **Smart Listener**  
     Wraps Netcat with `rlwrap`, enabling:
     - Command history
     - Line editing
     - Improved shell usability

3. Once started, all session activity is automatically logged to the `logs/` directory with timestamps.

---

### 2. Generating a Payload

Payloads are generated dynamically based on user-supplied network parameters.

1. From the main menu, select **Option 2**.
2. Provide the following information:
   - Local IP address (`LHOST`)
   - Listening port (`LPORT`)
3. Select a payload language from the available options:
   - Bash (`/dev/tcp`)
   - Python3 (PTY-spawned)
   - Netcat (`mkfifo`)
   - PHP (`exec`)
4. The framework outputs a ready-to-use one-liner payload.
5. You may optionally save the generated payload to an executable file for later use.

---

### 3. Encrypted Shells (Socat + TLS)

Encrypted shells provide transport-layer security by encapsulating shell traffic in SSL/TLS.

1. From the main menu, select **Option 3**.
2. Choose one of the following actions:
   - **Generate Certificate**  
     Automatically creates a temporary self-signed certificate (`.pem`).
   - **Start Encrypted Listener**  
     Launches a `socat` listener configured to accept TLS-encrypted connections.
   - **Generate Encrypted Payload**  
     Outputs the corresponding encrypted reverse shell command for the target system.
3. When used together, these options establish an encrypted communication channel, preventing cleartext traffic inspection.

---

### 4. Session Logging

- All active shell sessions are logged automatically.
- Logs are stored in the `logs/` directory.
- Each session log includes timestamps for improved traceability and analysis.

---

### 5. Exiting the Framework

- Use the menu exit option to safely terminate the framework.
- Active listeners should be stopped manually if running in separate terminals.
## 🚧 Roadmap

The following roadmap outlines the planned development phases and future enhancements for the RedTeam Shell Framework.

### ✅ Phase 1 – Core Listeners & Logging
- Raw Netcat listener support
- Smart listener mode using `rlwrap`
- Automatic session logging with timestamps
- Dependency checks and environment validation

### ✅ Phase 2 – Payload Generation
- Dynamic payload generation using `LHOST` / `LPORT`
- Multi-language payload support:
  - Bash (`/dev/tcp`)
  - Python3 (PTY-spawned)
  - Netcat (`mkfifo`)
  - PHP (`exec`)
- Optional payload export to executable files

### ⏳ Phase 3 – Encryption Layer (SSL/TLS)
- TLS-wrapped shell communication using `socat`
- Automatic self-signed certificate generation
- Encrypted listener support
- Encrypted payload generation for target hosts

### ⏳ Phase 4 – File Transfer Module
- Upload and download automation
- Support for multiple transfer methods (Netcat / Socat)
- Integrity verification of transferred files
- Logging of file transfer activity

### ⏳ Phase 5 – Pivoting & Relay Capabilities
- Traffic relaying using chained `socat` instances
- Internal network pivoting support
- Port forwarding and listener redirection
- Multi-hop session management

### ⏳ Phase 6 – Automated PTY Upgrades
- Automatic detection of non-interactive shells
- PTY upgrade automation (Python / script-based)
- Terminal stabilization (TTY, job control)
- Improved shell usability across environments

---

> Roadmap items are subject to change as the framework evolves and new features are introduced.

## ⚖️ Legal Disclaimer

⚠️ **Unauthorized use of this framework is illegal.**

The **RedTeam Shell Framework** is provided strictly for:

- Educational and research purposes  
- Authorized Red Team operations  
- Approved penetration testing engagements  
- Security tooling development and demonstration  

Any use of this framework against systems, networks, or applications **without explicit prior permission** from the system owner is strictly prohibited and may violate local, national, or international laws.

The developer assumes **no responsibility or liability** for any misuse, damage, or legal consequences resulting from the use of this software.  
By using this project, you agree that you are solely responsible for ensuring compliance with all applicable laws and regulations.

## 👤 Author

**Anas TAGUI**  

This project was developed as part of ongoing research into shell handling, encrypted communications, and modular Bash-based offensive security tooling.

---

## 📜 License

This project is licensed under the **MIT License**.

You are free to use, modify, and distribute this software in accordance with the terms of the MIT License.  
See the `LICENSE` file for full license details.
