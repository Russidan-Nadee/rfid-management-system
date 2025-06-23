// Path: backend/src/routes/route.js
const express = require('express');
const router = express.Router();

// Import controllers
const {
   plantController,
   locationController,
   unitController,
   userController,
   assetController,
   scanController
} = require('../controllers/controller');

// Import dashboard controller (separate file)
const dashboardController = require('../controllers/dashboardController');

// Import export controller
const ExportController = require('../controllers/exportController');
const exportController = new ExportController();

// Import validators
const {
   plantValidators,
   locationValidators,
   unitValidators,
   userValidators,
   assetValidators,
   statsValidators
} = require('../validators/validator');

// Import export validators
const {
   createExportValidator,
   getExportJobValidator,
   downloadExportValidator,
   getExportHistoryValidator,
   cancelExportValidator,
   validateExportConfigByType,
   validateExportSize
} = require('../validators/exportValidator');

// Import dashboard validators (ENHANCED)
const {
   dashboardStatsValidator,
   dashboardAlertsValidator,
   dashboardRecentValidator,
   dashboardOverviewValidator,
   dashboardQuickStatsValidator,
   assetsByDepartmentValidator,
   growthTrendsValidator,
   locationAnalyticsValidator,
   auditProgressValidator,
   dashboardLocationsValidator,
   dashboardExportValidator
} = require('../validators/dashboardValidator');

// Import middleware
const { createRateLimit, checkDatabaseConnection } = require('../middlewares/middleware');
const { authenticateToken } = require('../middlewares/authMiddleware');
const authRoutes = require('./authRoutes');

// Apply database connection check to all routes
router.use(checkDatabaseConnection);
router.use('/auth', authRoutes);
router.use('/search', require('./searchRoutes'));

// Apply rate limiting
const generalRateLimit = createRateLimit(15 * 60 * 1000, 1000); // 1000 requests per 15 minutes
const strictRateLimit = createRateLimit(15 * 60 * 1000, 100);   // 100 requests per 15 minutes

// Dashboard Routes (ENHANCED - แทนที่ส่วนเดิม)
router.get('/dashboard/locations',
   generalRateLimit,
   dashboardLocationsValidator,
   locationController.getLocations
);
router.get('/dashboard/stats',
   generalRateLimit,
   dashboardStatsValidator,
   dashboardController.getDashboardStats
);

router.get('/dashboard/alerts',
   generalRateLimit,
   dashboardAlertsValidator,
   dashboardController.getDashboardAlerts
);

router.get('/dashboard/recent',
   generalRateLimit,
   dashboardRecentValidator,
   dashboardController.getDashboardRecent
);

router.get('/dashboard/overview',
   generalRateLimit,
   dashboardOverviewValidator,
   dashboardController.getOverview
);

router.get('/dashboard/quick-stats',
   generalRateLimit,
   dashboardQuickStatsValidator,
   dashboardController.getQuickStats
);

// Enhanced Dashboard Routes (NEW FEATURE APIS)
router.get('/dashboard/assets-by-plant',
   generalRateLimit,
   assetsByDepartmentValidator,
   dashboardController.getAssetsByDepartment
);

router.get('/dashboard/growth-trends',
   generalRateLimit,
   growthTrendsValidator,
   dashboardController.getGrowthTrends
);

router.get('/dashboard/location-analytics',
   generalRateLimit,
   locationAnalyticsValidator,
   dashboardController.getLocationAnalytics
);

router.get('/dashboard/audit-progress',
   generalRateLimit,
   auditProgressValidator,
   dashboardController.getAuditProgress
);

