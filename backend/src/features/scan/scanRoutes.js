// Path: backend/src/features/scan/scanRoutes.js
const express = require('express');
const router = express.Router();

// Import scan controllers
const {
   plantController,
   locationController,
   unitController,
   assetController,
   scanController,
   departmentController
} = require('./scanController');

// Import middleware
const { createRateLimit } = require('../../middlewares/middleware');
const { authenticateToken } = require('../../middlewares/authMiddleware');

// Import validators
const {
   plantValidators,
   locationValidators,
   unitValidators,
   assetValidators
} = require('../../validators/validator');

// Apply rate limiting
const generalRateLimit = createRateLimit(15 * 60 * 1000, 1000);

// Department Routes
router.get('/departments', generalRateLimit, departmentController.getDepartments);

// ===== SCAN ASSET OPERATIONS =====
// Asset lookup during scanning
router.get('/scan/asset/:asset_no', generalRateLimit, assetValidators.getAssetByNo, assetController.getAssetByNo);

// Create unknown asset found during scan
router.post('/scan/asset/create', generalRateLimit, assetValidators.createAsset, assetController.createAsset);

// Update asset status after scan (mark as checked)
router.patch('/scan/asset/:asset_no/check', generalRateLimit, assetValidators.updateAssetStatus, assetController.updateAssetStatus);

// Get asset numbers for mock scanning
router.get('/scan/assets/mock', generalRateLimit, assetController.getAssetNumbers);

// ===== SCAN LOGGING =====
router.post('/scan/log', generalRateLimit, authenticateToken, scanController.logAssetScan);
router.post('/scan/mock', generalRateLimit, authenticateToken, scanController.mockRfidScan);

// ===== MASTER DATA FOR SCANNING =====
// Plant Routes
router.get('/plants', generalRateLimit, plantValidators.getPlants, plantController.getPlants);

// Location Routes  
router.get('/locations', generalRateLimit, locationValidators.getLocations, locationController.getLocations);

// Unit Routes
router.get('/units', generalRateLimit, unitValidators.getUnits, unitController.getUnits);

module.exports = router;