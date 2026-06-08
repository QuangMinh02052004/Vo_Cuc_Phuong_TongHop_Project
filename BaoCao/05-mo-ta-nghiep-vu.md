# Mô tả nghiệp vụ — Hệ thống Võ Cúc Phương

## 1. Giới thiệu doanh nghiệp

**Công ty TNHH Vận tải Võ Cúc Phương** là nhà xe khách hoạt động tại khu vực miền Đông Nam Bộ, chuyên kinh doanh 2 mảng nghiệp vụ chính:

- **Vận chuyển hành khách** — tuyến cố định Sài Gòn ↔ Long Khánh (Quốc lộ 1A) với loại xe 28 chỗ, tần suất 30 phút/chuyến, thời gian hoạt động 03:30 – 18:00.
- **Vận chuyển hàng hoá** — nhận/giao hàng tại các trạm dọc tuyến, hỗ trợ giao dọc đường (gửi kèm xe khách).

Mạng lưới gồm khoảng **25 trạm** ở 2 đầu tuyến (Sài Gòn: An Đông, Hàng Xanh, Suối Tiên...; Long Khánh: Trảng Bom, Dầu Giây, Xuân Lộc, Hưng Lộc...) và hơn **30 đầu xe** đang vận hành.

---

## 2. Hiện trạng trước khi áp dụng hệ thống

### 2.1. Khó khăn

| Vấn đề | Hậu quả |
|---|---|
| Bán vé thủ công bằng sổ giấy, gọi điện điều phối | NV ghi nhầm ghế, vé trùng chỗ, mất sổ |
| Nhân viên 2 trạm khó nắm tình hình của nhau | Khách hỏi "còn chỗ không?" — NV phải gọi sang trạm khác |
| Hàng hoá dọc đường ghi tay → mất, sai mã | Tài xế giao nhầm, khó truy vết |
| Doanh thu tính bằng máy tính bỏ túi cuối ngày | Sai số, không có báo cáo theo tuần/tháng |
| Khách muốn đặt vé phải gọi điện trực tiếp | Mất NV nghe máy, không đặt được ngoài giờ làm việc |
| Không kiểm soát được vé giả (in lại) | Tài xế nhận khách không có vé thật |

### 2.2. Yêu cầu cải tiến (do chủ doanh nghiệp đặt ra)

1. **Số hoá toàn bộ vé giấy** → vé điện tử có QR
2. **Đặt vé online** — khách tự đặt qua web/app, thanh toán VNPay/MoMo
3. **Đồng bộ giữa các trạm** — NV trạm A xem được tình hình trạm B realtime
4. **Quản lý hàng hoá** có sinh mã đơn theo trạm + ngày, audit log đầy đủ
5. **Tự động booking xe khi nhận hàng dọc đường** (vì hàng dọc đường thực chất đi cùng xe khách)
6. **Báo cáo doanh thu tự động** gửi email cuối ngày
7. **Kiểm soát vé qua QR** — tài xế quét trên điện thoại trước khi cho lên xe
8. **Phân quyền theo trạm + vai trò** — NV trạm chỉ thấy đơn của trạm mình

---

## 3. Các quy trình nghiệp vụ chính

### 3.1. Quy trình đặt vé tại quầy

```
Khách đến quầy
    ↓
NV mở app/web TongHop → chọn tuyến + ngày + chuyến
    ↓
Sơ đồ 28 ghế hiện ra (ghế đã đặt = xám, ghế trống = xanh)
    ↓
NV click ghế trống → hệ thống KHOÁ ghế 10 phút (tránh NV khác cùng chọn)
    ↓
Form nhập tên + SĐT + điểm đón + điểm trả + số tiền
    ↓
NV bấm Lưu → vé in ra giấy 92mm với QR code
    ↓
Khách trả tiền → NV ghi nhận "đã thanh toán"
    ↓
(Tuỳ chọn) NV gọi xác nhận trước giờ chạy 2h
```

**Quy tắc nghiệp vụ:**
- Mỗi ghế chỉ thuộc 1 booking trong cùng `(date, time, route)` — DB enforce qua UNIQUE constraint
- Vé chưa thanh toán vẫn được tạo (NV ghi `paid = 0`), cuối chuyến tài xế thu sau
- Vé huỷ KHÔNG xoá khỏi DB mà soft-delete (`status = 'cancelled'`) để giữ audit trail
- Khi sửa vé sau 2 phút từ lúc tạo, API trả 403 "Đã quá 2 phút" — chống NV sửa lén sau khi báo cáo

