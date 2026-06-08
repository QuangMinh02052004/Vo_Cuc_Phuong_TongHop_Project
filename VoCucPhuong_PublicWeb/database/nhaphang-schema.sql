-- ============================================================
-- NHAPHANG DATABASE SCHEMA FOR NEON POSTGRESQL
-- Migration from Firebase Firestore
-- Created: 2025-01-18
-- ============================================================

-- ============================================================
-- 1. Stations - Danh sách bến xe
-- ============================================================
CREATE TABLE IF NOT EXISTS "Stations" (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,           -- '01', '02', etc.
    name VARCHAR(100) NOT NULL,                  -- 'AN ĐÔNG', 'HÀNG XANH'
    "fullName" VARCHAR(150) NOT NULL UNIQUE,     -- '01 - AN ĐÔNG'
    address VARCHAR(255),                        -- Địa chỉ chi tiết
    phone VARCHAR(20),                           -- Số điện thoại bến
    "isActive" BOOLEAN DEFAULT true,
    "createdAt" TIMESTAMP DEFAULT NOW(),
    "updatedAt" TIMESTAMP DEFAULT NOW()
);

-- Indexes for Stations
CREATE INDEX IF NOT EXISTS idx_stations_code ON "Stations"(code);
CREATE INDEX IF NOT EXISTS idx_stations_name ON "Stations"(name);
CREATE INDEX IF NOT EXISTS idx_stations_active ON "Stations"("isActive");

-- ============================================================
-- 2. Users - Tài khoản nhân viên NhapHang
-- ============================================================
CREATE TABLE IF NOT EXISTS "Users" (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,              -- Hashed password
    "fullName" VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'employee',         -- 'admin', 'employee'
    station VARCHAR(150),                        -- FK to Stations.fullName
    active BOOLEAN DEFAULT true,
    "createdAt" TIMESTAMP DEFAULT NOW(),
    "updatedAt" TIMESTAMP DEFAULT NOW()
);

-- Indexes for Users
CREATE INDEX IF NOT EXISTS idx_users_username ON "Users"(username);
CREATE INDEX IF NOT EXISTS idx_users_station ON "Users"(station);
CREATE INDEX IF NOT EXISTS idx_users_active ON "Users"(active);

-- ============================================================
-- 3. Counters - Sinh mã đơn tự động
-- Format: YYMMDD.SSNN (SS=station code, NN=sequence)
-- ============================================================
CREATE TABLE IF NOT EXISTS "Counters" (
    id SERIAL PRIMARY KEY,
    "counterKey" VARCHAR(100) NOT NULL UNIQUE,   -- 'counter_01_180125' (station_date)
    station VARCHAR(10) NOT NULL,                -- Station code
    "dateKey" VARCHAR(10) NOT NULL,              -- DDMMYY format
    value INTEGER DEFAULT 0,                     -- Current counter value
    "lastUpdated" TIMESTAMP DEFAULT NOW(),
    CONSTRAINT uq_counter UNIQUE (station, "dateKey")
);

-- Indexes for Counters
CREATE INDEX IF NOT EXISTS idx_counters_key ON "Counters"("counterKey");
CREATE INDEX IF NOT EXISTS idx_counters_station_date ON "Counters"(station, "dateKey");

-- ============================================================
-- 4. Products - Đơn hàng vận chuyển (Main table)
-- ============================================================
CREATE TABLE IF NOT EXISTS "Products" (
    id VARCHAR(50) PRIMARY KEY,                  -- Format: YYMMDD.SSNN

    -- Sender Information
    "senderName" VARCHAR(100),
    "senderPhone" VARCHAR(20),
    "senderStation" VARCHAR(150) NOT NULL,       -- FK to Stations.fullName

    -- Receiver Information
    "receiverName" VARCHAR(100),
    "receiverPhone" VARCHAR(20),
    station VARCHAR(150) NOT NULL,               -- Destination station (FK to Stations.fullName)

    -- Shipment Details
    "productType" VARCHAR(200),                  -- '03 - Thùng', '24 - Thực phẩm'
    quantity VARCHAR(500),                       -- '2 thùng + 2 bao'
    vehicle VARCHAR(100),                        -- Vehicle code
    insurance DECIMAL(18,2) DEFAULT 0,           -- Insurance amount
    "totalAmount" DECIMAL(18,2) DEFAULT 0,       -- Total freight charge

    -- Payment & Status
    "paymentStatus" VARCHAR(20) DEFAULT 'unpaid', -- 'paid', 'unpaid'
    status VARCHAR(20) DEFAULT 'pending',         -- 'pending', 'in_transit', 'delivered', 'cancelled'
    "deliveryStatus" VARCHAR(50) DEFAULT 'pending', -- 'pending', 'waiting_send', 'waiting_receive', 'lost', 'no_contact', 'delivered'

    -- Personnel & Audit
    employee VARCHAR(100),                       -- Employee handling shipment
    "createdBy" VARCHAR(100),                    -- User who created order
    notes TEXT,                                  -- Additional notes

    -- Timestamps
    "sendDate" TIMESTAMP NOT NULL,               -- Date shipment sent
    "deliveredAt" TIMESTAMP,                     -- Delivery completion date
    "createdAt" TIMESTAMP DEFAULT NOW(),
    "updatedAt" TIMESTAMP DEFAULT NOW(),

    -- Integration with TongHop
    "tongHopBookingId" INTEGER,                  -- FK to TH_Bookings.id (if synced)
    "syncedToTongHop" BOOLEAN DEFAULT false      -- Whether this order was synced to TongHop
);

