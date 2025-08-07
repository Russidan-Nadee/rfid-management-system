const express = require('express');
const AdminController = require('./adminController');
const AdminValidator = require('./adminValidator');
const { authenticateToken } = require('../auth/authMiddleware');
const { requireAdmin } = require('../../core/middleware/roleMiddleware');

const router = express.Router();
const adminController = new AdminController();
const adminValidator = new AdminValidator();

// Apply authentication to all admin routes
router.use(authenticateToken);

// Apply admin role requirement to all admin routes
router.use(requireAdmin);

// Apply input sanitization to all routes
router.use(adminValidator.sanitizeInput);

// ===== ASSET MANAGEMENT ROUTES =====

/**
 * @route   GET /admin/assets
 * @desc    Get all assets with details
 * @access  Admin only
 */
router.get('/assets', 
   adminController.getAllAssets
);

/**
 * @route   GET /admin/assets/search
 * @desc    Search assets with filters
 * @access  Admin only
 * @query   {string} search - Search term (optional)
 * @query   {string} status - Status filter: A (Awaiting), C (Checked), or I (Inactive) (optional)
 * @query   {string} plant_code - Plant filter (optional)
 * @query   {string} location_code - Location filter (optional)
 * @query   {string} unit_code - Unit filter (optional)
 * @query   {string} category_code - Category filter (optional)
 * @query   {string} brand_code - Brand filter (optional)
 */
router.get('/assets/search',
   adminValidator.validateSearchQuery(),
   adminValidator.handleValidationErrors,
   adminController.searchAssets
);

/**
 * @route   GET /admin/assets/:assetNo
 * @desc    Get specific asset by asset number
 * @access  Admin only
 */
router.get('/assets/:assetNo',
   adminValidator.validateAssetNoParam(),
   adminValidator.handleValidationErrors,
   adminController.getAssetByNo
);

/**
 * @route   PUT /admin/assets/:assetNo
 * @desc    Update specific asset
 * @access  Admin only
 */
router.put('/assets/:assetNo',
   adminValidator.validateAssetNoParam(),
   adminValidator.validateAssetUpdate(),
   adminValidator.handleValidationErrors,
   adminValidator.validateBusinessRules,
   adminController.updateAsset
);

/**
 * @route   DELETE /admin/assets/:assetNo
 * @desc    Delete specific asset
 * @access  Admin only
 */
router.delete('/assets/:assetNo',
   adminValidator.validateAssetNoParam(),
   adminValidator.handleValidationErrors,
   adminValidator.validateBusinessRules,
   adminController.deleteAsset
);

// ===== BULK OPERATIONS ROUTES =====

/**
 * @route   PUT /admin/assets/bulk-update
 * @desc    Bulk update multiple assets
 * @access  Admin only
 * @body    {string[]} asset_numbers - Array of asset numbers
 * @body    {object} update_data - Data to update
 */
router.put('/assets/bulk-update',
   adminValidator.validateBulkUpdate(),
   adminValidator.handleValidationErrors,
   adminController.bulkUpdateAssets
);

/**
 * @route   DELETE /admin/assets/bulk-delete
 * @desc    Bulk delete multiple assets
 * @access  Admin only
 * @body    {string[]} asset_numbers - Array of asset numbers
 */
router.delete('/assets/bulk-delete',
   adminValidator.validateBulkDelete(),
   adminValidator.handleValidationErrors,
   adminController.bulkDeleteAssets
);

// ===== STATISTICS ROUTES =====

/**
 * @route   GET /admin/statistics
 * @desc    Get asset statistics
 * @access  Admin only
 */
router.get('/statistics',
   adminController.getAssetStatistics
);

// ===== MASTER DATA ROUTES =====

/**
 * @route   GET /admin/master-data
 * @desc    Get all master data for dropdowns (plants, locations, units, etc.)
 * @access  Admin only
 */
router.get('/master-data',
   adminController.getMasterData
);

// ===== HEALTH CHECK ROUTE =====

/**
 * @route   GET /admin/health
 * @desc    Health check for admin service
 * @access  Admin only
 */
router.get('/health', (req, res) => {
   res.status(200).json({
      success: true,
      message: 'Admin service is running',
      timestamp: new Date().toISOString(),
      user: {
         userId: req.user?.userId,
         username: req.user?.username,
         role: req.user?.role
      }
   });
});

// ===== ERROR HANDLING MIDDLEWARE =====

// Handle 404 for unmatched admin routes
router.use((req, res) => {
   res.status(404).json({
      success: false,
      message: `Admin endpoint ${req.method} ${req.path} not found`,
      timestamp: new Date().toISOString()
   });
});

// Handle errors in admin routes
router.use((error, req, res, next) => {
   console.error('Admin route error:', error);
   
   res.status(error.status || 500).json({
      success: false,
      message: error.message || 'Internal server error in admin service',
      timestamp: new Date().toISOString(),
      ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
   });
});

module.exports = router;