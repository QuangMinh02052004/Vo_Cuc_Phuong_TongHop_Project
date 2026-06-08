import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// GET /api/tong-hop/reports/cron-daily
// Vercel Cron hoặc cron-job.org gọi GET → tự động sinh date hôm nay (Asia/Ho_Chi_Minh)
// rồi internal fetch sang /reports/daily/send
export async function GET(request) {
  try {
    // Date hôm nay theo timezone VN (UTC+7)
    const now = new Date(Date.now() + 7 * 60 * 60 * 1000);
    const dd = String(now.getUTCDate()).padStart(2, '0');
    const mm = String(now.getUTCMonth() + 1).padStart(2, '0');
    const yyyy = now.getUTCFullYear();
    const date = `${dd}-${mm}-${yyyy}`;

    // Authorize: cho phép Vercel cron OR shared secret
    const cronSecret = process.env.CRON_SECRET;
    const auth = request.headers.get('authorization');
    if (cronSecret) {
      if (auth !== `Bearer ${cronSecret}`) {
        return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
      }
    }

    // Internal call sang send endpoint
    const url = new URL('/api/tong-hop/reports/daily/send', request.url);
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ date }),
    });
    const data = await res.json();
    return NextResponse.json({ ok: res.ok, date, result: data }, { status: res.status });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
