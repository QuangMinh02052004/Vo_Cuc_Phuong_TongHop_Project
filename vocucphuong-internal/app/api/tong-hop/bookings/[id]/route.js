import { queryTongHop, queryOneTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export async function GET(request, { params }) {
  try {
    const booking = await queryOneTongHop('SELECT * FROM "TH_Bookings" WHERE id = $1', [params.id]);
    if (!booking) {
      return NextResponse.json({ error: 'Không tìm thấy' }, { status: 404 });
    }
    return NextResponse.json(booking);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function PUT(request, { params }) {
  try {
    const body = await request.json();
    const {
      timeSlotId, phone, name, gender, nationality, pickupMethod,
      pickupAddress, dropoffMethod, dropoffAddress, note, seatNumber,
      amount, paid, timeSlot, date, route
    } = body;

    const result = await queryTongHop(`
      UPDATE "TH_Bookings"
      SET "timeSlotId" = $1, phone = $2, name = $3, gender = $4, nationality = $5,
          "pickupMethod" = $6, "pickupAddress" = $7, "dropoffMethod" = $8,
          "dropoffAddress" = $9, note = $10, "seatNumber" = $11, amount = $12,
          paid = $13, "timeSlot" = $14, date = $15, route = $16, "updatedAt" = NOW()
      WHERE id = $17
      RETURNING *
    `, [
      timeSlotId, phone, name, gender, nationality, pickupMethod,
      pickupAddress, dropoffMethod, dropoffAddress, note, seatNumber,
      amount, paid, timeSlot, date, route, params.id
    ]);

    if (result.length === 0) {
      return NextResponse.json({ error: 'Không tìm thấy' }, { status: 404 });
    }
    return NextResponse.json(result[0]);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function PATCH(request, { params }) {
  try {
    const body = await request.json();
    const allowedFields = [
      'timeSlotId', 'phone', 'name', 'gender', 'nationality', 'pickupMethod',
      'pickupAddress', 'dropoffMethod', 'dropoffAddress', 'note', 'seatNumber',
      'amount', 'paid', 'timeSlot', 'date', 'route'
    ];

    const updates = [];
    const values = [];
    let paramIndex = 1;

    for (const field of allowedFields) {
      if (body[field] !== undefined) {
        const dbField = ['timeSlotId', 'pickupMethod', 'pickupAddress', 'dropoffMethod', 'dropoffAddress', 'seatNumber', 'timeSlot'].includes(field)
          ? `"${field}"`
          : field;
        updates.push(`${dbField} = $${paramIndex}`);
        values.push(body[field]);
        paramIndex++;
      }
    }

    if (updates.length === 0) {
      return NextResponse.json({ error: 'Không có dữ liệu cập nhật' }, { status: 400 });
    }

    updates.push(`"updatedAt" = NOW()`);
    values.push(params.id);

    const sqlQuery = `UPDATE "TH_Bookings" SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`;
    const result = await queryTongHop(sqlQuery, values);

    if (result.length === 0) {
      return NextResponse.json({ error: 'Không tìm thấy' }, { status: 404 });
    }
    return NextResponse.json(result[0]);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function DELETE(request, { params }) {
  try {
    await queryTongHop('DELETE FROM "TH_Bookings" WHERE id = $1', [params.id]);
    return NextResponse.json({ message: 'Đã xóa thành công' });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
