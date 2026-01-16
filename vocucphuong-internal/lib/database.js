import { Pool } from 'pg';

// Lazy initialize pools
let nhapHangPool = null;
let tongHopPool = null;

function getNhapHangPool() {
  if (!nhapHangPool) {
    nhapHangPool = new Pool({
      connectionString: process.env.DATABASE_URL_NHAPHANG,
      ssl: { rejectUnauthorized: false }
    });
  }
  return nhapHangPool;
}

function getTongHopPool() {
  if (!tongHopPool) {
    tongHopPool = new Pool({
      connectionString: process.env.DATABASE_URL_TONGHOP,
      ssl: { rejectUnauthorized: false }
    });
  }
  return tongHopPool;
}

// Nhập Hàng queries
export async function queryNhapHang(sqlQuery, params = []) {
  const pool = getNhapHangPool();
  const client = await pool.connect();
  try {
    const result = await client.query(sqlQuery, params);
    return result.rows;
  } finally {
    client.release();
  }
}

export async function queryOneNhapHang(sqlQuery, params = []) {
  const rows = await queryNhapHang(sqlQuery, params);
  return rows[0] || null;
}

// Tổng Hợp queries
export async function queryTongHop(sqlQuery, params = []) {
  const pool = getTongHopPool();
  const client = await pool.connect();
  try {
    const result = await client.query(sqlQuery, params);
    return result.rows;
  } finally {
    client.release();
  }
}

export async function queryOneTongHop(sqlQuery, params = []) {
  const rows = await queryTongHop(sqlQuery, params);
  return rows[0] || null;
}

// Legacy exports
export const query = queryNhapHang;
export const queryOne = queryOneNhapHang;
