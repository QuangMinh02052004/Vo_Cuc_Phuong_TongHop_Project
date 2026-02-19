import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

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

// PUT - Chuẩn hóa route names và xóa duplicates
// FORMAT GỐC: 'Sài Gòn- Long Khánh' (KHÔNG space) và 'Long Khánh - Sài Gòn' (CÓ space)
export async function PUT(request) {
  try {
    const results = [];

    // Step 1: Đếm timeslots trước khi cleanup
    const beforeCount = await queryTongHop('SELECT COUNT(*) as count FROM "TH_TimeSlots"');
    results.push(`Before: ${beforeCount[0].count} timeslots`);

    // Step 2: Xóa tất cả timeslots với route format SAI "Sài Gòn - Long Khánh" (có space)
    await queryTongHop(`
      DELETE FROM "TH_TimeSlots"
      WHERE route = 'Sài Gòn - Long Khánh'
    `);
    results.push(`Deleted timeslots with wrong route format`);

    // Step 3: Chuẩn hóa bookings về đúng format
    await queryTongHop(`
      UPDATE "TH_Bookings"
      SET route = 'Sài Gòn- Long Khánh'
      WHERE route = 'Sài Gòn - Long Khánh'
    `);
    results.push(`Normalized bookings route`);

    // Step 4: XÓA DUPLICATE TIMESLOTS - giữ lại ID nhỏ nhất cho mỗi time/date/route
    // Đây là nguyên nhân chính gây mất ô timeslot!
    await queryTongHop(`
      DELETE FROM "TH_TimeSlots"
      WHERE id NOT IN (
        SELECT MIN(id) FROM "TH_TimeSlots"
        GROUP BY time, date, route
      )
    `);
    results.push(`Deleted duplicate timeslots (kept oldest ID)`);

    // Step 5: Fix bookings có timeSlotId không hợp lệ
    await queryTongHop(`
      UPDATE "TH_Bookings" b
      SET "timeSlotId" = (
        SELECT t.id FROM "TH_TimeSlots" t
        WHERE t.time = b."timeSlot" AND t.date = b.date AND t.route = b.route
        LIMIT 1
      )
      WHERE NOT EXISTS (
        SELECT 1 FROM "TH_TimeSlots" t WHERE t.id = b."timeSlotId"
      )
    `);
    results.push(`Fixed orphan booking timeSlotIds`);

    // Step 6: Đếm sau khi cleanup
    const afterCount = await queryTongHop('SELECT COUNT(*) as count FROM "TH_TimeSlots"');
    results.push(`After: ${afterCount[0].count} timeslots`);

    return NextResponse.json({
      success: true,
      message: 'Đã cleanup và chuẩn hóa dữ liệu',
      results,
      deleted: Number(beforeCount[0].count) - Number(afterCount[0].count)
    });

  } catch (error) {
    console.error('[Cleanup] Error:', error);
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
