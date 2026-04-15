# 🇻🇳 Fix Warp Vietnamese Input

> Khắc phục lỗi gõ tiếng Việt (UniKey Telex/VNI) trên Warp Terminal

## ⚡ Vấn đề

Warp Terminal xử lý IME (Input Method Editor) không tốt, gây ra các lỗi khi gõ tiếng Việt:

- ❌ **Chữ bị lặp/dính**: `xin chào` → `xxin cchhaaof`
- ❌ **Không nhận dấu/thanh**: `xin chào bạn` → `xin ch b hf c`
- ❌ **Ký tự bị nuốt hoặc nhân đôi**
- ❌ **Pre-edit text không hiển thị đúng**

## 🚀 Cài đặt nhanh

### Trên macOS/Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/fix-warp-vietnamese-input/main/install.sh | bash
```

### Thủ công:
```bash
git clone https://github.com/YOUR_USERNAME/fix-warp-vietnamese-input.git
cd fix-warp-vietnamese-input
chmod +x fix-warp-vn.sh
./fix-warp-vn.sh
```

### Trên Windows (Git Bash / WSL):
```bash
git clone https://github.com/YOUR_USERNAME/fix-warp-vietnamese-input.git
cd fix-warp-vietnamese-input
bash fix-warp-vn.sh
```

## 🔧 Tool này làm gì?

1. **Backup** cấu hình Warp hiện tại
2. **Patch Warp settings** để tương thích với IME
3. **Thiết lập environment variables** cần thiết cho input method
4. **Cấu hình shell profile** (`.bashrc` / `.zshrc`) với các workaround
5. **Hướng dẫn cấu hình UniKey** tối ưu cho Warp

## 📋 Yêu cầu

- [Warp Terminal](https://www.warp.dev/) đã cài đặt
- Bộ gõ tiếng Việt: UniKey, EVKey, hoặc GoTiengViet
- Bash hoặc Zsh shell

## 🔄 Gỡ cài đặt

```bash
./uninstall.sh
```

Hoặc khôi phục backup thủ công từ thư mục `~/.warp-vn-backup/`

## 🛠️ Troubleshooting

### Vẫn bị lỗi sau khi chạy script?

1. **Windows + UniKey**: Mở UniKey → Mở rộng → ☑ **Sử dụng clipboard để gõ**
2. **Restart hoàn toàn** Warp (đóng tất cả cửa sổ, không chỉ tab)
3. Chạy `vn-status` để kiểm tra trạng thái
4. Chạy `vn-test` để test gõ tiếng Việt

### Lệnh hữu ích sau khi cài:

| Lệnh | Mô tả |
|-------|--------|
| `vn-test` | Test gõ tiếng Việt interactive |
| `vn-status` | Xem trạng thái IME & fix |

## 💡 Mẹo sử dụng

- Nên dùng **UniKey** với chế độ gõ **Telex**
- Bật chế độ **"Sử dụng clipboard để gõ"** trong UniKey nếu vẫn còn lỗi
- Restart Warp sau khi chạy script

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón! Hãy tạo Issue hoặc Pull Request.

## 📝 License

MIT License
