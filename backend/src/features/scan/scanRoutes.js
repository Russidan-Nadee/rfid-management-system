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

// Asset Routes  
router.get('/assets/:asset_no', generalRateLimit, assetValidators.getAssetByNo, assetController.getAssetByNo);
router.post('/assets', generalRateLimit, assetValidators.createAsset, assetController.createAsset);
router.patch('/assets/:asset_no/status', generalRateLimit, assetValidators.updateAssetStatus, assetController.updateAssetStatus);
router.get('/assets/numbers', generalRateLimit, assetController.getAssetNumbers);

// Scan Routes

router.post('/scan/log', generalRateLimit, authenticateToken, scanController.logAssetScan);
router.post('/scan/mock', generalRateLimit, authenticateToken, scanController.mockRfidScan);

// Plant Routes
router.get('/plants', generalRateLimit, plantValidators.getPlants, plantController.getPlants);

// Location Routes  
router.get('/locations', generalRateLimit, locationValidators.getLocations, locationController.getLocations);

// Unit Routes
router.get('/units', generalRateLimit, unitValidators.getUnits, unitController.getUnits);

module.exports = router;