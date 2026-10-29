const express = require('express');
const router = express.Router();
const { getPool } = require('../config/db');

// Default user ID for demonstration/single-user authentication isolation
const DEFAULT_USER_ID = 'user_rahul_01';

// @route   GET /api/transactions
// @desc    Get all transactions sorted by date
router.get('/', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;

    const [rows] = await pool.query(
      `SELECT 
        id, 
        user_id AS userId, 
        title, 
        amount, 
        type, 
        category, 
        date, 
        payment_method AS paymentMethod, 
        receipt_path AS receiptPath, 
        note, 
        created_at AS createdAt 
      FROM transactions 
      WHERE user_id = ? 
      ORDER BY date DESC`,
      [userId]
    );

    // Format dates to ISO strings for Flutter compatibility
    const formatted = rows.map((r) => ({
      ...r,
      amount: Number(r.amount),
      date: r.date instanceof Date ? r.date.toISOString() : new Date(r.date).toISOString(),
    }));

    res.json({
      success: true,
      count: formatted.length,
      data: formatted,
    });
  } catch (err) {
    console.error('❌ [TiDB] Error fetching transactions:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   GET /api/transactions/:id
// @desc    Get single transaction by ID
router.get('/:id', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { id } = req.params;

    const [rows] = await pool.query(
      `SELECT 
        id, 
        user_id AS userId, 
        title, 
        amount, 
        type, 
        category, 
        date, 
        payment_method AS paymentMethod, 
        receipt_path AS receiptPath, 
        note, 
        created_at AS createdAt 
      FROM transactions 
      WHERE id = ? AND user_id = ?`,
      [id, userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Transaction not found' });
    }

    const r = rows[0];
    res.json({
      success: true,
      data: {
        ...r,
        amount: Number(r.amount),
        date: r.date instanceof Date ? r.date.toISOString() : new Date(r.date).toISOString(),
      },
    });
  } catch (err) {
    console.error('❌ [TiDB] Error fetching transaction:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   POST /api/transactions
// @desc    Add a new transaction using parameterized SQL query
router.post('/', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { id, title, amount, type, category, date, paymentMethod, note, receiptPath } = req.body;

    if (!title || amount === undefined || !type || !category) {
      return res.status(400).json({
        success: false,
        error: 'Please provide title, amount, type, and category',
      });
    }

    const txId = id || `tx_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const txDate = date ? new Date(date) : new Date();
    const txAmount = Number(amount);
    const txMethod = paymentMethod || 'UPI';

    await pool.query(
      `INSERT INTO transactions (id, user_id, title, amount, type, category, date, payment_method, note, receipt_path)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [txId, userId, title, txAmount, type, category, txDate, txMethod, note || null, receiptPath || null]
    );

    // If it's an expense, update category budget spent amount
    if (type === 'expense') {
      await pool.query(
        `UPDATE budgets 
         SET spent_amount = spent_amount + ? 
         WHERE user_id = ? AND category = ?`,
        [txAmount, userId, category]
      );
    }

    console.log(`💳 [TiDB] Transaction recorded: "${title}" - ₹${txAmount} (ID: ${txId})`);

    res.status(201).json({
      success: true,
      message: 'Transaction saved to TiDB Cloud successfully!',
      data: {
        id: txId,
        userId,
        title,
        amount: txAmount,
        type,
        category,
        date: txDate.toISOString(),
        paymentMethod: txMethod,
        note: note || null,
        receiptPath: receiptPath || null,
      },
    });
  } catch (err) {
    console.error('❌ [TiDB] Error creating transaction:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   PUT /api/transactions/:id
// @desc    Update existing transaction by ID
router.put('/:id', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { id } = req.params;
    const { title, amount, type, category, date, paymentMethod, note, receiptPath } = req.body;

    const [existing] = await pool.query(
      'SELECT amount, type, category FROM transactions WHERE id = ? AND user_id = ?',
      [id, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({ success: false, error: 'Transaction not found' });
    }

    const oldTx = existing[0];
    const oldAmount = Number(oldTx.amount);
    const oldType = oldTx.type;
    const oldCategory = oldTx.category;

    const newAmount = amount !== undefined ? Number(amount) : oldAmount;
    const newType = type || oldType;
    const newCategory = category || oldCategory;
    const txDate = date ? new Date(date) : undefined;
    const txMethod = paymentMethod || 'UPI';

    await pool.query(
      `UPDATE transactions 
       SET title = COALESCE(?, title),
           amount = ?,
           type = ?,
           category = ?,
           date = COALESCE(?, date),
           payment_method = ?,
           note = ?,
           receipt_path = COALESCE(?, receipt_path)
       WHERE id = ? AND user_id = ?`,
      [
        title || null,
        newAmount,
        newType,
        newCategory,
        txDate || null,
        txMethod,
        note !== undefined ? note : null,
        receiptPath || null,
        id,
        userId,
      ]
    );

    // Rollback old budget if old was expense
    if (oldType === 'expense') {
      await pool.query(
        `UPDATE budgets 
         SET spent_amount = GREATEST(0, spent_amount - ?) 
         WHERE user_id = ? AND category = ?`,
        [oldAmount, userId, oldCategory]
      );
    }

    // Apply new budget if new is expense
    if (newType === 'expense') {
      await pool.query(
        `UPDATE budgets 
         SET spent_amount = spent_amount + ? 
         WHERE user_id = ? AND category = ?`,
        [newAmount, userId, newCategory]
      );
    }

    console.log(`✏️ [TiDB] Updated transaction: ${id} ("${title || id}" - ₹${newAmount})`);

    res.json({
      success: true,
      message: 'Transaction updated successfully',
      data: {
        id,
        userId,
        title,
        amount: newAmount,
        type: newType,
        category: newCategory,
        date: txDate ? txDate.toISOString() : undefined,
        paymentMethod: txMethod,
        note: note || null,
        receiptPath: receiptPath || null,
      },
    });
  } catch (err) {
    console.error('❌ [TiDB] Error updating transaction:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   DELETE /api/transactions/:id
// @desc    Delete transaction by ID
router.delete('/:id', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { id } = req.params;

    // Check transaction and rollback budget if expense
    const [existing] = await pool.query(
      'SELECT amount, type, category FROM transactions WHERE id = ? AND user_id = ?',
      [id, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({ success: false, error: 'Transaction not found' });
    }

    const tx = existing[0];
    await pool.query('DELETE FROM transactions WHERE id = ? AND user_id = ?', [id, userId]);

    if (tx.type === 'expense') {
      await pool.query(
        `UPDATE budgets 
         SET spent_amount = GREATEST(0, spent_amount - ?) 
         WHERE user_id = ? AND category = ?`,
        [Number(tx.amount), userId, tx.category]
      );
    }

    console.log(`🗑️ [TiDB] Deleted transaction: ${id}`);
    res.json({ success: true, message: 'Transaction deleted successfully' });
  } catch (err) {
    console.error('❌ [TiDB] Error deleting transaction:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
