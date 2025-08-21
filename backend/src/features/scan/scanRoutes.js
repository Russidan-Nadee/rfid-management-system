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
   departmentController,
   categoryController,
   brandController
} = require('./scanController');

// Import middleware
const { createRateLimit } = require('./scanMiddleware');
const { authenticateToken } = require('../auth/authMiddleware');
const SessionMiddleware = require('../../core/middleware/sessionMiddleware');

// Import validators
const {
   plantValidators,
   locationValidators,
   unitValidators,
   assetValidators
} = require('./scanValidator');

// Apply rate limiting
const generalRateLimit = createRateLimit(15 * 60 * 1000, 1000);

// Apply authentication and session auto-extension to protected routes
router.use(authenticateToken);
router.use(SessionMiddleware.extendActiveSession);

// Department Routes
router.get('/departments', generalRateLimit, departmentController.getDepartments);

// ===== SCAN ASSET OPERATIONS =====
// Asset lookup during scanning
router.get('/scan/asset/:asset_no', generalRateLimit, assetValidators.getAssetByNo, assetController.getAssetByNo);

// ===== NEW EPC-BASED OPERATIONS =====
// Asset lookup by EPC during scanning
router.get('/scan/epc/:epc_code', generalRateLimit, assetValidators.getAssetByEpc, assetController.getAssetByEpc);

// Update asset status by EPC after scan (mark as checked)
router.patch('/scan/epc/:epc_code/check', generalRateLimit, assetValidators.updateAssetStatusByEpc, assetController.updateAssetStatusByEpc);

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

// Category Routes
router.get('/categories', generalRateLimit, categoryController.getCategories);

// Brand Routes  
router.get('/brands', generalRateLimit, brandController.getBrands);

module.exports = router;