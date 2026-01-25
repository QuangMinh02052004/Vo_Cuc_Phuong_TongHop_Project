import { queryNhapHang, queryOneNhapHang, queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: Freight - Đơn hàng dọc đường từ NhapHang
// ===========================================
// GET /api/tong-hop/freight - Lấy danh sách đơn dọc đường đã sync
// GET /api/tong-hop/freight/stats/summary - Thống kê

// Helper: Check if station is "Dọc Đường"
function isDocDuong(stationName) {
  if (!stationName) return false;
  const lower = stationName.toLowerCase();

  if (lower.startsWith('00 -') || lower.startsWith('00-')) {
    return true;
  }

  const patterns = [
    'dọc đường', 'doc duong', 'dọc duong', 'doc đường'
  ];

  return patterns.some(p => lower.includes(p));
}

// Helper: Sanitize sendDate
function sanitizeSendDate(product) {
  if (product && product.sendDate) {
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
      product.sendDate = product.sendDate.replace('Z', '').replace(/[+-]\d{2}:\d{2}$/, '');
    }
  }
  return product;
}

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');
    const timeSlotId = searchParams.get('timeSlotId');
    const fromDate = searchParams.get('fromDate');
    const toDate = searchParams.get('toDate');

    // Get all "Dọc Đường" products from NhapHang that are synced to TongHop
    let query = `
      SELECT
        p.id,
        p."senderName" as sender_name,
        p."senderPhone" as sender_phone,
        p."senderStation" as sender_station,
        p."receiverName" as receiver_name,
        p."receiverPhone" as receiver_phone,
        p.station as delivery_station,
        p."productType" as product_type,
        p.quantity,
        p."totalAmount" as freight_charge,
        p."paymentStatus" as payment_status,
        p.status,
        p."deliveryStatus" as delivery_status,
        p."sendDate" as departure_time,
        p.notes as special_instructions,
        p."tongHopBookingId" as tonghop_booking_id,
        p."syncedToTongHop" as synced,
        p."createdAt" as created_at
      FROM "NH_Products" p
      WHERE (p.station LIKE '00 -%' OR p.station LIKE '00-%' OR LOWER(p.station) LIKE '%dọc đường%' OR LOWER(p.station) LIKE '%doc duong%')
    `;

    const params = [];
    let paramIndex = 1;

    // Filter by status
    if (status) {
      if (status === 'delivered') {
        query += ` AND (p.status = 'delivered' OR p."deliveryStatus" = 'delivered')`;
      } else if (status === 'pending') {
        query += ` AND p.status = 'pending'`;
      } else if (status === 'in_transit') {
        query += ` AND (p.status = 'processing' OR p."deliveryStatus" = 'in_transit')`;
      } else if (status === 'picked_up') {
        query += ` AND p."deliveryStatus" = 'picked_up'`;
      } else if (status === 'cancelled') {
        query += ` AND p.status = 'cancelled'`;
      }
    }

    // Filter by date range
    if (fromDate) {
      query += ` AND DATE(p."sendDate") >= $${paramIndex}`;
      params.push(fromDate);
      paramIndex++;
    }

    if (toDate) {
      query += ` AND DATE(p."sendDate") <= $${paramIndex}`;
      params.push(toDate);
      paramIndex++;
    }

    query += ` ORDER BY p."sendDate" DESC LIMIT 200`;

    const products = await queryNhapHang(query, params);

    // Map to freight format
    const freightList = products.map(p => ({
      id: p.id,
      sender_name: p.sender_name,
      sender_phone: p.sender_phone,
      sender_station: p.sender_station,
      receiver_name: p.receiver_name,
      receiver_phone: p.receiver_phone,
      delivery_station: p.delivery_station,
      description: `${p.product_type || ''} ${p.quantity || ''}`.trim() || 'Hàng hóa',
      weight: null,
      quantity: 1,
      freight_charge: parseFloat(p.freight_charge) || 0,
      cod_amount: 0,
      status: mapStatus(p.status, p.delivery_status),
      departure_time: p.departure_time,
      special_instructions: p.special_instructions,
      tonghop_booking_id: p.tonghop_booking_id,
      created_at: p.created_at
    }));

    return NextResponse.json(freightList);

  } catch (error) {
    console.error('[TongHop Freight] GET Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

// Map NhapHang status to freight status
function mapStatus(status, deliveryStatus) {
  if (deliveryStatus === 'delivered' || status === 'delivered') return 'delivered';
  if (deliveryStatus === 'in_transit') return 'in_transit';
  if (deliveryStatus === 'picked_up') return 'picked_up';
  if (status === 'cancelled') return 'cancelled';
  return 'pending';
}