// API Documentation สำหรับ Dashboard APIs (ENHANCED)
router.get('/dashboard/docs', (req, res) => {
   const dashboardDocs = {
      success: true,
      message: 'Enhanced Dashboard API Documentation',
      version: '2.0.0',
      timestamp: new Date().toISOString(),
      endpoints: {
         '/dashboard/stats': {
            method: 'GET',
            description: 'Get dashboard statistics with percentage changes',
            parameters: {
               period: 'Time period filter: today|7d|30d (default: today)'
            },
            response: {
               overview: 'Asset counts, scan counts, export counts with trends',
               charts: 'Asset status breakdown, scan trends',
               period_info: 'Period details and comparison data'
            },
            example: '/dashboard/stats?period=7d'
         },
         '/dashboard/alerts': {
            method: 'GET',
            description: 'Get system alerts and notifications',
            response: {
               alerts: 'Array of alert objects with severity levels'
            },
            severity_levels: ['error', 'warning', 'info']
         },
         '/dashboard/recent': {
            method: 'GET',
            description: 'Get recent activities (scans and exports)',
            parameters: {
               period: 'Time period filter: today|7d|30d (default: 7d)'
            },
            response: {
               recent_scans: '5 latest scans in period',
               recent_exports: '5 latest exports in period'
            }
         },
         '/dashboard/overview': {
            method: 'GET',
            description: 'Get system overview with charts',
            parameters: {
               period: 'Time period filter: today|7d|30d (default: 7d)'
            },
            response: {
               assets_by_plant: 'Asset distribution by plant',
               assets_by_location: 'Asset distribution by location',
               recent_assets: 'Recently created assets',
               scan_trend: 'Scan activity trend'
            }
         },
         '/dashboard/quick-stats': {
            method: 'GET',
            description: 'Get quick statistics for widgets',
            parameters: {
               period: 'Time period filter: today|7d|30d (default: today)'
            },
            response: {
               assets: 'Asset counts by status',
               scans: 'Scan activity in period',
               exports: 'Export activity in period',
               users: 'Active users in period'
            }
         },
         '/dashboard/assets-by-plant': {
            method: 'GET',
            description: 'Get assets distribution by department (Pie Chart data)',
            parameters: {
               plant_code: 'Filter by specific plant (optional)'
            },
            response: {
               pie_chart_data: 'Asset distribution with percentages',
               summary: 'Department statistics summary',
               filter_info: 'Applied filters and metadata'
            },
            example: '/dashboard/assets-by-plant?plant_code=P001'
         },
         '/dashboard/growth-trends': {
            method: 'GET',
            description: 'Get growth trends by department/location (Line Chart data)',
            parameters: {
               dept_code: 'Filter by department (optional)',
               period: 'Time period: Q1|Q2|Q3|Q4|1Y|custom (default: Q2)',
               year: 'Year for quarterly/yearly data (default: current year)',
               start_date: 'Start date for custom period (YYYY-MM-DD)',
               end_date: 'End date for custom period (YYYY-MM-DD)'
            },
            response: {
               trends: 'Monthly/quarterly growth data with percentages',
               period_info: 'Period details and summary'
            },
            examples: [
               '/dashboard/growth-trends?period=Q2&year=2024',
               '/dashboard/growth-trends?dept_code=IT&period=custom&start_date=2024-01-01&end_date=2024-06-30'
            ]
         },
         '/dashboard/location-analytics': {
            method: 'GET',
            description: 'Get location analytics and utilization data',
            parameters: {
               location_code: 'Filter by specific location (optional)',
               period: 'Time period for trends: Q1|Q2|Q3|Q4|1Y|custom (default: Q2)',
               year: 'Year for trend data (default: current year)',
               start_date: 'Start date for custom period (YYYY-MM-DD)',
               end_date: 'End date for custom period (YYYY-MM-DD)',
               include_trends: 'Include growth trends: true|false (default: true)'
            },
            response: {
               location_analytics: 'Location utilization and asset statistics',
               analytics_summary: 'Utilization metrics summary',
               growth_trends: 'Location-specific growth trends (if requested)'
            },
            example: '/dashboard/location-analytics?location_code=L001&include_trends=true'
         },
         '/dashboard/audit-progress': {
            method: 'GET',
            description: 'Get audit progress and completion status',
            parameters: {
               dept_code: 'Filter by department (optional)',
               include_details: 'Include detailed asset audit data: true|false (default: false)',
               audit_status: 'Filter by audit status: audited|never_audited|overdue (optional)'
            },
            response: {
               audit_progress: 'Department-wise audit completion data',
               overall_progress: 'Overall audit statistics (if multiple departments)',
               detailed_audit: 'Asset-level audit details (if requested)',
               recommendations: 'Audit improvement recommendations'
            },
            example: '/dashboard/audit-progress?dept_code=IT&include_details=true'
         }
      },
      database_tables: {
         asset_master: 'Main asset data with status tracking',
         asset_scan_log: 'RFID scan activity logs',
         asset_status_history: 'Asset status change history',
         export_history: 'Export job tracking',
         mst_plant: 'Plant master data',
         mst_location: 'Location master data',
         mst_department: 'Department master data (NEW)',
         mst_user: 'User master data',
         user_login_log: 'User activity logs'
      },
      period_options: {
         basic_periods: {
            today: 'Current day (00:00 to now)',
            '7d': 'Last 7 days',
            '30d': 'Last 30 days'
         },
         enhanced_periods: {
            Q1: 'Quarter 1 (January - March)',
            Q2: 'Quarter 2 (April - June)',
            Q3: 'Quarter 3 (July - September)',
            Q4: 'Quarter 4 (October - December)',
            '1Y': 'Full year (January - December)',
            custom: 'Custom date range (requires start_date and end_date)'
         }
      },
      asset_status_codes: {
         'A': 'Active',
         'I': 'Inactive',
         'C': 'Created'
      },
      export_status_codes: {
         'P': 'Pending',
         'C': 'Completed',
         'F': 'Failed'
      },
      audit_status_codes: {
         'audited': 'Audited within last 12 months',
         'never_audited': 'Never been audited',
         'overdue': 'Audit overdue (more than 12 months)'
      },
      new_features: {
         department_analytics: 'Asset distribution and growth tracking by department',
         location_insights: 'Location utilization and performance metrics',
         audit_tracking: 'Asset audit progress and compliance monitoring',
         quarterly_trends: 'Quarterly and custom date range analytics',
         growth_calculations: 'Automatic growth percentage calculations',
         recommendations: 'AI-driven audit and utilization recommendations'
      }
   };

   res.status(200).json(dashboardDocs);
});

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
router.post('/assets', generalRateLimit, assetValidators.createAsset, assetController.createAsset);
router.put('/assets/:asset_no', generalRateLimit, assetValidators.updateAsset, assetController.updateAsset);
router.patch('/assets/:asset_no/status', generalRateLimit, assetValidators.updateAssetStatus, assetController.updateAssetStatus);
router.get('/assets/:asset_no/status/history', generalRateLimit, assetValidators.getAssetByNo, assetController.getAssetStatusHistory);
router.get('/assets', generalRateLimit, assetValidators.getAssets, assetController.getAssets);
router.get('/assets/numbers', generalRateLimit, assetController.getAssetNumbers);
router.get('/assets/search', generalRateLimit, assetValidators.searchAssets, assetController.searchAssets);
router.get('/assets/stats', generalRateLimit, assetController.getAssetStats);
router.get('/assets/stats/by-plant', generalRateLimit, assetController.getAssetStatsByPlant);
router.get('/assets/stats/by-location', generalRateLimit, assetController.getAssetStatsByLocation);
router.get('/assets/:asset_no', generalRateLimit, assetValidators.getAssetByNo, assetController.getAssetByNo);

