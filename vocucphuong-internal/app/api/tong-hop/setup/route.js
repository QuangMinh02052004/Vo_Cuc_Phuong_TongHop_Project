import { queryTongHop, queryOneTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';

export const dynamic = 'force-dynamic';

export async function GET(request) {
  const results = [];

  try {
    // Tạo bảng TH_Users
    await queryTongHop(`
      CREATE TABLE IF NOT EXISTS "TH_Users" (
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
    results.push('✅ TH_Users table ready');

    // Thêm cột email, phone nếu chưa có
    try {
      await queryTongHop(`ALTER TABLE "TH_Users" ADD COLUMN IF NOT EXISTS email VARCHAR(100)`);
      await queryTongHop(`ALTER TABLE "TH_Users" ADD COLUMN IF NOT EXISTS phone VARCHAR(20)`);
      results.push('✅ TH_Users email/phone columns ready');
    } catch (e) {
      results.push('⚠️ TH_Users alter: ' + e.message);
    }

    // Seed Users nếu chưa có
    const userCount = await queryOneTongHop('SELECT COUNT(*) as count FROM "TH_Users"');
    if (parseInt(userCount.count) === 0) {
      const hashedPassword = await bcrypt.hash('admin123', 10);
      await queryTongHop(`
        INSERT INTO "TH_Users" (username, password, "fullName", role) VALUES
        ('admin', $1, 'Administrator', 'admin'),
        ('quanly1', $1, 'Quản lý 1', 'manager'),
        ('nhanvien1', $1, 'Nhân viên 1', 'employee')
      `, [hashedPassword]);
      results.push('✅ Users seeded (admin/quanly1/nhanvien1 - password: admin123)');
    }

    // Tạo bảng TH_TimeSlots
    await queryTongHop(`
      CREATE TABLE IF NOT EXISTS "TH_TimeSlots" (
        id SERIAL PRIMARY KEY,
        time VARCHAR(10) NOT NULL,
        date VARCHAR(20),
        type VARCHAR(50),
        code VARCHAR(20),
        driver VARCHAR(100),
        phone VARCHAR(20),
        route VARCHAR(100),
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✅ TH_TimeSlots table ready');

    // Tạo bảng TH_Bookings
    await queryTongHop(`
      CREATE TABLE IF NOT EXISTS "TH_Bookings" (
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
    results.push('✅ TH_Bookings table ready');

    // Tạo bảng TH_Drivers
    await queryTongHop(`
      CREATE TABLE IF NOT EXISTS "TH_Drivers" (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        phone VARCHAR(20) NOT NULL,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✅ TH_Drivers table ready');

    // Tạo bảng TH_Vehicles
    await queryTongHop(`
      CREATE TABLE IF NOT EXISTS "TH_Vehicles" (
        id SERIAL PRIMARY KEY,
        code VARCHAR(20) NOT NULL UNIQUE,
        type VARCHAR(50) NOT NULL,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✅ TH_Vehicles table ready');

    // Tạo bảng TH_SeatLocks
    await queryTongHop(`
      CREATE TABLE IF NOT EXISTS "TH_SeatLocks" (
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
    results.push('✅ TH_SeatLocks table ready');

    // Seed Drivers
    const driverCount = await queryOneTongHop('SELECT COUNT(*) as count FROM "TH_Drivers"');
    if (parseInt(driverCount.count) === 0) {
      await queryTongHop(`
        INSERT INTO "TH_Drivers" (name, phone) VALUES
        ('Nguyễn Văn A', '0901234567'),
        ('Trần Văn B', '0912345678'),
        ('Lê Văn C', '0923456789')
      `);
      results.push('✅ Drivers seeded');
    }

    // Seed Vehicles
    const vehicleCount = await queryOneTongHop('SELECT COUNT(*) as count FROM "TH_Vehicles"');
    if (parseInt(vehicleCount.count) === 0) {
      await queryTongHop(`
        INSERT INTO "TH_Vehicles" (code, type) VALUES
        ('29A-12345', 'Limousine 9 chỗ'),
        ('29B-67890', 'Limousine 9 chỗ'),
        ('51H-11111', 'Limousine 12 chỗ')
      `);
      results.push('✅ Vehicles seeded');
    }

    // Tạo bảng TH_Routes
    await queryTongHop(`
      CREATE TABLE IF NOT EXISTS "TH_Routes" (
        id SERIAL PRIMARY KEY,
        name VARCHAR(200) NOT NULL UNIQUE,
        "routeType" VARCHAR(50) DEFAULT 'quoc_lo',
        "fromStation" VARCHAR(100),
        "toStation" VARCHAR(100),
        price DECIMAL(18,2) DEFAULT 0,
        duration VARCHAR(50),
        "busType" VARCHAR(50) DEFAULT 'Ghế ngồi',
        seats INTEGER DEFAULT 28,
        distance VARCHAR(50),
        "operatingStart" VARCHAR(10) DEFAULT '03:30',
        "operatingEnd" VARCHAR(10) DEFAULT '18:00',
        "intervalMinutes" INTEGER DEFAULT 30,
        "isActive" BOOLEAN DEFAULT true,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✅ TH_Routes table ready');

    // Thêm cột mới cho TH_Routes nếu chưa có (migration)
    try {
      await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "fromStation" VARCHAR(100)`);
      await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "toStation" VARCHAR(100)`);
      await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "busType" VARCHAR(50) DEFAULT 'Ghế ngồi'`);
      await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS seats INTEGER DEFAULT 28`);
      await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS distance VARCHAR(50)`);
      await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "operatingStart" VARCHAR(10) DEFAULT '03:30'`);
      await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "operatingEnd" VARCHAR(10) DEFAULT '18:00'`);
      await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "intervalMinutes" INTEGER DEFAULT 30`);
      results.push('✅ TH_Routes columns migrated');
    } catch (e) {
      results.push('⚠️ TH_Routes migration: ' + e.message);
    }

    // Seed Routes nếu chưa có
    const routeCount = await queryOneTongHop('SELECT COUNT(*) as count FROM "TH_Routes"');
    if (parseInt(routeCount.count) === 0) {
      await queryTongHop(`
        INSERT INTO "TH_Routes" (name, "routeType", "fromStation", "toStation", price, duration, "busType", seats, distance, "operatingStart", "operatingEnd", "intervalMinutes") VALUES
        ('Long Khánh - Sài Gòn (Cao tốc)', 'cao_toc', 'Long Khánh', 'Sài Gòn', 120000, '1.5 giờ', 'Ghế ngồi', 28, '80 km', '03:30', '18:00', 30),
        ('Long Khánh - Sài Gòn (Quốc lộ)', 'quoc_lo', 'Long Khánh', 'Sài Gòn', 110000, '2 giờ', 'Ghế ngồi', 28, '80 km', '03:30', '18:00', 30),
        ('Sài Gòn - Long Khánh (Cao tốc)', 'cao_toc', 'Sài Gòn', 'Long Khánh', 120000, '1.5 giờ', 'Ghế ngồi', 28, '80 km', '05:30', '20:00', 30),
        ('Sài Gòn - Long Khánh (Quốc lộ)', 'quoc_lo', 'Sài Gòn', 'Long Khánh', 110000, '~ 2 giờ 30 phút', 'Ghế ngồi', 28, '80 km', '05:30', '20:00', 30),
        ('Sài Gòn - Xuân Lộc (Cao tốc)', 'cao_toc', 'Sài Gòn', 'Xuân Lộc', 130000, '2 giờ ~ 4 giờ', 'Ghế ngồi', 28, '80 km', '05:30', '18:30', 30),
        ('Quốc Lộ 1A - Xuân Lộc (Quốc lộ)', 'quoc_lo', 'Quốc Lộ 1A', 'Xuân Lộc', 130000, '1.5 giờ ~ 4 tiếng', 'Ghế ngồi', 28, '80 km', '05:30', '17:00', 30),
        ('Xuân Lộc - Long Khánh (Cao tốc)', 'cao_toc', 'Xuân Lộc', 'Long Khánh', 130000, '1 giờ', 'Ghế ngồi', 28, '80 km', '03:30', '17:00', 30),
        ('Xuân Lộc - Long Khánh (Quốc lộ)', 'quoc_lo', 'Xuân Lộc', 'Long Khánh', 130000, '1.5 giờ', 'Ghế ngồi', 28, '80 km', '03:30', '17:00', 30)
      `);
      results.push('✅ Routes seeded (8 tuyến mặc định - khớp DatVe)');
    }

    // Clean expired seat locks
    await queryTongHop('DELETE FROM "TH_SeatLocks" WHERE "expiresAt" < NOW()');
    results.push('✅ Cleaned expired seat locks');

    return NextResponse.json({
      success: true,
      message: 'Tổng Hợp Database setup completed!',
      results
    });

  } catch (error) {
    return NextResponse.json({
      success: false,
      message: error.message,
      results
    }, { status: 500 });
  }
}
