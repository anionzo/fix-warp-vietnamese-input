#!/usr/bin/env bash
# Uninstaller for fix-warp-vietnamese-input
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }

MARKER_START="# >>> fix-warp-vietnamese-input >>>"
MARKER_END="# <<< fix-warp-vietnamese-input <<<"

echo ""
echo "=== Uninstalling Fix Warp Vietnamese Input ==="
echo ""

# Remove env block from shell configs
for config in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile"; do
    if [ -f "$config" ] && grep -q "$MARKER_START" "$config"; then
        tmp_file=$(mktemp)
        sed "/$MARKER_START/,/$MARKER_END/d" "$config" > "$tmp_file"
        mv "$tmp_file" "$config"
        success "Da xoa fix block tu $config"
    fi
done

# Offer to restore backup
LATEST_BACKUP=""
if [ -f "$HOME/.warp-vn-backup/latest" ]; then
    LATEST_BACKUP=$(cat "$HOME/.warp-vn-backup/latest")
fi

if [ -n "$LATEST_BACKUP" ] && [ -d "$LATEST_BACKUP" ]; then
    echo ""
    info "Tim thay backup tai: $LATEST_BACKUP"
    read -r -p "Ban co muon khoi phuc backup? (y/N): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        # Restore shell profiles
        for profile in ".bashrc" ".zshrc" ".profile" ".bash_profile"; do
            if [ -f "$LATEST_BACKUP/$profile" ]; then
                cp "$LATEST_BACKUP/$profile" "$HOME/$profile"
                success "Da khoi phuc $profile"
            fi
        done

        # Restore Warp config
        if [ -d "$LATEST_BACKUP/warp-config" ]; then
            case "$(uname -s)" in
                Darwin*) WARP_DIR="$HOME/.warp" ;;
                Linux*) WARP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/warp-terminal" ;;
                MINGW*|MSYS*|CYGWIN*)
                    if [ -n "${LOCALAPPDATA:-}" ]; then
                        WARP_DIR="$(cygpath -u "$LOCALAPPDATA")/warp-terminal"
                    else
                        WARP_DIR="$HOME/.warp"
                    fi
                    ;;
            esac
            if [ -n "${WARP_DIR:-}" ]; then
                cp -r "$LATEST_BACKUP/warp-config/"* "$WARP_DIR/" 2>/dev/null || true
                success "Da khoi phuc Warp config"
            fi
        fi
    fi
fi

echo ""
success "Da go cai dat fix-warp-vietnamese-input!"
echo ""
echo "  Hay restart Warp Terminal de ap dung thay doi."
echo ""
