import { queryNhapHang, queryOneNhapHang, queryTongHop, queryOneTongHop } from '../../../../lib/database';
import { extractAddressFromName, extractNameOnly } from '../../../../lib/stations';
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
// Giờ đã lưu trực tiếp là Vietnam time, không cần convert
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

// Helper: Convert sendDate to string without timezone (để frontend không bị convert)
function sanitizeSendDate(product) {
  if (product && product.sendDate) {
    // Nếu là Date object, convert thành string không có Z
    if (product.sendDate instanceof Date) {
      const d = product.sendDate;
      const year = d.getUTCFullYear();
      const month = String(d.getUTCMonth() + 1).padStart(2, '0');
      const day = String(d.getUTCDate()).padStart(2, '0');
      const hours = String(d.getUTCHours()).padStart(2, '0');
      const minutes = String(d.getUTCMinutes()).padStart(2, '0');
      const seconds = String(d.getUTCSeconds()).padStart(2, '0');
      product.sendDate = `${year}-${month}-${day}T${hours}:${minutes}:${seconds}`;
    } else if (typeof product.sendDate === 'string') {
      // Nếu đã là string, bỏ Z suffix
      product.sendDate = product.sendDate.replace('Z', '').replace(/[+-]\d{2}:\d{2}$/, '');
    }
  }
  return product;
}

// Helper: Check if station is "Dọc Đường" (handles various Unicode encodings)
function isDocDuong(stationName) {
  if (!stationName) return false;
  const lower = stationName.toLowerCase();

  // Check for "00 - " prefix (station code for Dọc Đường)
  if (lower.startsWith('00 -') || lower.startsWith('00-')) {
    console.log(`[isDocDuong] Matched by station code: "${stationName}"`);
    return true;
  }

  // Check for various forms of "dọc đường"
  // Vietnamese: dọc đường, doc duong, dọc duong, doc đường
  const patterns = [
    'dọc đường',    // Full Vietnamese
    'doc duong',    // ASCII
    'dọc duong',    // Mixed
    'doc đường',    // Mixed
    'dọc đuong',    // Typo variation
    'd\u1ecdc',     // Unicode: ọ = \u1ecd
    'đường'         // Just "đường" as fallback
  ];

  const matched = patterns.some(p => lower.includes(p));
  if (matched) {
    console.log(`[isDocDuong] Matched pattern in: "${stationName}"`);
  }
  return matched;
}

// Helper: Determine route based on sender station (matching original logic)
function determineRoute(senderStation, receiverStation) {
  if (!senderStation) {
    console.log('[RouteMapper] No senderStation, defaulting to "Sài Gòn- Long Khánh"');
    return 'Sài Gòn- Long Khánh';
  }

  const stationName = senderStation.toLowerCase();

  // Các trạm ở khu vực Long Khánh (GỬI TỪ Long Khánh ĐI Sài Gòn)
  const longKhanhStations = [
    'trảng bom', 'trang bom',
    'dầu giây', 'dau giay',
    'long khánh', 'long khanh',
    'bưu điện trảng bom', 'bu dien trang bom',
    'thu phí bầu cá', 'thu phi bau ca', 'bau ca',
    'hưng lộc', 'hung loc',
    'tam hiệp', 'tam hiep',
    'hố nai', 'ho nai',
    'bến xe hố nai', 'ben xe ho nai',
    'cầu sập', 'cau sap',
    'chợ sặt', 'cho sat',
    'ngã 4 621', 'nga 4 621',
    'tân vạn', 'tan van',
    'amata', 'xuân lộc', 'xuan loc'
  ];

  const isLongKhanhStation = longKhanhStations.some(name => stationName.includes(name));

  if (isLongKhanhStation) {
    console.log(`[RouteMapper] "${senderStation}" → "Long Khánh - Sài Gòn" (station in LK area)`);
    return 'Long Khánh - Sài Gòn';
  }

  // Các trạm ở khu vực Sài Gòn (GỬI TỪ Sài Gòn ĐI Long Khánh)
  const saigonStations = [
    'an đông', 'an dong',
    'metro', 'cantavil',
    'suối tiên', 'suoi tien',
    'cầu đen', 'cau den',
    'cầu trắng', 'cau trang',
    'thủ đức', 'thu duc',
    'bình thái', 'binh thai',
    'nguyễn thị minh khai', 'nguyen thi minh khai',
    'trần phú', 'tran phu',
    'pasteur', 'hàng xanh', 'hang xanh',
    'ngã tư ga', 'nga tu ga',
    'chợ cầu', 'cho cau',
    'bến xe miền đông', 'ben xe mien dong'
  ];

  const isSaigonStation = saigonStations.some(name => stationName.includes(name));

  if (isSaigonStation) {
    console.log(`[RouteMapper] "${senderStation}" → "Sài Gòn- Long Khánh" (station in SG area)`);
    return 'Sài Gòn- Long Khánh';
  }

  // Default: Sài Gòn
  console.log(`[RouteMapper] "${senderStation}" → "Sài Gòn- Long Khánh" (default)`);
  return 'Sài Gòn- Long Khánh';
}

