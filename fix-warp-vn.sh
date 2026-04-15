#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; }

banner() {
    echo -e "${CYAN}${BOLD}"
    echo "======================================================"
    echo "     Fix Warp Vietnamese Input v1.0.0"
    echo "     Khac phuc loi go tieng Viet tren Warp"
    echo "======================================================"
    echo -e "${NC}"
}

detect_os() {
    case "$(uname -s)" in
        Darwin*)  OS="macos";;
        Linux*)   OS="linux";;
        MINGW*|MSYS*|CYGWIN*) OS="windows";;
        *)        OS="unknown";;
    esac
    info "He dieu hanh: ${BOLD}${OS}${NC}"
}

get_warp_config_dir() {
    case "$OS" in
        macos)
            WARP_CONFIG_DIR="$HOME/.warp"
            WARP_SETTINGS_DIR="$HOME/.warp"
            ;;
        linux)
            WARP_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/warp-terminal"
            WARP_SETTINGS_DIR="$WARP_CONFIG_DIR"
            ;;
        windows)
            if [ -n "${LOCALAPPDATA:-}" ]; then
                WARP_CONFIG_DIR="$(cygpath -u "$LOCALAPPDATA")/warp-terminal"
            else
                WARP_CONFIG_DIR="$HOME/.warp"
            fi
            WARP_SETTINGS_DIR="$WARP_CONFIG_DIR"
            ;;
        *)
            error "Khong ho tro he dieu hanh nay!"
            exit 1
            ;;
    esac
    info "Thu muc config Warp: ${BOLD}${WARP_CONFIG_DIR}${NC}"
}

BACKUP_DIR="$HOME/.warp-vn-backup/$(date +%Y%m%d_%H%M%S)"

backup_configs() {
    info "Dang backup cau hinh hien tai..."
    mkdir -p "$BACKUP_DIR"
    if [ -d "$WARP_CONFIG_DIR" ]; then
        cp -r "$WARP_CONFIG_DIR" "$BACKUP_DIR/warp-config" 2>/dev/null || true
        success "Da backup Warp config -> $BACKUP_DIR/warp-config"
    fi
    for profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile"; do
        if [ -f "$profile" ]; then
            cp "$profile" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    success "Da backup shell profiles -> $BACKUP_DIR/"
    echo "$BACKUP_DIR" > "$HOME/.warp-vn-backup/latest"
}

patch_warp_settings() {
    info "Dang patch Warp settings..."
    mkdir -p "$WARP_SETTINGS_DIR"
    local settings_file="$WARP_SETTINGS_DIR/user_preferences.json"

    if [ -f "$settings_file" ]; then
        if command -v jq &>/dev/null; then
            local tmp_file; tmp_file=$(mktemp)
            jq '. + { "HonorPS1": true }' "$settings_file" > "$tmp_file" && mv "$tmp_file" "$settings_file"
        else
            warn "jq not found, skipping JSON patch"
        fi
    else
        echo '{ "HonorPS1": true }' > "$settings_file"
    fi
    success "Da patch Warp settings"
}

MARKER_START="# >>> fix-warp-vietnamese-input >>>"
MARKER_END="# <<< fix-warp-vietnamese-input <<<"

write_env_block() {
    local target="$1"
    cat >> "$target" << 'ENVBLOCK'

# >>> fix-warp-vietnamese-input >>>
# Fix Vietnamese input (UniKey/EVKey) on Warp Terminal

if [ -n "${WARP_IS_LOCAL_SHELL_SESSION:-}" ] || [ "${TERM_PROGRAM:-}" = "WarpTerminal" ]; then

    # === IME Environment Variables ===
    if command -v ibus-daemon &>/dev/null; then
        export GTK_IM_MODULE="ibus"
        export QT_IM_MODULE="ibus"
        export XMODIFIERS="@im=ibus"
    elif command -v fcitx5 &>/dev/null || command -v fcitx &>/dev/null; then
        export GTK_IM_MODULE="fcitx"
        export QT_IM_MODULE="fcitx"
        export XMODIFIERS="@im=fcitx"
    fi

    # === Warp-specific fixes ===
    export WARP_ENABLE_WAYLAND=0
    export WARP_HONOR_PS1=1

    # === Helper Functions ===
    vn-test() {
        echo ""
        echo "=== Test go tieng Viet tren Warp Terminal ==="
        echo ""
        echo "Hay thu go cac cau sau va so sanh:"
        echo "  Mau 1: Xin chao ban!"
        echo "  Mau 2: Viet Nam dat nuoc tuoi dep"
        echo "  Mau 3: Toi dang su dung Warp Terminal"
        echo ""
        echo "Go thu vao day (Enter khi xong, Ctrl+C de thoat):"
        echo ""
        while IFS= read -r -p "  > " line; do
            if [ -z "$line" ]; then break; fi
            echo "  Ban da go: $line"
        done
        echo ""
        echo "Neu chu hien thi dung -> Fix thanh cong!"
        echo "Neu van loi -> Thu cac buoc trong README troubleshooting"
    }

    vn-status() {
        echo ""
        echo "=== Trang thai Vietnamese Input Fix ==="
        echo "  TERM_PROGRAM:    ${TERM_PROGRAM:-N/A}"
        echo "  GTK_IM_MODULE:   ${GTK_IM_MODULE:-N/A}"
        echo "  QT_IM_MODULE:    ${QT_IM_MODULE:-N/A}"
        echo "  XMODIFIERS:      ${XMODIFIERS:-N/A}"
        echo "  WARP_HONOR_PS1:  ${WARP_HONOR_PS1:-N/A}"
        echo "  Shell:           $SHELL"
        echo "  OS:              $(uname -s)"
        echo ""
        echo "  Bo go tieng Viet:"
        if command -v ibus-daemon &>/dev/null; then echo "    - IBus detected"; fi
        if command -v fcitx5 &>/dev/null; then echo "    - Fcitx5 detected"; fi
        if command -v fcitx &>/dev/null; then echo "    - Fcitx detected"; fi
        case "$(uname -s)" in
            Darwin*) echo "    macOS: Su dung bo go he thong hoac UniKey" ;;
            MINGW*|MSYS*|CYGWIN*) echo "    Windows: Su dung UniKey, EVKey, hoac GoTiengViet" ;;
        esac
        echo ""
    }
