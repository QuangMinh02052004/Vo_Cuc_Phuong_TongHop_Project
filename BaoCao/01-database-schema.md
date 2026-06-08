# Thiết kế cơ sở dữ liệu — Hệ thống Võ Cúc Phương

Hệ thống chia 3 cơ sở dữ liệu độc lập trên Neon PostgreSQL, đồng bộ qua webhook + REST API.

| CSDL | Mục đích | Tên Neon project |
|---|---|---|
| **NhapHang DB** | Quản lý hàng hoá vận chuyển | ep-dark-paper |
| **TongHop DB** | Đặt vé tại quầy, điều phối xe | ep-autumn-sun |
| **DatVe DB** | Đặt vé online (khách hàng) | ep-holy-recipe |

---

## 1. NhapHang DB

### 1.1. Bảng `Products` — Đơn hàng vận chuyển

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| `id` | VARCHAR(20) | PRIMARY KEY | Mã đơn dạng `YYMMDD.SSNN` (SS = mã trạm nhận, NN = số thứ tự) |
| `senderName` | VARCHAR(200) | | Tên người gửi |
| `senderPhone` | VARCHAR(20) | | SĐT người gửi |
| `senderStation` | VARCHAR(100) | NOT NULL | Trạm gửi (dạng "01 - AN ĐÔNG") |
| `receiverName` | VARCHAR(200) | | Tên người nhận |
| `receiverPhone` | VARCHAR(20) | | SĐT người nhận |
| `station` | VARCHAR(100) | NOT NULL | Trạm nhận (dạng "01 - AN ĐÔNG" hoặc "00 - Dọc đường") |
| `productType` | VARCHAR(100) | | Loại hàng ("01 - Gói", "02 - Thùng", "06 - Kiện"...) |
| `quantity` | VARCHAR(50) | | Số lượng / mô tả số kiện |
| `vehicle` | VARCHAR(50) | | Biển số xe |
| `insurance` | DECIMAL(18,2) | DEFAULT 0 | Phí bảo hiểm |
| `totalAmount` | DECIMAL(18,2) | DEFAULT 0 | Tổng tiền cước |
| `deliveredAmount` | DECIMAL(18,2) | DEFAULT 0 | Tiền đã giao (thanh toán đầu nhận) |
| `paymentStatus` | VARCHAR(20) | | `paid` / `unpaid` |
| `status` | VARCHAR(20) | DEFAULT 'pending' | `pending` / `delivered` / `cancelled` |
| `deliveryStatus` | VARCHAR(20) | DEFAULT 'pending' | `pending` / `in_transit` / `delivered` |
| `employee` | VARCHAR(100) | | NV xử lý đơn |
| `createdBy` | VARCHAR(100) | | User tạo đơn |
| `notes` | TEXT | | Ghi chú (chứa `o2b:XXX` nếu sync từ O2BSoft) |
| `cancelNote` | TEXT | | Lý do huỷ |
| `sendDate` | TIMESTAMP | | Giờ gửi hàng (giờ VN, không timezone) |
| `syncedToTongHop` | BOOLEAN | DEFAULT false | Đã sync sang TongHop (chỉ áp dụng đơn dọc đường) |
| `tongHopBookingId` | INTEGER | | ID booking tương ứng trong TongHop |
| `createdAt` | TIMESTAMP | DEFAULT NOW() | |
| `updatedAt` | TIMESTAMP | DEFAULT NOW() | |

### 1.2. Bảng `ProductLogs` — Lịch sử thao tác đơn hàng

| Cột | Kiểu | Mô tả |
|---|---|---|
| `id` | SERIAL PK | |
| `productId` | VARCHAR(20) FK → Products.id | |
| `action` | VARCHAR(20) | `create` / `update` / `delete` / `cancel` |
| `field` | VARCHAR(100) | Tên trường thay đổi |
| `oldValue` | TEXT | |
| `newValue` | TEXT | |
| `changedBy` | VARCHAR(100) | |
| `ipAddress` | VARCHAR(50) | |
| `createdAt` | TIMESTAMP | DEFAULT NOW() |

### 1.3. Bảng `Stations` — Danh mục trạm

| Cột | Kiểu | Mô tả |
|---|---|---|
| `id` | SERIAL PK | |
| `code` | VARCHAR(10) UNIQUE | Mã 2 số (vd. `01`) |
| `name` | VARCHAR(100) | Tên trạm (vd. `AN ĐÔNG`) |
| `fullName` | VARCHAR(120) | Hiển thị (`01 - AN ĐÔNG`) |
| `address` | VARCHAR(500) | |
| `phone` | VARCHAR(20) | |
| `region` | VARCHAR(50) | `Sài Gòn` / `Long Khánh` |
| `isActive` | BOOLEAN | |

### 1.4. Bảng `Counters` — Sinh mã đơn atomic

