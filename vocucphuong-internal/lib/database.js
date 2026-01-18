import { Pool } from 'pg';

// Lazy initialize pools - 3 separate Neon databases
let nhapHangPool = null;
let tongHopPool = null;
let datVePool = null;

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

function getDatVePool() {
  if (!datVePool) {
    datVePool = new Pool({
      connectionString: process.env.DATABASE_URL_DATVE,
      ssl: { rejectUnauthorized: false }
    });
  }
  return datVePool;
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

// Đặt Vé queries
export async function queryDatVe(sqlQuery, params = []) {
  const pool = getDatVePool();
  const client = await pool.connect();
  try {
    const result = await client.query(sqlQuery, params);
    return result.rows;
  } finally {
    client.release();
  }
}

export async function queryOneDatVe(sqlQuery, params = []) {
  const rows = await queryDatVe(sqlQuery, params);
  return rows[0] || null;
}

// Legacy exports
export const query = queryNhapHang;
export const queryOne = queryOneNhapHang;
