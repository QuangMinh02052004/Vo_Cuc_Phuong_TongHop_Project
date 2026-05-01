import { queryTongHop } from '../../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

const fmtVND = (n) => new Intl.NumberFormat('vi-VN').format(Math.round(Number(n) || 0));

function buildHTML(report) {
  const { date, summary, byRoute, byTimeSlot } = report;
  return `
<!DOCTYPE html>
<html lang="vi"><head><meta charset="utf-8"><title>Báo cáo ${date}</title></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Arial,sans-serif;color:#1f2937;background:#f8fafc;padding:24px;margin:0;">
  <div style="max-width:720px;margin:0 auto;background:#fff;border-radius:12px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,0.1);">
    <h1 style="margin:0 0 8px;color:#0f172a;font-size:22px;">Báo cáo ngày ${date}</h1>
    <p style="margin:0 0 20px;color:#64748b;font-size:13px;">Võ Cúc Phương — hệ thống quản lý vé khách</p>

    <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:12px;margin-bottom:24px;">
      <div style="background:#f0f9ff;border-left:4px solid #0ea5e9;padding:12px;border-radius:4px;">
        <div style="font-size:11px;color:#64748b;">Tổng vé bán</div>
        <div style="font-size:22px;font-weight:600;color:#0369a1;">${summary.totalBookings}</div>
        ${summary.cancelledBookings > 0 ? `<div style="font-size:11px;color:#dc2626;">+ ${summary.cancelledBookings} đã hủy</div>` : ''}
      </div>
      <div style="background:#f0fdf4;border-left:4px solid #10b981;padding:12px;border-radius:4px;">
        <div style="font-size:11px;color:#64748b;">Đã thu</div>
        <div style="font-size:22px;font-weight:600;color:#047857;">${fmtVND(summary.totalPaid)} đ</div>
        <div style="font-size:11px;color:#64748b;">Tổng giá trị: ${fmtVND(summary.totalAmount)} đ</div>
      </div>
    </div>

    ${summary.totalDebt > 0 ? `
    <div style="background:#fef2f2;border-left:4px solid #ef4444;padding:12px;border-radius:4px;margin-bottom:20px;">
      <div style="font-size:11px;color:#64748b;">Còn nợ</div>
      <div style="font-size:18px;font-weight:600;color:#b91c1c;">${fmtVND(summary.totalDebt)} đ</div>
    </div>` : ''}

    <h2 style="font-size:15px;margin:24px 0 8px;color:#0f172a;">Theo tuyến</h2>
    <table style="width:100%;border-collapse:collapse;font-size:13px;">
      <thead><tr style="background:#f1f5f9;">
        <th style="padding:8px;text-align:left;border-bottom:1px solid #e2e8f0;">Tuyến</th>
        <th style="padding:8px;text-align:right;border-bottom:1px solid #e2e8f0;">Vé</th>
        <th style="padding:8px;text-align:right;border-bottom:1px solid #e2e8f0;">Đã thu</th>
        <th style="padding:8px;text-align:right;border-bottom:1px solid #e2e8f0;">Tổng</th>
      </tr></thead>
      <tbody>
      ${byRoute.map(r => `
        <tr>
          <td style="padding:8px;border-bottom:1px solid #f1f5f9;">${r.route}</td>
          <td style="padding:8px;text-align:right;border-bottom:1px solid #f1f5f9;">${r.count}</td>
          <td style="padding:8px;text-align:right;border-bottom:1px solid #f1f5f9;color:#047857;font-weight:600;">${fmtVND(r.paid)}</td>
          <td style="padding:8px;text-align:right;border-bottom:1px solid #f1f5f9;color:#64748b;">${fmtVND(r.amount)}</td>
        </tr>
      `).join('')}
      </tbody>
    </table>

    <h2 style="font-size:15px;margin:24px 0 8px;color:#0f172a;">Theo khung giờ</h2>
    <table style="width:100%;border-collapse:collapse;font-size:13px;">
      <thead><tr style="background:#f1f5f9;">
        <th style="padding:8px;text-align:left;border-bottom:1px solid #e2e8f0;">Tuyến</th>
        <th style="padding:8px;text-align:left;border-bottom:1px solid #e2e8f0;">Giờ</th>
        <th style="padding:8px;text-align:right;border-bottom:1px solid #e2e8f0;">Vé</th>
        <th style="padding:8px;text-align:right;border-bottom:1px solid #e2e8f0;">Đã thu</th>
      </tr></thead>
      <tbody>
      ${byTimeSlot.map(t => `
        <tr>
          <td style="padding:6px 8px;border-bottom:1px solid #f1f5f9;font-size:12px;color:#64748b;">${t.route}</td>
          <td style="padding:6px 8px;border-bottom:1px solid #f1f5f9;font-weight:600;">${t.timeSlot}</td>
          <td style="padding:6px 8px;text-align:right;border-bottom:1px solid #f1f5f9;">${t.count}</td>
          <td style="padding:6px 8px;text-align:right;border-bottom:1px solid #f1f5f9;color:#047857;">${fmtVND(t.paid)}</td>
        </tr>
      `).join('')}
      </tbody>
    </table>

    <p style="margin-top:32px;font-size:11px;color:#94a3b8;text-align:center;border-top:1px solid #e2e8f0;padding-top:16px;">
      Báo cáo tự động sinh bởi VCP Manage · ${new Date().toLocaleString('vi-VN')}
    </p>
  </div>
</body></html>`;
}

