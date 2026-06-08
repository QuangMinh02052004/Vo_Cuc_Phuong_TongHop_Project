import jwt from 'jsonwebtoken';
import { NextResponse } from 'next/server';

const JWT_SECRET = process.env.JWT_SECRET || 'vocucphuong-secret-key-2024';

const ADMIN_PERMS = ['phongve.view','phongve.create','phongve.edit','phongve.cancel','kho.view','kho.edit','thongke.view','logs.view','users.manage'];
const EMPLOYEE_PERMS = ['phongve.view','phongve.create','phongve.edit','kho.view','kho.edit','thongke.view'];

// Decode JWT từ Authorization header. Trả về user object hoặc null.
export function decodeAuthToken(request) {
  try {
    const authHeader = request.headers.get('authorization') || request.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) return null;
    const token = authHeader.slice(7);
    const decoded = jwt.verify(token, JWT_SECRET);
    return decoded;
  } catch (e) {
    return null;
  }
}

// Lấy user từ token, normalize permissions/scope (fallback theo role nếu thiếu).
export function getAuthUser(request) {
  const u = decodeAuthToken(request);
  if (!u) return null;
  let permissions = Array.isArray(u.permissions) ? u.permissions : [];
  if (permissions.length === 0) {
    permissions = u.role === 'admin' ? ADMIN_PERMS : EMPLOYEE_PERMS;
  }
  const scope = u.scope || (u.role === 'admin' ? 'all_stations' : 'own_station');
  return { ...u, permissions, scope };
}

// Check permission. Admin luôn pass.
export function userHasPerm(user, perm) {
  if (!user) return false;
  if (user.role === 'admin') return true;
  return Array.isArray(user.permissions) && user.permissions.includes(perm);
}

// Hard gate: trả về NextResponse 401/403 nếu thiếu, hoặc null nếu pass.
export function requirePerm(request, perm) {
  const user = getAuthUser(request);
  if (!user) {
    return {
      response: NextResponse.json({ success: false, error: 'Chưa đăng nhập', code: 'AUTH_REQUIRED' }, { status: 401 }),
      user: null,
    };
  }
  if (!userHasPerm(user, perm)) {
    return {
      response: NextResponse.json({ success: false, error: 'Không có quyền truy cập', code: 'FORBIDDEN', requiredPerm: perm }, { status: 403 }),
      user,
    };
  }
  return { response: null, user };
}

// Soft gate: log warning nếu thiếu quyền nhưng vẫn cho qua. Trả về user (có thể null).
// Dùng cho giai đoạn quan sát trước khi chuyển hard.
export function softCheckPerm(request, perm, routeLabel = '') {
  const user = getAuthUser(request);
  if (!user) {
    console.warn(`[SOFT-AUTH] ${routeLabel}: no token`);
    return null;
  }
  if (!userHasPerm(user, perm)) {
    console.warn(`[SOFT-AUTH] ${routeLabel}: user=${user.username} role=${user.role} thiếu quyền ${perm}`);
  }
  return user;
}

// Trả về true nếu user có scope toàn cục (admin hoặc scope=all_stations)
export function hasGlobalScope(user) {
  if (!user) return false;
  if (user.role === 'admin') return true;
  return user.scope === 'all_stations';
}
