# Sequence Diagrams (RD — Realization Diagrams) — Các luồng chính

## 1. Khách đặt vé online

```mermaid
sequenceDiagram
    autonumber
    actor Khach as Khách hàng
    participant Web as DatVe Web<br/>(Next.js)
    participant API as DatVe API
    participant DB as DatVe DB
    participant VNPay as Cổng VNPay/MoMo

    Khach->>Web: Chọn tuyến + ngày
    Web->>API: GET /api/schedules?route=&date=
    API->>DB: SELECT Schedule WHERE...
    DB-->>API: List schedules
    API-->>Web: JSON
    Web-->>Khach: Hiển thị danh sách chuyến

    Khach->>Web: Click chuyến → SeatPicker
    Web->>API: POST /api/seat-lock {scheduleId, seat}
    API->>DB: INSERT TH_SeatLocks (TTL 10 phút)
    DB-->>API: lockId
    API-->>Web: OK lock

    Khach->>Web: Điền form + chọn thanh toán
    Web->>API: POST /api/bookings (PENDING)
    API->>DB: INSERT Booking (status=PENDING)
    API->>VNPay: Tạo payment URL
    VNPay-->>API: Redirect URL
    API-->>Web: Trả URL
    Web-->>Khach: Redirect VNPay

    Khach->>VNPay: Nhập thẻ + xác thực OTP
    VNPay-->>API: Callback /api/payment/callback
    API->>DB: UPDATE Booking SET status=CONFIRMED
    API->>DB: INSERT Payment (status=SUCCESS)
    API->>DB: DELETE TH_SeatLocks
    API-->>Khach: SMS/Email QR code
```

---

## 2. NV quầy tạo vé thủ công

```mermaid
sequenceDiagram
    autonumber
    actor NV as Nhân viên quầy
    participant App as TongHop SPA<br/>(React)
    participant CTX as BookingContext
    participant API as TongHop API
    participant DB as TongHop DB
    participant BC as BroadcastChannel<br/>(multi-tab sync)

    NV->>App: Mở SeatMap ngày + tuyến
    App->>API: GET /api/tong-hop/bookings?date=&timeSlotId=
    API->>DB: SELECT TH_Bookings + TH_SeatLocks
    DB-->>API: bookings + locks
    API-->>App: JSON
    App-->>NV: Sơ đồ 28 ghế (xám=đã đặt, vàng=lock, xanh=trống)

    NV->>App: Click ghế trống
    App->>API: POST /api/seat-locks {date, time, route, seat, userId}
    API->>DB: INSERT TH_SeatLocks WHERE NOT EXISTS
    alt Lock OK
        DB-->>API: lockId
        API-->>App: Cho phép sửa
        App-->>NV: Mở PassengerForm
    else Ghế đã bị lock
        DB-->>API: conflict
        API-->>App: 409
        App-->>NV: Toast "Ghế đang được chọn"
    end

    NV->>App: Nhập tên/SĐT/note
    App->>App: Auto-detect điểm trả từ note<br/>(stations.js aliases)
    App->>App: Format VND tự động
    NV->>App: Bấm Lưu
    App->>API: POST /api/tong-hop/bookings
    API->>DB: INSERT TH_Bookings
    API->>DB: DELETE TH_SeatLocks WHERE userId=
    DB-->>API: bookingId
    API-->>App: 201
    App->>BC: postMessage('vcp-route-sync')
    BC-->>App: Tab khác nhận → reload bookings
    App-->>NV: Toast "Đã lưu vé"
```

---

## 3. Sync NhapHang "Dọc đường" → TongHop (luồng tự động)

```mermaid
sequenceDiagram
    autonumber
    actor NVK as NV Kho
    participant FE as NhapHang Frontend
    participant API as POST /products
    participant NH_DB as NhapHang DB
    participant TH_DB as TongHop DB
    participant BG as Background task<br/>(fire-and-forget)
    participant Reconcile as GET /reconcile-doc-duong<br/>(polling 30s + cron daily)

    NVK->>FE: Nhập đơn, trạm nhận = "Dọc đường"
    FE->>API: POST /api/nhap-hang/products
    API->>NH_DB: UPSERT Counters → sinh mã YYMMDD.SSNN
    API->>NH_DB: INSERT Products
    API-->>FE: 201 Response (NHANH, <200ms)

    Note over API,BG: --- Fire-and-forget từ đây ---
    API->>BG: createTongHopBooking()
    BG->>TH_DB: findNearestTimeslot()
    BG->>TH_DB: SELECT seat trống
    BG->>TH_DB: INSERT TH_Bookings (clientReqId = Products.id)<br/>ON CONFLICT (clientReqId) DO UPDATE
    TH_DB-->>BG: bookingId
    BG->>NH_DB: UPDATE Products SET syncedToTongHop=true,<br/>tongHopBookingId=:id

    Note over Reconcile,TH_DB: --- Safety net: nếu BG bị Vercel kill ---
    loop Mỗi 30s (frontend) + mỗi 24h (Vercel Cron)
        Reconcile->>NH_DB: SELECT Products<br/>WHERE syncedToTongHop=false<br/>AND station LIKE '%Dọc đường%'
        NH_DB-->>Reconcile: List sót
        Reconcile->>TH_DB: createBookingWithSeatRetry() (idempotent)
        Reconcile->>NH_DB: UPDATE syncedToTongHop=true
    end
```

---

## 4. Tài xế quét QR check-in

