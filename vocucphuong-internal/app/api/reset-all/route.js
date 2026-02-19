import { queryNhapHang, queryOneNhapHang, queryTongHop, queryOneTongHop } from '../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';

export const dynamic = 'force-dynamic';

// ===========================================
// API: RESET ALL DATABASES
// ===========================================
// GET /api/reset-all?confirm=yes
// Xóa và tạo lại toàn bộ database cho NhapHang và TongHop

// Khung giờ cho tuyến Sài Gòn - Long Khánh (05:30 - 20:00)
const SGtoLK_TIMES = [
  '05:30', '06:00', '06:30', '07:00', '07:30', '08:00', '08:30', '09:00', '09:30', '10:00',
  '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00',
  '15:30', '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30', '20:00'
];

// Khung giờ cho tuyến Long Khánh - Sài Gòn (03:30 - 18:00) - matching original
const LKtoSG_TIMES = [
  '03:30', '04:00', '04:30', '05:00', '05:30', '06:00', '06:30', '07:00', '07:30', '08:00',
  '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00',
  '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30', '18:00'
];

const ROUTE_SG_LK = 'Sài Gòn- Long Khánh';
const ROUTE_LK_SG = 'Long Khánh - Sài Gòn';

function formatDate(date) {
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const year = date.getFullYear();
  return `${day}-${month}-${year}`;
}

