import { queryTongHop, queryOneTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// ===========================================
// API: WEBHOOK NHẬN BOOKING TỪ DATVE (Website Đặt Vé)
// ===========================================
// POST /api/tong-hop/webhook/datve

// Helper: Format date DD-MM-YYYY
function formatDate(dateStr) {
  const d = new Date(dateStr);
  const day = String(d.getDate()).padStart(2, '0');
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const year = d.getFullYear();
  return `${day}-${month}-${year}`;
}

// Helper: Xác định route name từ DatVe route string
// DatVe gửi dạng: "Long Khánh → Sài Gòn (Cao tốc)" hoặc "Sài Gòn → Long Khánh (Quốc lộ)"
// TongHop routes dạng: "Long Khánh - Sài Gòn (Cao tốc)"
async function determineRoute(routeStr) {
  const raw = (routeStr || '').trim();

  // 1. Parse route string từ DatVe: "From → To (Type)"
  // Extract from, to, type
  const arrowMatch = raw.match(/^(.+?)\s*[→\->]+\s*(.+)$/);
  let from = '', to = '', routeType = '';

  if (arrowMatch) {
    from = arrowMatch[1].trim();
    to = arrowMatch[2].trim();
  } else {
    from = raw;
  }

  // Extract route type from "to" field: "Sài Gòn (Cao tốc)" → to="Sài Gòn", type="Cao tốc"
  const typeMatch = to.match(/^(.+?)\s*\(([^)]+)\)\s*$/);
  if (typeMatch) {
    to = typeMatch[1].trim();
    routeType = typeMatch[2].trim().toLowerCase();
  }

  // 2. Tìm route match trong TH_Routes database
  try {
    const allRoutes = await queryTongHop('SELECT * FROM "TH_Routes" WHERE "isActive" = true');

    if (allRoutes.length > 0) {
      // Thử exact match trước: "Long Khánh - Sài Gòn (Cao tốc)"
      const typeSuffix = routeType.includes('cao') ? 'Cao tốc' : routeType.includes('qu') ? 'Quốc lộ' : '';
      const targetName = typeSuffix ? `${from} - ${to} (${typeSuffix})` : `${from} - ${to}`;

      // Tìm exact match (case-insensitive)
      let matched = allRoutes.find(r =>
        r.name.toLowerCase() === targetName.toLowerCase()
      );

      // Nếu không exact match, tìm fuzzy: route chứa cả from, to, và type
      if (!matched && from && to) {
        matched = allRoutes.find(r => {
          const name = r.name.toLowerCase();
          const hasFrom = name.includes(from.toLowerCase());
          const hasTo = name.includes(to.toLowerCase());
          const hasType = !typeSuffix || name.includes(typeSuffix.toLowerCase());
          // Kiểm tra hướng: from phải đứng trước to
          if (hasFrom && hasTo && hasType) {
            const fromIdx = name.indexOf(from.toLowerCase());
            const toIdx = name.indexOf(to.toLowerCase());
            return fromIdx < toIdx;
          }
          return false;
        });
      }

      // Nếu match được, dùng tên route từ database
      if (matched) {
        console.log(`[Webhook] Route matched: "${raw}" → "${matched.name}"`);
        return matched.name;
      }
    }
  } catch (err) {
    console.error('[Webhook] Error querying routes:', err.message);
  }

  // 3. Fallback: tạo tên route từ parsed data
  const typeSuffix = routeType.includes('cao') ? ' (Cao tốc)' : routeType.includes('qu') ? ' (Quốc lộ)' : '';
  if (from && to) {
    return `${from} - ${to}${typeSuffix}`;
  }

  // 4. Legacy fallback cho route cũ không có type
  const route = raw.toLowerCase();
  const sgPos = route.indexOf('sài gòn');
  const lkPos = route.indexOf('long khánh');

  if (sgPos !== -1 && lkPos !== -1) {
    return sgPos < lkPos ? `Sài Gòn - Long Khánh${typeSuffix}` : `Long Khánh - Sài Gòn${typeSuffix}`;
  }

  return `Sài Gòn - Long Khánh${typeSuffix}` || 'Sài Gòn - Long Khánh';
}

// Helper: Tìm hoặc tạo timeslot phù hợp
async function findOrCreateTimeSlot(date, time, route) {
  // Format date to DD-MM-YYYY
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
  // Lấy danh sách ghế đã đặt
  const bookedSeats = await queryTongHop(
    `SELECT "seatNumber" FROM "TH_Bookings"
     WHERE "timeSlotId" = $1 AND date = $2 AND route = $3
     AND "seatNumber" > 0`,
    [timeSlotId, date, route]
  );

  const bookedNumbers = bookedSeats.map(b => b.seatNumber);

  // Tìm ghế trống từ 1-28
  for (let i = 1; i <= 28; i++) {
    if (!bookedNumbers.includes(i)) {
      return i;
    }
  }

  // Hết ghế, trả về 0
  return 0;
}

export async function POST(request) {
  try {
    const body = await request.json();
    console.log('[Webhook DatVe] Received booking:', body);

    const {
      bookingCode,
      customerName,
      customerPhone,
      date,
      departureTime,
      seats = 1,
      totalPrice = 0,
      route: routeStr,
      notes
    } = body;

    // Validate required fields
    if (!customerName || !customerPhone) {
      return NextResponse.json({
        success: false,
        error: 'Thiếu thông tin bắt buộc (customerName, customerPhone)'
      }, { status: 400 });
    }

    // Xác định route (async - query database)
    const route = await determineRoute(routeStr);
    const formattedDate = formatDate(date || new Date());

    // Tìm hoặc tạo timeslot
    const timeSlot = await findOrCreateTimeSlot(
      date || new Date(),
      departureTime || '06:00',
      route
    );

    // Tạo booking cho mỗi ghế
    const createdBookings = [];

    for (let i = 0; i < seats; i++) {
      // Tìm ghế trống
      const seatNumber = await findNextAvailableSeat(timeSlot.id, formattedDate, route);

      if (seatNumber === 0) {
        console.log('[Webhook DatVe] Hết ghế trống cho booking:', bookingCode);
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
        customerPhone,
        customerName,
        '', // gender
        '', // nationality
        'Website', // pickupMethod
        '', // pickupAddress
        'Bến xe', // dropoffMethod
        '', // dropoffAddress
        `[DatVe: ${bookingCode}] ${notes || ''}`.trim(),
        seatNumber,
        totalPrice / seats, // amount per seat
        0, // paid
        departureTime || timeSlot.time,
        formattedDate,
        route
      ]);

      createdBookings.push(result[0]);
    }

    console.log(`[Webhook DatVe] Created ${createdBookings.length} booking(s) for ${bookingCode}`);

    return NextResponse.json({
      success: true,
      message: `Đã nhận ${createdBookings.length} booking từ DatVe`,
      data: {
        bookingCode,
        bookingsCreated: createdBookings.length,
        timeSlot: timeSlot.time,
        date: formattedDate,
        route
      }
    }, { status: 201 });

  } catch (error) {
    console.error('[Webhook DatVe] Error:', error);
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
    message: 'Webhook DatVe endpoint is active',
    timestamp: new Date().toISOString()
  });
}