// Export Routes - ต้องใช้ authentication
router.post('/export/jobs',
   generalRateLimit,
   authenticateToken,
   createExportValidator,
   validateExportConfigByType,
   validateExportSize,
   (req, res) => exportController.createExport(req, res)
);

router.get('/export/jobs/:jobId',
   generalRateLimit,
   authenticateToken,
   getExportJobValidator,
   (req, res) => exportController.getExportStatus(req, res)
);

router.get('/export/download/:jobId',
   strictRateLimit,
   authenticateToken,
   downloadExportValidator,
   (req, res) => exportController.downloadExport(req, res)
);

router.get('/export/history',
   generalRateLimit,
   authenticateToken,
   getExportHistoryValidator,
   (req, res) => exportController.getExportHistory(req, res)
);

router.delete('/export/jobs/:jobId',
   generalRateLimit,
   authenticateToken,
   cancelExportValidator,
   (req, res) => exportController.cancelExport(req, res)
);

router.get('/export/stats',
   generalRateLimit,
   authenticateToken,
   (req, res) => exportController.getExportStats(req, res)
);

router.post('/export/cleanup',
   strictRateLimit,
   authenticateToken,
   (req, res) => exportController.cleanupExpiredFiles(req, res)
);

// Scan Routes
router.post('/scan/log', generalRateLimit, authenticateToken, scanController.logAssetScan);
router.post('/scan/mock', generalRateLimit, authenticateToken, scanController.mockRfidScan);

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
            'GET /api/v1/dashboard/stats': 'Get dashboard statistics with percentage changes and time period filtering',
            'GET /api/v1/dashboard/alerts': 'Get system alerts and notifications',
            'GET /api/v1/dashboard/recent': 'Get recent activities (scans and exports)',
            'GET /api/v1/dashboard/overview': 'Get system overview with charts and trends',
            'GET /api/v1/dashboard/quick-stats': 'Get quick statistics for widgets',
            'GET /api/v1/dashboard/assets-by-plant': 'Get assets distribution by department (Pie Chart)',
            'GET /api/v1/dashboard/growth-trends': 'Get growth trends by department/location (Line Chart)',
            'GET /api/v1/dashboard/location-analytics': 'Get location analytics and utilization data',
            'GET /api/v1/dashboard/audit-progress': 'Get audit progress and completion status',
            'GET /api/v1/dashboard/docs': 'Get detailed dashboard API documentation'
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
            'GET /api/v1/assets/:asset_no': 'Get asset by number with details',
            'POST /api/v1/assets': 'Create new asset',
            'PUT /api/v1/assets/:asset_no': 'Update asset',
            'PATCH /api/v1/assets/:asset_no/status': 'Update asset status'
         },
         export: {
            'POST /api/v1/export/jobs': 'Create export job',
            'GET /api/v1/export/jobs/:jobId': 'Get export job status',
            'GET /api/v1/export/download/:jobId': 'Download export file',
            'GET /api/v1/export/history': 'Get export history',
            'DELETE /api/v1/export/jobs/:jobId': 'Cancel export job',
            'GET /api/v1/export/stats': 'Get export statistics',
            'POST /api/v1/export/cleanup': 'Cleanup expired files (Admin only)'
         },
         scan: {
            'POST /api/v1/scan/log': 'Log asset scan',
            'POST /api/v1/scan/mock': 'Mock RFID scan (returns random assets)'
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
            dept_code: 'Filter by department code (NEW)',
            period: 'Time period filter (today, 7d, 30d, Q1, Q2, Q3, Q4, 1Y, custom)',
            year: 'Year for quarterly/yearly data',
            start_date: 'Start date for custom period (YYYY-MM-DD)',
            end_date: 'End date for custom period (YYYY-MM-DD)'
         },
         search: {
            search: 'Search term for asset number, description, serial number, inventory number'
         },
         export: {
            exportType: 'Type of export (assets, scan_logs, status_history)',
            exportConfig: 'Export configuration object with filters and format'
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