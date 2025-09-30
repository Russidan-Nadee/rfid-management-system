// Path: backend/src/index.js
const express = require('express');
const router = express.Router();

// Import validators (keep existing validators)
const {
   plantValidators,
   locationValidators,
   unitValidators,
   assetValidators,
   statsValidators
} = require('./features/scan/scanValidator');

// Import middleware
const { createRateLimit, checkDatabaseConnection } = require('./features/scan/scanMiddleware');
const { authenticateToken } = require('./features/auth/authMiddleware');

// Import feature routes
const authRoutes = require('./features/auth/authRoutes');
const exportRoutes = require('./features/export/exportRoutes');
const dashboardRoutes = require('./features/dashboard/dashboardRoutes');
const imageRoutes = require('./features/image/image.routes');
const adminRoutes = require('./features/admin/adminRoutes');
const notificationRoutes = require('./features/notification/notificationRoutes');
const costCenterRoutes = require('./features/cost-center/costCenter.routes');

// Apply database connection check to all routes
router.use(checkDatabaseConnection);

// Apply rate limiting
const generalRateLimit = createRateLimit(15 * 60 * 1000, 1000); // 1000 requests per 15 minutes
const strictRateLimit = createRateLimit(15 * 60 * 1000, 100);   // 100 requests per 15 minutes

/**
 * =================================
 * FEATURE ROUTES (MODULAR)
 * =================================
 */
router.use('/auth', authRoutes);
router.use('/search', require('./features/search/searchRoutes'));
router.use('/dashboard', dashboardRoutes);
router.use('/export', exportRoutes);
router.use('/admin', adminRoutes);
router.use('/notifications', notificationRoutes);
router.use('/', costCenterRoutes);
router.use('/', imageRoutes);
router.use(require('./features/scan/scanRoutes'));

/**
 * =================================
 * LEGACY ASSET ROUTES (MINIMAL)
 * =================================
 */

// Import controllers from scan feature (since they have all the controllers we need)
const {
   plantController,
   locationController,
   unitController,
   assetController,
   scanController
} = require('./features/scan/scanController');

// Asset Routes (using scan controllers)
router.get('/assets/numbers', generalRateLimit, assetController.getAssetNumbers);
router.get('/assets', generalRateLimit, assetValidators.getAssets, assetController.getAssets);
router.get('/assets/search', generalRateLimit, assetValidators.searchAssets, assetController.searchAssets);
router.get('/assets/stats', generalRateLimit, assetController.getAssetStats);
router.get('/assets/stats/by-plant', generalRateLimit, assetController.getAssetStatsByPlant);
router.get('/assets/stats/by-location', generalRateLimit, assetController.getAssetStatsByLocation);

// Asset filtering routes (using scan controllers)
router.get('/plants/:plant_code/assets', generalRateLimit, assetValidators.getAssetsByPlant, assetController.getAssetsByPlant);
router.get('/locations/:location_code/assets', generalRateLimit, assetValidators.getAssetsByLocation, assetController.getAssetsByLocation);

/**
 * =================================
 * API DOCUMENTATION ROUTES
 * =================================
 */

