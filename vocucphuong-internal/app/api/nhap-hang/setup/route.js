import { queryNhapHang, queryOneNhapHang } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: SETUP DATABASE TABLES CHO NHẬP HÀNG
// ===========================================
// GET /api/nhap-hang/setup
//
// Tạo đầy đủ các bảng với schema chuẩn:
// - NH_Stations: Danh sách bến xe
// - NH_Users: Tài khoản nhân viên
// - NH_Counters: Sinh mã đơn tự động (YYMMDD.SSNN)
// - NH_Products: Đơn hàng vận chuyển
// - NH_ProductLogs: Lịch sử thay đổi

export async function GET(request) {
  try {
    const results = [];

    // ============================================================
    // 1. NH_Stations - Danh sách bến xe
    // ============================================================
    await queryNhapHang(`
      CREATE TABLE IF NOT EXISTS "NH_Stations" (
        id SERIAL PRIMARY KEY,
        code VARCHAR(10) NOT NULL UNIQUE,
        name VARCHAR(100) NOT NULL,
        "fullName" VARCHAR(150) NOT NULL UNIQUE,
        address VARCHAR(255),
        phone VARCHAR(20),
        region VARCHAR(50),
        "isActive" BOOLEAN DEFAULT true,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✓ NH_Stations table created');

    // ============================================================
    // 2. NH_Users - Tài khoản nhân viên NhapHang
    // ============================================================
    await queryNhapHang(`
      CREATE TABLE IF NOT EXISTS "NH_Users" (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        "fullName" VARCHAR(100) NOT NULL,
        phone VARCHAR(20),
        role VARCHAR(20) DEFAULT 'employee',
        station VARCHAR(150),
        active BOOLEAN DEFAULT true,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✓ NH_Users table created');

    // ============================================================
    // 3. NH_Counters - Sinh mã đơn tự động
    // Format: YYMMDD.SSNN (SS=station code, NN=sequence)
    // ============================================================
    await queryNhapHang(`
      CREATE TABLE IF NOT EXISTS "NH_Counters" (
        id SERIAL PRIMARY KEY,
        "counterKey" VARCHAR(100) NOT NULL UNIQUE,
        station VARCHAR(10) NOT NULL,
        "dateKey" VARCHAR(10) NOT NULL,
        value INTEGER DEFAULT 0,
        "lastUpdated" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✓ NH_Counters table created');

    // ============================================================
    // 4. NH_Products - Đơn hàng vận chuyển (Main table)
    // ID format: YYMMDD.SSNN
    // ============================================================
    await queryNhapHang(`
      CREATE TABLE IF NOT EXISTS "NH_Products" (
        id VARCHAR(50) PRIMARY KEY,

        -- Sender Information
        "senderName" VARCHAR(100),
        "senderPhone" VARCHAR(20),
        "senderStation" VARCHAR(150) NOT NULL,

        -- Receiver Information
        "receiverName" VARCHAR(100),
        "receiverPhone" VARCHAR(20),
        station VARCHAR(150) NOT NULL,

        -- Shipment Details
        "productType" VARCHAR(200),
        quantity VARCHAR(500),
        vehicle VARCHAR(100),
        insurance DECIMAL(18,2) DEFAULT 0,
        "totalAmount" DECIMAL(18,2) DEFAULT 0,

        -- Payment & Status
        "paymentStatus" VARCHAR(20) DEFAULT 'unpaid',
        status VARCHAR(20) DEFAULT 'pending',
        "deliveryStatus" VARCHAR(50) DEFAULT 'pending',

        -- Personnel & Audit
        employee VARCHAR(100),
        "createdBy" VARCHAR(100),
        notes TEXT,

        -- Timestamps
        "sendDate" TIMESTAMP NOT NULL,
        "deliveredAt" TIMESTAMP,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW(),

        -- Integration with TongHop
        "tongHopBookingId" INTEGER,
        "syncedToTongHop" BOOLEAN DEFAULT false
      )
    `);
    results.push('✓ NH_Products table created');

    // ============================================================
    // 5. NH_ProductLogs - Audit trail for changes
    // ============================================================
    await queryNhapHang(`
      CREATE TABLE IF NOT EXISTS "NH_ProductLogs" (
        "logId" SERIAL PRIMARY KEY,
        "productId" VARCHAR(50) NOT NULL,
        action VARCHAR(20) NOT NULL,
        field VARCHAR(50),
        "oldValue" TEXT,
        "newValue" TEXT,
        "changedBy" VARCHAR(100),
        "changedAt" TIMESTAMP DEFAULT NOW(),
        "ipAddress" VARCHAR(50)
      )
    `);
    results.push('✓ NH_ProductLogs table created');

    // ============================================================
    // Create Indexes
    // ============================================================
    const indexes = [
      'CREATE INDEX IF NOT EXISTS idx_nh_stations_code ON "NH_Stations"(code)',
      'CREATE INDEX IF NOT EXISTS idx_nh_stations_name ON "NH_Stations"(name)',
      'CREATE INDEX IF NOT EXISTS idx_nh_stations_active ON "NH_Stations"("isActive")',
      'CREATE INDEX IF NOT EXISTS idx_nh_users_username ON "NH_Users"(username)',
      'CREATE INDEX IF NOT EXISTS idx_nh_users_station ON "NH_Users"(station)',
      'CREATE INDEX IF NOT EXISTS idx_nh_users_active ON "NH_Users"(active)',
      'CREATE INDEX IF NOT EXISTS idx_nh_counters_key ON "NH_Counters"("counterKey")',
      'CREATE INDEX IF NOT EXISTS idx_nh_counters_station_date ON "NH_Counters"(station, "dateKey")',
      'CREATE INDEX IF NOT EXISTS idx_nh_products_senddate ON "NH_Products"("sendDate")',
      'CREATE INDEX IF NOT EXISTS idx_nh_products_sender_station ON "NH_Products"("senderStation")',
      'CREATE INDEX IF NOT EXISTS idx_nh_products_station ON "NH_Products"(station)',
      'CREATE INDEX IF NOT EXISTS idx_nh_products_payment ON "NH_Products"("paymentStatus")',
      'CREATE INDEX IF NOT EXISTS idx_nh_products_status ON "NH_Products"(status)',
      'CREATE INDEX IF NOT EXISTS idx_nh_products_delivery ON "NH_Products"("deliveryStatus")',
      'CREATE INDEX IF NOT EXISTS idx_nh_products_sender_phone ON "NH_Products"("senderPhone")',
      'CREATE INDEX IF NOT EXISTS idx_nh_products_receiver_phone ON "NH_Products"("receiverPhone")',
      'CREATE INDEX IF NOT EXISTS idx_nh_products_vehicle ON "NH_Products"(vehicle)',
      'CREATE INDEX IF NOT EXISTS idx_nh_products_synced ON "NH_Products"("syncedToTongHop")',
      'CREATE INDEX IF NOT EXISTS idx_nh_productlogs_product ON "NH_ProductLogs"("productId")',
      'CREATE INDEX IF NOT EXISTS idx_nh_productlogs_action ON "NH_ProductLogs"(action)',
      'CREATE INDEX IF NOT EXISTS idx_nh_productlogs_changed_at ON "NH_ProductLogs"("changedAt")',
    ];

    for (const idx of indexes) {
      await queryNhapHang(idx);
    }
    results.push('✓ All indexes created');

    // ============================================================
    // Create updatedAt trigger function
    // ============================================================
    await queryNhapHang(`
      CREATE OR REPLACE FUNCTION update_nh_updated_at()
      RETURNS TRIGGER AS $$
      BEGIN
          NEW."updatedAt" = NOW();
          RETURN NEW;
      END;
      $$ LANGUAGE plpgsql
    `);
    results.push('✓ Trigger function created');

    // Triggers for auto-updating updatedAt
    await queryNhapHang(`DROP TRIGGER IF EXISTS trg_nh_stations_updated ON "NH_Stations"`);
    await queryNhapHang(`
      CREATE TRIGGER trg_nh_stations_updated
        BEFORE UPDATE ON "NH_Stations"
        FOR EACH ROW EXECUTE FUNCTION update_nh_updated_at()
    `);

    await queryNhapHang(`DROP TRIGGER IF EXISTS trg_nh_users_updated ON "NH_Users"`);
    await queryNhapHang(`
      CREATE TRIGGER trg_nh_users_updated
        BEFORE UPDATE ON "NH_Users"
        FOR EACH ROW EXECUTE FUNCTION update_nh_updated_at()
    `);

    await queryNhapHang(`DROP TRIGGER IF EXISTS trg_nh_products_updated ON "NH_Products"`);
    await queryNhapHang(`
      CREATE TRIGGER trg_nh_products_updated
        BEFORE UPDATE ON "NH_Products"
        FOR EACH ROW EXECUTE FUNCTION update_nh_updated_at()
    `);
    results.push('✓ Triggers created');

    // ============================================================
    // SAMPLE DATA - Stations
    // ============================================================
    const stationCount = await queryOneNhapHang('SELECT COUNT(*) as count FROM "NH_Stations"');

    if (parseInt(stationCount.count) === 0) {
      const stations = [
        { code: '01', name: 'AN ĐÔNG', fullName: '01 - AN ĐÔNG', address: 'Chợ An Đông, Q.5, TP.HCM', phone: '028-1234-5678', region: 'Sài Gòn' },
        { code: '02', name: 'HÀNG XANH', fullName: '02 - HÀNG XANH', address: 'Bến xe Hàng Xanh, Bình Thạnh', phone: '028-2345-6789', region: 'Sài Gòn' },
        { code: '03', name: 'NGUYỄN CƯ TRINH', fullName: '03 - NGUYỄN CƯ TRINH', address: 'Q.1, TP.HCM', phone: '028-3456-7890', region: 'Sài Gòn' },
        { code: '04', name: 'CHỢ CẦU', fullName: '04 - CHỢ CẦU', address: 'Q.12, TP.HCM', phone: '028-4567-8901', region: 'Sài Gòn' },
        { code: '05', name: 'NGÃ TƯ GA', fullName: '05 - NGÃ TƯ GA', address: 'Q.12, TP.HCM', phone: '028-5678-9012', region: 'Sài Gòn' },
        { code: '06', name: 'SUỐI TIÊN', fullName: '06 - SUỐI TIÊN', address: 'Q.9, TP.HCM', phone: '028-6789-0123', region: 'Sài Gòn' },
        { code: '07', name: 'LONG KHÁNH', fullName: '07 - LONG KHÁNH', address: 'TP Long Khánh, Đồng Nai', phone: '0251-1234-567', region: 'Long Khánh' },
        { code: '08', name: 'XUÂN LỘC', fullName: '08 - XUÂN LỘC', address: 'Xuân Lộc, Đồng Nai', phone: '0251-2345-678', region: 'Long Khánh' },
        { code: '00', name: 'DỌC ĐƯỜNG', fullName: '00 - DỌC ĐƯỜNG', address: 'Đón/trả dọc đường', phone: null, region: 'Dọc đường' },
        { code: '10', name: 'BẾN XE MIỀN ĐÔNG', fullName: '10 - BẾN XE MIỀN ĐÔNG', address: 'Bến xe Miền Đông mới, Q.9', phone: '028-7890-1234', region: 'Sài Gòn' },
      ];

      for (const s of stations) {
        await queryNhapHang(`
          INSERT INTO "NH_Stations" (code, name, "fullName", address, phone, region, "isActive")
          VALUES ($1, $2, $3, $4, $5, $6, true)
          ON CONFLICT (code) DO NOTHING
        `, [s.code, s.name, s.fullName, s.address, s.phone, s.region]);
      }
      results.push('✓ Default stations inserted');
    } else {
      results.push('○ Stations already exist, skipped');
    }

    // ============================================================
    // SAMPLE DATA - Users
    // ============================================================
    const userCount = await queryOneNhapHang('SELECT COUNT(*) as count FROM "NH_Users"');

    if (parseInt(userCount.count) === 0) {
      const users = [
        { username: 'admin', password: 'admin123', fullName: 'Quản trị viên', role: 'admin', station: null },
        { username: 'nv_andong', password: 'nv123456', fullName: 'Nhân viên An Đông', role: 'employee', station: '01 - AN ĐÔNG' },
        { username: 'nv_hangxanh', password: 'nv123456', fullName: 'Nhân viên Hàng Xanh', role: 'employee', station: '02 - HÀNG XANH' },
        { username: 'nv_longkhanh', password: 'nv123456', fullName: 'Nhân viên Long Khánh', role: 'employee', station: '07 - LONG KHÁNH' },
      ];

      for (const u of users) {
        await queryNhapHang(`
          INSERT INTO "NH_Users" (username, password, "fullName", role, station, active)
          VALUES ($1, $2, $3, $4, $5, true)
          ON CONFLICT (username) DO NOTHING
        `, [u.username, u.password, u.fullName, u.role, u.station]);
      }
      results.push('✓ Default users created');
    } else {
      results.push('○ Users already exist, skipped');
    }

    return NextResponse.json({
      success: true,
      message: 'NhapHang database setup completed!',
      tables: ['NH_Stations', 'NH_Users', 'NH_Counters', 'NH_Products', 'NH_ProductLogs'],
      results
    });

  } catch (error) {
    console.error('[NhapHang Setup] Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