### 3.2. Quy trình đặt vé online (khách tự đặt)

```
Khách mở web https://vocucphuong.vercel.app hoặc app "VCP Đặt Vé"
    ↓
Chọn điểm đi + điểm đến + ngày → hệ thống hiện danh sách chuyến + giá
    ↓
Click chuyến muốn đi → SeatPicker hiện sơ đồ ghế (realtime, đồng bộ với quầy)
    ↓
Click ghế trống → hệ thống lock ghế 10 phút cho khách hoàn tất thanh toán
    ↓
Nhập tên + SĐT + email → chọn cổng thanh toán (VNPay / MoMo)
    ↓
Redirect cổng thanh toán → xác thực OTP → quay lại web
    ↓
Nếu OK: tạo Booking + sinh QR code + gửi qua SMS/Email
Nếu fail: giữ lock cho khách thử lại trong thời gian còn lại của TTL
    ↓
Khách lưu QR vào ảnh / chuyển vào Apple Wallet
```

**Quy tắc:**
- Khách KHÔNG cần đăng ký tài khoản — đặt được bằng SĐT
- Admin có thể tắt đặt vé online toàn cục qua trang `/admin/settings` (vd. khi lễ tết quá tải)
- Khách hủy vé trước 6h: hoàn 100%. Trong 6h: hoàn 50%. Trong 2h: không hoàn

### 3.3. Quy trình nhận hàng tại trạm

```
Khách mang hàng đến trạm
    ↓
NV kho mở app/web NhapHang → đăng nhập (NV chỉ thấy trạm mình)
    ↓
Form: trạm gửi (mặc định = trạm NV) + trạm nhận (dropdown) + tên/SĐT người gửi + người nhận
    ↓
Chọn loại hàng (Gói/Thùng/Kiện/Bao/Thùng xốp) + cân/đo + tính tiền cước
    ↓
Bấm Lưu → server gọi atomic upsert Counters → sinh mã đơn YYMMDD.SSNN
    ↓
In biên lai 92mm có mã + QR + thông tin gửi/nhận
    ↓
Khách giữ biên lai có mã đơn để tra cứu / báo người nhận
    ↓
* Nếu trạm nhận = "Dọc đường" → hệ thống tự tạo booking xe (xe khách sẽ thả hàng dọc đường khi đi qua)
```

**Quy tắc sinh mã:**
- Format: `YYMMDD.SSNN`
  - `YYMMDD` = ngày gửi (vd. `070626` = 07/06/2026)
  - `SS` = mã 2 số của trạm nhận (vd. `01` = An Đông)
  - `NN` = số thứ tự trong ngày + trạm (1, 2, 3, …)
- Atomic qua bảng `Counters` với `INSERT … ON CONFLICT DO UPDATE value = value + 1` — không bao giờ trùng mã kể cả khi 2 NV nhập cùng lúc

### 3.4. Quy trình giao hàng

```
Hàng từ trạm gửi → đi trên xe khách → đến trạm nhận
    ↓
NV trạm nhận quét QR / nhập mã đơn để xác nhận đã đến
    ↓
Hệ thống cập nhật deliveryStatus = 'delivered'
    ↓
Khách đến lấy hàng → trả tiền cước (nếu chưa thanh toán đầu gửi)
    ↓
NV ghi nhận "deliveredAmount" → hàng kết thúc vòng đời
```

### 3.5. Quy trình điều phối xe / tài xế

```
Đầu ngày: Admin gán xe + tài xế vào từng khung giờ chạy (TH_TimeSlots)
    ↓
Tài xế mở app "VCP Nội Bộ" → tab Tài xế → đăng nhập
    ↓
Modal "Đổi biển số xe" hiện ra → tài xế chọn xe đang chạy hôm nay
    ↓
Trước giờ khởi hành, tài xế đến bến → bấm "Bắt đầu chuyến"
    ↓
Khách lên xe → đưa vé giấy hoặc mở app cho tài xế quét QR
    ↓
Hệ thống verify: vé này có đúng tuyến + đúng ngày không?
    ↓
OK → đánh dấu scanStatus = 'scanned' + hiện ghế của khách
    ↓
Lặp lại cho mọi khách
    ↓
Hết chuyến → tài xế bấm "Hoàn thành chuyến" → tổng kết doanh thu
```

