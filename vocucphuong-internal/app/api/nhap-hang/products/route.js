import { queryNhapHang, queryOneNhapHang, queryTongHop, queryOneTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: NH_Products - Đơn hàng vận chuyển
// ===========================================
// GET /api/nhap-hang/products - Lấy danh sách đơn hàng
// POST /api/nhap-hang/products - Tạo đơn hàng mới (+ tự động tạo TongHop booking nếu là Dọc Đường)

// Helper: Format date to DDMMYY
function formatDateKey(date) {
  const d = new Date(date);
  const day = String(d.getDate()).padStart(2, '0');
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const year = String(d.getFullYear()).slice(-2);
  return `${day}${month}${year}`;
}

// Helper: Format date to YYMMDD
function formatYYMMDD(date) {
  const d = new Date(date);
  const day = String(d.getDate()).padStart(2, '0');
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const year = String(d.getFullYear()).slice(-2);
  return `${year}${month}${day}`;
}

// Helper: Format date to DD-MM-YYYY for TongHop
function formatDDMMYYYY(date) {
  const d = new Date(date);
  const day = String(d.getDate()).padStart(2, '0');
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const year = d.getFullYear();
  return `${day}-${month}-${year}`;
}

// Helper: Generate product ID
function generateProductId(date, stationCode, sequence) {
  const yymmdd = formatYYMMDD(date);
  const ss = stationCode.padStart(2, '0');
  const nn = String(sequence).padStart(2, '0');
  return `${yymmdd}.${ss}${nn}`;
}

// Helper: Extract station code from fullName (e.g., "01 - AN ĐÔNG" -> "01")
function extractStationCode(fullName) {
  if (!fullName) return '00';
  const match = fullName.match(/^(\d+)/);
  return match ? match[1] : '00';
}

// Helper: Check if station is "Dọc Đường"
function isDocDuong(stationName) {
  if (!stationName) return false;
  const lower = stationName.toLowerCase();
  return lower.includes('dọc đường') || lower.includes('doc duong');
}

// Helper: Determine route based on stations
function determineRoute(senderStation, receiverStation) {
  const saiGonStations = ['AN ĐÔNG', 'HÀNG XANH', 'NGUYỄN CƯ TRINH', 'CHỢ CẦU', 'NGÃ TƯ GA', 'SUỐI TIÊN', 'BẾN XE MIỀN ĐÔNG'];
  const longKhanhStations = ['LONG KHÁNH', 'XUÂN LỘC'];

  const senderUpper = (senderStation || '').toUpperCase();
  const receiverUpper = (receiverStation || '').toUpperCase();

  const senderIsSaiGon = saiGonStations.some(s => senderUpper.includes(s));
  const receiverIsLongKhanh = longKhanhStations.some(s => receiverUpper.includes(s));

  if (senderIsSaiGon || receiverIsLongKhanh) {
    return 'Sài Gòn- Long Khánh';
  }
  return 'Long Khánh - Sài Gòn';
}

// Helper: Round time UP to next 30-minute slot
function roundToNextTimeSlot(date) {
  const d = new Date(date);
  const minutes = d.getMinutes();
  const hours = d.getHours();

  if (minutes === 0 || minutes === 30) {
    return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
  }

  if (minutes < 30) {
    return `${String(hours).padStart(2, '0')}:30`;
  } else {
    const nextHour = (hours + 1) % 24;
    return `${String(nextHour).padStart(2, '0')}:00`;
  }
}

// Lấy IP từ request
function getClientIP(request) {
  return request.headers.get('x-forwarded-for')?.split(',')[0] ||
         request.headers.get('x-real-ip') ||
         null;
}

// Helper: Ghi log thay đổi
async function logProductChange(productId, action, field, oldValue, newValue, changedBy, ipAddress) {
  try {
    await queryNhapHang(`
      INSERT INTO "NH_ProductLogs" ("productId", action, field, "oldValue", "newValue", "changedBy", "ipAddress")
      VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [
      productId,
      action,
      field || null,
      oldValue !== undefined && oldValue !== null ? String(oldValue) : null,
      newValue !== undefined && newValue !== null ? String(newValue) : null,
      changedBy,
      ipAddress || null
    ]);
  } catch (error) {
    console.error('Error logging product change:', error.message);
  }
}

// Helper: Create TongHop booking for Dọc Đường orders (DIRECT DATABASE, NO WEBHOOK)
async function createTongHopBooking(product) {
  try {
    const route = determineRoute(product.senderStation, product.station);
    const dateStr = formatDDMMYYYY(product.sendDate);
    const timeStr = roundToNextTimeSlot(product.sendDate);

    console.log(`[TongHop Integration] Creating booking for ${product.id}, route=${route}, date=${dateStr}, time=${timeStr}`);

    // Find or create timeslot
    let timeSlot = await queryOneTongHop(`
      SELECT id FROM "TH_TimeSlots"
      WHERE date = $1 AND time = $2 AND route = $3
    `, [dateStr, timeStr, route]);

    if (!timeSlot) {
      timeSlot = await queryOneTongHop(`
        INSERT INTO "TH_TimeSlots" (time, date, route)
        VALUES ($1, $2, $3)
        RETURNING id
      `, [timeStr, dateStr, route]);
      console.log(`[TongHop Integration] Created new timeslot: ${timeSlot.id}`);
    }

    // Find next available seat
    const usedSeats = await queryTongHop(`
      SELECT "seatNumber" FROM "TH_Bookings"
      WHERE "timeSlotId" = $1 AND "seatNumber" > 0
    `, [timeSlot.id]);

    const usedSeatNumbers = usedSeats.map(s => s.seatNumber);
    let nextSeat = 0;
    for (let i = 1; i <= 28; i++) {
      if (!usedSeatNumbers.includes(i)) {
        nextSeat = i;
        break;
      }
    }

    // Create booking
    const booking = await queryOneTongHop(`
      INSERT INTO "TH_Bookings" (
        "timeSlotId", phone, name, "pickupMethod", "pickupAddress",
        "dropoffMethod", "dropoffAddress", note, "seatNumber",
        amount, paid, "timeSlot", date, route
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
      RETURNING id
    `, [
      timeSlot.id,
      product.receiverPhone || '',
      product.receiverName || '',
      'Dọc đường',
      product.senderStation || '',
      'Dọc đường',
      product.station || '',
      `[NhapHang: ${product.id}] Xe: ${product.vehicle || ''} | SL: ${product.quantity || ''} | ${product.notes || ''}`,
      nextSeat,
      0,
      0,
      timeStr,
      dateStr,
      route
    ]);

    console.log(`[TongHop Integration] Created booking: ${booking.id} with seat ${nextSeat}`);
    return booking.id;

  } catch (error) {
    console.error('[CreateTongHopBooking] Error:', error);
    return null;
  }
}

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date'); // Format: YYYY-MM-DD
    const station = searchParams.get('station');
    const senderStation = searchParams.get('senderStation');
    const status = searchParams.get('status');
    const paymentStatus = searchParams.get('paymentStatus');
    const search = searchParams.get('search');
    const limit = parseInt(searchParams.get('limit')) || 500;
    const offset = parseInt(searchParams.get('offset')) || 0;

    let query = 'SELECT * FROM "NH_Products" WHERE 1=1';
    const params = [];
    let paramIndex = 1;

    // Filter by date (same day only)
    if (date) {
      query += ` AND DATE("sendDate") = $${paramIndex}`;
      params.push(date);
      paramIndex++;
    }

    // Filter by destination station
    if (station) {
      query += ` AND station = $${paramIndex}`;
      params.push(station);
      paramIndex++;
    }

    // Filter by sender station
    if (senderStation) {
      query += ` AND "senderStation" = $${paramIndex}`;
      params.push(senderStation);
      paramIndex++;
    }

    // Filter by status
    if (status) {
      query += ` AND status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    // Filter by payment status
    if (paymentStatus) {
      query += ` AND "paymentStatus" = $${paramIndex}`;
      params.push(paymentStatus);
      paramIndex++;
    }

    // Search by name/phone/id
    if (search) {
      query += ` AND ("receiverName" ILIKE $${paramIndex} OR "senderName" ILIKE $${paramIndex} OR "receiverPhone" ILIKE $${paramIndex} OR "senderPhone" ILIKE $${paramIndex} OR id ILIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    query += ` ORDER BY "sendDate" DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const products = await queryNhapHang(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM "NH_Products" WHERE 1=1';
    const countParams = [];
    let countIndex = 1;

    if (date) {
      countQuery += ` AND DATE("sendDate") = $${countIndex}`;
      countParams.push(date);
      countIndex++;
    }
    if (station) {
      countQuery += ` AND station = $${countIndex}`;
      countParams.push(station);
      countIndex++;
    }
    if (senderStation) {
      countQuery += ` AND "senderStation" = $${countIndex}`;
      countParams.push(senderStation);
      countIndex++;
    }
    if (status) {
      countQuery += ` AND status = $${countIndex}`;
      countParams.push(status);
      countIndex++;
    }
    if (paymentStatus) {
      countQuery += ` AND "paymentStatus" = $${countIndex}`;
      countParams.push(paymentStatus);
      countIndex++;
    }
    if (search) {
      countQuery += ` AND ("receiverName" ILIKE $${countIndex} OR "senderName" ILIKE $${countIndex} OR "receiverPhone" ILIKE $${countIndex} OR "senderPhone" ILIKE $${countIndex} OR id ILIKE $${countIndex})`;
      countParams.push(`%${search}%`);
      countIndex++;
    }

    const countResult = await queryOneNhapHang(countQuery, countParams);

    return NextResponse.json({
      success: true,
      data: products,
      products, // Backward compatibility
      count: products.length,
      total: parseInt(countResult.total),
      limit,
      offset
    });

  } catch (error) {
    console.error('[NH_Products] GET Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      message: error.message
    }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const body = await request.json();
    const {
      id: providedId,
      senderName,
      senderPhone,
      senderStation,
      receiverName,
      receiverPhone,
      station,
      productType,
      quantity,
      vehicle,
      insurance,
      totalAmount,
      paymentStatus,
      employee,
      createdBy,
      notes,
      sendDate
    } = body;

    // Validate required fields
    if (!senderStation || !station) {
      return NextResponse.json({
        success: false,
        error: 'senderStation và station là bắt buộc',
        message: 'senderStation và station là bắt buộc'
      }, { status: 400 });
    }

    // Generate product ID
    const stationCode = extractStationCode(senderStation);
    const sendDateTime = sendDate ? new Date(sendDate) : new Date();
    const dateKey = formatDateKey(sendDateTime);
    const counterKey = `counter_${stationCode}_${dateKey}`;

    let productId = providedId;

    if (!productId) {
      // Get next counter value
      const counterResult = await queryOneNhapHang(`
        INSERT INTO "NH_Counters" ("counterKey", station, "dateKey", value, "lastUpdated")
        VALUES ($1, $2, $3, 1, NOW())
        ON CONFLICT ("counterKey")
        DO UPDATE SET value = "NH_Counters".value + 1, "lastUpdated" = NOW()
        RETURNING value
      `, [counterKey, stationCode, dateKey]);

      productId = generateProductId(sendDateTime, stationCode, counterResult.value);
    }

    // Determine payment status based on amount
    const finalPaymentStatus = paymentStatus || (parseFloat(totalAmount) >= 10000 ? 'paid' : 'unpaid');

    // Insert product
    const result = await queryNhapHang(`
      INSERT INTO "NH_Products" (
        id, "senderName", "senderPhone", "senderStation",
        "receiverName", "receiverPhone", station,
        "productType", quantity, vehicle, insurance, "totalAmount",
        "paymentStatus", status, "deliveryStatus",
        employee, "createdBy", notes, "sendDate",
        "syncedToTongHop"
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, false
      )
      RETURNING *
    `, [
      productId,
      senderName || null,
      senderPhone || null,
      senderStation,
      receiverName || null,
      receiverPhone || null,
      station,
      productType || null,
      quantity || null,
      vehicle || null,
      insurance || 0,
      totalAmount || 0,
      finalPaymentStatus,
      'pending',
      'pending',
      employee || null,
      createdBy || null,
      notes || null,
      sendDateTime.toISOString()
    ]);

    const product = result[0];

    // Log creation
    const clientIP = getClientIP(request);
    await logProductChange(
      productId,
      'create',
      'product_info',
      null,
      JSON.stringify({ receiverName, receiverPhone, totalAmount: totalAmount || 0 }),
      createdBy || 'system',
      clientIP
    );

    // If destination is "Dọc Đường", auto-create TongHop booking (DIRECT DATABASE)
    let tongHopBookingId = null;
    if (isDocDuong(station)) {
      console.log(`[NhapHang] Đơn dọc đường detected: ${productId}, syncing to TongHop directly...`);

      tongHopBookingId = await createTongHopBooking({
        id: productId,
        senderStation,
        station,
        receiverName,
        receiverPhone,
        vehicle,
        quantity,
        notes,
        sendDate: sendDateTime
      });

      if (tongHopBookingId) {
        await queryNhapHang(`
          UPDATE "NH_Products"
          SET "tongHopBookingId" = $1, "syncedToTongHop" = true
          WHERE id = $2
        `, [tongHopBookingId, productId]);

        product.tongHopBookingId = tongHopBookingId;
        product.syncedToTongHop = true;

        console.log(`[NhapHang] Synced to TongHop booking ID: ${tongHopBookingId}`);
      }
    }

    return NextResponse.json({
      success: true,
      message: 'Tạo đơn hàng thành công!',
      data: product,
      product, // Backward compatibility
      tongHopBookingId
    }, { status: 201 });

  } catch (error) {
    console.error('[NH_Products] POST Error:', error);

    if (error.code === '23505') {
      return NextResponse.json({
        success: false,
        error: 'Product ID đã tồn tại',
        message: 'Product ID đã tồn tại'
      }, { status: 409 });
    }

    return NextResponse.json({
      success: false,
      error: error.message,
      message: error.message
    }, { status: 500 });
  }
}
