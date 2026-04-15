#!/usr/bin/env bash
set -euo pipefail

MODE="native"  # native | clipboard

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
    echo "     Khắc phục lỗi gõ tiếng Việt trên Warp"
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
    info "Hệ điều hành: ${BOLD}${OS}${NC}"
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
            error "Không hỗ trợ hệ điều hành này!"
            exit 1
            ;;
    esac
    info "Thư mục config Warp: ${BOLD}${WARP_CONFIG_DIR}${NC}"
}

BACKUP_DIR="$HOME/.warp-vn-backup/$(date +%Y%m%d_%H%M%S)"

backup_configs() {
    info "Đang backup cấu hình hiện tại..."
    mkdir -p "$BACKUP_DIR"
    if [ -d "$WARP_CONFIG_DIR" ]; then
        cp -r "$WARP_CONFIG_DIR" "$BACKUP_DIR/warp-config" 2>/dev/null || true
        success "Đã backup Warp config -> $BACKUP_DIR/warp-config"
    fi
    for profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile"; do
        if [ -f "$profile" ]; then
            cp "$profile" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    success "Đã backup shell profiles -> $BACKUP_DIR/"
    echo "$BACKUP_DIR" > "$HOME/.warp-vn-backup/latest"
}

patch_warp_settings() {
    info "Đang patch Warp settings..."
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
    success "Đã patch Warp settings"
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
        echo "=== Test gõ tiếng Việt trên Warp Terminal ==="
        echo ""
        echo "Hãy thử gõ các câu sau và so sánh:"
        echo "  Mẫu 1: Xin chào bạn!"
        echo "  Mẫu 2: Việt Nam đất nước tươi đẹp"
        echo "  Mẫu 3: Tôi đang sử dụng Warp Terminal"
        echo ""
        echo "Gõ thử vào đây (Enter khi xong, Ctrl+C để thoát):"
        echo ""
        while IFS= read -r -p "  > " line; do
            if [ -z "$line" ]; then break; fi
            echo "  Bạn đã gõ: $line"
        done
        echo ""
        echo "Nếu chữ hiển thị đúng → Fix thành công!"
        echo "Nếu vẫn lỗi → Thử các bước trong README troubleshooting"
    }

    vn-status() {
        echo ""
        echo "=== Trạng thái Vietnamese Input Fix ==="
        echo "  TERM_PROGRAM:    ${TERM_PROGRAM:-N/A}"
        echo "  GTK_IM_MODULE:   ${GTK_IM_MODULE:-N/A}"
        echo "  QT_IM_MODULE:    ${QT_IM_MODULE:-N/A}"
        echo "  XMODIFIERS:      ${XMODIFIERS:-N/A}"
        echo "  WARP_HONOR_PS1:  ${WARP_HONOR_PS1:-N/A}"
        echo "  Shell:           $SHELL"
        echo "  OS:              $(uname -s)"
        echo ""
        echo "  Bộ gõ tiếng Việt:"
        if command -v ibus-daemon &>/dev/null; then echo "    - IBus detected"; fi
        if command -v fcitx5 &>/dev/null; then echo "    - Fcitx5 detected"; fi
        if command -v fcitx &>/dev/null; then echo "    - Fcitx detected"; fi
        case "$(uname -s)" in
            Darwin*) echo "    macOS: Sử dụng bộ gõ hệ thống hoặc UniKey" ;;
            MINGW*|MSYS*|CYGWIN*) echo "    Windows: Sử dụng UniKey, EVKey, hoặc GoTiengViet" ;;
        esac
        echo ""
    }
fi
# <<< fix-warp-vietnamese-input <<<
ENVBLOCK
}

inject_shell_config() {
    info "Đang cấu hình shell profile..."

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
            info "Đã xóa block cũ trong $config"
        fi
        touch "$config"
        write_env_block "$config"
        success "Đã thêm fix vào ${BOLD}${config}${NC}"
    done
}