**Quy tắc kiểm soát vé:**
- 1 QR chỉ quét được 1 lần (nếu quét lần 2 → cảnh báo "Vé đã sử dụng")
- Vé quét bên chuyến khác → cảnh báo "Sai chuyến"
- Tài xế KHÔNG sửa được vé, chỉ đánh dấu đã thu / chưa thu

### 3.6. Quy trình thanh toán

| Hình thức | Khi nào dùng | Xử lý |
|---|---|---|
| **Tiền mặt** | Phổ biến nhất, khách trả NV quầy hoặc tài xế | NV ghi `paid = totalAmount` |
| **Chuyển khoản** | Khách quét QR Vietcombank/MB ở trạm | NV verify Sao kê → ghi nhận |
| **VNPay** | Đặt vé online | Auto qua callback từ cổng VNPay |
| **MoMo** | Đặt vé online | Auto qua callback từ cổng MoMo |
| **Công nợ** | Khách quen, hàng giá trị thấp | NV ghi `paid = 0`, lập danh sách công nợ cuối tuần |

### 3.7. Quy trình báo cáo cuối ngày

```
23:30 mỗi ngày: Vercel Cron tự kích hoạt
    ↓
Endpoint /api/tong-hop/reports/cron-daily chạy
    ↓
Truy vấn TH_Bookings + Products trong ngày
    ↓
Tính: tổng vé bán, tổng doanh thu (tách 3 nguồn: Quầy/Online/Hàng), số chuyến, tỉ lệ lấp đầy
    ↓
Sinh PDF/HTML báo cáo + gửi email cho Admin qua Resend
```

### 3.8. Quy trình đồng bộ với O2BSoft (hệ thống cũ của công ty)

Trước khi triển khai hệ thống mới, một bộ phận NV vẫn dùng phần mềm O2BSoft (xe.o2bsoft.com — bên thứ 3 quản lý). Để không bị mất dữ liệu trong giai đoạn chuyển đổi:

```
NV vào tab xe.o2bsoft.com (đã có Tampermonkey + userscript cài sẵn)
    ↓
Bấm nút "SYNC NGAY" góc phải dưới
    ↓
Script tự đi qua tất cả các trang phân trang → đọc bảng → POST sang NhapHang
    ↓
Đơn mới → tạo. Đơn đã có → cập nhật. Đơn không đổi → bỏ qua.
    ↓
Mã o2b lưu vào notes dạng "o2b:030626.0348" để đối chiếu sau
```

Đồng bộ này giúp dữ liệu lịch sử O2BSoft chạy vào hệ thống mới mà NV không phải nhập tay lại.

---

## 4. Đối tượng người dùng & vai trò

### 4.1. Khách hàng (Customer)

**Đặc điểm:**
- Đa số dùng điện thoại Android, kỹ năng công nghệ trung bình
- 60% khách hàng quen, 40% khách vãng lai
- Thường đặt vé qua điện thoại trước (gọi NV) — hệ thống mới chuyển sang đặt online

**Nhu cầu:**
- Đặt vé nhanh, biết còn ghế hay không
- Nhận QR/SMS xác nhận tin cậy
- Hoãn / huỷ / đổi vé linh hoạt
- Tra cứu lịch sử đặt vé bằng SĐT

### 4.2. Nhân viên quầy (Counter Staff)

**Đặc điểm:**
- Quen máy tính, gõ nhanh, làm việc theo ca 8h
- 2-3 NV trực cùng lúc tại trạm lớn → cần khoá ghế chống đặt trùng
- NV mới: dễ nhầm điểm đón/trả nếu phải gõ tay

**Cần hệ thống hỗ trợ:**
- SeatMap trực quan thay vì danh sách dropdown
- Auto-detect điểm trả từ note ngắn (vd. "30/4" → "Bưu điện Trảng Bom")
- Auto-format số tiền (1000 → 1.000)
- Toast notification thay vì alert popup chặn thao tác
- Tìm khách toàn hệ thống bằng SĐT (cross-day) khi khách báo "tôi đã đặt rồi"
- In vé QR 1 bấm

### 4.3. Nhân viên kho (Warehouse Staff)

**Đặc điểm:**
- Ít kinh nghiệm máy tính, mobile-first
- Phải làm việc nhanh khi trạm đông khách
- Nhập nhiều đơn liên tục — không thể chờ load lâu

**Cần hệ thống hỗ trợ:**
- Sinh mã đơn tự động, NV không gõ tay
- Custom modal thay alert (lý do huỷ, format VND)
- Soft-delete đơn (không xoá hẳn) để giữ trace
- Realtime sync ~3s giữa NhapHang và TongHop
- Báo cáo doanh thu trạm theo ngày/tháng