-- Indexes for Products
CREATE INDEX IF NOT EXISTS idx_products_senddate ON "Products"("sendDate");
CREATE INDEX IF NOT EXISTS idx_products_sender_station ON "Products"("senderStation");
CREATE INDEX IF NOT EXISTS idx_products_station ON "Products"(station);
CREATE INDEX IF NOT EXISTS idx_products_payment ON "Products"("paymentStatus");
CREATE INDEX IF NOT EXISTS idx_products_status ON "Products"(status);
CREATE INDEX IF NOT EXISTS idx_products_delivery ON "Products"("deliveryStatus");
CREATE INDEX IF NOT EXISTS idx_products_sender_phone ON "Products"("senderPhone");
CREATE INDEX IF NOT EXISTS idx_products_receiver_phone ON "Products"("receiverPhone");
CREATE INDEX IF NOT EXISTS idx_products_vehicle ON "Products"(vehicle);
CREATE INDEX IF NOT EXISTS idx_products_synced ON "Products"("syncedToTongHop");

-- ============================================================
-- 5. ProductLogs - Audit trail for changes
-- ============================================================
CREATE TABLE IF NOT EXISTS "ProductLogs" (
    "logId" SERIAL PRIMARY KEY,
    "productId" VARCHAR(50) NOT NULL,            -- FK to Products.id
    action VARCHAR(20) NOT NULL,                 -- 'create', 'update', 'delete'
    field VARCHAR(50),                           -- Field name that changed
    "oldValue" TEXT,                             -- Previous value
    "newValue" TEXT,                             -- New value
    "changedBy" VARCHAR(100),                    -- User who made change
    "changedAt" TIMESTAMP DEFAULT NOW(),
    "ipAddress" VARCHAR(50),                     -- Client IP address

    CONSTRAINT fk_productlogs_product
        FOREIGN KEY ("productId")
        REFERENCES "Products"(id)
        ON DELETE CASCADE
);

-- Indexes for ProductLogs
CREATE INDEX IF NOT EXISTS idx_productlogs_product ON "ProductLogs"("productId");
CREATE INDEX IF NOT EXISTS idx_productlogs_action ON "ProductLogs"(action);
CREATE INDEX IF NOT EXISTS idx_productlogs_changed_at ON "ProductLogs"("changedAt");

-- ============================================================
-- SAMPLE DATA - Stations
-- ============================================================
INSERT INTO "Stations" (code, name, "fullName", address, phone, "isActive") VALUES
('01', 'AN ĐÔNG', '01 - AN ĐÔNG', 'Chợ An Đông, Q.5, TP.HCM', '028-1234-5678', true),
('02', 'HÀNG XANH', '02 - HÀNG XANH', 'Bến xe Hàng Xanh, Bình Thạnh', '028-2345-6789', true),
('03', 'NGUYỄN CƯ TRINH', '03 - NGUYỄN CƯ TRINH', 'Q.1, TP.HCM', '028-3456-7890', true),
('04', 'CHỢ CẦU', '04 - CHỢ CẦU', 'Q.12, TP.HCM', '028-4567-8901', true),
('05', 'NGÃ TƯ GA', '05 - NGÃ TƯ GA', 'Q.12, TP.HCM', '028-5678-9012', true),
('06', 'SUỐI TIÊN', '06 - SUỐI TIÊN', 'Q.9, TP.HCM', '028-6789-0123', true),
('07', 'LONG KHÁNH', '07 - LONG KHÁNH', 'TP Long Khánh, Đồng Nai', '0251-1234-567', true),
('08', 'XUÂN LỘC', '08 - XUÂN LỘC', 'Xuân Lộc, Đồng Nai', '0251-2345-678', true),
('09', 'DỌC ĐƯỜNG', '09 - DỌC ĐƯỜNG', 'Đón/trả dọc đường', NULL, true),
('10', 'BẾN XE MIỀN ĐÔNG', '10 - BẾN XE MIỀN ĐÔNG', 'Bến xe Miền Đông mới, Q.9', '028-7890-1234', true)
ON CONFLICT (code) DO NOTHING;

