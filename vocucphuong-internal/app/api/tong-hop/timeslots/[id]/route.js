import { queryTongHop, queryOneTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export async function GET(request, { params }) {
  try {
    const timeSlot = await queryOneTongHop('SELECT * FROM "TH_TimeSlots" WHERE id = $1', [params.id]);
    if (!timeSlot) {
      return NextResponse.json({ error: 'Không tìm thấy' }, { status: 404 });
    }
    return NextResponse.json(timeSlot);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function PUT(request, { params }) {
  try {
    const body = await request.json();
    const { time, date, route, type, code, driver, phone } = body;

    const result = await queryTongHop(`
      UPDATE "TH_TimeSlots"
      SET time = $1, date = $2, route = $3, type = $4, code = $5, driver = $6, phone = $7, "updatedAt" = NOW()
      WHERE id = $8
      RETURNING *
    `, [time, date, route, type, code, driver, phone, params.id]);

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
    await queryTongHop('DELETE FROM "TH_TimeSlots" WHERE id = $1', [params.id]);
    return NextResponse.json({ message: 'Đã xóa thành công' });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
