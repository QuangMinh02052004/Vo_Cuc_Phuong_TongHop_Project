# Tài liệu thiết kế — Hệ thống Võ Cúc Phương

Bộ tài liệu kèm theo đồ án tốt nghiệp.

| File | Nội dung |
|---|---|
| [01-database-schema.md](01-database-schema.md) | Schema chi tiết 3 CSDL (NhapHang / TongHop / DatVe): bảng, cột, kiểu dữ liệu, ràng buộc |
| [02-erd.md](02-erd.md) | Sơ đồ thực thể quan hệ ERD (Mermaid) cho từng CSDL + sơ đồ tổng thể đồng bộ liên CSDL |
| [03-use-case.md](03-use-case.md) | Mô hình Use Case: actors, sơ đồ tổng, mô tả luồng chi tiết, ma trận phân quyền |
| [04-sequence-diagrams.md](04-sequence-diagrams.md) | Sơ đồ tuần tự (Sequence/RD) cho 7 luồng nghiệp vụ chính |

## Cách xem & xuất ra hình

Các sơ đồ dùng cú pháp **Mermaid**, có 3 cách dùng:

1. **Xem trực tiếp trên GitHub** — push file lên repo, GitHub tự render Mermaid trong Markdown viewer.
2. **Mermaid Live Editor** — copy block ` ```mermaid ... ``` ` paste vào https://mermaid.live → click `Actions` → `Download PNG/SVG` → chèn vào Word.
3. **VS Code Extension** — cài "Markdown Preview Mermaid Support" → mở file `.md` → bấm Cmd+Shift+V để preview, export PNG.

## Lưu ý cho báo cáo Word

Khi paste sơ đồ vào file Word:
- Xuất từng diagram thành **PNG** (300 dpi) từ mermaid.live
- Đặt mỗi sơ đồ trong **Figure** có caption: `Hình 2.1 — Sơ đồ ERD CSDL NhapHang`
- Bảng schema giữ nguyên dạng table trong Word (dán từ Markdown qua copy 2 lần)

## Mã nguồn liên quan

- API server (Next.js): [`VoCucPhuong_PublicWeb/app/api/`](../VoCucPhuong_PublicWeb/app/api/)
- Quản lý vé TongHop (React): [`VoCucPhuong_TongHop/quan-ly-xe-khach/`](../VoCucPhuong_TongHop/quan-ly-xe-khach/)
- Đặt vé online (Next.js): [`VoCucPhuong_DatVe/`](../VoCucPhuong_DatVe/)
- App Flutter nội bộ: [`VoCucPhuong_FlutterApp/`](../VoCucPhuong_FlutterApp/)
- App Flutter khách hàng: [`VoCucPhuong_DatVeApp/`](../VoCucPhuong_DatVeApp/)
- Userscript O2BSoft sync: [`Auto_Update_Data/o2bsoft-to-nhaphang.user.js`](../Auto_Update_Data/o2bsoft-to-nhaphang.user.js)
