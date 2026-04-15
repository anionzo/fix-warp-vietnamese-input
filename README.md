# 🇻🇳 Fix Warp Vietnamese Input

> Khắc phục lỗi gõ tiếng Việt (UniKey Telex/VNI) trên Warp Terminal

## ⚡ Vấn đề

Warp Terminal xử lý IME (Input Method Editor) chưa tốt, có thể gây các lỗi:

- ❌ **Chữ bị lặp/dính**: `xin chào` → `xxin cchhaaof`
- ❌ **Không nhận dấu/thanh**: `xin chào bạn` → `xin ch b hf c`
- ❌ **Ký tự bị nuốt hoặc nhân đôi**
- ❌ **Pre-edit text hiển thị sai**

---

## 🚀 Cài đặt nhanh

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/anionzo/fix-warp-vietnamese-input/master/install.sh | bash
```

### Windows (Git Bash)

```bash
curl -fsSL https://raw.githubusercontent.com/anionzo/fix-warp-vietnamese-input/master/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/anionzo/fix-warp-vietnamese-input/master/install.sh | bash
```

> Nếu PowerShell báo không có `bash`, hãy dùng **Git Bash** rồi chạy lệnh ở trên.

### Cài thủ công

```bash
git clone https://github.com/anionzo/fix-warp-vietnamese-input.git
cd fix-warp-vietnamese-input
bash fix-warp-vn.sh
```

---

## 🔧 Tool này làm gì?

1. **Backup** cấu hình hiện tại
2. **Patch Warp settings** để giảm xung đột IME
3. **Thiết lập environment variables** cho input method
4. **Inject shell profile** (`.bashrc` / `.zshrc`) với workaround
5. **In hướng dẫn cấu hình UniKey** tối ưu cho Windows

---

## ✅ Sau khi cài

1. Đóng hoàn toàn Warp (không chỉ đóng tab)
2. Mở lại Warp
3. Chạy:

```bash
vn-status
vn-test
```

---

## 📋 Yêu cầu

- [Warp Terminal](https://www.warp.dev/) đã cài
- Bộ gõ tiếng Việt: UniKey / EVKey / GoTiengViet
- Bash shell (Git Bash trên Windows)

---

## 🔄 Gỡ cài đặt

```bash
bash uninstall.sh
```

Backup nằm tại:

```bash
~/.warp-vn-backup/
```

---

## 🛠️ Troubleshooting

### Vẫn lỗi sau khi chạy script?

1. **Windows + UniKey**: bật `Mở rộng → ☑ Sử dụng clipboard để gõ`
2. Restart hoàn toàn Warp
3. Chạy `vn-status` để kiểm tra trạng thái
4. Chạy `vn-test` để test trực tiếp

### Lệnh hữu ích

| Lệnh | Mô tả |
|------|------|
| `vn-test` | Test gõ tiếng Việt interactive |
| `vn-status` | Xem trạng thái IME & fix |

---

## 💡 Mẹo cho Windows + UniKey

- Bảng mã: **Unicode**
- Kiểu gõ: **Telex**
- Nên bật:
  - `Cho phép gõ tự do`
  - `Tự động khôi phục phím không dấu`
  - `Bỏ dấu kiểu mới`
  - `Sử dụng clipboard để gõ` (nếu vẫn lỗi)

---

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón! Tạo Issue hoặc Pull Request tại:

- https://github.com/anionzo/fix-warp-vietnamese-input

## 📝 License

MIT License
