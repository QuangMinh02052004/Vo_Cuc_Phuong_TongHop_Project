import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    const assignedTo = searchParams.get('assignedTo');

    let query = 'SELECT * FROM "TH_StaffTasks" WHERE 1=1';
    const params = [];
    if (date) { params.push(date); query += ` AND date = $${params.length}`; }
    if (assignedTo) { params.push(assignedTo); query += ` AND "assignedTo" ILIKE $${params.length}`; }
    query += ' ORDER BY "createdAt" DESC';

    const rows = await queryTongHop(query, params);
    return NextResponse.json(rows);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const { title, description, assignedTo, createdBy, date, dueTime, priority } = await request.json();
    if (!title) return NextResponse.json({ error: 'title required' }, { status: 400 });
    const result = await queryTongHop(`
      INSERT INTO "TH_StaffTasks" (title, description, "assignedTo", "createdBy", date, "dueTime", priority, status)
      VALUES ($1,$2,$3,$4,$5,$6,$7,'pending') RETURNING *
    `, [title, description || '', assignedTo || '', createdBy || '', date || '', dueTime || '', priority || 'normal']);
    return NextResponse.json(result[0], { status: 201 });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