export async function GET(request) {
  const { searchParams } = new URL(request.url);
  const confirm = searchParams.get('confirm');

  if (confirm !== 'yes') {
    return NextResponse.json({
      success: false,
      message: 'Để xác nhận reset, thêm ?confirm=yes vào URL',
      warning: 'Thao tác này sẽ XÓA TOÀN BỘ dữ liệu!'
    }, { status: 400 });
  }

  const results = [];

  try {
    // ========================================
    // STEP 1: RESET TONGHOP DATABASE
    // ========================================
    results.push('=== RESETTING TONGHOP DATABASE ===');

    // Drop all TongHop tables (in correct order due to foreign keys)
    await queryTongHop('DROP TABLE IF EXISTS "TH_SeatLocks" CASCADE');
    await queryTongHop('DROP TABLE IF EXISTS "TH_Bookings" CASCADE');
    await queryTongHop('DROP TABLE IF EXISTS "TH_TimeSlots" CASCADE');
    await queryTongHop('DROP TABLE IF EXISTS "TH_Drivers" CASCADE');
    await queryTongHop('DROP TABLE IF EXISTS "TH_Vehicles" CASCADE');
    await queryTongHop('DROP TABLE IF EXISTS "TH_Users" CASCADE');
    results.push('✓ Dropped all TongHop tables');

    // Create TH_Users
    await queryTongHop(`
      CREATE TABLE "TH_Users" (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        "fullName" VARCHAR(100),
        role VARCHAR(20) DEFAULT 'employee',
        active BOOLEAN DEFAULT true,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✓ TH_Users table created');

    // Create TH_TimeSlots
    await queryTongHop(`
      CREATE TABLE "TH_TimeSlots" (
        id SERIAL PRIMARY KEY,
        time VARCHAR(10) NOT NULL,
        date VARCHAR(20),
        type VARCHAR(50) DEFAULT 'Xe 28G',
        code VARCHAR(20),
        driver VARCHAR(100),
        phone VARCHAR(20),
        route VARCHAR(100),
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✓ TH_TimeSlots table created');

    // Create TH_Bookings
    await queryTongHop(`
      CREATE TABLE "TH_Bookings" (
        id SERIAL PRIMARY KEY,
        "timeSlotId" INTEGER REFERENCES "TH_TimeSlots"(id) ON DELETE CASCADE,
        phone VARCHAR(20),
        name VARCHAR(200),
        gender VARCHAR(10),
        nationality VARCHAR(100),
        "pickupMethod" VARCHAR(50),
        "pickupAddress" VARCHAR(500),
        "dropoffMethod" VARCHAR(50),
        "dropoffAddress" VARCHAR(500),
        note TEXT,
        "seatNumber" INTEGER,
        amount DECIMAL(18,2),
        paid DECIMAL(18,2) DEFAULT 0,
        "timeSlot" VARCHAR(10),
        date VARCHAR(20),
        route VARCHAR(100),
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✓ TH_Bookings table created');

    // Create TH_Drivers
    await queryTongHop(`
      CREATE TABLE "TH_Drivers" (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        phone VARCHAR(20) NOT NULL,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✓ TH_Drivers table created');

    // Create TH_Vehicles
    await queryTongHop(`
      CREATE TABLE "TH_Vehicles" (
        id SERIAL PRIMARY KEY,
        code VARCHAR(20) NOT NULL UNIQUE,
        type VARCHAR(50) NOT NULL,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✓ TH_Vehicles table created');

    // Create TH_SeatLocks
    await queryTongHop(`
      CREATE TABLE "TH_SeatLocks" (
        id SERIAL PRIMARY KEY,
        "timeSlotId" INTEGER NOT NULL,
        "seatNumber" INTEGER NOT NULL,
        "lockedBy" VARCHAR(100) NOT NULL,
        "lockedByUserId" INTEGER,
        "lockedAt" TIMESTAMP DEFAULT NOW(),
        "expiresAt" TIMESTAMP NOT NULL,
        date VARCHAR(20) NOT NULL,
        route VARCHAR(100) NOT NULL,
        CONSTRAINT "UQ_SeatLock" UNIQUE ("timeSlotId", "seatNumber", date, route)
      )
    `);
    results.push('✓ TH_SeatLocks table created');

    // Create indexes
    await queryTongHop('CREATE INDEX IF NOT EXISTS idx_th_timeslots_date ON "TH_TimeSlots"(date)');
    await queryTongHop('CREATE INDEX IF NOT EXISTS idx_th_timeslots_route ON "TH_TimeSlots"(route)');
    await queryTongHop('CREATE INDEX IF NOT EXISTS idx_th_timeslots_time ON "TH_TimeSlots"(time)');
    await queryTongHop('CREATE INDEX IF NOT EXISTS idx_th_bookings_timeslot ON "TH_Bookings"("timeSlotId")');
    await queryTongHop('CREATE INDEX IF NOT EXISTS idx_th_bookings_date ON "TH_Bookings"(date)');
    await queryTongHop('CREATE INDEX IF NOT EXISTS idx_th_bookings_route ON "TH_Bookings"(route)');
    results.push('✓ TongHop indexes created');

    // Seed TongHop Users
    const hashedPassword = await bcrypt.hash('admin123', 10);
    await queryTongHop(`
      INSERT INTO "TH_Users" (username, password, "fullName", role) VALUES
      ('admin', $1, 'Administrator', 'admin'),
      ('quanly1', $1, 'Quản lý 1', 'manager'),
      ('nhanvien1', $1, 'Nhân viên 1', 'employee')
    `, [hashedPassword]);
    results.push('✓ TongHop users seeded (admin/quanly1/nhanvien1 - password: admin123)');

    // Seed Drivers
    await queryTongHop(`
      INSERT INTO "TH_Drivers" (name, phone) VALUES
      ('Nguyễn Văn A', '0901234567'),
      ('Trần Văn B', '0912345678'),
      ('Lê Văn C', '0923456789')
    `);
    results.push('✓ TongHop drivers seeded');

    // Seed Vehicles
    await queryTongHop(`
      INSERT INTO "TH_Vehicles" (code, type) VALUES
      ('29A-12345', 'Xe 28G'),
      ('29B-67890', 'Xe 28G'),
      ('51H-11111', 'Xe 28G')
    `);
    results.push('✓ TongHop vehicles seeded');

    // Seed TimeSlots for next 7 days
    const startDate = new Date();
    let totalTimeslots = 0;

    for (let i = 0; i < 7; i++) {
      const currentDate = new Date(startDate);
      currentDate.setDate(startDate.getDate() + i);
      const dateStr = formatDate(currentDate);

      // Tuyến Sài Gòn - Long Khánh
      for (const time of SGtoLK_TIMES) {
        await queryTongHop(`
          INSERT INTO "TH_TimeSlots" (time, date, route, type)
          VALUES ($1, $2, $3, 'Xe 28G')
        `, [time, dateStr, ROUTE_SG_LK]);
        totalTimeslots++;
      }

      // Tuyến Long Khánh - Sài Gòn
      for (const time of LKtoSG_TIMES) {
        await queryTongHop(`
          INSERT INTO "TH_TimeSlots" (time, date, route, type)
          VALUES ($1, $2, $3, 'Xe 28G')
        `, [time, dateStr, ROUTE_LK_SG]);
        totalTimeslots++;
      }
    }
    results.push(`✓ TongHop timeslots seeded (${totalTimeslots} slots for 7 days)`);

    // ========================================
    // STEP 2: RESET NHAPHANG DATABASE
    // ========================================
    results.push('=== RESETTING NHAPHANG DATABASE ===');

    // Drop all NhapHang tables
    await queryNhapHang('DROP TABLE IF EXISTS "ProductLogs" CASCADE');
    await queryNhapHang('DROP TABLE IF EXISTS "Products" CASCADE');
    await queryNhapHang('DROP TABLE IF EXISTS "Counters" CASCADE');
    await queryNhapHang('DROP TABLE IF EXISTS "Users" CASCADE');
    await queryNhapHang('DROP TABLE IF EXISTS "Stations" CASCADE');
    results.push('✓ Dropped all NhapHang tables');

    // Create Stations
    await queryNhapHang(`
      CREATE TABLE "Stations" (
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
    results.push('✓ Stations table created');

    // Create Users
    await queryNhapHang(`
      CREATE TABLE "Users" (
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
    results.push('✓ Users table created');

    // Create Counters
    await queryNhapHang(`
      CREATE TABLE "Counters" (
        id SERIAL PRIMARY KEY,
        "counterKey" VARCHAR(100) NOT NULL UNIQUE,
        station VARCHAR(10) NOT NULL,
        "dateKey" VARCHAR(10) NOT NULL,
        value INTEGER DEFAULT 0,
        "lastUpdated" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✓ Counters table created');

    // Create Products
    await queryNhapHang(`
      CREATE TABLE "Products" (
        id VARCHAR(50) PRIMARY KEY,
        "senderName" VARCHAR(100),
        "senderPhone" VARCHAR(20),
        "senderStation" VARCHAR(150) NOT NULL,
        "receiverName" VARCHAR(100),
        "receiverPhone" VARCHAR(20),
        station VARCHAR(150) NOT NULL,
        "productType" VARCHAR(200),
        quantity VARCHAR(500),
        vehicle VARCHAR(100),
        insurance DECIMAL(18,2) DEFAULT 0,
        "totalAmount" DECIMAL(18,2) DEFAULT 0,
        "paymentStatus" VARCHAR(20) DEFAULT 'unpaid',
        status VARCHAR(20) DEFAULT 'pending',
        "deliveryStatus" VARCHAR(50) DEFAULT 'pending',
        employee VARCHAR(100),
        "createdBy" VARCHAR(100),
        notes TEXT,
        "sendDate" TIMESTAMP NOT NULL,
        "deliveredAt" TIMESTAMP,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW(),
        "tongHopBookingId" INTEGER,
        "syncedToTongHop" BOOLEAN DEFAULT false
      )
    `);
    results.push('✓ Products table created');

    // Create ProductLogs
    await queryNhapHang(`
      CREATE TABLE "ProductLogs" (
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
    results.push('✓ ProductLogs table created');

    // Create NhapHang indexes
    await queryNhapHang('CREATE INDEX IF NOT EXISTS idx_products_senddate ON "Products"("sendDate")');
    await queryNhapHang('CREATE INDEX IF NOT EXISTS idx_products_station ON "Products"(station)');
    await queryNhapHang('CREATE INDEX IF NOT EXISTS idx_products_sender ON "Products"("senderStation")');
    await queryNhapHang('CREATE INDEX IF NOT EXISTS idx_products_synced ON "Products"("syncedToTongHop")');
    results.push('✓ NhapHang indexes created');

    // Seed Stations
    const stations = [
      { code: '01', name: 'AN ĐÔNG', fullName: '01 - AN ĐÔNG', region: 'Sài Gòn' },
      { code: '02', name: 'HÀNG XANH', fullName: '02 - HÀNG XANH', region: 'Sài Gòn' },
      { code: '03', name: 'NGUYỄN CƯ TRINH', fullName: '03 - NGUYỄN CƯ TRINH', region: 'Sài Gòn' },
      { code: '04', name: 'CHỢ CẦU', fullName: '04 - CHỢ CẦU', region: 'Sài Gòn' },
      { code: '05', name: 'NGÃ TƯ GA', fullName: '05 - NGÃ TƯ GA', region: 'Sài Gòn' },
      { code: '06', name: 'SUỐI TIÊN', fullName: '06 - SUỐI TIÊN', region: 'Sài Gòn' },
      { code: '07', name: 'LONG KHÁNH', fullName: '07 - LONG KHÁNH', region: 'Long Khánh' },
      { code: '08', name: 'XUÂN LỘC', fullName: '08 - XUÂN LỘC', region: 'Long Khánh' },
      { code: '09', name: 'TRẢNG BOM', fullName: '09 - TRẢNG BOM', region: 'Long Khánh' },
      { code: '10', name: 'BẾN XE MIỀN ĐÔNG', fullName: '10 - BẾN XE MIỀN ĐÔNG', region: 'Sài Gòn' },
      { code: '00', name: 'DỌC ĐƯỜNG', fullName: '00 - DỌC ĐƯỜNG', region: 'Dọc đường' },
    ];

    for (const s of stations) {
      await queryNhapHang(`
        INSERT INTO "Stations" (code, name, "fullName", region, "isActive")
        VALUES ($1, $2, $3, $4, true)
      `, [s.code, s.name, s.fullName, s.region]);
    }
    results.push('✓ NhapHang stations seeded');

    // Seed NhapHang Users
    const users = [
      { username: 'admin', password: 'admin123', fullName: 'Quản trị viên', role: 'admin', station: null },
      { username: 'nv_andong', password: 'nv123456', fullName: 'Nhân viên An Đông', role: 'employee', station: '01 - AN ĐÔNG' },
      { username: 'nv_hangxanh', password: 'nv123456', fullName: 'Nhân viên Hàng Xanh', role: 'employee', station: '02 - HÀNG XANH' },
      { username: 'nv_longkhanh', password: 'nv123456', fullName: 'Nhân viên Long Khánh', role: 'employee', station: '07 - LONG KHÁNH' },
    ];

    for (const u of users) {
      await queryNhapHang(`
        INSERT INTO "Users" (username, password, "fullName", role, station, active)
        VALUES ($1, $2, $3, $4, $5, true)
      `, [u.username, u.password, u.fullName, u.role, u.station]);
    }
    results.push('✓ NhapHang users seeded (admin/admin123, nv_*/nv123456)');

    return NextResponse.json({
      success: true,
      message: 'Reset toàn bộ database thành công!',
      timestamp: new Date().toISOString(),
      results
    });

  } catch (error) {
    console.error('[Reset All] Error:', error);
    return NextResponse.json({
      success: false,
      message: error.message,
      results
    }, { status: 500 });
  }
}
