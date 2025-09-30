// Path: backend/src/features/cost-center/costCenter.routes.js
const express = require('express');
const router = express.Router();

const CostCenterController = require('./costCenter.controller');
const { authenticateToken } = require('../auth/authMiddleware');

const costCenterController = new CostCenterController();

// GET /api/cost-centers/stats - Get cost center statistics
router.get('/cost-centers/stats',
  authenticateToken,
  (req, res) => costCenterController.getCostCenterStats(req, res)
);

// GET /api/cost-centers - Get all cost centers with filters
router.get('/cost-centers',
  authenticateToken,
  (req, res) => costCenterController.getAllCostCenters(req, res)
);

// GET /api/cost-centers/:code - Get specific cost center
router.get('/cost-centers/:code',
  authenticateToken,
  (req, res) => costCenterController.getCostCenterByCode(req, res)
);

// GET /api/divisions - Get all divisions with cost centers
router.get('/divisions',
  authenticateToken,
  (req, res) => costCenterController.getAllDivisions(req, res)
);

// GET /api/divisions/:divisionCode/cost-centers - Get cost centers by division
router.get('/divisions/:divisionCode/cost-centers',
  authenticateToken,
  (req, res) => costCenterController.getCostCentersByDivision(req, res)
);

// GET /api/plants/:plantCode/cost-centers - Get cost centers by plant
router.get('/plants/:plantCode/cost-centers',
  authenticateToken,
  (req, res) => costCenterController.getCostCentersByPlant(req, res)
);

module.exports = router;