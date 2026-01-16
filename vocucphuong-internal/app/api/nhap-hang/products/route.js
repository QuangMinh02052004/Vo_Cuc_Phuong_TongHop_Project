import { query, queryOne } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// GET /api/nhap-hang/products
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const station = searchParams.get('station');
    const status = searchParams.get('status');
    const search = searchParams.get('search');

    let sqlQuery = 'SELECT * FROM "Products" WHERE 1=1';
    const params = [];
    let paramIndex = 1;

    if (station) {
      sqlQuery += ` AND station = $${paramIndex}`;
      params.push(station);
      paramIndex++;
    }

    if (status) {
      sqlQuery += ` AND status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    if (search) {
      sqlQuery += ` AND ("receiverName" ILIKE $${paramIndex} OR "senderName" ILIKE $${paramIndex} OR id ILIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    sqlQuery += ' ORDER BY "sendDate" DESC LIMIT 500';

    const products = await query(sqlQuery, params);

    return NextResponse.json({
      success: true,
      count: products.length,
      products
    });
  } catch (error) {
    console.error('Error getting products:', error);
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}

// POST /api/nhap-hang/products
export async function POST(request) {
  try {
    const body = await request.json();
    const {
      id,
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
      notes
    } = body;

    if (!receiverName || !receiverPhone || !station || !productType) {
      return NextResponse.json({
        success: false,
        message: 'Thiếu thông tin bắt buộc!'
      }, { status: 400 });
    }

    // Auto-generate ID
    let productId = id;
    if (!productId) {
      const stationCode = station.split(' - ')[0];
      const now = new Date();
      const dateKey = `${now.getFullYear().toString().slice(-2)}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}`;
      const idPrefix = `${dateKey}.${stationCode.padStart(2, '0')}`;

      const maxResult = await queryOne(`
        SELECT MAX(CAST(SUBSTRING(id, LENGTH($1) + 1, 10) AS INTEGER)) as "maxCounter"
        FROM "Products"
        WHERE id LIKE $1 || '%'
      `, [idPrefix]);

      const nextCounter = (maxResult?.maxCounter || 0) + 1;
      productId = `${idPrefix}${nextCounter}`;
    }

    const result = await query(`
      INSERT INTO "Products" (
        id, "senderName", "senderPhone", "senderStation",
        "receiverName", "receiverPhone", station,
        "productType", quantity, vehicle, insurance, "totalAmount",
        "paymentStatus", "sendDate", status, notes
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, NOW(), 'pending', $14
      )
      RETURNING *
    `, [
      productId,
      senderName || '',
      senderPhone || '',
      senderStation || '',
      receiverName,
      receiverPhone,
      station,
      productType,
      quantity || 1,
      vehicle || null,
      insurance || 0,
      totalAmount || 0,
      paymentStatus || 'unpaid',
      notes || null
    ]);

    const createdProduct = result[0];

    // ===========================================
    // AUTO-SYNC: Nếu là đơn "DỌC ĐƯỜNG", tự động tạo booking trong TongHop
    // ===========================================
    if (station && station.includes('DỌC ĐƯỜNG')) {
      try {
        console.log('[NhapHang] Đơn dọc đường detected, syncing to TongHop...');

        // Gọi internal webhook (cùng server)
        const baseUrl = process.env.VERCEL_URL
          ? `https://${process.env.VERCEL_URL}`
          : 'http://localhost:3000';

        const webhookResponse = await fetch(`${baseUrl}/api/tong-hop/webhook/nhaphang`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            productId: productId,
            receiverName: receiverName,
            receiverPhone: receiverPhone,
            senderStation: senderStation,
            station: station,
            vehicle: vehicle,
            sendDate: new Date().toISOString(),
            notes: notes,
            quantity: quantity || 1
          })
        });

        const webhookResult = await webhookResponse.json();

        if (webhookResult.success) {
          console.log('[NhapHang] ✅ Đã sync booking sang TongHop:', webhookResult.data);
        } else {
          console.error('[NhapHang] ❌ Lỗi sync TongHop:', webhookResult.error);
        }
      } catch (syncError) {
        // Không throw error - vẫn trả về thành công cho đơn hàng
        console.error('[NhapHang] ⚠️ Lỗi kết nối TongHop:', syncError.message);
      }
    }

    return NextResponse.json({
      success: true,
      message: 'Tạo đơn hàng thành công!',
      product: createdProduct
    }, { status: 201 });
  } catch (error) {
    console.error('Error creating product:', error);
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}
