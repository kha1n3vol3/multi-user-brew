#!/usr/bin/env bash
# repair-brew – one-command, idempotent fix for multi-user Homebrew
set -euo pipefail

ARCH=$(uname -m)
PREFIX=$([[ "$ARCH" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local")

echo "==> Repairing $PREFIX"
sudo chown -R root:homebrew "$PREFIX"
sudo chmod -R g+rwX  "$PREFIX"
sudo find "$PREFIX" -type d -exec chmod g+s {} +

echo "✅ Done – any member of the 'homebrew' group can now use brew."
