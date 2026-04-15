# OPENCODE Notes

Hướng dẫn nhanh khi chạy project này trong môi trường OpenCode/agent.

## Run nhanh

```bash
# Recommended: native IME (no clipboard)
bash fix-warp-vn.sh --mode native
```

Fallback nếu native vẫn lỗi:

```bash
bash fix-warp-vn.sh --mode clipboard
```

Sau đó:

```bash
vn-status
vn-test
```

Nếu chưa nhận lệnh:

```bash
source ~/.bashrc
# hoặc
source ~/.zshrc
```

## Luồng verify chuẩn

1. Chạy script (ưu tiên): `bash fix-warp-vn.sh --mode native`
2. Đóng hoàn toàn Warp, mở lại
3. Kiểm tra `vn-status`
4. Test gõ bằng `vn-test`
5. Nếu vẫn lỗi: `bash fix-warp-vn.sh --mode clipboard`

## Uninstall

```bash
bash uninstall.sh
```

## Ghi chú

- Script là idempotent: chạy lại không nhân đôi block config
- Backup ở: `~/.warp-vn-backup/`
