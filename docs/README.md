RedTeam Shell Framework

⚠️ PROJECT UNDER CONSTRUCTION > This framework is currently in active development. Some modules  are currently placeholders or partially implemented. Features are subject to change.


🛡️ Project Overview

The RedTeam Shell Framework is a lightweight, modular Command & Control (C2) suite developed for educational purposes and authorized security assessments.

Unlike heavy, dependency-rich C2 frameworks, this tool focuses on minimalism and portability. It leverages standard Unix binaries (nc, socat, openssl, rlwrap) to establish stable, logging-enabled, and encrypted reverse shell connections.

Key Objective: To demonstrate the mechanics of shell handling, traffic encryption, and modular bash scripting architecture without relying on opaque, pre-compiled binaries.

🚀 Features

Phase 1: Core Listeners

Smart Listening: Automates the usage of rlwrap for history and line-editing in raw Netcat shells.

Session Logging: Automatically captures session data to the logs/ directory with timestamps.

Dependency Handling: Checks for required tools and prompts for installation if missing.

Phase 2: Payload Generation

Dynamic Generation: Creates payloads on-the-fly based on user-supplied LHOST/LPORT.

Multi-Language Support:

Bash (/dev/tcp)

Python3 (PTY-spawned)

Netcat (mkfifo)

PHP (exec)

Export options: Save payloads directly to executable files.

Phase 3: Encryption Layer

Traffic Obfuscation: Implements socat with OpenSSL to wrap shell traffic in TLS.

Certificate Automation: Auto-generates ephemeral self-signed certificates (.pem) for encrypted listeners.

Evasion: Bypasses basic cleartext traffic analysis by encapsulating commands in SSL.

🏗️ Architecture

The framework follows a Controller-Module design pattern to ensure maintainability and scalability.

redteam-shell-framework/
├── shellmaster.sh       # [Controller] Main Event Loop & UI
├── modules/             # [Logic Layer] Stateless functional modules
│   ├── listeners.sh     # Wraps nc/rlwrap logic
│   ├── shells.sh        # Payload template factory
│   ├── encrypt.sh       # OpenSSL/Socat abstraction
│   ├── logger.sh        # Session recording
│   └── ...
├── logs/                # [Data Layer] Session artifacts
└── setup_env.sh         # [Init] Environment bootstrapper


Engineering Highlights

Separation of Concerns: The UI logic (shellmaster.sh) is completely decoupled from the execution logic (modules/).

Input Sanitization: User inputs (Ports/IPs) are validated before execution to prevent script errors.

Defensive Coding: Uses safe_source functions to prevent the framework from crashing if a module file is missing or corrupted.

🛠️ Installation & Usage

Prerequisites

The framework relies on standard Linux networking tools:

netcat (nc)

socat

openssl

rlwrap (optional, but recommended for shell stability)

Quick Start

Clone the Repository

git clone [https://github.com/yourusername/redteam-shell-framework.git](https://github.com/yourusername/redteam-shell-framework.git)
cd redteam-shell-framework


Initialize Environment
Run the setup script to create directory structures and check dependencies.

chmod +x setup_env.sh
./setup_env.sh


Run the Framework

./shellmaster.sh


📖 Usage Guide

1. Starting a Listener

Select Option 1 from the main menu.

Standard Listener: Uses raw nc.

Smart Listener: Wraps nc with rlwrap to allow arrow-key usage and command history in the remote shell.

2. Generating a Payload

Select Option 2 from the main menu.

Input your IP and Port.

Choose the target language (e.g., Python3).

The tool generates the one-liner and offers to save it to a script file.

3. Encrypted Shells (Socat)

Select Option 3 from the main menu.

Generate Cert: Creates a bind.pem key/cert pair in tmp/.

Start Listener: Starts a socat listener expecting SSL traffic.

Generate Payload: Provides the specific socat command required on the victim machine to connect back using encryption.

🚧 Roadmap

[x] Phase 1: Core Listeners & Logging

[x] Phase 2: Payload Generator

[x] Phase 3: Encryption (SSL/TLS)

[ ] Phase 4: File Transfer Module (Upload/Download automation)

[ ] Phase 5: Pivot/Relay (Chaining socat for internal network access)

[ ] Phase 6: Automated PTY Upgrades (Magic sequence injection)

⚖️ Legal Disclaimer

Usage of the RedTeam Shell Framework for attacking targets without prior mutual consent is illegal. This project is created for:

Educational purposes (Learning bash scripting, networking protocols, and system administration).

Authorized Red Team operations and penetration testing engagements.

Portfolio demonstration of security tool development.

The developer assumes no liability and is not responsible for any misuse or damage caused by this program.

Author: [Your Name]

License: MIT