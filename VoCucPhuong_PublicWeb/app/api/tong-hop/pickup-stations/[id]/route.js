import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function PATCH(request, { params }) {
  try {
    const { id } = await params;
    const body = await request.json();
    const fields = [];
    const values = [];
    let p = 1;

    if (body.stt !== undefined) { fields.push(`stt = $${p++}`); values.push(String(body.stt)); }
    if (body.sortOrder !== undefined) { fields.push(`"sortOrder" = $${p++}`); values.push(parseFloat(body.sortOrder)); }
    if (body.name !== undefined) { fields.push(`name = $${p++}`); values.push(body.name); }
    if (body.aliases !== undefined) { fields.push(`aliases = $${p++}::jsonb`); values.push(JSON.stringify(body.aliases)); }
    if (body.isActive !== undefined) { fields.push(`"isActive" = $${p++}`); values.push(!!body.isActive); }

    if (fields.length === 0) {
      return NextResponse.json({ error: 'Không có trường nào để cập nhật' }, { status: 400 });
    }

    fields.push(`"updatedAt" = NOW()`);
    values.push(parseInt(id));

    const result = await queryTongHop(
      `UPDATE "TH_PickupStations" SET ${fields.join(', ')} WHERE id = $${p} RETURNING *`,
      values
    );

    if (result.length === 0) {
      return NextResponse.json({ error: 'Không tìm thấy trạm' }, { status: 404 });
    }
    return NextResponse.json(result[0]);
  } catch (error) {
    console.error('[PickupStations PATCH]', error);
    if (String(error.code) === '23505') {
      return NextResponse.json({ error: 'sortOrder đã tồn tại, chọn giá trị khác' }, { status: 409 });
    }
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function DELETE(_request, { params }) {
  try {
    const { id } = await params;
    const result = await queryTongHop(
      `DELETE FROM "TH_PickupStations" WHERE id = $1 RETURNING id`,
      [parseInt(id)]
    );
    if (result.length === 0) {
      return NextResponse.json({ error: 'Không tìm thấy trạm' }, { status: 404 });
    }
    return NextResponse.json({ success: true, id: result[0].id });
  } catch (error) {
    console.error('[PickupStations DELETE]', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