async function buildReport(date) {
  const bookings = await queryTongHop(`
    SELECT id, name, phone, "seatNumber", "timeSlot", "timeSlotId", route, date,
           amount, paid, status, "createdAt", "createdBy"
    FROM "TH_Bookings"
    WHERE date = $1
  `, [date]);

  const active = bookings.filter(b => b.status !== 'cancelled');
  const cancelled = bookings.filter(b => b.status === 'cancelled');
  const totalAmount = active.reduce((s, b) => s + (Number(b.amount) || 0), 0);
  const totalPaid = active.reduce((s, b) => s + (Number(b.paid) || 0), 0);

  const byRouteMap = new Map();
  for (const b of active) {
    const k = b.route || '(không tuyến)';
    if (!byRouteMap.has(k)) byRouteMap.set(k, { route: k, count: 0, amount: 0, paid: 0 });
    const g = byRouteMap.get(k);
    g.count++;
    g.amount += Number(b.amount) || 0;
    g.paid += Number(b.paid) || 0;
  }
  const byTSMap = new Map();
  for (const b of active) {
    const k = `${b.route}|${b.timeSlot}`;
    if (!byTSMap.has(k)) byTSMap.set(k, { route: b.route, timeSlot: b.timeSlot, count: 0, amount: 0, paid: 0 });
    const g = byTSMap.get(k);
    g.count++;
    g.amount += Number(b.amount) || 0;
    g.paid += Number(b.paid) || 0;
  }

  return {
    date,
    summary: {
      totalBookings: active.length,
      cancelledBookings: cancelled.length,
      totalAmount,
      totalPaid,
      totalDebt: totalAmount - totalPaid,
    },
    byRoute: Array.from(byRouteMap.values()).sort((a, b) => b.paid - a.paid),
    byTimeSlot: Array.from(byTSMap.values()).sort((a, b) => {
      if (a.route !== b.route) return (a.route || '').localeCompare(b.route || '');
      return (a.timeSlot || '').localeCompare(b.timeSlot || '');
    }),
  };
}

// POST { date, to } - gửi email báo cáo qua Resend
export async function POST(request) {
  try {
    const body = await request.json();
    const { date, to } = body;
    if (!date) return NextResponse.json({ error: 'Missing date' }, { status: 400 });

    const recipients = (to || process.env.REPORT_RECIPIENTS || '').split(',').map(s => s.trim()).filter(Boolean);
    if (recipients.length === 0) {
      return NextResponse.json({ error: 'No recipients (cần truyền `to` hoặc set env REPORT_RECIPIENTS)' }, { status: 400 });
    }

    const apiKey = process.env.RESEND_API_KEY;
    if (!apiKey) {
      return NextResponse.json({ error: 'RESEND_API_KEY chưa cấu hình' }, { status: 500 });
    }

    const report = await buildReport(date);
    const html = buildHTML(report);
    const subject = `Báo cáo VCP ngày ${date} — ${report.summary.totalBookings} vé · ${fmtVND(report.summary.totalPaid)} đ`;

    // Resend HTTP API trực tiếp (không cần SDK)
    const fromAddr = process.env.RESEND_FROM || 'VCP Manage <onboarding@resend.dev>';
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: fromAddr,
        to: recipients,
        subject,
        html,
      }),
    });

    if (!res.ok) {
      const err = await res.text();
      return NextResponse.json({ error: 'Resend error: ' + err }, { status: 502 });
    }
    const data = await res.json();
    return NextResponse.json({ ok: true, sent: recipients, id: data.id, summary: report.summary });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
