const express = require('express');
const router = express.Router();
const { getPool } = require('../config/db');

const DEFAULT_USER_ID = 'user_rahul_01';

// @route   GET /api/user/profile (or /api/user)
// @desc    Retrieve user profile from TiDB Cloud
router.get(['/', '/profile'], async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;

    const [rows] = await pool.query(
      `SELECT 
        id, 
        name, 
        email, 
        phone, 
        avatar_url AS avatarUrl, 
        currency, 
        biometrics_enabled AS biometricsEnabled, 
        monthly_income AS monthlyIncome,
        created_at AS createdAt,
        updated_at AS updatedAt
      FROM users 
      WHERE id = ?`,
      [userId]
    );

    if (rows.length === 0) {
      // Ensure default user exists if not yet inserted
      await pool.query(
        `INSERT IGNORE INTO users (id, name, email, phone, currency, biometrics_enabled, monthly_income)
         VALUES (?, 'Rahul Sharma', 'rahul@gmail.com', '+91 98765 43210', '₹', TRUE, 20000.00)`,
        [userId]
      );

      const [newRows] = await pool.query(
        `SELECT 
          id, name, email, phone, avatar_url AS avatarUrl, currency, 
          biometrics_enabled AS biometricsEnabled, monthly_income AS monthlyIncome 
        FROM users WHERE id = ?`,
        [userId]
      );
      const user = newRows[0];
      return res.json({
        success: true,
        data: {
          ...user,
          monthlyIncome: Number(user.monthlyIncome),
          biometricsEnabled: Boolean(user.biometricsEnabled),
        },
      });
    }

    const user = rows[0];
    res.json({
      success: true,
      data: {
        ...user,
        monthlyIncome: Number(user.monthlyIncome),
        biometricsEnabled: Boolean(user.biometricsEnabled),
      },
    });
  } catch (err) {
    console.error('❌ [TiDB] Error fetching user profile:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   PUT /api/user/profile (or /api/user)
// @desc    Update user profile in TiDB Cloud
router.put(['/', '/profile'], async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.headers['x-user-id'] || DEFAULT_USER_ID;
    const { name, email, phone, avatarUrl, currency, biometricsEnabled, monthlyIncome } = req.body;

    await pool.query(
      `UPDATE users 
       SET name = COALESCE(?, name),
           email = COALESCE(?, email),
           phone = COALESCE(?, phone),
           avatar_url = COALESCE(?, avatar_url),
           currency = COALESCE(?, currency),
           biometrics_enabled = COALESCE(?, biometrics_enabled),
           monthly_income = COALESCE(?, monthly_income)
       WHERE id = ?`,
      [
        name || null,
        email || null,
        phone || null,
        avatarUrl || null,
        currency || null,
        biometricsEnabled !== undefined ? Boolean(biometricsEnabled) : null,
        monthlyIncome !== undefined ? Number(monthlyIncome) : null,
        userId,
      ]
    );

    const [rows] = await pool.query(
      `SELECT 
        id, name, email, phone, avatar_url AS avatarUrl, currency, 
        biometrics_enabled AS biometricsEnabled, monthly_income AS monthlyIncome 
      FROM users WHERE id = ?`,
      [userId]
    );

    const updatedUser = rows[0];
    console.log(`👤 [TiDB] Updated User Profile: ${userId} (${updatedUser.name})`);

    res.json({
      success: true,
      message: 'User profile updated in TiDB Cloud',
      data: {
        ...updatedUser,
        monthlyIncome: Number(updatedUser.monthlyIncome),
        biometricsEnabled: Boolean(updatedUser.biometricsEnabled),
      },
    });
  } catch (err) {
    console.error('❌ [TiDB] Error updating user profile:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
