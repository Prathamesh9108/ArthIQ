const express = require('express');
const router = express.Router();
const { getPool, getDbStatus } = require('../config/db');

// @route   GET /api/health
// @desc    Verify backend status, memory, and TiDB Cloud connectivity
router.get('/', async (req, res) => {
  const startTime = Date.now();
  try {
    const dbStatus = await getDbStatus();
    const isDbConnected = dbStatus.status === 'connected';
    const latency = Date.now() - startTime;

    res.json({
      status: isDbConnected ? 'healthy' : 'degraded',
      service: 'ArthIQ Backend API',
      database: 'TiDB Cloud (MySQL Compatible)',
      dbStatus: dbStatus.status,
      host: dbStatus.host || null,
      latencyMs: latency,
      timestamp: new Date().toISOString(),
      uptimeSeconds: Math.floor(process.uptime()),
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      service: 'ArthIQ Backend API',
      database: 'TiDB Cloud',
      error: err.message,
    });
  }
});

module.exports = router;