// Main API Documentation Route
router.get('/docs', (req, res) => {
   const apiDocs = {
      success: true,
      message: 'Asset Management API Documentation',
      version: '1.0.0',
      timestamp: new Date().toISOString(),

      feature_modules: {
         '/auth': 'Authentication and authorization endpoints',
         '/dashboard': 'Dashboard statistics and analytics endpoints',
         '/search': 'Search functionality across all entities',
         '/export': 'Data export functionality',
         '/admin': 'Admin asset management endpoints (requires admin role)',
         '/notifications': 'Problem reporting and notification management endpoints',
         '/scan': 'Asset scanning and logging endpoints',
         '/images': 'Image management for assets'
      },

      endpoints: {
         authentication: {
            'POST /api/v1/auth/login': 'User login with credentials',
            'POST /api/v1/auth/logout': 'User logout',
            'POST /api/v1/auth/refresh': 'Refresh access token',
            'GET /api/v1/auth/me': 'Get current user profile',
            'POST /api/v1/auth/change-password': 'Change user password'
         },

         dashboard: {
            'GET /api/v1/dashboard/stats': 'Get dashboard statistics with percentage changes',
            'GET /api/v1/dashboard/alerts': 'Get system alerts and notifications',
            'GET /api/v1/dashboard/recent': 'Get recent activities (scans and exports)',
            'GET /api/v1/dashboard/overview': 'Get system overview with charts',
            'GET /api/v1/dashboard/quick-stats': 'Get quick statistics for widgets',
            'GET /api/v1/dashboard/assets-by-plant': 'Get assets distribution by department',
            'GET /api/v1/dashboard/growth-trends': 'Get growth trends by department/location',
            'GET /api/v1/dashboard/location-analytics': 'Get location analytics and utilization',
            'GET /api/v1/dashboard/audit-progress': 'Get audit progress and completion status',
            'GET /api/v1/dashboard/docs': 'Get detailed dashboard API documentation'
         },

         search: {
            'GET /api/v1/search/instant': 'Real-time search with fast response',
            'GET /api/v1/search/suggestions': 'Autocomplete suggestions',
            'GET /api/v1/search/global': 'Comprehensive search across all entities',
            'GET /api/v1/search/advanced': 'Advanced search with filters',
            'GET /api/v1/search/recent': 'Get user recent searches',
            'GET /api/v1/search/popular': 'Get popular search terms'
         },

         export: {
            'POST /api/v1/export/jobs': 'Create export job',
            'GET /api/v1/export/jobs/:jobId': 'Get export job status',
            'GET /api/v1/export/download/:jobId': 'Download export file',
            'GET /api/v1/export/history': 'Get export history',
            'DELETE /api/v1/export/jobs/:jobId': 'Cancel export job',
            'GET /api/v1/export/stats': 'Get export statistics'
         },

         admin: {
            'GET /api/v1/admin/assets': 'Get all assets with full details (admin only)',
            'GET /api/v1/admin/assets/search': 'Search assets with advanced filters (admin only)',
            'GET /api/v1/admin/assets/:assetNo': 'Get specific asset details (admin only)',
            'PUT /api/v1/admin/assets/:assetNo': 'Update asset details (admin only)',
            'DELETE /api/v1/admin/assets/:assetNo': 'Delete asset (admin only)',
            'PUT /api/v1/admin/assets/bulk-update': 'Bulk update multiple assets (admin only)',
            'DELETE /api/v1/admin/assets/bulk-delete': 'Bulk delete multiple assets (admin only)',
            'GET /api/v1/admin/statistics': 'Get comprehensive asset statistics (admin only)',
            'GET /api/v1/admin/master-data': 'Get master data for dropdowns (admin only)',
            'GET /api/v1/admin/health': 'Admin service health check (admin only)'
         },

         notifications: {
            'POST /api/v1/notifications/report-problem': 'Submit a problem report for any asset',
            'GET /api/v1/notifications': 'Get all notifications (admin/manager only)',
            'GET /api/v1/notifications/counts': 'Get notification counts by status (admin/manager only)',
            'GET /api/v1/notifications/:id': 'Get specific notification details (admin/manager only)',
            'PATCH /api/v1/notifications/:id/status': 'Update notification status (admin/manager only)',
            'GET /api/v1/notifications/asset/:assetNo': 'Get notifications for specific asset (admin/manager only)'
         },

         images: {
            'POST /api/v1/assets/:asset_no/images': 'Upload images for asset (max 10)',
            'GET /api/v1/assets/:asset_no/images': 'Get all images for asset',
            'GET /api/v1/images/:imageId': 'Serve image file with optimization',
            'PUT /api/v1/assets/:asset_no/images/:imageId': 'Replace existing image',
            'PATCH /api/v1/assets/:asset_no/images/:imageId': 'Update image metadata',
            'POST /api/v1/assets/:asset_no/images/:imageId/primary': 'Set image as primary',
            'DELETE /api/v1/assets/:asset_no/images/:imageId': 'Delete image',
            'GET /api/v1/images/search': 'Search images across all assets',
            'GET /api/v1/images/system/stats': 'Get system image statistics (admin)'
         },

         scan: {
            'GET /api/v1/scan/asset/:asset_no': 'Get asset by number for scanning',
            'POST /api/v1/scan/asset/create': 'Create unknown asset found during scan',
            'PATCH /api/v1/scan/asset/:asset_no/check': 'Update asset status after scan',
            'POST /api/v1/scan/log': 'Log asset scan',
            'POST /api/v1/scan/mock': 'Mock RFID scan for testing',
            'GET /api/v1/scan/assets/mock': 'Get asset numbers for mock scanning'
         },

         legacy_assets: {
            'GET /api/v1/assets': 'Get all active assets with details',
            'GET /api/v1/assets/search': 'Search assets with filters',
            'GET /api/v1/assets/stats': 'Get asset statistics',
            'GET /api/v1/assets/stats/by-plant': 'Get asset statistics by plant',
            'GET /api/v1/assets/stats/by-location': 'Get asset statistics by location',
            'GET /api/v1/assets/numbers': 'Get asset numbers for mock scanning'
         }
      },

      queryParameters: {
         pagination: {
            page: 'Page number (default: 1)',
            limit: 'Items per page (default: 50, max: 1000)'
         },
         filtering: {
            status: 'Filter by status (A=Active, I=Inactive, C=Created)',
            plant_code: 'Filter by plant code',
            location_code: 'Filter by location code',
            unit_code: 'Filter by unit code',
            dept_code: 'Filter by department code',
            period: 'Time period filter (today, 7d, 30d, Q1, Q2, Q3, Q4, 1Y, custom)',
            year: 'Year for quarterly/yearly data',
            start_date: 'Start date for custom period (YYYY-MM-DD)',
            end_date: 'End date for custom period (YYYY-MM-DD)'
         },
         search: {
            search: 'Search term for asset number, description, serial number, inventory number',
            q: 'Search query for search endpoints',
            entities: 'Target entities for search (assets,plants,locations)',
            fuzzy: 'Enable fuzzy matching for suggestions'
         },
         images: {
            size: 'Image size (original, thumb, small, medium, large)',
            quality: 'Image quality (low, medium, high)',
            format: 'Output format (jpeg, png, webp)',
            include_thumbnails: 'Include thumbnail URLs (default: true)'
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
         401: 'Unauthorized - Authentication required',
         403: 'Forbidden - Access denied',
         404: 'Not Found - Resource not found',
         409: 'Conflict - Resource conflict (e.g., pending export exists)',
         410: 'Gone - Resource expired',
         413: 'Payload Too Large - File too large',
         429: 'Too Many Requests - Rate limit exceeded',
         500: 'Internal Server Error - Server error',
         503: 'Service Unavailable - Database connection failed'
      },

      rate_limiting: {
         general: '1000 requests per 15 minutes',
         strict: '100 requests per 15 minutes (for sensitive operations)',
         search_instant: '120 requests per minute',
         search_general: '60 requests per minute',
         image_upload: '20 uploads per 5 minutes',
         admin_operations: '10 operations per hour'
      },

      authentication: {
         required_endpoints: 'Most endpoints except /docs, /status, and image serving require authentication',
         token_type: 'Bearer JWT Token',
         header: 'Authorization: Bearer <token>',
         refresh: 'Use /auth/refresh to get new tokens'
      },

      file_specifications: {
         supported_formats: ['JPEG', 'PNG', 'WebP'],
         max_file_size: '10MB per file',
         max_files_per_asset: 10,
         thumbnail_size: '300x300 pixels (aspect ratio maintained)',
         naming_convention: '{asset_no}_{YYYYMMDD}_{HHMMSS}_{sequence}.{ext}',
         storage_location: '/uploads/assets/ for originals, /uploads/assets/thumbs/ for thumbnails'
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
      environment: process.env.NODE_ENV || 'development',
      features: {
         authentication: 'Active',
         dashboard: 'Active',
         search: 'Active',
         export: 'Active',
         admin: 'Active',
         notifications: 'Active',
         scan: 'Active',
         images: 'Active'
      }
   });
});

module.exports = router;