# ssh_bandit_helper

This is a tiny Bash utility for working through the [OverTheWire: Bandit](https://overthewire.org/wargames/bandit/) wargame. It wraps `sshpass` or SSH keys to log in to each Bandit level with minimal effort — assuming you've already retrieved the password and saved it locally.

It’s designed for shell learners, sysadmin trainees, or anyone working through Bandit who wants to automate the boring bits while still solving the puzzles themselves.

## 🔧 Features

- One command to connect to any Bandit level
- Uses `sshpass` (or a private key file, if provided)
- Passwords stored locally in a flat file (`~/.local/etc/ssh_bandit/passwords`)
- Installer script creates everything under `~/.local` — no sudo required
- Won’t touch your `PATH`, but will warn you if `~/.local/bin` isn’t in it

## 🧪 Dependencies
- bash
- ssh
- sshpass

## 🚀 Installation

First, install sshpass with:
```bash
sudo apt install sshpass
```
Then install the ssh bandit helper with:
```bash
./setup.sh --install
```

You’ll get:

- `~/.local/bin/ssh_bandit` (the actual helper script)
- `~/.local/etc/ssh_bandit/passwords` (the password store)

Make sure `~/.local/bin` is in your $PATH. If not, add this to your shell config:
```bash
export PATH="$HOME/.local/bin:$PATH"
```
## 🧼 Uninstall
```bash
./setup.sh --remove
```
Use `--force` to skip confirmation.  

## 🗝️ How to Use
Once installed:
```bash
ssh_bandit 12
```
This looks up the password for Bandit level 12 (i.e., the 13th line in your `~/.local/etc/ssh_bandit/passwords` file), and uses `sshpass` to log in.  You can also pass additional arguments to SSH:
```bash
ssh_bandit 14 -t 'bash -l'
```
If you have a private key instead of a password, just put the path to the key (e.g. `~/.ssh/id_rsa`) on that line in the password file — the script will detect it and use `ssh -i`.
## 📁 Password File Format
This is just a plain-text file, line-by-line:
- Line 1 = password for level 0
- Line 2 = password for level 1
- Line 3 = password for level 2
- etc...
The script will grab line `N + 1` for level `N`. If you're unsure what to put there, just play Bandit the normal way and copy/paste each password into the file as you go.

## ⚠️ Caveats
- This doesn't solve anything for you. It just saves you typing ssh and pasting passwords.
- It’s dumb-simple on purpose
- No encryption — this is a local dev helper for a game, **not** a secure password vault.

## TODO
- need to make it easier to update the password file
- for now you can add `export secret_bandit_passwords=~/.local/etc/ssh_bandit/passwords` to your `~/.bashrc`
- this allows you to update the file like `vi $secret_bandit_passwords`
