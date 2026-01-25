import { queryNhapHang, queryOneNhapHang } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: Freight Stats - Thống kê đơn hàng dọc đường
// ===========================================
// GET /api/tong-hop/freight/stats - Thống kê tổng quan

export async function GET(request) {
  try {
    // Get stats for "Dọc Đường" products
    const stats = await queryOneNhapHang(`
      SELECT
        COUNT(*) as total_freight,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending,
        COUNT(CASE WHEN "deliveryStatus" = 'picked_up' THEN 1 END) as picked_up,
        COUNT(CASE WHEN status = 'processing' OR "deliveryStatus" = 'in_transit' THEN 1 END) as in_transit,
        COUNT(CASE WHEN status = 'delivered' OR "deliveryStatus" = 'delivered' THEN 1 END) as delivered,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled,
        COALESCE(SUM("totalAmount"), 0) as total_revenue
      FROM "NH_Products"
      WHERE (station LIKE '00 -%' OR station LIKE '00-%' OR LOWER(station) LIKE '%dọc đường%' OR LOWER(station) LIKE '%doc duong%')
    `);

    return NextResponse.json({
      total_freight: parseInt(stats.total_freight) || 0,
      pending: parseInt(stats.pending) || 0,
      picked_up: parseInt(stats.picked_up) || 0,
      in_transit: parseInt(stats.in_transit) || 0,
      delivered: parseInt(stats.delivered) || 0,
      cancelled: parseInt(stats.cancelled) || 0,
      total_revenue: parseFloat(stats.total_revenue) || 0
    });

  } catch (error) {
    console.error('[TongHop Freight Stats] Error:', error);
    return NextResponse.json({
      total_freight: 0,
      pending: 0,
      picked_up: 0,
      in_transit: 0,
      delivered: 0,
      cancelled: 0,
      total_revenue: 0
    });
  }
}