### 4.4. Tài xế (Driver)

**Đặc điểm:**
- Hoàn toàn mobile, 1 tay cầm điện thoại, 1 tay chuẩn bị xe
- Mỗi tài xế 1-2 xe gắn cố định, đôi khi đổi
- Không quen UI phức tạp

**Cần hệ thống hỗ trợ:**
- App rất gọn, chỉ 2 chức năng: chọn xe + quét QR
- Header chỉ 2 mục cần thiết
- Tìm xe theo 5 số đuôi biển số (vd. "04669") thay vì gõ cả biển
- Cảnh báo to, rõ khi vé sai / đã quét

### 4.5. Quản trị viên (Admin)

**Đặc điểm:**
- Thường là chủ doanh nghiệp hoặc kế toán trưởng
- Cần xem báo cáo tổng + chi tiết

**Cần hệ thống hỗ trợ:**
- Dashboard số liệu tổng quan
- Heatmap tỉ lệ lấp đầy theo khung giờ
- Top khách hàng (frequency)
- Phân quyền chi tiết theo trạm + role + 15 keys permission
- Audit log (ai sửa gì, khi nào)
- Tắt/bật đặt vé online toàn cục khi cần (lễ tết)

---

## 5. Quy tắc nghiệp vụ tổng hợp (Business Rules)

| ID | Quy tắc | Triển khai |
|---|---|---|
| BR-01 | Mã đơn hàng NhapHang luôn duy nhất theo `(date, trạm nhận, sequence)` | Bảng `Counters` + atomic upsert |
| BR-02 | 1 ghế chỉ thuộc 1 booking trong 1 chuyến | UNIQUE (date, time, route, seatNumber) + retry logic |
| BR-03 | Ghế đang chọn bị khoá 10 phút | Bảng `TH_SeatLocks` với `expiresAt` |
| BR-04 | Đơn dọc đường tự đẻ booking trên xe khách | Fire-and-forget từ POST `/products` + cron reconcile |
| BR-05 | Vé đã quét không quét lại được | `scanStatus = 'scanned'` immutable |
| BR-06 | Đơn cũ hơn 2 phút không sửa được | API trả 403 từ PUT `/products/:id` |
| BR-07 | Huỷ đơn = soft delete, không xoá | `status = 'cancelled'` + `cancelNote` |
| BR-08 | NV chỉ thấy đơn trạm mình | JWT carry `scope = own_station` filter ở backend |
| BR-09 | Khách online hoãn trước 6h hoàn 100%, 2-6h hoàn 50%, <2h không hoàn | Logic ở payment refund flow |
| BR-10 | Báo cáo doanh thu tách 3 nguồn (Quầy/Online/Hàng) | Dedup theo `bookingId` để không cộng đôi |
| BR-11 | Khách không cần đăng ký tài khoản để đặt vé online | Booking gắn SĐT thay vì userId |
| BR-12 | Audit log mọi thao tác sửa/xoá | `ProductLogs` + `TH_ActivityLog` |

---

## 6. Đầu vào / Đầu ra hệ thống

### 6.1. Đầu vào (Input)

| Nguồn | Loại dữ liệu | Tần suất |
|---|---|---|
| Khách hàng | Đặt vé online (form) | Liên tục |
| NV quầy | Vé thủ công | ~50-200 vé/trạm/ngày |
| NV kho | Đơn hàng hoá | ~100-300 đơn/trạm/ngày |
| Tài xế | Quét QR vé | ~30-50 vé/chuyến |
| Admin | Cấu hình tuyến / xe / user | Thấp |
| O2BSoft userscript | Đơn cũ scrape từ hệ thống ngoài | Theo phiên NV |
| Cổng VNPay / MoMo | Callback thanh toán | Theo từng giao dịch |

### 6.2. Đầu ra (Output)

| Sản phẩm | Đối tượng | Hình thức |
|---|---|---|
| Vé in 92mm có QR | Khách hàng | Giấy nhiệt |
| QR code điện tử | Khách online | SMS / Email / In trên app |
| Biên lai gửi hàng | Khách gửi hàng | Giấy nhiệt 92mm |
| Báo cáo doanh thu cuối ngày | Admin | Email PDF qua Resend |
| Dashboard realtime | NV + Admin | Web hiển thị |
| Audit log | Admin | Web tra cứu |
| API REST | Hệ thống khác (mobile app) | JSON |
