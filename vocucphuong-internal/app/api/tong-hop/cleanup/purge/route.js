import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: XÓA TẤT CẢ TIMESLOTS CŨ, GIỮ LẠI 7 NGÀY GẦN NHẤT
// ===========================================
// POST /api/tong-hop/cleanup/purge

export async function POST(request) {
  try {
    // Lấy danh sách ngày cần giữ (7 ngày gần nhất)
    const today = new Date();
    const keepDates = [];
    for (let i = 0; i < 7; i++) {
      const d = new Date(today);
      d.setDate(d.getDate() + i);
      const day = String(d.getDate()).padStart(2, '0');
      const month = String(d.getMonth() + 1).padStart(2, '0');
      const year = d.getFullYear();
      keepDates.push(`${day}-${month}-${year}`);
    }

    console.log('[Purge] Keeping dates:', keepDates);

    // Đếm trước
    const beforeCount = await queryTongHop('SELECT COUNT(*) as count FROM "TH_TimeSlots"');

    // Xóa timeslots không nằm trong danh sách ngày cần giữ
    await queryTongHop(`
      DELETE FROM "TH_TimeSlots"
      WHERE date NOT IN (${keepDates.map((_, i) => `$${i + 1}`).join(', ')})
    `, keepDates);

    // Đếm sau
    const afterCount = await queryTongHop('SELECT COUNT(*) as count FROM "TH_TimeSlots"');

    return NextResponse.json({
      success: true,
      message: 'Đã xóa timeslots cũ',
      keepDates,
      before: Number(beforeCount[0].count),
      after: Number(afterCount[0].count),
      deleted: Number(beforeCount[0].count) - Number(afterCount[0].count)
    });

  } catch (error) {
    console.error('[Purge] Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

// PUT - Chuẩn hóa route names về FORMAT GỐC
// FORMAT GỐC: 'Sài Gòn- Long Khánh' (KHÔNG space) và 'Long Khánh - Sài Gòn' (CÓ space)
export async function PUT(request) {
  try {
    // Chuẩn hóa về format gốc
    // "Sài Gòn - Long Khánh" -> "Sài Gòn- Long Khánh" (bỏ space trước dấu gạch)

    const result1 = await queryTongHop(`
      UPDATE "TH_TimeSlots"
      SET route = 'Sài Gòn- Long Khánh'
      WHERE route = 'Sài Gòn - Long Khánh'
    `);

    // "Long Khánh- Sài Gòn" -> "Long Khánh - Sài Gòn" (thêm space nếu thiếu)
    const result2 = await queryTongHop(`
      UPDATE "TH_TimeSlots"
      SET route = 'Long Khánh - Sài Gòn'
      WHERE route = 'Long Khánh- Sài Gòn'
    `);

    // Cũng chuẩn hóa bookings
    await queryTongHop(`
      UPDATE "TH_Bookings"
      SET route = 'Sài Gòn- Long Khánh'
      WHERE route = 'Sài Gòn - Long Khánh'
    `);

    await queryTongHop(`
      UPDATE "TH_Bookings"
      SET route = 'Long Khánh - Sài Gòn'
      WHERE route = 'Long Khánh- Sài Gòn'
    `);

    return NextResponse.json({
      success: true,
      message: 'Đã chuẩn hóa route names về format gốc'
    });

  } catch (error) {
    console.error('[Normalize] Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

// GET - Xem thống kê theo ngày
export async function GET(request) {
  try {
    const byDate = await queryTongHop(`
      SELECT date, COUNT(*) as count
      FROM "TH_TimeSlots"
      GROUP BY date
      ORDER BY date DESC
      LIMIT 20
    `);

    return NextResponse.json({
      success: true,
      byDate
    });

  } catch (error) {
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
