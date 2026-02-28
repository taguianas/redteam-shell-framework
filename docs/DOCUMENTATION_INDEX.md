# Documentation Index

Complete documentation reference for the RedTeam Shell Framework.

---

## Documentation Files

| File | Purpose | Audience |
|------|---------|----------|
| [`../README.md`](../README.md) | Overview, installation, usage, modules | All users |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | System design, data flow, module internals | Developers |
| [`API.md`](API.md) | Function reference for all modules and utilities | Developers |
| [`EXAMPLES.md`](EXAMPLES.md) | Real-world usage walkthroughs | All users |
| [`SECURITY.md`](SECURITY.md) | Threat model, security considerations, best practices | Security users |
| [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) | Common issues and solutions | All users |

---

## Quick Navigation

**Get started** → `README.md` (Installation + Usage)

**Understand the design** → `ARCHITECTURE.md`

**Look up a function** → `API.md`

**See working examples** → `EXAMPLES.md`

**Understand the security model** → `SECURITY.md`

**Fix a problem** → `TROUBLESHOOTING.md`

**Extend the framework** → `ARCHITECTURE.md` (Module Interface) + `API.md`

---

## Project Structure

```
redteam-shell-framework/
├── shellmaster.sh        # Main CLI — menu loop & module loader
├── config.sh             # Global paths, version, environment config
├── utils.sh              # Colors, validation, JSON logging, session utils
│
├── modules/
│   ├── listeners.sh      # Reverse & bind shell listeners
│   ├── shells.sh         # Payload generator (Bash / PowerShell / Python)
│   ├── encrypt.sh        # SSL/TLS encrypted listener via socat
│   ├── transfer.sh       # SCP file upload/download & checksum
│   ├── relay.sh          # socat relay & SSH tunnel management
│   └── upgrade.sh        # PTY upgrade guides & environment stabilization
│
├── docs/
│   ├── DOCUMENTATION_INDEX.md  ← you are here
│   ├── ARCHITECTURE.md
│   ├── API.md
│   ├── EXAMPLES.md
│   ├── SECURITY.md
│   └── TROUBLESHOOTING.md
│
├── logs/       # Runtime logs and session records (git-ignored)
├── certs/      # Generated SSL certificates (git-ignored)
├── payloads/   # Generated payload files (git-ignored)
├── LICENSE
├── .gitattributes
└── .gitignore
```

---

## Recommended Reading Order

### New Users
1. `README.md` — full read
2. `EXAMPLES.md` — pick relevant scenarios
3. `TROUBLESHOOTING.md` — as needed

### Developers
1. `README.md` — Installation and overview
2. `ARCHITECTURE.md` — System design and module interface
3. `API.md` — Function reference

### Security Professionals
1. `README.md`
2. `SECURITY.md`
3. `EXAMPLES.md`

---

## Topic Cross-Reference

| Topic | Documents |
|-------|-----------|
| Listeners | README.md, ARCHITECTURE.md, EXAMPLES.md |
| Payloads | README.md, EXAMPLES.md, API.md |
| Encryption / SSL | README.md, SECURITY.md, EXAMPLES.md |
| File Transfer | README.md, EXAMPLES.md, API.md |
| Relay / Pivoting | README.md, ARCHITECTURE.md, EXAMPLES.md |
| PTY Upgrade | README.md, EXAMPLES.md, API.md |
| Session Tracking | ARCHITECTURE.md, API.md |
| Logging | ARCHITECTURE.md, API.md |
| Configuration | README.md, ARCHITECTURE.md |

---

Framework Version: v1.0.0