-- ============================================================
-- SAMPLE DATA - Users (password: admin123 - should be hashed in production)
-- ============================================================
INSERT INTO "Users" (username, password, "fullName", role, station, active) VALUES
('admin', 'admin123', 'Quản trị viên', 'admin', NULL, true),
('nv_andong', 'nv123456', 'Nhân viên An Đông', 'employee', '01 - AN ĐÔNG', true),
('nv_hangxanh', 'nv123456', 'Nhân viên Hàng Xanh', 'employee', '02 - HÀNG XANH', true),
('nv_longkhanh', 'nv123456', 'Nhân viên Long Khánh', 'employee', '07 - LONG KHÁNH', true)
ON CONFLICT (username) DO NOTHING;

-- ============================================================
-- FUNCTION: Auto-update updatedAt timestamp
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for auto-updating updatedAt
DROP TRIGGER IF EXISTS trg_stations_updated ON "Stations";
CREATE TRIGGER trg_stations_updated
    BEFORE UPDATE ON "Stations"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trg_users_updated ON "Users";
CREATE TRIGGER trg_users_updated
    BEFORE UPDATE ON "Users"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trg_products_updated ON "Products";
CREATE TRIGGER trg_products_updated
    BEFORE UPDATE ON "Products"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- FUNCTION: Generate Product ID
-- Format: YYMMDD.SSNN (YY=year, MM=month, DD=day, SS=station, NN=sequence)
-- ============================================================
CREATE OR REPLACE FUNCTION generate_product_id(
    p_station_code VARCHAR(10),
    p_date TIMESTAMP
) RETURNS VARCHAR(50) AS $$
DECLARE
    v_date_key VARCHAR(10);
    v_counter_key VARCHAR(100);
    v_sequence INTEGER;
    v_product_id VARCHAR(50);
BEGIN
    -- Format date as DDMMYY
    v_date_key := TO_CHAR(p_date, 'DDMMYY');
    v_counter_key := 'counter_' || p_station_code || '_' || v_date_key;

    -- Get and increment counter (with upsert)
    INSERT INTO "Counters" ("counterKey", station, "dateKey", value, "lastUpdated")
    VALUES (v_counter_key, p_station_code, v_date_key, 1, NOW())
    ON CONFLICT ("counterKey")
    DO UPDATE SET value = "Counters".value + 1, "lastUpdated" = NOW()
    RETURNING value INTO v_sequence;

    -- Format: YYMMDD.SSNN
    v_product_id := TO_CHAR(p_date, 'YYMMDD') || '.' ||
                    LPAD(p_station_code, 2, '0') ||
                    LPAD(v_sequence::TEXT, 2, '0');

    RETURN v_product_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- COMMENTS
-- ============================================================
COMMENT ON TABLE "Stations" IS 'Danh sách các bến xe/trạm trong hệ thống NhapHang';
COMMENT ON TABLE "Users" IS 'Tài khoản nhân viên sử dụng hệ thống NhapHang';
COMMENT ON TABLE "Counters" IS 'Bộ đếm để sinh mã đơn hàng tự động theo ngày và bến';
COMMENT ON TABLE "Products" IS 'Đơn hàng vận chuyển - bảng chính của NhapHang';
COMMENT ON TABLE "ProductLogs" IS 'Lịch sử thay đổi đơn hàng (audit trail)';
COMMENT ON COLUMN "Products"."tongHopBookingId" IS 'ID của booking tương ứng trong TH_Bookings (nếu là đơn Dọc Đường)';
COMMENT ON COLUMN "Products"."syncedToTongHop" IS 'Đánh dấu đơn đã được sync sang TongHop chưa';
