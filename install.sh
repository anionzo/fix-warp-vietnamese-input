#!/usr/bin/env bash
# One-liner installer for fix-warp-vietnamese-input
set -euo pipefail

REPO_URL="https://github.com/YOUR_USERNAME/fix-warp-vietnamese-input"
INSTALL_DIR="$HOME/.fix-warp-vn"

echo ""
echo "=== Installing Fix Warp Vietnamese Input ==="
echo ""

# Clone or update
if [ -d "$INSTALL_DIR" ]; then
    echo "[INFO] Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull --ff-only 2>/dev/null || {
        echo "[WARN] Could not update, reinstalling..."
        cd "$HOME"
        rm -rf "$INSTALL_DIR"
        git clone "$REPO_URL" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    }
else
    echo "[INFO] Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Run the fix script
echo "[INFO] Running fix script..."
bash fix-warp-vn.sh

echo ""
echo "[OK] Installation complete!"
echo "     Installed to: $INSTALL_DIR"
echo ""