// Helper: Làm tròn LÊN đến khung giờ 30 phút tiếp theo
// Date đã là Vietnam time, đọc trực tiếp
function roundToNextTimeSlot(date) {
  const d = new Date(date);
  let hours = d.getHours();
  let minutes = d.getMinutes();

  console.log(`[roundToNextTimeSlot] Input: ${hours}:${minutes}`);

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

// Helper: Format booking note - "giao {name} {quantity}" (matching original logic)
function formatBookingNote(receiverName, productType, quantity) {
  const name = receiverName || '';

  // Priority 1: Use 'quantity' field if provided
  if (quantity && quantity.trim()) {
    return `giao ${name} ${quantity}`;
  }

  // Priority 2: Extract type name from productType and use default "1"
  // If productType = "06 - Kiện" → extract "Kiện", return "1 Kiện"
  const type = productType || '';
  const match = type.match(/^(\d+)\s*-\s*(.+)$/);

  if (match) {
    const typeName = match[2].trim();
    return `giao ${name} 1 ${typeName}`;
  }

  // If productType doesn't have number format, use as-is with "1"
  if (type.trim()) {
    return `giao ${name} 1 ${type.trim()}`;
  }

  // Final fallback
  return `giao ${name} 1`;
}

// Helper: Lấy giờ phút từ date (đã là Vietnam time)
function getTimeFromDate(date) {
  const d = date || new Date();
  const hours = d.getHours();
  const minutes = d.getMinutes();
  return { hours, minutes, totalMinutes: hours * 60 + minutes };
}

// Helper: Find nearest timeslot (matching original timeslot-matcher logic)
// Date đã là Vietnam time, đọc trực tiếp
async function findNearestTimeslot(route, currentDate) {
  const now = currentDate || new Date();
  const timeInfo = getTimeFromDate(now);
  const currentHour = timeInfo.hours;
  const currentMinute = timeInfo.minutes;
  const currentTotalMinutes = timeInfo.totalMinutes;

  console.log(`[findNearestTimeslot] Time: ${currentHour}:${currentMinute}`);

  const todayDateStr = formatDDMMYYYY(now);

  // Step 1: Find future timeslots today
  const todaySlots = await queryTongHop(`
    SELECT * FROM "TH_TimeSlots"
    WHERE date = $1 AND route = $2
    ORDER BY time ASC
  `, [todayDateStr, route]);

  // Filter to find future slots
  for (const slot of todaySlots) {
    const [hours, minutes] = slot.time.split(':').map(Number);
    const slotTotalMinutes = hours * 60 + minutes;
    if (slotTotalMinutes > currentTotalMinutes) {
      return slot;
    }
  }

  // Step 2: No future slots today, get first slot tomorrow
  const tomorrow = new Date(now);
  tomorrow.setDate(tomorrow.getDate() + 1);
  const tomorrowDateStr = formatDDMMYYYY(tomorrow);

  const tomorrowSlot = await queryOneTongHop(`
    SELECT * FROM "TH_TimeSlots"
    WHERE date = $1 AND route = $2
    ORDER BY time ASC
    LIMIT 1
  `, [tomorrowDateStr, route]);

  return tomorrowSlot;
}

// Helper: Create TongHop booking for Dọc Đường orders (DIRECT DATABASE, matching original logic)
async function createTongHopBooking(product) {
  try {
    const route = determineRoute(product.senderStation, product.station);
    // ✅ FIX: Use product's sendDate (already in UTC), NOT current server time!
    const now = product.sendDate ? new Date(product.sendDate) : new Date();

    console.log(`[TongHop Integration] Creating booking for ${product.id}, route=${route}, sendDate=${now.toISOString()}`);

    // Find nearest timeslot (future today or first tomorrow)
    let timeSlot = await findNearestTimeslot(route, now);

    // If no timeslot found, create one for current time
    if (!timeSlot) {
      const dateStr = formatDDMMYYYY(now);
      const timeStr = roundToNextTimeSlot(now);

      timeSlot = await queryOneTongHop(`
        INSERT INTO "TH_TimeSlots" (time, date, route, type)
        VALUES ($1, $2, $3, 'Xe 28G')
        RETURNING *
      `, [timeStr, dateStr, route]);
      console.log(`[TongHop Integration] Created new timeslot: ${timeSlot.id}`);
    }

    console.log(`[TongHop Integration] Using timeslot: ${timeSlot.time} on ${timeSlot.date} (ID: ${timeSlot.id})`);

    // Find next available seat
    const usedSeats = await queryTongHop(`
      SELECT "seatNumber" FROM "TH_Bookings"
      WHERE "timeSlotId" = $1 AND "seatNumber" > 0
    `, [timeSlot.id]);

    const usedSeatNumbers = usedSeats.map(s => s.seatNumber);
    let nextSeat = 28; // Default to last seat if all occupied
    for (let i = 1; i <= 28; i++) {
      if (!usedSeatNumbers.includes(i)) {
        nextSeat = i;
        break;
      }
    }

    console.log(`[TongHop Integration] Found ${usedSeats.length} existing bookings, assigned seat ${nextSeat}`);

    // === Parse viết tắt từ receiverName ===
    const matchResult = extractAddressFromName(product.receiverName);
    const cleanName = matchResult
      ? extractNameOnly(product.receiverName, matchResult.matchedText)
      : (product.receiverName || '');
    const dropoffAddress = matchResult
      ? `${matchResult.stt}. ${matchResult.stationName}`
      : (product.station || 'Dọc đường');

    console.log(`[TongHop Integration] Address match: ${matchResult ? `${matchResult.stt}. ${matchResult.stationName}` : 'none'}, Clean name: "${cleanName}"`);

    // Format note: "giao {name} {quantity}"
    const bookingNote = formatBookingNote(cleanName, product.productType, product.quantity);

    // Create booking with correct format (matching original)
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
      cleanName,              // Tên đã bỏ phần viết tắt
      'Tại bến',           // pickupMethod - matching original
      'tại bến',           // pickupAddress - matching original (lowercase)
      'Dọc đường',         // dropoffMethod
      dropoffAddress,      // Điểm trả đã match (vd: "54. Trà Cổ")
      bookingNote,         // Format: "giao {cleanName} {quantity}"
      nextSeat,
      parseFloat(product.totalAmount) || 0,  // amount
      parseFloat(product.totalAmount) || 0,  // paid (already paid as freight)
      timeSlot.time,
      timeSlot.date,
      route
    ]);

    console.log(`[TongHop Integration] ✅ Created booking: ${booking.id} with seat ${nextSeat}, note: "${bookingNote}"`);
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

    // Sanitize sendDate cho tất cả products
    const sanitizedProducts = products.map(p => sanitizeSendDate({ ...p }));

    return NextResponse.json({
      success: true,
      data: sanitizedProducts,
      products: sanitizedProducts, // Backward compatibility
      count: sanitizedProducts.length,
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

    // ✅ SIMPLE FIX: Giữ nguyên giờ Vietnam, không cần convert
    // Frontend gửi 20:47 → Server lưu 20:47 → Hiển thị 20:47
    let sendDateTime;
    let sendDateString; // Lưu dạng string không có timezone

    if (sendDate) {
      // Bỏ Z suffix và timezone, giữ nguyên giờ Vietnam
      sendDateString = String(sendDate).replace('Z', '').replace(/[+-]\d{2}:\d{2}$/, '');
      sendDateTime = new Date(sendDateString);
      console.log(`[POST] sendDate: "${sendDate}" → stored as: "${sendDateString}"`);
    } else {
      // Không có sendDate → dùng giờ Vietnam hiện tại
      const now = new Date();
      const vnTime = new Date(now.getTime() + (7 * 60 * 60 * 1000));
      // Format thủ công không có Z
      sendDateString = vnTime.toISOString().replace('Z', '');
      sendDateTime = vnTime;
      console.log(`[POST] No sendDate, using Vietnam time: "${sendDateString}"`);
    }

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
      sendDateString  // Không có Z suffix để PostgreSQL không convert timezone
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
        productType,
        quantity,
        totalAmount,
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

    // Sanitize sendDate để không có Z suffix
    const sanitizedProduct = sanitizeSendDate({ ...product });

    return NextResponse.json({
      success: true,
      message: 'Tạo đơn hàng thành công!',
      data: sanitizedProduct,
      product: sanitizedProduct, // Backward compatibility
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
// Force deploy 1769295254