| Cột | Kiểu | Mô tả |
|---|---|---|
| `counterKey` | VARCHAR(50) PK | `counter_{stationCode}_{dateKey}` (vd. `counter_01_070626`) |
| `station` | VARCHAR(10) | |
| `dateKey` | VARCHAR(10) | DDMMYY |
| `value` | INTEGER DEFAULT 1 | Số thứ tự hiện tại |
| `lastUpdated` | TIMESTAMP | |

### 1.5. Bảng `Users` — Tài khoản nhân viên NhapHang

| Cột | Kiểu | Mô tả |
|---|---|---|
| `id` | SERIAL PK | |
| `username` | VARCHAR(100) UNIQUE | |
| `password` | VARCHAR(255) | bcrypt hoặc plain (legacy, rehash khi login) |
| `role` | VARCHAR(20) | `admin` / `staff` |
| `fullName` | VARCHAR(200) | |
| `station` | VARCHAR(100) | Trạm gắn user (null = all) |
| `permissions` | JSONB | Mảng quyền chi tiết |
| `scope` | VARCHAR(20) | `own_station` / `all_stations` |
| `email` | VARCHAR(100) | |
| `phone` | VARCHAR(20) | |
| `active` | BOOLEAN | DEFAULT true |
| `createdAt` | TIMESTAMP | |

---

## 2. TongHop DB

### 2.1. Bảng `TH_Bookings` — Vé xe khách

| Cột | Kiểu | Mô tả |
|---|---|---|
| `id` | SERIAL PK | |
| `timeSlotId` | INTEGER FK → TH_TimeSlots(id) ON DELETE CASCADE | |
| `phone` | VARCHAR(20) | |
| `name` | VARCHAR(200) | |
| `gender` | VARCHAR(10) | |
| `nationality` | VARCHAR(100) | |
| `pickupMethod` | VARCHAR(50) | `Tại bến` / `Tận nơi` |
| `pickupAddress` | VARCHAR(500) | |
| `dropoffMethod` | VARCHAR(50) | |
| `dropoffAddress` | VARCHAR(500) | |
| `note` | TEXT | |
| `seatNumber` | INTEGER | 1..28 |
| `amount` | DECIMAL(18,2) | Tổng tiền vé |
| `paid` | DECIMAL(18,2) DEFAULT 0 | Đã thu |
| `deposit` | DECIMAL(18,2) | Cọc |
| `timeSlot` | VARCHAR(10) | HH:MM |
| `date` | VARCHAR(20) | DD-MM-YYYY |
| `route` | VARCHAR(100) | |
| `clientReqId` | TEXT UNIQUE | Idempotency key — chính là Products.id khi sync từ NhapHang |
| `callStatus` | VARCHAR(100) DEFAULT 'Chưa gọi' | `Chưa gọi` / `Đã gọi` / `Đã xác nhận` / `Hoãn` / `Khách huỷ` |
| `printed` | BOOLEAN DEFAULT false | Đã in vé chưa |
| `qrToken` | TEXT | Token QR cho khách quét |
| `scanStatus` | VARCHAR(20) | `pending` / `scanned` / `invalid` |
| `scannedAt` | TIMESTAMP | |
| `createdAt` | TIMESTAMP DEFAULT NOW() | |
| `updatedAt` | TIMESTAMP DEFAULT NOW() | |

### 2.2. Bảng `TH_TimeSlots` — Khung giờ chuyến đi

| Cột | Kiểu | Mô tả |
|---|---|---|
| `id` | SERIAL PK | |
| `time` | VARCHAR(10) | HH:MM |
| `date` | VARCHAR(20) | DD-MM-YYYY |
| `route` | VARCHAR(100) | |
| `type` | VARCHAR(50) | Loại xe (vd. `Xe 28G`) |
| `code` | VARCHAR(50) | Mã chuyến |
| `driver` | VARCHAR(100) | Tài xế |
| `phone` | VARCHAR(20) | SĐT tài xế |
| `vehiclePlate` | VARCHAR(50) | Biển số xe |

UNIQUE (date, time, route)

### 2.3. Bảng `TH_Routes` — Tuyến đường

| Cột | Kiểu | Mô tả |
|---|---|---|
| `id` | SERIAL PK | |
| `name` | VARCHAR(100) UNIQUE | vd. `Sài Gòn - Long Khánh (Quốc lộ)` |
| `fromStation` | VARCHAR(100) | |
| `toStation` | VARCHAR(100) | |
| `distance` | VARCHAR(50) | |
| `seats` | INTEGER DEFAULT 28 | Số ghế xe |
| `busType` | VARCHAR(50) DEFAULT 'Ghế ngồi' | |
| `operatingStart` | VARCHAR(10) DEFAULT '03:30' | Giờ chuyến đầu |
| `operatingEnd` | VARCHAR(10) DEFAULT '18:00' | Giờ chuyến cuối |
| `intervalMinutes` | INTEGER DEFAULT 30 | Khoảng cách chuyến |
| `isActive` | BOOLEAN DEFAULT true | |

