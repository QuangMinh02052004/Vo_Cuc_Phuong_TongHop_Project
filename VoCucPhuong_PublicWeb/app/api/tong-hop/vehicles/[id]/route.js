import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function PUT(request, { params }) {
  try {
    const { id } = params;
    const { code, type } = await request.json();
    const result = await queryTongHop(
      'UPDATE "TH_Vehicles" SET code=$1, type=$2 WHERE id=$3 RETURNING *',
      [code || '', type || '', id]
    );
    if (result.length === 0) return NextResponse.json({ error: 'Not found' }, { status: 404 });
    return NextResponse.json(result[0]);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function DELETE(request, { params }) {
  try {
    const { id } = params;
    await queryTongHop('DELETE FROM "TH_Vehicles" WHERE id=$1', [id]);
    return NextResponse.json({ success: true });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
