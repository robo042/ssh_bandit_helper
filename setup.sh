#!/usr/bin/env bash

set -euo pipefail

confirm(){
    local prompt="Are you sure you want to $1 the ssh_bandit helper? (y/N)"
    read -p "$prompt" confirmation
    [[ $confirmation =~ ^[Yy]$ ]] || error_exit "${1^} cancelled."
}

error(){ echo -e "\n❌ $@" >&2 && return 0 ; } 

error_exit(){ error "$@"; exit 1; }

usage(){
    cat <<- ____EOF | sed -e 's/^    //';
    Usage: $0 [OPTION]

    Options:
      -i, --install       Install ssh_bandit
      -r, --remove        Uninstall ssh_bandit
      -f, --force         Bypass confirmation for uninstall
      -h, --help          Show this message
____EOF
    return 0
}

if [[ ${BASH_SOURCE[0]} == $0 ]]; then

    force=/bin/false install=/bin/false remove=/bin/false
    while [[ $# -gt 0 ]]; do case "$1" in
        -i|--install) install=/bin/true ;;
        -r|--remove)   remove=/bin/true ;;
        -f|--force )    force=/bin/true ;;
        -h|--help)        usage; exit 0 ;;
    esac; shift; done

    $install && $remove && error_exit "Can't have it both ways."
    $install || $remove ||{ usage; exit 1; }
    
    bin="${HOME}/.local/bin"
    etc="${HOME}/.local/etc/ssh_bandit"
    script_dir="$(cd -- $(dirname -- "${BASH_SOURCE[0]}") &>/dev/null && pwd)"

    pwfile="${etc}/passwords"
    src="${script_dir}/ssh_bandit"
    dest="${bin}/ssh_bandit"

    [[ -f $src ]] || error_exit "Missing script source: $src"

    if $install; then
        $force || confirm install
        echo '📦 Installing ssh_bandit...'
        mkdir -p "$bin" "$etc"
        cp "$src" "$dest"
        chmod +x "$dest"
        touch "$pwfile"
        echo "✅ Installed ssh_bandit to: $dest"
        echo "📁 Password file: $pwfile"
        if ! echo "$PATH" | grep -q "$bin"; then
            error "Warning: $bin is not in your PATH."
            echo  '    Add this to your ~/.profile or ~/.bashrc:'
            echo  "    export PATH=\"${bin}:\$PATH\""
        fi
        if ! command -v sshpass &>/dev/null; then
            error "'sshpass' is not installed. "
            echo -e \
                "You will need to install sshpass " \
                "(e.g. sudo apt install sshpass) for this tool to work"
        fi
        exit 0
    fi

    if $remove; then
        $force || confirm uninstall
        echo '🧹 Uninstalling ssh_bandit...'
        rm -f "$dest"
        echo "✅ Removed from: $dest"
        if [[ -f $pwfile ]]; then
            echo -e "\n⚠️ Password file remains: $pwfile"
            echo -e "\tremove manually if desired."
        fi
        if command -v sshpass &>/dev/null; then
            echo -e "\n⚠️ 'sshpass' is still installed; "
            echo -e "\tuninstall manually if desired."
        fi
        exit 0
    fi
fi
