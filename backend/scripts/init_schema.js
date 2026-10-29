const mysql = require('mysql2/promise');
require('dotenv').config();
const { getPool, testConnection } = require('../config/db');

/**
 * Safe, idempotent SQL Schema Initialization for TiDB Cloud
 * Uses CREATE DATABASE / CREATE TABLE IF NOT EXISTS - never drops tables or destroys existing data.
 */
async function initSchema() {
  console.log('🔄 [TiDB Cloud] Starting safe schema initialization...');

  const targetDb = process.env.TIDB_DATABASE || 'arthiq';

  // 0. Ensure target database exists
  try {
    const adminConn = await mysql.createConnection({
      host: process.env.TIDB_HOST,
      port: Number(process.env.TIDB_PORT) || 4000,
      user: process.env.TIDB_USER,
      password: process.env.TIDB_PASSWORD,
      database: 'test',
      ssl: { minVersion: 'TLSv1.2', rejectUnauthorized: true },
    });
    await adminConn.query(`CREATE DATABASE IF NOT EXISTS \`${targetDb}\`;`);
    await adminConn.end();
    console.log(`  ✅ Database verified: ${targetDb}`);
  } catch (dbErr) {
    console.log(`  ℹ️ Pre-flight database check: ${dbErr.message}`);
  }

  const isConnected = await testConnection();
  if (!isConnected) {
    console.error('❌ Aborting schema initialization: Database connection not available.');
    process.exit(1);
  }

  const pool = getPool();

  try {
    // 1. Users Table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(64) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(150) NOT NULL UNIQUE,
        phone VARCHAR(20),
        avatar_url VARCHAR(255),
        currency VARCHAR(10) DEFAULT '₹',
        biometrics_enabled BOOLEAN DEFAULT FALSE,
        monthly_income DECIMAL(12, 2) DEFAULT 20000.00,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);
    console.log('  ✅ Table verified: users');

    // 2. Categories Table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS categories (
        id VARCHAR(64) PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        type ENUM('expense', 'income') NOT NULL,
        icon VARCHAR(50),
        color VARCHAR(20),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);
    console.log('  ✅ Table verified: categories');

    // 3. Transactions Table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS transactions (
        id VARCHAR(64) PRIMARY KEY,
        user_id VARCHAR(64) NOT NULL DEFAULT 'user_rahul_01',
        title VARCHAR(150) NOT NULL,
        amount DECIMAL(12, 2) NOT NULL,
        type ENUM('expense', 'income') NOT NULL,
        category VARCHAR(50) NOT NULL,
        date DATETIME NOT NULL,
        payment_method VARCHAR(50) DEFAULT 'UPI',
        receipt_path VARCHAR(255),
        note TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_user_date (user_id, date),
        INDEX idx_type (type),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);
    console.log('  ✅ Table verified: transactions');

    // 4. Budgets Table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS budgets (
        id VARCHAR(64) PRIMARY KEY,
        user_id VARCHAR(64) NOT NULL DEFAULT 'user_rahul_01',
        category VARCHAR(50) NOT NULL,
        limit_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
        spent_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
        period VARCHAR(20) DEFAULT 'monthly',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY unique_user_category (user_id, category),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);
    console.log('  ✅ Table verified: budgets');

    // 5. Savings Goals Table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS savings_goals (
        id VARCHAR(64) PRIMARY KEY,
        user_id VARCHAR(64) NOT NULL DEFAULT 'user_rahul_01',
        title VARCHAR(150) NOT NULL,
        current_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
        target_amount DECIMAL(12, 2) NOT NULL,
        icon_type VARCHAR(50) DEFAULT 'goal',
        target_date DATETIME,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);
    console.log('  ✅ Table verified: savings_goals');

    // 6. Seed Default User if not exists
    await pool.query(`
      INSERT IGNORE INTO users (id, name, email, phone, currency, biometrics_enabled, monthly_income)
      VALUES ('user_rahul_01', 'Rahul Sharma', 'rahul@gmail.com', '+91 98765 43210', '₹', TRUE, 20000.00);
    `);
    console.log('  ✅ Seed user verified: Rahul Sharma (user_rahul_01)');

    // 7. Seed Initial Budgets if table is empty
    const [existingBudgets] = await pool.query('SELECT COUNT(*) as count FROM budgets');
    if (existingBudgets[0].count === 0) {
      await pool.query(`
        INSERT INTO budgets (id, user_id, category, limit_amount, spent_amount, period) VALUES
        ('b_1', 'user_rahul_01', 'Food & Dining', 5000.00, 4500.00, 'monthly'),
        ('b_2', 'user_rahul_01', 'Transport', 2500.00, 1800.00, 'monthly'),
        ('b_3', 'user_rahul_01', 'Bills & Utilities', 3500.00, 2200.00, 'monthly'),
        ('b_4', 'user_rahul_01', 'Shopping', 2000.00, 1200.00, 'monthly'),
        ('b_5', 'user_rahul_01', 'Entertainment', 1500.00, 900.00, 'monthly'),
        ('b_6', 'user_rahul_01', 'Healthcare', 2000.00, 400.00, 'monthly');
      `);
      console.log('  ✅ Seed budgets inserted (6 initial categories)');
    }

    // 8. Seed Initial Savings Goals if table is empty
    const [existingGoals] = await pool.query('SELECT COUNT(*) as count FROM savings_goals');
    if (existingGoals[0].count === 0) {
      await pool.query(`
        INSERT INTO savings_goals (id, user_id, title, current_amount, target_amount, icon_type) VALUES
        ('sg_1', 'user_rahul_01', 'Emergency Fund', 15000.00, 50000.00, 'shield'),
        ('sg_2', 'user_rahul_01', 'New Laptop', 8000.00, 65000.00, 'gadget'),
        ('sg_3', 'user_rahul_01', 'Diwali Gifts', 5450.00, 10000.00, 'gift');
      `);
      console.log('  ✅ Seed savings goals inserted (3 goals)');
    }

    // 9. Seed Initial Transactions if table is empty
    const [existingTxs] = await pool.query('SELECT COUNT(*) as count FROM transactions');
    if (existingTxs[0].count === 0) {
      await pool.query(`
        INSERT INTO transactions (id, user_id, title, amount, type, category, date, payment_method) VALUES
        ('tx_1', 'user_rahul_01', 'Salary Credited', 28000.00, 'income', 'Salary', NOW() - INTERVAL 2 DAY, 'Bank Transfer'),
        ('tx_2', 'user_rahul_01', 'D-Mart Grocery', 2450.00, 'expense', 'Food & Dining', NOW() - INTERVAL 1 DAY, 'UPI'),
        ('tx_3', 'user_rahul_01', 'Electricity Bill', 1250.00, 'expense', 'Bills & Utilities', NOW() - INTERVAL 1 DAY, 'UPI'),
        ('tx_4', 'user_rahul_01', 'Metro SmartCard', 500.00, 'expense', 'Transport', NOW(), 'UPI');
      `);
      console.log('  ✅ Seed transactions inserted');
    }

    console.log('\n🎉 [TiDB Cloud] Database schema and initial data initialized successfully!\n');
    process.exit(0);
  } catch (err) {
    console.error('❌ [TiDB Cloud] Schema initialization failed:');
    console.error(err);
    process.exit(1);
  }
}

if (require.main === module) {
  initSchema();
}

module.exports = { initSchema };
