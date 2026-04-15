# 🇻🇳 Fix Warp Vietnamese Input

Khắc phục lỗi gõ tiếng Việt (đặc biệt với UniKey Telex) trên Warp Terminal.

---

## ⚠️ Vấn đề thường gặp

Khi gõ tiếng Việt trong Warp, bạn có thể gặp:

- Chữ bị lặp/dính ký tự
- Không ăn dấu/thanh
- Ký tự bị nuốt hoặc hiển thị sai
- Cảm giác gõ Telex không ổn định

Ví dụ lỗi thực tế:

- `xin chào bạn hiền của tớ` → `xin ch b hf c`

---

## ✅ Tool này làm gì?

Script sẽ tự động:

1. Backup cấu hình hiện tại
2. Patch Warp settings để giảm xung đột IME
3. Inject cấu hình môi trường vào shell profile (`.bashrc` / `.zshrc`)
4. Tạo helper command để test nhanh:
   - `vn-test`
   - `vn-status`
5. In hướng dẫn tối ưu UniKey trên Windows

---

## 📦 Cài đặt

### Cách 1: Chạy trực tiếp từ repo

```bash
git clone https://github.com/anionzo/fix-warp-vietnamese-input.git
cd fix-warp-vietnamese-input

# Recommended (mặc định): Native IME, không dùng clipboard
bash fix-warp-vn.sh --mode native
```

### Mode triển khai

```bash
# Tốt nhất (khuyến nghị): Native IME (không clipboard)
bash fix-warp-vn.sh --mode native

# Fallback khi native vẫn lỗi: UniKey clipboard mode
bash fix-warp-vn.sh --mode clipboard

# Xem help
bash fix-warp-vn.sh --help
```

### Cách 2: Dùng installer (macOS/Linux/Git Bash)

```bash
curl -fsSL https://raw.githubusercontent.com/anionzo/fix-warp-vietnamese-input/master/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/anionzo/fix-warp-vietnamese-input/master/install.sh | bash
```

> Nếu PowerShell báo không có `bash`, hãy dùng **Git Bash** và chạy lại lệnh installer.

---

## 🧪 Sau khi cài đặt (giải thích dễ hiểu)

Vì script có thêm cấu hình vào shell profile (`.bashrc` / `.zshrc`), bạn cần mở phiên shell mới để nhận thay đổi.

### Cách chuẩn nhất

1. **Đóng hẳn Warp** (thoát toàn bộ app, không chỉ đóng tab)
2. **Mở lại Warp**
3. Chạy lần lượt:

```bash
vn-status
vn-test
```

### 2 lệnh này để làm gì?

- `vn-status`: kiểm tra các biến môi trường/IME đã được nạp chưa
- `vn-test`: mở chế độ test nhập để bạn thử gõ tiếng Việt ngay trong terminal

### Nếu báo `command not found`?

Chạy 1 trong 2 lệnh sau rồi thử lại:

```bash
source ~/.bashrc
# hoặc
source ~/.zshrc
```

---

## 🪟 Khuyến nghị cho Windows (ưu tiên mode native)

### ✅ Ưu tiên tốt nhất: Native IME (không clipboard)

1. Vào `Windows Settings → Time & language → Language & region`
2. Add keyboard: **Vietnamese Telex** (native của Windows)
3. Trong Warp, đổi input bằng `Win + Space`
4. Nếu dùng UniKey song song: **không bật** `Sử dụng clipboard để gõ`

### 🧯 Fallback khi native vẫn lỗi

Chạy:

```bash
bash fix-warp-vn.sh --mode clipboard
```

Rồi bật trong UniKey:

- ✅ `Sử dụng clipboard để gõ`

> Tóm lại: **native trước, clipboard sau**.

---

## 🔄 Gỡ cài đặt

```bash
bash uninstall.sh
```

Script sẽ:

- Xóa block config đã inject trong shell profile
- Cho phép bạn chọn restore từ backup

Backup được lưu tại:

- `~/.warp-vn-backup/`

---

## 🧰 Yêu cầu

- Warp Terminal
- Bash shell
- Bộ gõ tiếng Việt (UniKey / EVKey / GoTiengViet)

---

## ❓ Troubleshooting nhanh

### Vẫn lỗi sau khi chạy script?

- Kiểm tra bạn đã **restart hẳn Warp** chưa
- Chạy `vn-status` để xem trạng thái env
- Nếu đang native mode mà vẫn lỗi, chuyển fallback:
  - `bash fix-warp-vn.sh --mode clipboard`
- Nếu đang clipboard mode, thử quay lại:
  - `bash fix-warp-vn.sh --mode native`
- Có thể chạy script nhiều lần an toàn (idempotent, không inject trùng block)

---

## 🤝 Đóng góp

Welcome PR/Issue.

Repo: https://github.com/anionzo/fix-warp-vietnamese-input

OpenCode note: xem thêm `OPENCODE.md`

---

## 📝 License

MIT