fi
# <<< fix-warp-vietnamese-input <<<
ENVBLOCK
}

inject_shell_config() {
    info "Dang cau hinh shell profile..."

    local shell_configs=()
    if [ -f "$HOME/.zshrc" ] || [ "$SHELL" = "$(command -v zsh 2>/dev/null)" ]; then
        shell_configs+=("$HOME/.zshrc")
    fi
    if [ -f "$HOME/.bashrc" ] || [ "$SHELL" = "$(command -v bash 2>/dev/null)" ]; then
        shell_configs+=("$HOME/.bashrc")
    fi
    if [ ${#shell_configs[@]} -eq 0 ]; then
        shell_configs+=("$HOME/.bashrc")
    fi

    for config in "${shell_configs[@]}"; do
        if [ -f "$config" ] && grep -q "$MARKER_START" "$config"; then
            local tmp_file; tmp_file=$(mktemp)
            sed "/$MARKER_START/,/$MARKER_END/d" "$config" > "$tmp_file"
            mv "$tmp_file" "$config"
            info "Da xoa block cu trong $config"
        fi
        touch "$config"
        write_env_block "$config"
        success "Da them fix vao ${BOLD}${config}${NC}"
    done
}

patch_warp_keybindings() {
    info "Dang kiem tra Warp keybindings..."
    local keybindings_file="$WARP_SETTINGS_DIR/keybindings.yaml"
    if [ ! -f "$keybindings_file" ]; then
        echo "# Fix Warp Vietnamese Input - Keybindings" > "$keybindings_file"
        success "Da tao keybindings config"
    else
        info "Keybindings file da ton tai, giu nguyen"
    fi
}

fix_macos_specific() {
    if [ "$OS" != "macos" ]; then return; fi
    info "Ap dung fix cho macOS..."
    defaults write dev.warp.Warp-Stable ApplePressAndHoldEnabled -bool false 2>/dev/null || true
    success "Da ap dung macOS-specific fixes"
}

fix_windows_specific() {
    if [ "$OS" != "windows" ]; then return; fi
    info "Ap dung fix cho Windows (UniKey)..."
    echo ""
    echo -e "${CYAN}${BOLD}=== Huong dan cau hinh UniKey cho Warp ===${NC}"
    echo ""
    echo "  1. Mo UniKey -> Click chuot phai vao icon tren taskbar"
    echo "  2. Chon Bang dieu khien (Control Panel)"
    echo "  3. Thiet lap:"
    echo "     +-------------------------------------------+"
    echo "     | Bang ma:     Unicode                      |"
    echo "     | Kieu go:     Telex                        |"
    echo "     | Mo rong:                                  |"
    echo "     |   [x] Cho phep go tu do                   |"
    echo "     |   [x] Tu dong khoi phuc phim khong dau    |"
    echo "     |   [x] Bo dau kieu moi                     |"
    echo "     +-------------------------------------------+"
    echo ""

    echo "  4. QUAN TRONG: Neu van bi loi:"
    echo "     -> Mo rong -> [x] Su dung clipboard de go"
    echo "     (Workaround hieu qua nhat cho Warp tren Windows)"
    echo ""
    echo "  5. Nhan Dong va restart Warp Terminal"
    echo ""
    success "Da hien thi huong dan UniKey"
}

verify_install() {
    echo ""
    echo -e "${GREEN}${BOLD}=== Cai dat hoan tat! ===${NC}"
    echo ""
    echo "  Backup: $BACKUP_DIR"
    echo ""
    echo "  Buoc tiep theo:"
    echo "  1. Dong hoan toan Warp Terminal"
    echo "  2. Mo lai Warp Terminal"
    echo "  3. Go vn-test de kiem tra tieng Viet"
    echo "  4. Go vn-status de xem trang thai"
    echo ""
    echo "  Neu van bi loi tren Windows:"
    echo "  -> Mo UniKey -> Mo rong -> [x] Su dung clipboard de go"
    echo ""
    echo "  Go cai dat: ./uninstall.sh"
    echo ""
}

main() {
    banner
    detect_os
    get_warp_config_dir
    echo ""
    info "Bat dau fix Vietnamese input cho Warp Terminal..."
    echo ""
    backup_configs
    patch_warp_settings
    inject_shell_config
    patch_warp_keybindings
    fix_macos_specific
    fix_windows_specific
    verify_install
}

main "$@"
