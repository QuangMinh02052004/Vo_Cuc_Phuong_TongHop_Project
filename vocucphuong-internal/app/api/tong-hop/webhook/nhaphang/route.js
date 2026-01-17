import { queryTongHop, queryOneTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: WEBHOOK NHẬN ĐƠN "DỌC ĐƯỜNG" TỪ NHẬP HÀNG
// ===========================================
// POST /api/tong-hop/webhook/nhaphang

// Helper: Format date DD-MM-YYYY
function formatDate(dateStr) {
  const d = new Date(dateStr);
  const day = String(d.getDate()).padStart(2, '0');
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const year = d.getFullYear();
  return `${day}-${month}-${year}`;
}

// Helper: Xác định route dựa trên senderStation và station
function determineRoute(senderStation, receiverStation) {
  const sender = (senderStation || '').toLowerCase();
  const receiver = (receiverStation || '').toLowerCase();

  // Nếu gửi từ khu vực Sài Gòn
  const sgKeywords = ['an đông', 'hàng xanh', 'sài gòn', 'sg', 'hcm', 'bình dương', 'thủ đức'];
  // Nếu gửi từ khu vực Long Khánh
  const lkKeywords = ['long khánh', 'xuân lộc', 'sông ray', 'xuân trường', 'bảo bình', 'định quán', 'tân phú'];

  const senderIsSG = sgKeywords.some(k => sender.includes(k));
  const senderIsLK = lkKeywords.some(k => sender.includes(k));
  const receiverIsSG = sgKeywords.some(k => receiver.includes(k));
  const receiverIsLK = lkKeywords.some(k => receiver.includes(k));

  if (senderIsSG || receiverIsLK) {
    return 'Sài Gòn - Long Khánh';
  }
  if (senderIsLK || receiverIsSG) {
    return 'Long Khánh - Sài Gòn';
  }

  // Default - phần lớn là từ Sài Gòn về Long Khánh
  return 'Sài Gòn - Long Khánh';
}

// Helper: Xác định khung giờ từ sendDate hoặc vehicle
// Làm tròn về khung giờ gần nhất (30 phút)
// Sử dụng UTC+7 (Vietnam timezone)
function determineTimeSlot(sendDate, vehicle) {
  // Nếu có sendDate, lấy giờ từ đó
  if (sendDate) {
    const d = new Date(sendDate);
    // Chuyển sang giờ Việt Nam (UTC+7)
    let hours = d.getUTCHours() + 7;
    let minutes = d.getUTCMinutes();

    // Xử lý overflow
    if (hours >= 24) hours -= 24;

    console.log(`[determineTimeSlot] Input: ${sendDate}, UTC: ${d.getUTCHours()}:${d.getUTCMinutes()}, Vietnam: ${hours}:${minutes}`);

    // Làm tròn đến 30 phút gần nhất
    if (minutes < 15) {
      minutes = 0;
    } else if (minutes < 45) {
      minutes = 30;
    } else {
      minutes = 0;
      hours = (hours + 1) % 24;
    }

    // Giới hạn trong khoảng 05:30 - 20:30
    if (hours < 5 || (hours === 5 && minutes < 30)) {
      return '05:30';
    }
    if (hours > 20 || (hours === 20 && minutes > 30)) {
      return '20:30';
    }

    const result = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
    console.log(`[determineTimeSlot] Result: ${result}`);
    return result;
  }

  // Default: 08:00
  console.log('[determineTimeSlot] No sendDate, using default 08:00');
  return '08:00';
}

// Helper: Tìm hoặc tạo timeslot phù hợp
async function findOrCreateTimeSlot(date, time, route) {
  const formattedDate = formatDate(date);

  // Tìm timeslot có sẵn
  let timeSlot = await queryOneTongHop(
    `SELECT * FROM "TH_TimeSlots"
     WHERE date = $1 AND time = $2 AND route = $3`,
    [formattedDate, time, route]
  );

  if (timeSlot) {
    return timeSlot;
  }

  // Không có thì tạo mới
  const result = await queryTongHop(
    `INSERT INTO "TH_TimeSlots" (time, date, route, type)
     VALUES ($1, $2, $3, 'Xe 28G')
     RETURNING *`,
    [time, formattedDate, route]
  );

  return result[0];
}

// Helper: Tìm ghế trống tiếp theo
async function findNextAvailableSeat(timeSlotId, date, route) {
  const bookedSeats = await queryTongHop(
    `SELECT "seatNumber" FROM "TH_Bookings"
     WHERE "timeSlotId" = $1 AND date = $2 AND route = $3
     AND "seatNumber" > 0`,
    [timeSlotId, date, route]
  );

  const bookedNumbers = bookedSeats.map(b => b.seatNumber);

  for (let i = 1; i <= 28; i++) {
    if (!bookedNumbers.includes(i)) {
      return i;
    }
  }

  return 0;
}

export async function POST(request) {
  try {
    const body = await request.json();
    console.log('[Webhook NhapHang] Received order:', body);

    const {
      productId,      // ID đơn hàng từ NhapHang
      receiverName,   // Tên người nhận = tên hành khách
      receiverPhone,  // SĐT người nhận
      senderStation,  // Trạm gửi
      station,        // Trạm nhận ("00 - DỌC ĐƯỜNG")
      vehicle,        // Biển số xe
      sendDate,       // Ngày gửi
      notes,          // Ghi chú
      quantity = 1    // Số lượng (= số vé)
    } = body;

    // Validate required fields
    if (!receiverName || !receiverPhone) {
      return NextResponse.json({
        success: false,
        error: 'Thiếu thông tin bắt buộc (receiverName, receiverPhone)'
      }, { status: 400 });
    }

    // Xác định route và time
    const route = determineRoute(senderStation, station);
    const time = determineTimeSlot(sendDate, vehicle);
    const formattedDate = formatDate(sendDate || new Date());

    console.log(`[Webhook NhapHang] Route: ${route}, Time: ${time}, Date: ${formattedDate}`);

    // Tìm hoặc tạo timeslot
    const timeSlot = await findOrCreateTimeSlot(
      sendDate || new Date(),
      time,
      route
    );

    // Tạo booking cho số lượng vé
    const createdBookings = [];

    for (let i = 0; i < quantity; i++) {
      const seatNumber = await findNextAvailableSeat(timeSlot.id, formattedDate, route);

      if (seatNumber === 0) {
        console.log('[Webhook NhapHang] Hết ghế trống cho đơn:', productId);
        break;
      }

      const result = await queryTongHop(`
        INSERT INTO "TH_Bookings" (
          "timeSlotId", phone, name, gender, nationality,
          "pickupMethod", "pickupAddress", "dropoffMethod", "dropoffAddress",
          note, "seatNumber", amount, paid, "timeSlot", date, route
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
        RETURNING *
      `, [
        timeSlot.id,
        receiverPhone,
        receiverName,
        '', // gender
        '', // nationality
        'Dọc đường', // pickupMethod
        senderStation || '', // pickupAddress - điểm đón
        'Dọc đường', // dropoffMethod
        station || '', // dropoffAddress - điểm trả
        `[NhapHang: ${productId}] Xe: ${vehicle || 'N/A'} | ${notes || ''}`.trim(),
        seatNumber,
        0, // amount - hàng dọc đường thường không tính tiền vé
        0, // paid
        time,
        formattedDate,
        route
      ]);

      createdBookings.push(result[0]);
    }

    console.log(`[Webhook NhapHang] Created ${createdBookings.length} booking(s) for order ${productId}`);

    return NextResponse.json({
      success: true,
      message: `Đã tạo ${createdBookings.length} booking từ NhapHang`,
      data: {
        productId,
        bookingsCreated: createdBookings.length,
        timeSlot: timeSlot.time,
        date: formattedDate,
        route
      }
    }, { status: 201 });

  } catch (error) {
    console.error('[Webhook NhapHang] Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

// GET - Health check
export async function GET() {
  return NextResponse.json({
    success: true,
    message: 'Webhook NhapHang endpoint is active',
    timestamp: new Date().toISOString()
  });
}
// Force deploy 1768657155
