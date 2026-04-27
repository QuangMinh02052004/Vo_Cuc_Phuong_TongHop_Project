# Database Backups - Võ Cúc Phương

Bản backup gần nhất: **2026-04-27**

## Các file

| File | Database | Neon endpoint | Mô tả |
|------|----------|---------------|-------|
| `TongHop_backup_2026-04-27.sql` | TongHop | ep-autumn-sun | Đặt vé nội bộ, xe, tài xế, timeslot |
| `NhapHang_backup_2026-04-27.sql` | NhapHang | ep-dark-paper | Sản phẩm, kho, log, user, counter |
| `DatVe_backup_2026-04-27.sql` | DatVe | ep-holy-recipe | Đặt vé online (vocucphuong.vercel.app) |

## Restore

```bash
# Tạo DB mới rồi:
psql "postgresql://USER:PASS@HOST/DB" -f TongHop_backup_2026-04-27.sql
```

## Cách tạo backup mới

```bash
PG_DUMP=/opt/homebrew/opt/postgresql@17/bin/pg_dump
$PG_DUMP "$DATABASE_URL_TONGHOP" --no-owner --no-acl > TongHop_backup_$(date +%F).sql
$PG_DUMP "$DATABASE_URL_NHAPHANG" --no-owner --no-acl > NhapHang_backup_$(date +%F).sql
$PG_DUMP "$DATABASE_URL_DATVE" --no-owner --no-acl > DatVe_backup_$(date +%F).sql
```

DB URLs nằm trong `vocucphuong-internal/.env.local`.
