# Sơ đồ ERD — Hệ thống Võ Cúc Phương

Sơ đồ dùng cú pháp **Mermaid** — paste vào https://mermaid.live để xuất PNG / SVG, hoặc xem trực tiếp trên GitHub.

---

## 1. ERD NhapHang DB

```mermaid
erDiagram
    Users ||--o{ Products : "createdBy / employee"
    Stations ||--o{ Products : "senderStation"
    Stations ||--o{ Products : "station (nhận)"
    Stations ||--o{ Counters : "station"
    Products ||--o{ ProductLogs : "productId"

    Users {
        int id PK
        string username UK
        string password
        string role "admin|staff"
        string fullName
        string station
        jsonb permissions
        string scope "own_station|all_stations"
        string email
        string phone
        bool active
        timestamp createdAt
    }

    Stations {
        int id PK
        string code UK "01..99"
        string name
        string fullName
        string address
        string phone
        string region
        bool isActive
    }

    Products {
        string id PK "YYMMDD.SSNN"
        string senderName
        string senderPhone
        string senderStation FK
        string receiverName
        string receiverPhone
        string station FK "trạm nhận"
        string productType
        string quantity
        string vehicle
        decimal insurance
        decimal totalAmount
        decimal deliveredAmount
        string paymentStatus
        string status "pending|delivered|cancelled"
        string deliveryStatus
        string employee
        string createdBy FK
        text notes
        text cancelNote
        timestamp sendDate
        bool syncedToTongHop
        int tongHopBookingId "FK→TH_Bookings(cross-DB)"
        timestamp createdAt
        timestamp updatedAt
    }

    ProductLogs {
        int id PK
        string productId FK
        string action
        string field
        text oldValue
        text newValue
        string changedBy
        string ipAddress
        timestamp createdAt
    }

    Counters {
        string counterKey PK
        string station
        string dateKey "DDMMYY"
        int value
        timestamp lastUpdated
    }
```

---

## 2. ERD TongHop DB

```mermaid
erDiagram
    TH_Routes ||--o{ TH_TimeSlots : "route"
    TH_TimeSlots ||--o{ TH_Bookings : "timeSlotId"
    TH_TimeSlots ||--o{ TH_SeatLocks : "timeSlot composite"
    TH_Users ||--o{ TH_SeatLocks : "userId"
    TH_Users ||--o{ TH_ActivityLog : "userId"
    TH_Routes ||--o{ TH_PickupStations : "route"
    TH_Vehicles ||--o{ TH_TimeSlots : "vehiclePlate"
    TH_Drivers ||--o{ TH_TimeSlots : "driver"

    TH_Routes {
        int id PK
        string name UK
        string fromStation
        string toStation
        string distance
        int seats "default 28"
        string busType
        string operatingStart
        string operatingEnd
        int intervalMinutes
        bool isActive
    }

    TH_TimeSlots {
        int id PK
        string time
        string date
        string route FK
        string type
        string code
        string driver
        string phone
        string vehiclePlate
    }

    TH_Bookings {
        int id PK
        int timeSlotId FK
        string phone
        string name
        string gender
        string nationality
        string pickupMethod
        string pickupAddress
        string dropoffMethod
        string dropoffAddress
        text note
        int seatNumber "1..28"
        decimal amount
        decimal paid
        decimal deposit
        string timeSlot
        string date
        string route
        text clientReqId UK "idempotency key"
        string callStatus "Chưa gọi|Đã gọi|Đã xác nhận|Hoãn|Khách huỷ"
        bool printed
        text qrToken
        string scanStatus
        timestamp scannedAt
        timestamp createdAt
        timestamp updatedAt
    }

    TH_SeatLocks {
        int id PK
        string date
        string time
        string route
        int seatNumber
        int userId FK
        timestamp expiresAt
    }

    TH_Vehicles {
        int id PK
        string code "28G / 50F-01057"
        string type "biển số chi tiết"
    }

    TH_Drivers {
        int id PK
        string name
        string phone
        string vehiclePlate
        bool active
    }

    TH_PickupStations {
        int id PK
        int stt
        string stationName
        string route FK
        string direction "pickup|dropoff"
        text aliases
    }

    TH_Users {
        int id PK
        string username UK
        string password
        string role
        string fullName
        string station
        jsonb permissions
        string scope
        string email
        string phone
        bool active
    }

    TH_ActivityLog {
        int id PK
        int userId FK
        string action
        string entityType
        string entityId
        text description
        string ipAddress
        timestamp createdAt
    }
```

---

## 3. ERD DatVe DB (Đặt vé online cho khách)

```mermaid
erDiagram
    User ||--o{ Booking : "userId"
    Schedule ||--o{ Booking : "scheduleId"
    Route ||--o{ Schedule : "routeId"
    Bus ||--o{ Schedule : "busId"
    Booking ||--|| Payment : "bookingId"

    User {
        int id PK
        string email UK
        string name
        string phone
        string password
        string role "USER|STAFF|DRIVER|ADMIN"
        string vehiclePlate "(if DRIVER)"
        timestamp createdAt
    }

    Route {
        int id PK
        string fromCity
        string toCity
        decimal price
        int duration "phút"
        bool isActive
    }

    Bus {
        int id PK
        string plate UK
        string model
        int seats
    }

    Schedule {
        int id PK
        int routeId FK
        int busId FK
        string departureTime
        string arrivalTime
        string date
        string status
    }

    Booking {
        int id PK
        int userId FK
        int scheduleId FK
        int seatNumber
        string status "PENDING|CONFIRMED|CANCELLED"
        decimal totalPrice
        string qrCode
        bool scanned
        string paymentMethod
        timestamp createdAt
    }

    Payment {
        int id PK
        int bookingId FK
        decimal amount
        string method "VNPAY|MOMO|CASH"
        string transactionId
        string status
        timestamp createdAt
    }

    Setting {
        string key PK
        string value
    }
```

---

## 4. Sơ đồ tổng thể 3 CSDL

```mermaid
flowchart LR
    subgraph NhapHang["NhapHang DB (ep-dark-paper)"]
        P[Products]
        PL[ProductLogs]
        ST[Stations]
        CN[Counters]
        UN[Users]
    end

    subgraph TongHop["TongHop DB (ep-autumn-sun)"]
        TB[TH_Bookings]
        TT[TH_TimeSlots]
        TR[TH_Routes]
        TV[TH_Vehicles]
        TD[TH_Drivers]
        TSL[TH_SeatLocks]
        TU[TH_Users]
        TPS[TH_PickupStations]
    end

    subgraph DatVe["DatVe DB (ep-holy-recipe)"]
        DU[User]
        DR[Route]
        DB_[Bus]
        DS[Schedule]
        DBK[Booking]
        DP[Payment]
    end

    P -- "clientReqId = Products.id" --> TB
    TB -. "webhook sync" .-> DBK
    TR <-. "2-way sync" .-> DR
```
