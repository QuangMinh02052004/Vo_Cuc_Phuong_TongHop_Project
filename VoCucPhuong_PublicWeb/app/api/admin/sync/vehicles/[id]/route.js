import { queryTongHop, queryOneTongHop } from '../../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function PUT(request, { params }) {
  try {
    const { id } = await params;
    const { code, type } = await request.json();
    const row = await queryOneTongHop(
      `UPDATE "TH_Vehicles" SET code = COALESCE($1, code), type = COALESCE($2, type)
       WHERE id = $3 RETURNING id, code, type`,
      [code, type, id]
    );
    if (!row) return NextResponse.json({ error: 'Không tồn tại' }, { status: 404 });
    return NextResponse.json({ vehicle: row });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function DELETE(request, { params }) {
  try {
    const { id } = await params;
    await queryTongHop('DELETE FROM "TH_Vehicles" WHERE id = $1', [id]);
    return NextResponse.json({ success: true });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
