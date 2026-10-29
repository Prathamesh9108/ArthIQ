const express = require('express');
const cors = require('cors');
require('dotenv').config();

const { testConnection } = require('./config/db');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
  console.log(`📡 [${req.method}] ${req.url}`);
  next();
});

// REST API Routes
app.use('/api/health', require('./routes/healthRoutes'));
app.use('/api/transactions', require('./routes/transactionRoutes'));
app.use('/api/budgets', require('./routes/budgetRoutes'));
app.use('/api/savings-goals', require('./routes/savingsRoutes'));
app.use('/api/savings/goals', require('./routes/savingsRoutes'));
app.use('/api/user', require('./routes/userRoutes'));
app.use('/api/categories', require('./routes/categoryRoutes'));

// Root Discovery Endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'ArthIQ Backend API Server',
    database: 'TiDB Cloud Serverless (MySQL Compatible)',
    status: 'Running',
    endpoints: {
      health: '/api/health',
      transactions: '/api/transactions',
      budgets: '/api/budgets',
      savingsGoals: '/api/savings-goals',
      user: '/api/user/profile',
      categories: '/api/categories',
    },
  });
});

const PORT = process.env.PORT || 5000;

// Verify TiDB connection on start
app.listen(PORT, async () => {
  console.log(`\n========================================`);
  console.log(`🚀 ArthIQ Backend Server is running!`);
  console.log(`📍 URL: http://localhost:${PORT}`);
  console.log(`🏥 Health Check: http://localhost:${PORT}/api/health`);
  console.log(`💳 Transactions: http://localhost:${PORT}/api/transactions`);
  console.log(`📊 Budgets:      http://localhost:${PORT}/api/budgets`);
  console.log(`🎯 Savings:      http://localhost:${PORT}/api/savings-goals`);
  console.log(`========================================\n`);

  await testConnection();
});
