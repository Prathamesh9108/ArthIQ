const express = require('express');
const router = express.Router();
const { getPool } = require('../config/db');

const DEFAULT_USER_ID = 'user_rahul_01';

// @route   GET /api/budgets
// @desc    Retrieve all category budgets for the current user
router.get('/', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;

    const [rows] = await pool.query(
      `SELECT 
        b.id, 
        b.category, 
        b.limit_amount AS \`limit\`, 
        COALESCE(
          (SELECT SUM(t.amount) 
           FROM transactions t 
           WHERE t.user_id = b.user_id 
             AND LOWER(t.category) = LOWER(b.category) 
             AND t.type = 'expense' 
             AND t.date >= DATE_FORMAT(CURRENT_DATE, '%Y-%m-01')),
          b.spent_amount,
          0
        ) AS spent, 
        b.period 
      FROM budgets b 
      WHERE b.user_id = ? 
      ORDER BY b.category ASC`,
      [userId]
    );

    const formatted = rows.map((r) => ({
      id: r.id,
      category: r.category,
      limit: Number(r.limit),
      spent: Number(r.spent),
      period: r.period || 'monthly',
    }));

    res.json({
      success: true,
      count: formatted.length,
      data: formatted,
    });
  } catch (err) {
    console.error('❌ [TiDB] Error fetching budgets:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   POST /api/budgets
// @desc    Upsert a budget category limit
router.post('/', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { id, category, limit, period } = req.body;

    if (!category || limit === undefined) {
      return res.status(400).json({ success: false, error: 'Category and limit are required' });
    }

    const budgetId = id || `b_${Date.now()}`;
    const budgetLimit = Number(limit);
    const budgetPeriod = period || 'monthly';

    await pool.query(
      `INSERT INTO budgets (id, user_id, category, limit_amount, spent_amount, period)
       VALUES (?, ?, ?, ?, 0.00, ?)
       ON DUPLICATE KEY UPDATE 
         limit_amount = VALUES(limit_amount),
         period = VALUES(period)`,
      [budgetId, userId, category, budgetLimit, budgetPeriod]
    );

    console.log(`📊 [TiDB] Budget updated: ${category} -> Limit ₹${budgetLimit}`);

    res.status(200).json({
      success: true,
      message: 'Budget saved to TiDB Cloud successfully',
      data: { id: budgetId, category, limit: budgetLimit, period: budgetPeriod },
    });
  } catch (err) {
    console.error('❌ [TiDB] Error saving budget:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   POST /api/budgets/rebalance
// @desc    Rebalance budget funds between two categories atomically
router.post('/rebalance', async (req, res) => {
  const pool = getPool();
  const conn = await pool.getConnection();
  try {
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { fromCategory, toCategory, amount } = req.body;
    const transferAmount = Number(amount);

    if (!fromCategory || !toCategory || !transferAmount || transferAmount <= 0) {
      return res.status(400).json({ success: false, error: 'Invalid rebalance parameters' });
    }

    await conn.beginTransaction();

    // Deduct from source
    await conn.query(
      `UPDATE budgets 
       SET limit_amount = limit_amount - ? 
       WHERE user_id = ? AND category = ? AND limit_amount >= ?`,
      [transferAmount, userId, fromCategory, transferAmount]
    );

    // Add to target
    await conn.query(
      `UPDATE budgets 
       SET limit_amount = limit_amount + ? 
       WHERE user_id = ? AND category = ?`,
      [transferAmount, userId, toCategory]
    );

    await conn.commit();
    console.log(`🔄 [TiDB] Rebalanced ₹${transferAmount} from "${fromCategory}" to "${toCategory}"`);
    res.json({ success: true, message: 'Budgets rebalanced successfully' });
  } catch (err) {
    await conn.rollback();
    console.error('❌ [TiDB] Rebalance error:', err.message);
    res.status(500).json({ success: false, error: err.message });
  } finally {
    conn.release();
  }
});

// @route   DELETE /api/budgets/:id
// @desc    Delete a budget by ID
router.delete('/:id', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { id } = req.params;

    const [result] = await pool.query(
      'DELETE FROM budgets WHERE (id = ? OR category = ?) AND user_id = ?',
      [id, id, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Budget not found' });
    }

    console.log(`🗑️ [TiDB] Deleted Budget: ${id}`);
    res.json({ success: true, message: 'Budget deleted successfully' });
  } catch (err) {
    console.error('❌ [TiDB] Error deleting budget:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
