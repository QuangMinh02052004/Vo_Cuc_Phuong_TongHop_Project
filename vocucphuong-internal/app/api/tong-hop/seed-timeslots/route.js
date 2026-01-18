import { queryTongHop, queryOneTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// Các khung giờ cho tuyến Sài Gòn - Long Khánh
const SGtoLK_times = [
  '05:30', '06:00', '06:30', '07:00', '07:30', '08:00', '08:30', '09:00', '09:30', '10:00',
  '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00',
  '15:30', '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30', '20:00'
];

// Các khung giờ cho tuyến Long Khánh - Sài Gòn (03:30 - 18:00) - matching original
const LKtoSG_times = [
  '03:30', '04:00', '04:30', '05:00', '05:30', '06:00', '06:30', '07:00', '07:30', '08:00',
  '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00',
  '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30', '18:00'
];

function formatDate(date) {
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const year = date.getFullYear();
  return `${day}-${month}-${year}`;
}

export async function GET(request) {
  try {
    // Kiểm tra số lượng timeslots hiện có
    const countResult = await queryOneTongHop('SELECT COUNT(*) as count FROM "TH_TimeSlots"');
    const existingCount = parseInt(countResult.count);

    if (existingCount > 1000) {
      return NextResponse.json({
        success: true,
        message: `Đã có ${existingCount} timeslots. Không cần seed thêm.`,
        count: existingCount
      });
    }

    // Xóa timeslots cũ
    await queryTongHop('DELETE FROM "TH_TimeSlots"');

    // Tạo timeslots cho 3 tháng
    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + 3);

    let totalCreated = 0;
    const currentDate = new Date(startDate);

    // Batch insert - tạo tất cả values cho một ngày rồi insert một lần
    while (currentDate <= endDate) {
      const dateString = formatDate(currentDate);

      // Tạo values array cho cả 2 tuyến trong một ngày
      const values = [];
      let paramIndex = 1;
      const params = [];

      // Tuyến Sài Gòn - Long Khánh
      for (const time of SGtoLK_times) {
        values.push(`($${paramIndex++}, $${paramIndex++}, $${paramIndex++}, $${paramIndex++})`);
        params.push(time, dateString, 'Sài Gòn- Long Khánh', 'Xe 28G');
      }

      // Tuyến Long Khánh - Sài Gòn (CÓ space trước dấu gạch - format gốc)
      for (const time of LKtoSG_times) {
        values.push(`($${paramIndex++}, $${paramIndex++}, $${paramIndex++}, $${paramIndex++})`);
        params.push(time, dateString, 'Long Khánh - Sài Gòn', 'Xe 28G');
      }

      // Batch insert cho 1 ngày (60 records)
      await queryTongHop(`
        INSERT INTO "TH_TimeSlots" (time, date, route, type)
        VALUES ${values.join(', ')}
      `, params);

      totalCreated += 60;
      currentDate.setDate(currentDate.getDate() + 1);
    }

    return NextResponse.json({
      success: true,
      message: `Đã tạo ${totalCreated} timeslots từ ${formatDate(startDate)} đến ${formatDate(endDate)}`,
      count: totalCreated
    });

  } catch (error) {
    return NextResponse.json({
      success: false,
      message: error.message
    }, { status: 500 });
  }
}
