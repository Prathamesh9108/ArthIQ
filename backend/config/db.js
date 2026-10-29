const mysql = require('mysql2/promise');
require('dotenv').config();

let pool = null;

/**
 * Returns or creates the MySQL/TiDB connection pool
 */
const getPool = () => {
  if (!pool) {
    pool = mysql.createPool({
      host: process.env.TIDB_HOST,
      port: Number(process.env.TIDB_PORT) || 4000,
      user: process.env.TIDB_USER,
      password: process.env.TIDB_PASSWORD,
      database: process.env.TIDB_DATABASE || 'test',
      ssl: {
        minVersion: 'TLSv1.2',
        rejectUnauthorized: true,
      },
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      decimalNumbers: true,
    });
  }
  return pool;
};

/**
 * Verifies TiDB connectivity by executing a lightweight ping query
 */
const testConnection = async () => {
  try {
    if (!process.env.TIDB_HOST || !process.env.TIDB_USER) {
      throw new Error('TiDB credentials are not yet configured in .env (TIDB_HOST, TIDB_USER, TIDB_PASSWORD missing)');
    }
    const p = getPool();
    const [rows] = await p.query('SELECT 1 + 1 AS result, VERSION() AS tidb_version');
    console.log('✅ [TiDB Cloud] Connected successfully!');
    console.log(`   Host: ${process.env.TIDB_HOST}:${process.env.TIDB_PORT || 4000}`);
    console.log(`   Database: ${process.env.TIDB_DATABASE}`);
    console.log(`   Engine Version: ${rows[0].tidb_version}`);
    return true;
  } catch (err) {
    console.error('❌ [TiDB Cloud] Connection failed!');
    console.error(`   Message: ${err.message}`);
    return false;
  }
};

/**
 * Returns diagnostic connection state
 */
const getDbStatus = async () => {
  try {
    if (!process.env.TIDB_HOST || !process.env.TIDB_USER) {
      return { status: 'unconfigured', message: 'TIDB credentials not set in .env' };
    }
    const p = getPool();
    const [rows] = await p.query('SELECT 1 AS ok');
    return {
      status: 'connected',
      database: process.env.TIDB_DATABASE,
      host: process.env.TIDB_HOST,
      port: process.env.TIDB_PORT || 4000,
    };
  } catch (err) {
    return {
      status: 'error',
      message: err.message,
    };
  }
};

module.exports = {
  getPool,
  testConnection,
  getDbStatus,
};
