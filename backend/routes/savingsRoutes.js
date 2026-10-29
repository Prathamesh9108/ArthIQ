const express = require('express');
const router = express.Router();
const { getPool } = require('../config/db');

const DEFAULT_USER_ID = 'user_rahul_01';

// @route   GET /api/savings-goals
// @desc    Retrieve all savings goals
router.get('/', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;

    const [rows] = await pool.query(
      `SELECT 
        id, 
        title, 
        current_amount AS currentAmount, 
        target_amount AS targetAmount, 
        icon_type AS iconType, 
        target_date AS targetDate 
      FROM savings_goals 
      WHERE user_id = ? 
      ORDER BY created_at ASC`,
      [userId]
    );

    const formatted = rows.map((r) => ({
      id: r.id,
      title: r.title,
      currentAmount: Number(r.currentAmount),
      targetAmount: Number(r.targetAmount),
      iconType: r.iconType || 'goal',
      targetDate: r.targetDate ? new Date(r.targetDate).toISOString() : null,
    }));

    res.json({
      success: true,
      count: formatted.length,
      data: formatted,
    });
  } catch (err) {
    console.error('❌ [TiDB] Error fetching savings goals:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   POST /api/savings-goals
// @desc    Create a new savings goal
router.post('/', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { id, title, targetAmount, currentAmount, iconType, targetDate } = req.body;

    if (!title || targetAmount === undefined) {
      return res.status(400).json({ success: false, error: 'Title and target amount are required' });
    }

    const goalId = id || `sg_${Date.now()}`;
    const curr = Number(currentAmount) || 0;
    const target = Number(targetAmount);

    await pool.query(
      `INSERT INTO savings_goals (id, user_id, title, current_amount, target_amount, icon_type, target_date)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [goalId, userId, title, curr, target, iconType || 'goal', targetDate ? new Date(targetDate) : null]
    );

    console.log(`🎯 [TiDB] Created Savings Goal: "${title}" (Target: ₹${target})`);

    res.status(201).json({
      success: true,
      message: 'Savings goal created in TiDB Cloud',
      data: { id: goalId, title, currentAmount: curr, targetAmount: target, iconType },
    });
  } catch (err) {
    console.error('❌ [TiDB] Error saving goal:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   GET /api/savings-goals/auto-save
// @desc    Get user's auto-save configuration
router.get('/auto-save', async (req, res) => {
  res.json({
    success: true,
    data: {
      autoSaveEnabled: true,
      weeklyAutoSaveAmount: 500.0,
      linkedAccount: 'HDFC Bank (Primary)',
    },
  });
});

// @route   POST /api/savings-goals/auto-save
// @desc    Update user's auto-save configuration
router.post('/auto-save', async (req, res) => {
  const { autoSaveEnabled, weeklyAutoSaveAmount, linkedAccount } = req.body;
  res.json({
    success: true,
    message: 'Auto-save preferences updated',
    data: {
      autoSaveEnabled: autoSaveEnabled !== undefined ? Boolean(autoSaveEnabled) : true,
      weeklyAutoSaveAmount: weeklyAutoSaveAmount ? Number(weeklyAutoSaveAmount) : 500.0,
      linkedAccount: linkedAccount || 'HDFC Bank (Primary)',
    },
  });
});

// @route   POST /api/savings-goals/:id/contribute
// @desc    Deposit / contribute to a savings goal
router.post('/:id/contribute', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { id } = req.params;
    const { amount } = req.body;
    const contribution = Number(amount);

    if (!contribution || contribution <= 0) {
      return res.status(400).json({ success: false, error: 'Valid contribution amount required' });
    }

    const [result] = await pool.query(
      `UPDATE savings_goals 
       SET current_amount = current_amount + ? 
       WHERE id = ? AND user_id = ?`,
      [contribution, id, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Savings goal not found' });
    }

    console.log(`💰 [TiDB] Contributed ₹${contribution} to Goal ID: ${id}`);
    res.json({ success: true, message: `Successfully deposited ₹${contribution}` });
  } catch (err) {
    console.error('❌ [TiDB] Contribution error:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   PUT /api/savings-goals/:id
// @desc    Update a savings goal
router.put('/:id', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { id } = req.params;
    const { title, targetAmount, currentAmount, iconType, targetDate } = req.body;

    const [existing] = await pool.query(
      'SELECT id FROM savings_goals WHERE id = ? AND user_id = ?',
      [id, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({ success: false, error: 'Savings goal not found' });
    }

    await pool.query(
      `UPDATE savings_goals 
       SET title = COALESCE(?, title),
           target_amount = COALESCE(?, target_amount),
           current_amount = COALESCE(?, current_amount),
           icon_type = COALESCE(?, icon_type),
           target_date = COALESCE(?, target_date)
       WHERE id = ? AND user_id = ?`,
      [
        title || null,
        targetAmount !== undefined ? Number(targetAmount) : null,
        currentAmount !== undefined ? Number(currentAmount) : null,
        iconType || null,
        targetDate ? new Date(targetDate) : null,
        id,
        userId,
      ]
    );

    console.log(`🎯 [TiDB] Updated Savings Goal ID: ${id}`);
    res.json({ success: true, message: 'Savings goal updated successfully' });
  } catch (err) {
    console.error('❌ [TiDB] Error updating savings goal:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   DELETE /api/savings-goals/:id
// @desc    Delete a savings goal
router.delete('/:id', async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { id } = req.params;

    const [result] = await pool.query(
      'DELETE FROM savings_goals WHERE id = ? AND user_id = ?',
      [id, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Savings goal not found' });
    }

    console.log(`🗑️ [TiDB] Deleted Savings Goal ID: ${id}`);
    res.json({ success: true, message: 'Savings goal deleted successfully' });
  } catch (err) {
    console.error('❌ [TiDB] Error deleting savings goal:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
