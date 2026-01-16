# Migration Plan: SQL Server → PostgreSQL

## Backup Location
- **Folder:** `/BACKUP_SQL_SERVER/`
- **Nhập Hàng:** `/BACKUP_SQL_SERVER/NhapHang/`
- **Tổng Hợp:** `/BACKUP_SQL_SERVER/TongHop/`

---

## Database Structure

### NHẬP HÀNG (4 tables)
1. **Users** - Người dùng hệ thống nhập hàng
2. **Stations** - Các trạm gửi/nhận hàng
3. **Products** - Hàng hóa được vận chuyển
4. **Counters** - Bộ đếm cho mã hàng

### TỔNG HỢP (6+ tables)
1. **Users** - Người dùng hệ thống
2. **Customers** - Khách hàng
3. **Stations** - Các trạm
4. **TimeSlots** - Khung giờ xe chạy
5. **Bookings** - Đặt vé
6. **Freight** - Hàng hóa

---

## Migration Steps

### Step 1: Tạo tables trong PostgreSQL (Neon)
- Sử dụng cùng database với vocucphuong.vercel.app
- Prefix tables để phân biệt: `nh_` cho nhập hàng, `th_` cho tổng hợp

### Step 2: Migrate backend code
- Thay `mssql` package bằng `pg` package
- Chuyển syntax SQL Server → PostgreSQL
- Update connection string

### Step 3: Deploy
- Nhập hàng + Tổng hợp → Render/Railway (free tier)
- Hoặc gộp vào vocucphuong.vercel.app dưới dạng API routes

---

## Files cần sửa

### Nhập Hàng
- `backend/config/database.js` → PostgreSQL connection
- `backend/routes/*.js` → Update SQL syntax
- `backend/server.js` → Update middleware

### Tổng Hợp
- `quan-ly-xe-khach-backend/config/database.js`
- `quan-ly-xe-khach-backend/routes/*.js`
- `quan-ly-xe-khach-backend/server.js`

---

## Notes
- Backup được tạo ngày: 15-01-2026
- Original database: SQL Server (local)
- Target database: Neon PostgreSQL (cloud)
