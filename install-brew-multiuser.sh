#!/usr/bin/env bash
# install-brew-multiuser
# One-shot installer & multi-user setup for Homebrew on macOS.
# Run without sudo; it escalates only when required.
set -euo pipefail
IFS=$'\n\t'

die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log()  { printf '==> %s\n' "$*"; }

ARCH=$(uname -m)
PREFIX=$([[ "$ARCH" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local")
export PREFIX
[[ -d "$PREFIX" ]] || mkdir -p "$PREFIX"

# Install Homebrew if missing
if [[ ! -x "$PREFIX/bin/brew" ]]; then
  log "Installing Homebrew…"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  log "Homebrew already installed at $PREFIX"
fi

# Group setup
GROUP="homebrew"
GID=8000

log "Creating group '$GROUP' (GID $GID)…"
if dscl . -read "/Groups/$GROUP" &>/dev/null; then
  EXIST_GID=$(dscl . -read "/Groups/$GROUP" gid | awk '{print $2}')
  [[ "$EXIST_GID" == "$GID" ]] || \
    die "Group '$GROUP' exists with GID $EXIST_GID (requested $GID)."
  log "   Group '$GROUP' already exists – skipping creation."
else
  if dscl . -list /Groups gid | awk '{print $2}' | grep -q "^${GID}$"; then
    die "GID $GID is already assigned – choose another."
  fi
  sudo dscl . create "/Groups/$GROUP"
  sudo dscl . -create "/Groups/$GROUP" RealName "Homebrew Group"
  sudo dscl . -create "/Groups/$GROUP" gid "$GID"
fi

# Add current user
USER=$(whoami)
log "Adding user '$USER' to group '$GROUP'…"
sudo dseditgroup -o edit -a "$USER" -t user "$GROUP"

# Fix ownership & permissions
log "Fixing ownership & permissions for $PREFIX…"
sudo chown -R root:"$GROUP" "$PREFIX"
sudo chmod -R g+rwX "$PREFIX"
sudo find "$PREFIX" -type d -exec chmod g+s {} +

# Shell profile
RC_FILE=""
case "$SHELL" in
  */bash*) RC_FILE="$HOME/.bash_profile" ;;
  */zsh*)  RC_FILE="$HOME/.zprofile" ;;
  *)       RC_FILE="$HOME/.profile" ;;
esac
grep -qxF "eval \"\$($PREFIX/bin/brew shellenv)\"" "$RC_FILE" 2>/dev/null || \
  echo "eval \"\$($PREFIX/bin/brew shellenv)\"" >> "$RC_FILE"

eval "$($PREFIX/bin/brew shellenv)"
log "✅ Installation complete. Open a new terminal or run 'newgrp $GROUP'."
