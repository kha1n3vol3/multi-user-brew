# Homebrew Multi-User Setup

Two small scripts make Homebrew safe for **multiple users** on macOS.

| Script                 | Purpose                                      |
|------------------------|----------------------------------------------|
| `install-brew-multiuser` | First-time install and group setup           |
| `repair-brew`            | Repair permissions after Time-Machine restore, `sudo brew …`, etc. |

## Quick start

### 1. Install & configure (admin once)
```bash
curl -fsSL https://raw.githubusercontent.com/…/install-brew-multiuser > install-brew-multiuser
chmod +x install-brew-multiuser
./install-brew-multiuser        # needs sudo for chown/chmod
```

### 2. Add extra users to the group
```bash
sudo dseditgroup -o edit -a alice -t user homebrew
```

### 3. Repair anytime things break
```bash
curl -fsSL https://raw.githubusercontent.com/…/repair-brew > repair-brew
chmod +x repair-brew
sudo ./repair-brew
```

## How it works

* **Group**: `homebrew` (GID 8000)  
* **Ownership**: `root:homebrew` – root owns, group can write.  
* **Permissions**: `g+rwx` on files, `g+ws` on directories (set-gid keeps new files in group).  

After running either script, **log out/in or `newgrp homebrew`** so your shell picks up the new group list.