### 2.4. Bảng `TH_SeatLocks` — Khoá ghế tạm khi đang chọn

| Cột | Kiểu | Mô tả |
|---|---|---|
| `id` | SERIAL PK | |
| `date` | VARCHAR(20) | |
| `time` | VARCHAR(10) | |
| `route` | VARCHAR(100) | |
| `seatNumber` | INTEGER | |
| `userId` | INTEGER | NV đang chọn |
| `expiresAt` | TIMESTAMP | TTL 10 phút |

UNIQUE (date, time, route, seatNumber)

### 2.5. Bảng `TH_Vehicles` — Danh sách xe

| Cột | Kiểu | Mô tả |
|---|---|---|
| `id` | SERIAL PK | |
| `code` | VARCHAR(50) | Mã loại xe (`28G`, `50F-01057`...) |
| `type` | VARCHAR(50) | Biển số chi tiết (`60B04669`) |

### 2.6. Bảng `TH_Drivers` — Tài xế

| Cột | Kiểu | Mô tả |
|---|---|---|
| `id` | SERIAL PK | |
| `name` | VARCHAR(200) | |
| `phone` | VARCHAR(20) | |
| `vehiclePlate` | VARCHAR(50) | Xe đang gắn |
| `active` | BOOLEAN | |

### 2.7. Bảng `TH_Users` — Tài khoản nhân viên TongHop

Cấu trúc giống `Users` của NhapHang, thêm `email`, `phone` (đã ALTER).

### 2.8. Bảng `TH_PickupStations` — Điểm đón / trả khách

| Cột | Kiểu | Mô tả |
|---|---|---|
| `id` | SERIAL PK | |
| `stt` | INTEGER | Số thứ tự |
| `stationName` | VARCHAR(200) | Tên điểm |
| `route` | VARCHAR(100) | Tuyến |
| `direction` | VARCHAR(20) | `pickup` / `dropoff` |
| `aliases` | TEXT[] | Viết tắt để auto-detect |

### 2.9. Bảng `TH_ActivityLog` — Nhật ký hệ thống

| Cột | Kiểu | Mô tả |
|---|---|---|
| `id` | SERIAL PK | |
| `userId` | INTEGER | |
| `action` | VARCHAR(50) | `create` / `update` / `delete` / `login` |
| `entityType` | VARCHAR(50) | `booking` / `timeslot` / `user` |
| `entityId` | VARCHAR(50) | |
| `description` | TEXT | |
| `ipAddress` | VARCHAR(50) | |
| `createdAt` | TIMESTAMP | |

---

## 3. DatVe DB (Đặt vé online cho khách hàng)

Dùng Prisma + NextAuth, các bảng chính:

### 3.1. `User` — Khách hàng + nhân viên + tài xế
Gồm: id, email, name, phone, password, role (`USER`/`STAFF`/`DRIVER`/`ADMIN`), vehiclePlate (cho DRIVER), createdAt.

### 3.2. `Route` — Tuyến online
Gồm: id, fromCity, toCity, price, duration, isActive.

### 3.3. `Bus` — Xe
Gồm: id, plate, model, seats.

### 3.4. `Schedule` — Lịch chạy
Gồm: id, routeId, busId, departureTime, arrivalTime, date, status.

### 3.5. `Booking` — Vé khách đặt online
Gồm: id, userId, scheduleId, seatNumber, status (`PENDING`/`CONFIRMED`/`CANCELLED`), totalPrice, qrCode, scanned, paymentMethod, createdAt.

### 3.6. `Payment` — Thanh toán
Gồm: id, bookingId, amount, method (`VNPAY`/`MOMO`/`CASH`), transactionId, status, createdAt.

### 3.7. `Setting` — Cấu hình chung
Gồm: key, value. Vd. `booking_enabled` để admin tắt/bật cho phép đặt vé.

### 3.8. `PartnerApiKey` — (đã gỡ trong v5.07)

---

## 4. Đồng bộ giữa 3 CSDL

| Luồng | Cơ chế |
|---|---|
| NhapHang → TongHop (đơn dọc đường) | POST `/products` fire-and-forget tạo `TH_Bookings` với `clientReqId = Products.id`. Idempotent qua UNIQUE constraint `clientReqId`. |
| Reconciliation NhapHang ↔ TongHop | Endpoint `GET /api/nhap-hang/reconcile-doc-duong` quét `Products.syncedToTongHop=false` và tạo bù. Chạy frontend polling 30s + Vercel Cron daily. |
| TongHop ↔ DatVe (Routes) | Webhook `/api/tong-hop/routes/by-datve/[id]` đồng bộ 2 chiều. |
| O2BSoft → NhapHang | Tampermonkey userscript scrape DOM bảng `Kho hàng` → POST `/products` với `notes: o2b:{maO2B}`. |
