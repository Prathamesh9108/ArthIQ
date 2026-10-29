const http = require('http');
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const { testConnection } = require('../config/db');

async function testApiEndpoints() {
  console.log('====================================================');
  console.log('🧪 Testing Backend Express Endpoints with TiDB Cloud');
  console.log('====================================================\n');

  const app = express();
  app.use(cors());
  app.use(express.json());

  app.use('/api/health', require('../routes/healthRoutes'));
  app.use('/api/transactions', require('../routes/transactionRoutes'));
  app.use('/api/budgets', require('../routes/budgetRoutes'));
  app.use('/api/savings-goals', require('../routes/savingsRoutes'));
  app.use('/api/savings/goals', require('../routes/savingsRoutes'));
  app.use('/api/user', require('../routes/userRoutes'));
  app.use('/api/categories', require('../routes/categoryRoutes'));

  const server = http.createServer(app);
  const TEST_PORT = 5055;

  await new Promise((resolve) => server.listen(TEST_PORT, resolve));
  console.log(`🚀 Test server started on port ${TEST_PORT}\n`);

  function request(method, path, body = null) {
    return new Promise((resolve, reject) => {
      const options = {
        hostname: 'localhost',
        port: TEST_PORT,
        path,
        method,
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': 'user_rahul_01',
        },
      };

      const req = http.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          try {
            const parsed = JSON.parse(data);
            resolve({ statusCode: res.statusCode, body: parsed });
          } catch (e) {
            resolve({ statusCode: res.statusCode, body: data });
          }
        });
      });

      req.on('error', reject);
      if (body) {
        req.write(JSON.stringify(body));
      }
      req.end();
    });
  }

  let passed = 0;
  let total = 0;

  function assert(condition, message) {
    total++;
    if (condition) {
      console.log(`  ✅ PASS: ${message}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${message}`);
    }
  }

  try {
    // 1. Health
    const healthRes = await request('GET', '/api/health');
    assert(healthRes.statusCode === 200 && healthRes.body.status === 'healthy' && healthRes.body.dbStatus === 'connected', 'Health endpoint reports connected TiDB Cloud');

    // 2. User Profile
    const userRes = await request('GET', '/api/user/profile');
    assert(userRes.statusCode === 200 && userRes.body.data.name === 'Rahul Sharma', 'User profile retrieved from TiDB Cloud');

    // Update User Profile
    const updateProfileRes = await request('PUT', '/api/user/profile', { phone: '+91 98765 43210' });
    assert(updateProfileRes.statusCode === 200 && updateProfileRes.body.success, 'User profile update persisted in TiDB Cloud');

    // 3. Categories
    const catRes = await request('GET', '/api/categories');
    assert(catRes.statusCode === 200 && catRes.body.count > 0, `Categories retrieved from TiDB Cloud (count: ${catRes.body.count})`);

    // 4. Transactions GET
    const txRes = await request('GET', '/api/transactions');
    assert(txRes.statusCode === 200 && Array.isArray(txRes.body.data), `Transactions retrieved from TiDB Cloud (count: ${txRes.body.count})`);

    // 5. Budgets GET
    const budgetRes = await request('GET', '/api/budgets');
    assert(budgetRes.statusCode === 200 && Array.isArray(budgetRes.body.data), `Budgets retrieved from TiDB Cloud (count: ${budgetRes.body.count})`);

    // 6. Savings Goals GET
    const goalRes = await request('GET', '/api/savings-goals');
    assert(goalRes.statusCode === 200 && Array.isArray(goalRes.body.data), `Savings goals retrieved from TiDB Cloud (count: ${goalRes.body.count})`);

    // 7. Savings Goals alias /api/savings/goals
    const aliasRes = await request('GET', '/api/savings/goals');
    assert(aliasRes.statusCode === 200 && aliasRes.body.count === goalRes.body.count, 'Alias /api/savings/goals functions identically');

    // 8. Auto-save config
    const autoSaveRes = await request('GET', '/api/savings-goals/auto-save');
    assert(autoSaveRes.statusCode === 200 && autoSaveRes.body.data.weeklyAutoSaveAmount === 500, 'Auto-save endpoint returned valid config');

    console.log('\n====================================================');
    console.log(`🏁 API Test Results: ${passed}/${total} Passed (${((passed / total) * 100).toFixed(0)}%)`);
    console.log('====================================================\n');
  } catch (err) {
    console.error('❌ Error testing API endpoints:', err);
  } finally {
    server.close();
    process.exit(passed === total ? 0 : 1);
  }
}

testApiEndpoints();
