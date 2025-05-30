const express = require('express');
const router = express.Router();

// Import controllers
const {
   plantController,
   locationController,
   unitController,
   userController,
   assetController,
   dashboardController
} = require('../controllers/controller');

// Import validators
const {
   plantValidators,
   locationValidators,
   unitValidators,
   userValidators,
   assetValidators,
   statsValidators
} = require('../validators/validator');

// Import middleware
const { createRateLimit, checkDatabaseConnection } = require('../middlewares/middleware');

// Apply database connection check to all routes
router.use(checkDatabaseConnection);

// Apply rate limiting
const generalRateLimit = createRateLimit(15 * 60 * 1000, 1000); // 1000 requests per 15 minutes
const strictRateLimit = createRateLimit(15 * 60 * 1000, 100);   // 100 requests per 15 minutes

// Dashboard Routes
router.get('/dashboard/stats', generalRateLimit, dashboardController.getDashboardStats);
router.get('/dashboard/overview', generalRateLimit, dashboardController.getOverview);

// Plant Routes
router.get('/plants', generalRateLimit, plantValidators.getPlants, plantController.getPlants);
router.get('/plants/stats', generalRateLimit, plantController.getPlantStats);
router.get('/plants/:plant_code', generalRateLimit, plantValidators.getPlantByCode, plantController.getPlantByCode);

// Location Routes
router.get('/locations', generalRateLimit, locationValidators.getLocations, locationController.getLocations);
router.get('/locations/:location_code', generalRateLimit, locationValidators.getLocationByCode, locationController.getLocationByCode);
router.get('/plants/:plant_code/locations', generalRateLimit, locationValidators.getLocationsByPlant, locationController.getLocationsByPlant);

// Unit Routes
router.get('/units', generalRateLimit, unitValidators.getUnits, unitController.getUnits);
router.get('/units/:unit_code', generalRateLimit, unitValidators.getUnitByCode, unitController.getUnitByCode);

// User Routes
router.get('/users', generalRateLimit, userValidators.getUsers, userController.getUsers);
router.get('/users/:user_id', generalRateLimit, userValidators.getUserById, userController.getUserById);
router.get('/users/username/:username', generalRateLimit, userValidators.getUserByUsername, userController.getUserByUsername);

// Asset Routes
router.get('/assets', generalRateLimit, assetValidators.getAssets, assetController.getAssets);
router.get('/assets/search', generalRateLimit, assetValidators.searchAssets, assetController.searchAssets);
router.get('/assets/stats', generalRateLimit, assetController.getAssetStats);
router.get('/assets/stats/by-plant', generalRateLimit, assetController.getAssetStatsByPlant);
router.get('/assets/stats/by-location', generalRateLimit, assetController.getAssetStatsByLocation);
router.get('/assets/:asset_no', generalRateLimit, assetValidators.getAssetByNo, assetController.getAssetByNo);

// Asset filtering routes
router.get('/plants/:plant_code/assets', generalRateLimit, assetValidators.getAssetsByPlant, assetController.getAssetsByPlant);
router.get('/locations/:location_code/assets', generalRateLimit, assetValidators.getAssetsByLocation, assetController.getAssetsByLocation);

// API Documentation Route
router.get('/docs', (req, res) => {
   const apiDocs = {
      success: true,
      message: 'Asset Management API Documentation',
      version: '1.0.0',
      timestamp: new Date().toISOString(),
      endpoints: {
         dashboard: {
            'GET /api/v1/dashboard/stats': 'Get dashboard statistics',
            'GET /api/v1/dashboard/overview': 'Get system overview'
         },
         plants: {
            'GET /api/v1/plants': 'Get all active plants',
            'GET /api/v1/plants/stats': 'Get plant statistics',
            'GET /api/v1/plants/:plant_code': 'Get plant by code',
            'GET /api/v1/plants/:plant_code/locations': 'Get locations by plant',
            'GET /api/v1/plants/:plant_code/assets': 'Get assets by plant'
         },
         locations: {
            'GET /api/v1/locations': 'Get all active locations with plant details',
            'GET /api/v1/locations/:location_code': 'Get location by code',
            'GET /api/v1/locations/:location_code/assets': 'Get assets by location'
         },
         units: {
            'GET /api/v1/units': 'Get all active units',
            'GET /api/v1/units/:unit_code': 'Get unit by code'
         },
         users: {
            'GET /api/v1/users': 'Get all active users',
            'GET /api/v1/users/:user_id': 'Get user by ID',
            'GET /api/v1/users/username/:username': 'Get user by username'
         },
         assets: {
            'GET /api/v1/assets': 'Get all active assets with details',
            'GET /api/v1/assets/search?search=term&plant_code=&location_code=&unit_code=': 'Search assets',
            'GET /api/v1/assets/stats': 'Get asset statistics',
            'GET /api/v1/assets/stats/by-plant': 'Get asset statistics by plant',
            'GET /api/v1/assets/stats/by-location': 'Get asset statistics by location',
            'GET /api/v1/assets/:asset_no': 'Get asset by number with details'
         }
      },
      queryParameters: {
         pagination: {
            page: 'Page number (default: 1)',
            limit: 'Items per page (default: 50, max: 1000)'
         },
         filtering: {
            status: 'Filter by status (A=Active, I=Inactive)',
            plant_code: 'Filter by plant code',
            location_code: 'Filter by location code',
            unit_code: 'Filter by unit code'
         },
         search: {
            search: 'Search term for asset number, description, serial number, inventory number'
         }
      },
      responseFormat: {
         success: 'boolean - Request success status',
         message: 'string - Response message',
         timestamp: 'string - ISO timestamp',
         data: 'object|array - Response data',
         meta: 'object - Additional metadata (pagination, etc.)'
      },
      errorCodes: {
         400: 'Bad Request - Invalid parameters or validation failed',
         404: 'Not Found - Resource not found',
         429: 'Too Many Requests - Rate limit exceeded',
         500: 'Internal Server Error - Server error',
         503: 'Service Unavailable - Database connection failed'
      }
   };

   res.status(200).json(apiDocs);
});

// API Status Route
router.get('/status', (req, res) => {
   res.status(200).json({
      success: true,
      message: 'Asset Management API is running',
      version: '1.0.0',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development'
   });
});

module.exports = router;