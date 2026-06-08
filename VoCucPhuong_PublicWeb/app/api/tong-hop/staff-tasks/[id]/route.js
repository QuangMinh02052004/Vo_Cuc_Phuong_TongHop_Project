import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function PATCH(request, { params }) {
  try {
    const { id } = params;
    const body = await request.json();
    const allowed = ['title', 'description', 'assignedTo', 'date', 'dueTime', 'status', 'priority'];
    const fields = Object.keys(body).filter(k => allowed.includes(k));
    if (fields.length === 0) return NextResponse.json({ error: 'No valid fields' }, { status: 400 });
    const sets = fields.map((f, i) => `"${f}" = $${i + 1}`).join(', ');
    const values = fields.map(f => body[f]);
    values.push(id);
    const result = await queryTongHop(
      `UPDATE "TH_StaffTasks" SET ${sets}, "updatedAt"=NOW() WHERE id=$${values.length} RETURNING *`,
      values
    );
    return NextResponse.json(result[0]);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function DELETE(request, { params }) {
  try {
    await queryTongHop('DELETE FROM "TH_StaffTasks" WHERE id=$1', [params.id]);
    return NextResponse.json({ success: true });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
