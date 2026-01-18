-- ============================================================
-- NHAPHANG DATABASE SCHEMA FOR NEON POSTGRESQL
-- Migration from Firebase Firestore
-- Created: 2025-01-18
-- ============================================================

-- ============================================================
-- 1. NH_Stations - Danh sách bến xe
-- ============================================================
CREATE TABLE IF NOT EXISTS "NH_Stations" (
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

-- Indexes for NH_Stations
CREATE INDEX IF NOT EXISTS idx_nh_stations_code ON "NH_Stations"(code);
CREATE INDEX IF NOT EXISTS idx_nh_stations_name ON "NH_Stations"(name);
CREATE INDEX IF NOT EXISTS idx_nh_stations_active ON "NH_Stations"("isActive");

-- ============================================================
-- 2. NH_Users - Tài khoản nhân viên NhapHang
-- ============================================================
CREATE TABLE IF NOT EXISTS "NH_Users" (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,              -- Hashed password
    "fullName" VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'employee',         -- 'admin', 'employee'
    station VARCHAR(150),                        -- FK to NH_Stations.fullName
    active BOOLEAN DEFAULT true,
    "createdAt" TIMESTAMP DEFAULT NOW(),
    "updatedAt" TIMESTAMP DEFAULT NOW()
);

-- Indexes for NH_Users
CREATE INDEX IF NOT EXISTS idx_nh_users_username ON "NH_Users"(username);
CREATE INDEX IF NOT EXISTS idx_nh_users_station ON "NH_Users"(station);
CREATE INDEX IF NOT EXISTS idx_nh_users_active ON "NH_Users"(active);

-- ============================================================
-- 3. NH_Counters - Sinh mã đơn tự động
-- Format: YYMMDD.SSNN (SS=station code, NN=sequence)
-- ============================================================
CREATE TABLE IF NOT EXISTS "NH_Counters" (
    id SERIAL PRIMARY KEY,
    "counterKey" VARCHAR(100) NOT NULL UNIQUE,   -- 'counter_01_180125' (station_date)
    station VARCHAR(10) NOT NULL,                -- Station code
    "dateKey" VARCHAR(10) NOT NULL,              -- DDMMYY format
    value INTEGER DEFAULT 0,                     -- Current counter value
    "lastUpdated" TIMESTAMP DEFAULT NOW(),
    CONSTRAINT uq_nh_counter UNIQUE (station, "dateKey")
);

-- Indexes for NH_Counters
CREATE INDEX IF NOT EXISTS idx_nh_counters_key ON "NH_Counters"("counterKey");
CREATE INDEX IF NOT EXISTS idx_nh_counters_station_date ON "NH_Counters"(station, "dateKey");

-- ============================================================
-- 4. NH_Products - Đơn hàng vận chuyển (Main table)
-- ============================================================
CREATE TABLE IF NOT EXISTS "NH_Products" (
    id VARCHAR(50) PRIMARY KEY,                  -- Format: YYMMDD.SSNN

    -- Sender Information
    "senderName" VARCHAR(100),
    "senderPhone" VARCHAR(20),
    "senderStation" VARCHAR(150) NOT NULL,       -- FK to NH_Stations.fullName

    -- Receiver Information
    "receiverName" VARCHAR(100),
    "receiverPhone" VARCHAR(20),
    station VARCHAR(150) NOT NULL,               -- Destination station (FK to NH_Stations.fullName)

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

-- Indexes for NH_Products
CREATE INDEX IF NOT EXISTS idx_nh_products_senddate ON "NH_Products"("sendDate");
CREATE INDEX IF NOT EXISTS idx_nh_products_sender_station ON "NH_Products"("senderStation");
CREATE INDEX IF NOT EXISTS idx_nh_products_station ON "NH_Products"(station);
CREATE INDEX IF NOT EXISTS idx_nh_products_payment ON "NH_Products"("paymentStatus");
CREATE INDEX IF NOT EXISTS idx_nh_products_status ON "NH_Products"(status);
CREATE INDEX IF NOT EXISTS idx_nh_products_delivery ON "NH_Products"("deliveryStatus");
CREATE INDEX IF NOT EXISTS idx_nh_products_sender_phone ON "NH_Products"("senderPhone");
CREATE INDEX IF NOT EXISTS idx_nh_products_receiver_phone ON "NH_Products"("receiverPhone");
CREATE INDEX IF NOT EXISTS idx_nh_products_vehicle ON "NH_Products"(vehicle);
CREATE INDEX IF NOT EXISTS idx_nh_products_synced ON "NH_Products"("syncedToTongHop");

-- ============================================================
-- 5. NH_ProductLogs - Audit trail for changes
-- ============================================================
CREATE TABLE IF NOT EXISTS "NH_ProductLogs" (
    "logId" SERIAL PRIMARY KEY,
    "productId" VARCHAR(50) NOT NULL,            -- FK to NH_Products.id
    action VARCHAR(20) NOT NULL,                 -- 'create', 'update', 'delete'
    field VARCHAR(50),                           -- Field name that changed
    "oldValue" TEXT,                             -- Previous value
    "newValue" TEXT,                             -- New value
    "changedBy" VARCHAR(100),                    -- User who made change
    "changedAt" TIMESTAMP DEFAULT NOW(),
    "ipAddress" VARCHAR(50),                     -- Client IP address

    CONSTRAINT fk_nh_productlogs_product
        FOREIGN KEY ("productId")
        REFERENCES "NH_Products"(id)
        ON DELETE CASCADE
);

-- Indexes for NH_ProductLogs
CREATE INDEX IF NOT EXISTS idx_nh_productlogs_product ON "NH_ProductLogs"("productId");
CREATE INDEX IF NOT EXISTS idx_nh_productlogs_action ON "NH_ProductLogs"(action);
CREATE INDEX IF NOT EXISTS idx_nh_productlogs_changed_at ON "NH_ProductLogs"("changedAt");

-- ============================================================
-- SAMPLE DATA - Stations
-- ============================================================
INSERT INTO "NH_Stations" (code, name, "fullName", address, phone, "isActive") VALUES
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
INSERT INTO "NH_Users" (username, password, "fullName", role, station, active) VALUES
('admin', 'admin123', 'Quản trị viên', 'admin', NULL, true),
('nv_andong', 'nv123456', 'Nhân viên An Đông', 'employee', '01 - AN ĐÔNG', true),
('nv_hangxanh', 'nv123456', 'Nhân viên Hàng Xanh', 'employee', '02 - HÀNG XANH', true),
('nv_longkhanh', 'nv123456', 'Nhân viên Long Khánh', 'employee', '07 - LONG KHÁNH', true)
ON CONFLICT (username) DO NOTHING;

-- ============================================================
-- FUNCTION: Auto-update updatedAt timestamp
-- ============================================================
CREATE OR REPLACE FUNCTION update_nh_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for auto-updating updatedAt
DROP TRIGGER IF EXISTS trg_nh_stations_updated ON "NH_Stations";
CREATE TRIGGER trg_nh_stations_updated
    BEFORE UPDATE ON "NH_Stations"
    FOR EACH ROW EXECUTE FUNCTION update_nh_updated_at();

DROP TRIGGER IF EXISTS trg_nh_users_updated ON "NH_Users";
CREATE TRIGGER trg_nh_users_updated
    BEFORE UPDATE ON "NH_Users"
    FOR EACH ROW EXECUTE FUNCTION update_nh_updated_at();

DROP TRIGGER IF EXISTS trg_nh_products_updated ON "NH_Products";
CREATE TRIGGER trg_nh_products_updated
    BEFORE UPDATE ON "NH_Products"
    FOR EACH ROW EXECUTE FUNCTION update_nh_updated_at();

-- ============================================================
-- FUNCTION: Generate Product ID
-- Format: YYMMDD.SSNN (YY=year, MM=month, DD=day, SS=station, NN=sequence)
-- ============================================================
CREATE OR REPLACE FUNCTION generate_nh_product_id(
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
    INSERT INTO "NH_Counters" ("counterKey", station, "dateKey", value, "lastUpdated")
    VALUES (v_counter_key, p_station_code, v_date_key, 1, NOW())
    ON CONFLICT ("counterKey")
    DO UPDATE SET value = "NH_Counters".value + 1, "lastUpdated" = NOW()
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
COMMENT ON TABLE "NH_Stations" IS 'Danh sách các bến xe/trạm trong hệ thống NhapHang';
COMMENT ON TABLE "NH_Users" IS 'Tài khoản nhân viên sử dụng hệ thống NhapHang';
COMMENT ON TABLE "NH_Counters" IS 'Bộ đếm để sinh mã đơn hàng tự động theo ngày và bến';
COMMENT ON TABLE "NH_Products" IS 'Đơn hàng vận chuyển - bảng chính của NhapHang';
COMMENT ON TABLE "NH_ProductLogs" IS 'Lịch sử thay đổi đơn hàng (audit trail)';
COMMENT ON COLUMN "NH_Products"."tongHopBookingId" IS 'ID của booking tương ứng trong TH_Bookings (nếu là đơn Dọc Đường)';
COMMENT ON COLUMN "NH_Products"."syncedToTongHop" IS 'Đánh dấu đơn đã được sync sang TongHop chưa';
