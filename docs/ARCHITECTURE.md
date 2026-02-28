# Architecture

## System Overview

RedTeam Shell Framework follows a **controller–module** pattern. The main controller (`shellmaster.sh`) loads modules at startup, presents a menu, and delegates each selection to the appropriate module. All modules share a common foundation of configuration (`config.sh`) and utility functions (`utils.sh`).

```
┌─────────────────────────────────────────────────────────────┐
│                   shellmaster.sh                            │
│           Main CLI — menu loop & module loader              │
└────────────────────────┬────────────────────────────────────┘
                         │  sources
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
    config.sh        utils.sh       modules/*.sh
    (paths,          (colors,       (feature logic)
     version,         logging,
     dirs)            validation)
         │
         ▼
  ┌──────────────────────────────────────┐
  │  Runtime directories (auto-created)  │
  │  logs/      – framework & session    │
  │  certs/     – SSL certificates       │
  │  payloads/  – generated payloads     │
  └──────────────────────────────────────┘
```

---

## File Roles

| File | Role |
|------|------|
| `shellmaster.sh` | Entry point — loads modules, runs dependency check, renders menu, routes selections |
| `config.sh` | Exports all global variables and creates runtime directories |
| `utils.sh` | Colors, message helpers, validation, JSON logging, IP detection, session notes |
| `modules/listeners.sh` | Reverse & bind listener management with auto-detected nc variant |
| `modules/shells.sh` | Payload generator for Bash, PowerShell, Python, Perl, Ruby, PHP |
| `modules/encrypt.sh` | SSL/TLS listener and cert generation via socat/openssl |
| `modules/transfer.sh` | SCP upload/download, HTTP file server, checksum verification |
| `modules/relay.sh` | socat port relays and SSH tunnel management |
| `modules/upgrade.sh` | PTY upgrade and environment stabilization guides |

---

## Startup Sequence

```
1. shellmaster.sh starts
   │
   ├─ Source utils.sh        (colors, helpers, logging, IP detection, session notes)
   ├─ Source config.sh       (paths, init_framework → mkdir + touch log)
   │
   ├─ safe_source listeners.sh
   ├─ safe_source shells.sh
   ├─ safe_source encrypt.sh
   ├─ safe_source transfer.sh
   ├─ safe_source relay.sh
   ├─ safe_source upgrade.sh
   │
   ├─ check_dependencies()   (warns if socat, nc, python3, rlwrap, openssl, or scp are missing)
   │
   └─ Enter while true loop → main_menu()
```

`safe_source()` silently skips a module if it cannot be loaded, preventing a crash on startup.

---

## Module Interface

Every module follows the same structure:

```bash
#!/bin/bash
# Module description

module_menu() {
    while true; do
        clear
        # display styled menu
        read -r choice
        case "$choice" in
            1) feature_one ;;
            ...
            N) break ;;        # Back to main menu
            *) error_msg "Invalid option"; sleep 2 ;;
        esac
    done
}

feature_one() { ... }
feature_two() { ... }
```

Menu functions are named `<module>_menu` and called by `handle_choice()` in `shellmaster.sh`.

---

## Configuration System

`config.sh` exports all global variables on load and auto-runs `init_framework()` to create required directories.

```bash
VERSION="1.0.0"
FRAMEWORK_DIR=<project root>
MODULES_DIR="${FRAMEWORK_DIR}/modules"
LOGS_DIR="${FRAMEWORK_DIR}/logs"
CERTS_DIR="${FRAMEWORK_DIR}/certs"
PAYLOADS_DIR="${FRAMEWORK_DIR}/payloads"
LOG_FILE="${LOGS_DIR}/framework.log"
LOG_LEVEL="INFO"          # DEBUG | INFO | WARN | ERROR
SESSION_DIR="${LOGS_DIR}/sessions"
SESSION_PREFIX="shell_"
SESSION_TIMEOUT=3600
DEFAULT_CIPHER="aes-256-cbc"
KEY_SIZE=2048
CERT_VALIDITY=365
CLI_COLORS=true
```

### Local overrides

Create a `.env` file in the project root to override any variable:

```bash
LOG_LEVEL=DEBUG
CLI_COLORS=false
```

---

## Logging System

Logging is handled by `utils.sh`. All log entries go to `LOG_FILE` (`logs/framework.log`) in JSON format.

```json
{"timestamp":"2026-02-25T01:00:00Z","level":"INFO","message":"Listener starting...","user":"root","pid":1234}
```

Log levels, controlled by `LOG_LEVEL`:

| Level | Function | When written |
|-------|----------|-------------|
| DEBUG | `log_debug` | LOG_LEVEL=DEBUG only |
| INFO | `log_info` | DEBUG or INFO |
| WARN | `log_warn` | DEBUG, INFO, or WARN |
| ERROR | `log_error` | Always |

### Session tracking

Each listener session gets a unique ID (`shell_<timestamp>_<random>`). Session metadata and events are written to `logs/sessions/`:

```
logs/sessions/shell_1708867275_28340.json   – metadata (IP, port, status)
logs/sessions/shell_1708867275_28340.log    – events (started, ended)
```

---

## Data Flow: Reverse Shell

```
User selects "Listeners" → "Reverse Listener"
  │
  ├─ Prompt: listen IP, port, rlwrap preference
  ├─ validate_port() check
  ├─ detect_nc() → returns binary + flags + exec-support for installed variant
  ├─ generate_session_id()
  ├─ create_session() → writes .json to logs/sessions/
  ├─ log_session() → listener_started event
  ├─ get_local_ip() → show connect-back command with detected IP
  ├─ Build nc/ncat command (+ rlwrap if requested)
  ├─ eval "$cmd"           ← blocking — waits for connection
  ├─ log_session() → listener_ended event
  └─ Prompt: "Add a note to this session? [y/n]"
       └─ add_session_note() → appends to logs/sessions/<id>.notes
```

## Data Flow: Session Notes

```
Notes are stored in: logs/sessions/<session_id>.notes
One timestamped line per note.

Access points:
  1. Automatically prompted after a reverse listener session ends
  2. Listeners menu → 5 (Session Notes) → session_notes_menu()
       └─ Lists all session .json files → pick one → Add / View
```

---

## Certificate Storage

Certificates generated by `modules/encrypt.sh` are stored in `CERTS_DIR` (`certs/`):

```
certs/
├── bind.key    – RSA private key
├── bind.crt    – self-signed certificate
└── bind.pem    – combined key+cert for socat
```

The `certs/` directory is git-ignored to prevent accidental key commits.

---

## Cross-Platform Notes

| Environment | Support |
|------------|---------|
| Linux (Debian, RHEL, Alpine) | Full support |
| macOS | Full support (`brew install socat rlwrap`) |
| Windows (Git Bash) | Supported — run via Git Bash, not PowerShell/CMD |
| Windows (WSL2) | Full support |

All scripts use LF line endings enforced via `.gitattributes` to prevent CRLF breakage on Windows.
