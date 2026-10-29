const express = require('express');
const router = express.Router();
const { getPool } = require('../config/db');

// Default initial categories to seed if table is empty
const DEFAULT_CATEGORIES = [
  { id: 'cat_food', name: 'Food & Dining', type: 'expense', icon: 'restaurant_rounded', color: '#FF9F43' },
  { id: 'cat_transport', name: 'Transport', type: 'expense', icon: 'directions_car_rounded', color: '#54A0FF' },
  { id: 'cat_shopping', name: 'Shopping', type: 'expense', icon: 'shopping_bag_rounded', color: '#FF6B81' },
  { id: 'cat_bills', name: 'Bills & Utilities', type: 'expense', icon: 'receipt_long_rounded', color: '#FECA57' },
  { id: 'cat_rent', name: 'Rent', type: 'expense', icon: 'home_rounded', color: '#10AC84' },
  { id: 'cat_entertainment', name: 'Entertainment', type: 'expense', icon: 'movie_filter_rounded', color: '#5F27CD' },
  { id: 'cat_health', name: 'Health', type: 'expense', icon: 'favorite_rounded', color: '#FF7675' },
  { id: 'cat_groceries', name: 'Groceries', type: 'expense', icon: 'local_grocery_store_rounded', color: '#00D2D3' },
  { id: 'cat_education', name: 'Education', type: 'expense', icon: 'school_rounded', color: '#5F27CD' },
  { id: 'cat_investments', name: 'Investments', type: 'expense', icon: 'trending_up_rounded', color: '#48DBFB' },
  { id: 'cat_salary', name: 'Salary Credit', type: 'income', icon: 'account_balance_wallet_rounded', color: '#1DD1A1' },
  { id: 'cat_freelance', name: 'Freelance', type: 'income', icon: 'work_rounded', color: '#00D2D3' },
  { id: 'cat_dividends', name: 'Investments & Dividends', type: 'income', icon: 'trending_up_rounded', color: '#48DBFB' },
  { id: 'cat_rental_inc', name: 'Rental Income', type: 'income', icon: 'domain_rounded', color: '#1DD1A1' },
  { id: 'cat_cashback', name: 'Cashback & Rewards', type: 'income', icon: 'card_giftcard_rounded', color: '#FF9FF3' },
  { id: 'cat_other_inc', name: 'Other Income', type: 'income', icon: 'attach_money_rounded', color: '#54A0FF' },
  { id: 'cat_others', name: 'Others', type: 'expense', icon: 'category_rounded', color: '#8395A7' },
];

// @route   GET /api/categories
// @desc    Retrieve all categories from TiDB Cloud
router.get('/', async (req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query(
      'SELECT id, name, type, icon, color, created_at AS createdAt FROM categories ORDER BY type ASC, name ASC'
    );

    if (rows.length === 0) {
      // Seed default categories into TiDB Cloud
      for (const cat of DEFAULT_CATEGORIES) {
        await pool.query(
          'INSERT IGNORE INTO categories (id, name, type, icon, color) VALUES (?, ?, ?, ?, ?)',
          [cat.id, cat.name, cat.type, cat.icon, cat.color]
        );
      }
      const [seeded] = await pool.query(
        'SELECT id, name, type, icon, color, created_at AS createdAt FROM categories ORDER BY type ASC, name ASC'
      );
      return res.json({ success: true, count: seeded.length, data: seeded });
    }

    res.json({
      success: true,
      count: rows.length,
      data: rows,
    });
  } catch (err) {
    console.error('❌ [TiDB] Error fetching categories:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   POST /api/categories
// @desc    Add a category to TiDB Cloud
router.post('/', async (req, res) => {
  try {
    const pool = getPool();
    const { id, name, type, icon, color } = req.body;

    if (!name || !type) {
      return res.status(400).json({ success: false, error: 'Name and type (expense/income) are required' });
    }

    const catId = id || `cat_${Date.now()}`;
    await pool.query(
      'INSERT INTO categories (id, name, type, icon, color) VALUES (?, ?, ?, ?, ?)',
      [catId, name, type, icon || 'category_rounded', color || '#8395A7']
    );

    console.log(`🏷️ [TiDB] Created Category: ${name} (${type})`);
    res.status(201).json({
      success: true,
      message: 'Category created in TiDB Cloud',
      data: { id: catId, name, type, icon, color },
    });
  } catch (err) {
    console.error('❌ [TiDB] Error creating category:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// @route   DELETE /api/categories/:id
// @desc    Delete a category
router.delete('/:id', async (req, res) => {
  try {
    const pool = getPool();
    const { id } = req.params;

    const [result] = await pool.query('DELETE FROM categories WHERE id = ? OR name = ?', [id, id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Category not found' });
    }

    console.log(`🗑️ [TiDB] Deleted Category: ${id}`);
    res.json({ success: true, message: 'Category deleted from TiDB Cloud' });
  } catch (err) {
    console.error('❌ [TiDB] Error deleting category:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
