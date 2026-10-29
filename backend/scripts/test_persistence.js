const { getPool, testConnection } = require('../config/db');

async function runPersistenceTests() {
  console.log('====================================================');
  console.log('🧪 Starting TiDB Cloud Single Source of Truth Tests');
  console.log('====================================================\n');

  const isConnected = await testConnection();
  if (!isConnected) {
    console.error('❌ Cannot connect to TiDB Cloud. Check credentials in backend/.env');
    process.exit(1);
  }

  const pool = getPool();
  const testUserId = 'user_rahul_01';
  let passedCount = 0;
  let totalCount = 0;

  function assert(condition, testName) {
    totalCount++;
    if (condition) {
      console.log(`  ✅ PASS: ${testName}`);
      passedCount++;
    } else {
      console.error(`  ❌ FAIL: ${testName}`);
    }
  }

  try {
    // ----------------------------------------------------
    // TEST 1: User isolation and existence
    // ----------------------------------------------------
    console.log('\n--- 1. User Isolation & Profile Verification ---');
    const [userRows] = await pool.query('SELECT id, name, email FROM users WHERE id = ?', [testUserId]);
    assert(userRows.length === 1, `Default user "${testUserId}" exists in TiDB Cloud`);
    assert(userRows[0].email === 'rahul@gmail.com', `User email verified: ${userRows[0]?.email}`);

    // ----------------------------------------------------
    // TEST 2: Transaction CRUD against TiDB Cloud
    // ----------------------------------------------------
    console.log('\n--- 2. Transaction CRUD & Persistence Verification ---');
    const testTxId = `test_tx_${Date.now()}`;
    const txDate = new Date();
    
    // Create
    await pool.query(
      `INSERT INTO transactions (id, user_id, title, amount, type, category, date, payment_method, note, receipt_path)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [testTxId, testUserId, 'Automated Test Expense', 750.50, 'expense', 'Food & Dining', txDate, 'UPI', 'Persistence check note', 'receipt_test.jpg']
    );
    console.log(`  ➕ Inserted transaction: ${testTxId}`);

    // Read
    const [createdTxRows] = await pool.query('SELECT * FROM transactions WHERE id = ? AND user_id = ?', [testTxId, testUserId]);
    assert(createdTxRows.length === 1, 'Transaction retrieved from TiDB Cloud');
    assert(Number(createdTxRows[0].amount) === 750.50, 'Transaction amount matches exactly 750.50');
    assert(createdTxRows[0].title === 'Automated Test Expense', 'Transaction title matches');
    assert(createdTxRows[0].payment_method === 'UPI', 'Transaction payment method matches');
    assert(createdTxRows[0].note === 'Persistence check note', 'Transaction note matches');
    assert(createdTxRows[0].receipt_path === 'receipt_test.jpg', 'Transaction receipt path matches');

    // Update
    await pool.query(
      `UPDATE transactions SET amount = ?, note = ? WHERE id = ? AND user_id = ?`,
      [900.00, 'Updated test note', testTxId, testUserId]
    );
    const [updatedTxRows] = await pool.query('SELECT * FROM transactions WHERE id = ? AND user_id = ?', [testTxId, testUserId]);
    assert(Number(updatedTxRows[0].amount) === 900.00, 'Transaction update persisted (new amount 900.00)');
    assert(updatedTxRows[0].note === 'Updated test note', 'Transaction note update persisted');

    // Delete
    await pool.query('DELETE FROM transactions WHERE id = ? AND user_id = ?', [testTxId, testUserId]);
    const [deletedTxRows] = await pool.query('SELECT * FROM transactions WHERE id = ? AND user_id = ?', [testTxId, testUserId]);
    assert(deletedTxRows.length === 0, 'Transaction deletion confirmed in TiDB Cloud');

    // ----------------------------------------------------
    // TEST 3: Budget CRUD against TiDB Cloud
    // ----------------------------------------------------
    console.log('\n--- 3. Budget CRUD & Persistence Verification ---');
    const testBudgetId = `test_b_${Date.now()}`;
    const testCat = 'Automated Test Category';

    // Create / Upsert
    await pool.query(
      `INSERT INTO budgets (id, user_id, category, limit_amount, spent_amount, period)
       VALUES (?, ?, ?, 4000.00, 0.00, 'monthly')
       ON DUPLICATE KEY UPDATE limit_amount = 4000.00`,
      [testBudgetId, testUserId, testCat]
    );
    const [createdBudgets] = await pool.query('SELECT * FROM budgets WHERE category = ? AND user_id = ?', [testCat, testUserId]);
    assert(createdBudgets.length === 1, 'Budget category inserted in TiDB Cloud');
    assert(Number(createdBudgets[0].limit_amount) === 4000.00, 'Budget limit persisted as 4000.00');

    // Clean up test budget
    await pool.query('DELETE FROM budgets WHERE category = ? AND user_id = ?', [testCat, testUserId]);
    const [deletedBudgets] = await pool.query('SELECT * FROM budgets WHERE category = ? AND user_id = ?', [testCat, testUserId]);
    assert(deletedBudgets.length === 0, 'Budget category deleted cleanly');

    // ----------------------------------------------------
    // TEST 4: Savings Goal CRUD against TiDB Cloud
    // ----------------------------------------------------
    console.log('\n--- 4. Savings Goal CRUD & Persistence Verification ---');
    const testGoalId = `test_sg_${Date.now()}`;
    
    // Create
    await pool.query(
      `INSERT INTO savings_goals (id, user_id, title, current_amount, target_amount, icon_type)
       VALUES (?, ?, 'New Bike Fund', 2000.00, 25000.00, 'bike')`,
      [testGoalId, testUserId]
    );
    const [createdGoals] = await pool.query('SELECT * FROM savings_goals WHERE id = ? AND user_id = ?', [testGoalId, testUserId]);
    assert(createdGoals.length === 1, 'Savings goal created in TiDB Cloud');
    assert(Number(createdGoals[0].current_amount) === 2000.00, 'Savings goal current amount is 2000.00');
    assert(Number(createdGoals[0].target_amount) === 25000.00, 'Savings goal target amount is 25000.00');

    // Contribute
    await pool.query(
      `UPDATE savings_goals SET current_amount = current_amount + ? WHERE id = ? AND user_id = ?`,
      [500.00, testGoalId, testUserId]
    );
    const [contributedGoals] = await pool.query('SELECT current_amount FROM savings_goals WHERE id = ? AND user_id = ?', [testGoalId, testUserId]);
    assert(Number(contributedGoals[0].current_amount) === 2500.00, 'Contribution persisted (2000 + 500 = 2500.00)');

    // Delete
    await pool.query('DELETE FROM savings_goals WHERE id = ? AND user_id = ?', [testGoalId, testUserId]);
    const [deletedGoals] = await pool.query('SELECT * FROM savings_goals WHERE id = ? AND user_id = ?', [testGoalId, testUserId]);
    assert(deletedGoals.length === 0, 'Savings goal deletion confirmed in TiDB Cloud');

    // ----------------------------------------------------
    // Summary of Current Records in TiDB Cloud
    // ----------------------------------------------------
    console.log('\n--- 5. TiDB Cloud Active Table Counts ---');
    const [txCount] = await pool.query('SELECT COUNT(*) as count FROM transactions WHERE user_id = ?', [testUserId]);
    const [budgetCount] = await pool.query('SELECT COUNT(*) as count FROM budgets WHERE user_id = ?', [testUserId]);
    const [goalCount] = await pool.query('SELECT COUNT(*) as count FROM savings_goals WHERE user_id = ?', [testUserId]);
    console.log(`  💳 Active Transactions in TiDB: ${txCount[0].count}`);
    console.log(`  📊 Active Budgets in TiDB:      ${budgetCount[0].count}`);
    console.log(`  🎯 Active Savings Goals in TiDB: ${goalCount[0].count}`);

    console.log('\n====================================================');
    console.log(`🏁 Test Results: ${passedCount}/${totalCount} Passed (${((passedCount/totalCount)*100).toFixed(0)}%)`);
    console.log('====================================================\n');

    process.exit(passedCount === totalCount ? 0 : 1);
  } catch (err) {
    console.error('❌ Error during persistence tests:', err);
    process.exit(1);
  }
}

runPersistenceTests();
