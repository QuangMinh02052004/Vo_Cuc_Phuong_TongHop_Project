import { queryNhapHang } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// ===========================================
// API: Freight by Vehicle - Hàng hóa theo xe
// ===========================================
// GET /api/tong-hop/freight/by-vehicle?vehicle=29A-12345&date=2026-03-22

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const vehicle = searchParams.get('vehicle');
    const date = searchParams.get('date');

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
        p.vehicle,
        p."totalAmount" as freight_charge,
        p."paymentStatus" as payment_status,
        p.status,
        p."deliveryStatus" as delivery_status,
        p."sendDate" as send_date,
        p.notes,
        p."createdAt" as created_at
      FROM "Products" p
      WHERE p.vehicle IS NOT NULL AND p.vehicle != ''
    `;

    const params = [];
    let paramIndex = 1;

    if (vehicle) {
      query += ` AND LOWER(p.vehicle) LIKE LOWER($${paramIndex})`;
      params.push(`%${vehicle}%`);
      paramIndex++;
    }

    if (date) {
      query += ` AND DATE(p."sendDate") = $${paramIndex}`;
      params.push(date);
      paramIndex++;
    }

    query += ` ORDER BY p.vehicle, p."sendDate" DESC LIMIT 500`;

    const products = await queryNhapHang(query, params);

    // Group by vehicle
    const vehicleMap = {};
    for (const p of products) {
      const veh = p.vehicle || 'Chưa gán xe';
      if (!vehicleMap[veh]) {
        vehicleMap[veh] = {
          vehicle: veh,
          totalOrders: 0,
          totalFreight: 0,
          items: []
        };
      }
      vehicleMap[veh].totalOrders++;
      vehicleMap[veh].totalFreight += parseFloat(p.freight_charge) || 0;
      vehicleMap[veh].items.push({
        id: p.id,
        sender_name: p.sender_name,
        sender_phone: p.sender_phone,
        sender_station: p.sender_station,
        receiver_name: p.receiver_name,
        receiver_phone: p.receiver_phone,
        delivery_station: p.delivery_station,
        description: `${p.product_type || ''} ${p.quantity || ''}`.trim() || 'Hàng hóa',
        freight_charge: parseFloat(p.freight_charge) || 0,
        payment_status: p.payment_status,
        status: p.status,
        delivery_status: p.delivery_status,
        send_date: p.send_date,
        notes: p.notes
      });
    }

    const vehicles = Object.values(vehicleMap);

    return NextResponse.json({
      success: true,
      vehicles,
      totalVehicles: vehicles.length,
      totalOrders: products.length
    });

  } catch (error) {
    console.error('[Freight by Vehicle] GET Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
