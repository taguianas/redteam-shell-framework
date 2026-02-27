# Architecture & Design

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   RED TEAM SHELL FRAMEWORK                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────┐                                          │
│  │  shellmaster.sh│ (Main CLI Orchestrator)                  │
│  └────────┬───────┘                                          │
│           │                                                   │
│  ┌────────┴──────────────────────────────────────┐          │
│  │         Module System (Pluggable)              │          │
│  ├──────────────────────────────────────────────┤          │
│  │ ┌─────────────┐ ┌──────────────┐             │          │
│  │ │ Listeners   │ │ Shells       │             │          │
│  │ │ (bind/rev)  │ │ (generators) │             │          │
│  │ └─────────────┘ └──────────────┘             │          │
│  │ ┌─────────────┐ ┌──────────────┐             │          │
│  │ │ Encryption  │ │ Transfers    │             │          │
│  │ │ (TLS/SSL)   │ │ (up/down)    │             │          │
│  │ └─────────────┘ └──────────────┘             │          │
│  │ ┌─────────────┐ ┌──────────────┐             │          │
│  │ │ Relay       │ │ Upgrade      │             │          │
│  │ │ (pivot)     │ │ (PTY)        │             │          │
│  │ └─────────────┘ └──────────────┘             │          │
│  └──────────────────────────────────────────────┘          │
│           │                                                   │
│  ┌────────┴──────────────────────────────────────┐          │
│  │         Core Infrastructure                    │          │
│  ├──────────────────────────────────────────────┤          │
│  │ ┌──────────────────────────────────────────┐ │          │
│  │ │  config.sh - Configuration & Setup      │ │          │
│  │ │  utils.sh  - Utilities & Logging        │ │          │
│  │ │  logger.sh - Session Audit Trails       │ │          │
│  │ └──────────────────────────────────────────┘ │          │
│  └──────────────────────────────────────────────┘          │
│           │                                                   │
│  ┌────────┴──────────────────────────────────────┐          │
│  │      Storage & Logging                        │          │
│  ├──────────────────────────────────────────────┤          │
│  │ ┌──────────────┐ ┌──────────────┐           │          │
│  │ │ logs/        │ │ payloads/    │           │          │
│  │ │ (JSON logs)  │ │ (generated)  │           │          │
│  │ └──────────────┘ └──────────────┘           │          │
│  │ ┌──────────────┐ ┌──────────────┐           │          │
│  │ │ certs/       │ │ sessions/    │           │          │
│  │ │ (keys/certs) │ │ (tracking)   │           │          │
│  │ └──────────────┘ └──────────────┘           │          │
│  └──────────────────────────────────────────────┘          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow: Reverse Shell Connection

```
1. User starts shellmaster.sh
   ↓
2. Selects "Listeners" → "Reverse Listener"
   ↓
3. Framework creates session:
   - Generates unique session_id
   - Creates ${SESSION_DIR}/${session_id}.json
   - Logs initial event
   ↓
4. Starts nc listener with optional rlwrap:
   - rlwrap provides command history
   - Each command logged to session.log
   ↓
5. Target connects with reverse shell payload
   ↓
6. Session active - all input/output logged in JSON
   ↓
7. Connection closes - session marked inactive
   ↓
8. Audit trail complete in:
   - ${SESSION_DIR}/${session_id}.json (metadata)
   - ${SESSION_DIR}/${session_id}.log (events)
   - ${LOG_FILE} (framework.log)
```

## Configuration System

### config.sh - Global Variables

```bash
# Framework identification
VERSION="0.1.0"
FRAMEWORK_NAME="Red Team Shell Framework"

# Directory paths
FRAMEWORK_DIR=<root>
CORE_DIR, MODULES_DIR, LOGS_DIR, CERTS_DIR, PAYLOADS_DIR

# Logging
LOG_FILE="logs/framework.log"
LOG_LEVEL="INFO" (DEBUG|INFO|WARN|ERROR)
LOG_FORMAT="json"

# Sessions
SESSION_DIR="logs/sessions"
SESSION_PREFIX="shell_"
SESSION_TIMEOUT=3600

# Encryption
DEFAULT_CIPHER="aes-256-cbc"
KEY_SIZE=2048
CERT_VALIDITY=365

# Transfers
TRANSFER_CHUNK_SIZE=1048576 (1MB)
TRANSFER_TIMEOUT=300

# CLI
CLI_COLORS=true
CLI_SPINNER=true
```

### .env - Local Overrides

Create `.env` in framework root to override config:
```bash
LOG_LEVEL=DEBUG
CLI_COLORS=false
TRANSFER_TIMEOUT=600
```

## Logging System

