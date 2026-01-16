import { NextResponse } from 'next/server';
import { query } from '../../../../../lib/database';

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);

    const dateFrom = searchParams.get('dateFrom');
    const dateTo = searchParams.get('dateTo');
    const action = searchParams.get('action');
    const changedBy = searchParams.get('changedBy');
    const limit = parseInt(searchParams.get('limit') || '200');
    const senderStation = searchParams.get('senderStation');
    const station = searchParams.get('station');
    const search = searchParams.get('search');

    // Build query with filters
    let whereConditions = ['1=1'];
    let queryParams = [];
    let paramIndex = 1;

    if (dateFrom) {
      whereConditions.push(`l."changedAt" >= $${paramIndex}`);
      queryParams.push(dateFrom);
      paramIndex++;
    }

    if (dateTo) {
      whereConditions.push(`l."changedAt" <= $${paramIndex}`);
      queryParams.push(dateTo);
      paramIndex++;
    }

    if (action) {
      whereConditions.push(`l.action = $${paramIndex}`);
      queryParams.push(action);
      paramIndex++;
    }

    if (changedBy) {
      whereConditions.push(`l."changedBy" ILIKE $${paramIndex}`);
      queryParams.push(`%${changedBy}%`);
      paramIndex++;
    }

    if (senderStation) {
      whereConditions.push(`p."senderStation" = $${paramIndex}`);
      queryParams.push(senderStation);
      paramIndex++;
    }

    if (station) {
      whereConditions.push(`p.station = $${paramIndex}`);
      queryParams.push(station);
      paramIndex++;
    }

    if (search) {
      whereConditions.push(`(
        l."productId" ILIKE $${paramIndex} OR
        p."senderName" ILIKE $${paramIndex} OR
        p."receiverName" ILIKE $${paramIndex} OR
        p."senderPhone" ILIKE $${paramIndex} OR
        p."receiverPhone" ILIKE $${paramIndex}
      )`);
      queryParams.push(`%${search}%`);
      paramIndex++;
    }

    // Add limit at the end
    queryParams.push(limit);
    const limitParam = `$${paramIndex}`;

    const sqlQuery = `
      SELECT
        l."logId", l."productId", l.action, l.field, l."oldValue", l."newValue",
        l."changedBy", l."changedAt", l."ipAddress",
        p."senderName", p."senderPhone", p."senderStation",
        p."receiverName", p."receiverPhone", p.station,
        p."productType", p.quantity, p."totalAmount", p.vehicle
      FROM "ProductLogs" l
      LEFT JOIN "Products" p ON l."productId" = p.id
      WHERE ${whereConditions.join(' AND ')}
      ORDER BY l."changedAt" DESC
      LIMIT ${limitParam}
    `;

    const logs = await query(sqlQuery, queryParams);

    return NextResponse.json({
      success: true,
      count: logs.length,
      logs
    });
  } catch (error) {
    console.error('Error fetching logs:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