patch_warp_keybindings() {
    info "Đang kiểm tra Warp keybindings..."
    local keybindings_file="$WARP_SETTINGS_DIR/keybindings.yaml"
    if [ ! -f "$keybindings_file" ]; then
        echo "# Fix Warp Vietnamese Input - Keybindings" > "$keybindings_file"
        success "Đã tạo keybindings config"
    else
        info "Keybindings file đã tồn tại, giữ nguyên"
    fi
}

fix_macos_specific() {
    if [ "$OS" != "macos" ]; then return; fi
    info "Áp dụng fix cho macOS..."
    defaults write dev.warp.Warp-Stable ApplePressAndHoldEnabled -bool false 2>/dev/null || true
    success "Đã áp dụng macOS-specific fixes"
}

fix_windows_specific() {
    if [ "$OS" != "windows" ]; then return; fi
    info "Áp dụng fix cho Windows..."
    info "Chế độ hiện tại: ${BOLD}${MODE}${NC}"
    echo ""

    if [ "$MODE" = "native" ]; then
        echo -e "${CYAN}${BOLD}=== Khuyến nghị tốt nhất: Native IME (không clipboard) ===${NC}"
        echo ""
        echo "  1. Windows Settings → Time & language → Language & region"
        echo "  2. Add keyboard: Vietnamese Telex (native của Windows)"
        echo "  3. Trong Warp, chuyển input bằng Win+Space"
        echo "  4. Nếu dùng UniKey, KHÔNG bật 'Sử dụng clipboard để gõ'"
        echo "  5. Test lại: vn-test"
        echo ""
        echo "  Nếu vẫn lỗi, dùng fallback clipboard mode:"
        echo "    bash fix-warp-vn.sh --mode clipboard"
        echo ""
    else
        echo -e "${CYAN}${BOLD}=== Fallback: UniKey clipboard mode ===${NC}"
        echo ""
        echo "  1. Mở UniKey → Click chuột phải vào icon taskbar"
        echo "  2. Chọn Bảng điều khiển (Control Panel)"
        echo "  3. Chọn: Unicode + Telex"
        echo "  4. Mở rộng → ☑ Sử dụng clipboard để gõ"
        echo "  5. Đóng và restart Warp Terminal"
        echo ""
    fi

    success "Đã hiển thị hướng dẫn cho Windows"
}

verify_install() {
    echo ""
    echo -e "${GREEN}${BOLD}=== Cài đặt hoàn tất! ===${NC}"
    echo ""
    echo "  Backup: $BACKUP_DIR"
    echo ""
    echo "  Bước tiếp theo:"
    echo "  1. Đóng hoàn toàn Warp Terminal"
    echo "  2. Mở lại Warp Terminal"
    echo "  3. Gõ vn-test để kiểm tra tiếng Việt"
    echo "  4. Gõ vn-status để xem trạng thái fix"
    echo ""

    if [ "$OS" = "windows" ] && [ "$MODE" = "native" ]; then
        echo "  Khuyến nghị: ưu tiên Native IME (không clipboard)."
        echo "  Nếu vẫn lỗi: bash fix-warp-vn.sh --mode clipboard"
        echo ""
    elif [ "$OS" = "windows" ]; then
        echo "  Bạn đang dùng clipboard fallback mode."
        echo "  Đổi lại mode tốt hơn: bash fix-warp-vn.sh --mode native"
        echo ""
    fi

    echo "  Gỡ cài đặt: ./uninstall.sh"
    echo ""
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --mode)
                MODE="${2:-}"
                shift 2
                ;;
            --help|-h)
                cat << 'HELP'
Usage: bash fix-warp-vn.sh [--mode native|clipboard]

Modes:
  native     Recommended. Prefer Windows native Vietnamese IME (no clipboard).
  clipboard  Fallback mode for UniKey clipboard typing.
HELP
                exit 0
                ;;
            *)
                warn "Bỏ qua tham số không hợp lệ: $1"
                shift
                ;;
        esac
    done

    if [ "$MODE" != "native" ] && [ "$MODE" != "clipboard" ]; then
        error "--mode chỉ nhận: native | clipboard"
        exit 1
    fi
}

main() {
    parse_args "$@"
    banner
    detect_os
    get_warp_config_dir
    echo ""
    info "Bắt đầu fix Vietnamese input cho Warp Terminal..."
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