### Framework Logs (logs/framework.log)

JSON format, one entry per line:
```json
{"timestamp":"2026-02-25T01:00:00Z","level":"INFO","message":"Framework started","user":"pentester","pid":12345}
{"timestamp":"2026-02-25T01:01:15Z","level":"INFO","message":"Created session: shell_1234567_890","user":"pentester","pid":12345}
```

### Session Metadata (logs/sessions/shell_*.json)

```json
{
  "session_id": "shell_1234567_890",
  "created_at": "2026-02-25T01:01:15Z",
  "local_ip": "0.0.0.0",
  "local_port": 4444,
  "remote_ip": "192.168.1.100",
  "remote_port": 54321,
  "status": "active",
  "user": "pentester"
}
```

### Session Events (logs/sessions/shell_*.log)

```json
{"timestamp":"2026-02-25T01:01:20Z","session_id":"shell_1234567_890","event":"listener_started","data":"Reverse listener on port 4444","user":"pentester"}
{"timestamp":"2026-02-25T01:02:00Z","session_id":"shell_1234567_890","event":"connection_received","data":"192.168.1.100:54321","user":"pentester"}
{"timestamp":"2026-02-25T01:05:00Z","session_id":"shell_1234567_890","event":"listener_ended","data":"Connection closed","user":"pentester"}
```

## Module Interface

All modules follow this pattern:

```bash
#!/bin/bash
# Module name and description

# Main menu function
module_menu() {
    while true; do
        # Display menu
        # Read user choice
        # Call appropriate functions
    done
}

# Feature functions
feature_1() { ... }
feature_2() { ... }
```

## Session Management

### Session ID Format
```
shell_<TIMESTAMP>_<RANDOM>

Example: shell_1708867275_28340
```

### Session Lifecycle
1. **Created** - generate_session_id() creates metadata JSON
2. **Active** - Events logged during connection
3. **Closed** - Listener ends, session marked inactive
4. **Archived** - Old sessions can be archived with archive_session()

### Session Tracking
```bash
# Create new session
session_id=$(generate_session_id)
create_session "$session_id" "0.0.0.0" "4444" "192.168.1.100" "54321"

# Log events during session
log_session "$session_id" "event_type" "event_data"

# List active sessions
list_sessions

# Archive old session
archive_session "$session_id"
```

## Utility Functions

### Color Functions
- `color_red()` - Red text
- `color_green()` - Green text
- `color_yellow()` - Yellow text
- `color_cyan()` - Cyan text
- `color_blue()` - Blue text

### Message Functions
- `success_msg()` - Green ✓ prefix
- `error_msg()` - Red ✗ prefix
- `warn_msg()` - Yellow ⚠ prefix
- `info_msg()` - Cyan ℹ prefix

### Logging Functions
- `log_debug()` - DEBUG level
- `log_info()` - INFO level
- `log_warn()` - WARN level
- `log_error()` - ERROR level

### Validation Functions
- `validate_ip()` - Check IP format
- `validate_port()` - Check port range
- `ensure_file()` - Create if missing
- `ensure_dir()` - Create if missing

## Error Handling

All scripts use `set -euo pipefail` for safety:
- `-e` - Exit on error
- `-u` - Fail on undefined variables
- `-o pipefail` - Catch pipe errors

Error handling functions:
- `handle_error()` - Log and report
- `trap_error()` - Signal handler

## Cross-Platform Support

### Linux/macOS
- ✅ bash 4.0+
- ✅ nc/ncat
- ✅ socat
- ✅ openssl

### Windows (WSL2/Git Bash)
- ✅ bash 5.1+ (Windows Subsystem for Linux)
- ✅ nc/ncat via WSL package manager
- ⚠️ PowerShell payloads for native Windows

### Compatibility Notes
- Use `/bin/bash` explicitly in shebangs
- Test path assumptions on each platform
- Use portable commands (avoid GNU-specific flags)

## Security Model

### Session Confidentiality
- JSON logging contains metadata only (IPs/ports)
- Command history via rlwrap stored in ~/.shell_history
- Optional encryption via socat/ncat TLS

### Session Integrity
- Audit log timestamp validation
- PID tracking for process verification
- User attribution for all actions

### Session Authentication
- User identification via $USER/$SUDO_USER
- Optional token-based access (Phase 7)
- Role-based access control (Phase 7)

### Threat Model
| Threat | Mitigation | Phase |
|--------|-----------|-------|
| Unauthorized access | Log all actions | 1 ✓ |
| Network sniffing | Optional TLS | 3 |
| Log tampering | Append-only logs | 1 ✓ |
| Plaintext auth | Token system | 7 |
| Privilege escalation | RBAC | 7 |