```mermaid
sequenceDiagram
    autonumber
    actor TX as Tài xế
    participant App as VCP NoiBo App<br/>(Flutter WebView)
    participant Web as /driver page
    participant API as Scan API
    participant DB as TongHop DB

    TX->>App: Mở app → tab tài xế
    App->>Web: load /driver
    Web-->>TX: Hiện modal "Đổi biển số xe"
    TX->>Web: Chọn xe "28G — 60B04669"
    Web->>API: POST /api/driver/set-vehicle
    API->>DB: UPDATE User.vehiclePlate
    Web-->>TX: Hiện màn quét QR + nút "Bật camera"

    TX->>Web: Bấm "Bật camera"
    Note over App,Web: WebView gọi getUserMedia
    App->>TX: Dialog Android "Cho phép Camera?"
    TX->>App: Cho phép
    App->>Web: grant() → camera bật

    Khach-->>TX: Đưa QR vé
    TX->>Web: Quét QR
    Web->>API: GET /api/scan/{qrToken}
    API->>DB: SELECT TH_Bookings WHERE qrToken=
    alt Vé hợp lệ
        DB-->>API: booking
        API->>DB: UPDATE scanStatus=scanned, scannedAt=NOW()
        API-->>Web: 200 + info vé
        Web-->>TX: Hiện tên + ghế + tiền
    else Đã quét
        DB-->>API: scanStatus=scanned
        API-->>Web: 409
        Web-->>TX: Cảnh báo "Vé đã sử dụng"
    end
```

---

## 5. Đồng bộ Routes giữa TongHop ↔ DatVe (2 chiều)

```mermaid
sequenceDiagram
    autonumber
    actor Admin
    participant TH as TongHop Admin
    participant TH_API as TongHop API
    participant DV_API as DatVe API
    participant TH_DB as TongHop DB
    participant DV_DB as DatVe DB

    Admin->>TH: Tạo tuyến mới "Sài Gòn - Long Khánh"
    TH->>TH_API: POST /api/tong-hop/routes
    TH_API->>TH_DB: INSERT TH_Routes
    TH_API->>DV_API: POST /api/routes (webhook)
    DV_API->>DV_DB: INSERT Route (source=tonghop)
    DV_API-->>TH_API: created, datveId=42
    TH_API->>TH_DB: UPDATE TH_Routes SET datveId=42

    Note over Admin,DV_DB: Khi admin sửa tuyến ở phía nào,<br/>endpoint by-datve/[id] cập nhật bên kia.

    Admin->>DV_DB: Sửa giá tuyến (qua DatVe admin)
    DV_API->>TH_API: PATCH /api/tong-hop/routes/by-datve/42
    TH_API->>TH_DB: UPDATE TH_Routes WHERE datveId=42
```

---

## 6. O2BSoft → NhapHang sync (Tampermonkey userscript)

```mermaid
sequenceDiagram
    autonumber
    actor NV as NV Kho (Lê Thanh Tâm)
    participant Tab as Tab xe.o2bsoft.com
    participant Script as Userscript<br/>(Tampermonkey)
    participant O2B as O2BSoft<br/>(server bên ngoài)
    participant NH_API as NhapHang API
    participant NH_DB as NhapHang DB

    NV->>Tab: Bấm "SYNC NGAY"
    Script->>Script: findMaxPageNumber() từ DOM
    loop Mỗi 3 trang song song
        Script->>O2B: fetch(?pn=N) (giữ cookie)
        O2B-->>Script: HTML trang
        Script->>Script: parseRows() → JSON
    end
    Script->>Script: Dedup theo o2bId + sort sendDate ASC

    Script->>NH_API: GET /stations (lấy mapping)
    Script->>NH_API: GET /products?date=today (check trùng)
    NH_API-->>Script: existing map

    loop Mỗi đơn
        alt Đơn mới
            Script->>NH_API: POST /products<br/>notes: "o2b:{maO2B}"
            NH_API->>NH_DB: INSERT Products
            NH_API-->>Script: 201
        else Đơn đã tồn tại + dữ liệu khác
            Script->>NH_API: PUT /products/:id
            NH_API->>NH_DB: UPDATE
            alt 403 "Đã quá 2 phút"
                Script->>Script: skip (NhapHang khoá edit đơn cũ)
            end
        else Đơn không đổi
            Script->>Script: skip
        end
    end

    Script-->>NV: Popup "Tạo: X, Cập nhật: Y, Bỏ qua: Z, Lỗi: N"
```

---

## 7. Khoá ghế tạm khi 2 NV cùng chọn 1 ghế (race condition)

```mermaid
sequenceDiagram
    autonumber
    participant NV1 as NV-A
    participant App1 as Tab NV-A
    participant API as Seat Lock API
    participant DB as TH_SeatLocks
    participant App2 as Tab NV-B
    participant NV2 as NV-B

    par Đồng thời
        NV1->>App1: Click ghế 12
        NV2->>App2: Click ghế 12
    end

    par 2 request gửi gần như cùng lúc
        App1->>API: POST seat-locks {seat:12}
        App2->>API: POST seat-locks {seat:12}
    end

    API->>DB: INSERT ON CONFLICT (date,time,route,seat) DO NOTHING<br/>(NV-A đến trước theo DB timestamp)
    DB-->>API: row inserted (NV-A)
    API-->>App1: 201 OK
    App1-->>NV1: Mở form

    API->>DB: INSERT ... (NV-B đến sau)
    DB-->>API: 0 rows affected (conflict)
    API-->>App2: 409 Conflict
    App2-->>NV2: Toast "Ghế đang được NV khác chọn"

    Note over App1,DB: Sau 10 phút TTL hết hạn,<br/>polling 3s sẽ release lock tự động.
```
