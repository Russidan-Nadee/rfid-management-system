// Path: backend/src/features/dashboard/dashboardRoutes.js
const express = require('express');
const router = express.Router();

// Import dashboard controller
const dashboardController = require('./dashboardController');

// Import validators
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
   dashboardLocationsValidator
} = require('./dashboardValidator');

// Import middleware
const { createRateLimit } = require('../../middlewares/middleware');
const { authenticateToken } = require('../auth/authMiddleware');

// Apply rate limiting
const generalRateLimit = createRateLimit(15 * 60 * 1000, 1000); // 1000 requests per 15 minutes

// Apply authentication to all dashboard routes
router.use(authenticateToken);

/**
 * =================================
 * CORE DASHBOARD ROUTES
 * =================================
 */

// GET /api/v1/dashboard/stats?period=today|7d|30d
router.get('/stats',
   generalRateLimit,
   dashboardStatsValidator,
   dashboardController.getDashboardStats
);

// GET /api/v1/dashboard/alerts
router.get('/alerts',
   generalRateLimit,
   dashboardAlertsValidator,
   dashboardController.getDashboardAlerts
);

// GET /api/v1/dashboard/recent?period=today|7d|30d
router.get('/recent',
   generalRateLimit,
   dashboardRecentValidator,
   dashboardController.getDashboardRecent
);

// GET /api/v1/dashboard/overview?period=today|7d|30d
router.get('/overview',
   generalRateLimit,
   dashboardOverviewValidator,
   dashboardController.getOverview
);

// GET /api/v1/dashboard/quick-stats?period=today|7d|30d
router.get('/quick-stats',
   generalRateLimit,
   dashboardQuickStatsValidator,
   dashboardController.getQuickStats
);

/**
 * =================================
 * ENHANCED ANALYTICS ROUTES
 * =================================
 */

// GET /api/v1/dashboard/assets-by-plant?plant_code=xxx&dept_code=xxx
router.get('/assets-by-plant',
   generalRateLimit,
   assetsByDepartmentValidator,
   dashboardController.getAssetsByDepartment
);

// GET /api/v1/dashboard/growth-trends?dept_code=xxx&period=Q1|Q2|Q3|Q4|1Y|custom&start_date=2024-01-01&end_date=2024-06-30&year=2024
router.get('/growth-trends',
   generalRateLimit,
   growthTrendsValidator,
   dashboardController.getGrowthTrends
);

// GET /api/v1/dashboard/location-analytics?location_code=xxx&period=Q1|Q2|Q3|Q4|1Y|custom&start_date=2024-01-01&end_date=2024-06-30&include_trends=true
router.get('/location-analytics',
   generalRateLimit,
   locationAnalyticsValidator,
   dashboardController.getLocationAnalytics
);

// GET /api/v1/dashboard/audit-progress?dept_code=xxx&include_details=true&audit_status=audited|never_audited|overdue
router.get('/audit-progress',
   generalRateLimit,
   auditProgressValidator,
   dashboardController.getAuditProgress
);

/**
 * =================================
 * MASTER DATA ROUTES
 * =================================
 */

// GET /api/v1/dashboard/locations?plant_code=xxx
router.get('/locations',
   generalRateLimit,
   dashboardLocationsValidator,
   dashboardController.getLocations
);

/**
 * =================================
 * API DOCUMENTATION ROUTE
 * =================================
 */

// GET /api/v1/dashboard/docs
router.get('/docs', (req, res) => {
   const dashboardDocs = {
      success: true,
      message: 'Enhanced Dashboard API Documentation',
      version: '2.0.0',
      timestamp: new Date().toISOString(),
      base_path: '/api/v1/dashboard',
      authentication: 'Required for all endpoints',
      rate_limiting: '1000 requests per 15 minutes',

      endpoints: {
         core_dashboard: {
            '/stats': {
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
            '/alerts': {
               method: 'GET',
               description: 'Get system alerts and notifications',
               response: {
                  alerts: 'Array of alert objects with severity levels'
               },
               severity_levels: ['error', 'warning', 'info']
            },
            '/recent': {
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
            '/overview': {
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
            '/quick-stats': {
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
            }
         },

         enhanced_analytics: {
            '/assets-by-plant': {
               method: 'GET',
               description: 'Get assets distribution by department (Pie Chart data)',
               parameters: {
                  plant_code: 'Filter by specific plant (optional)',
                  dept_code: 'Filter by specific department (optional)'
               },
               response: {
                  pie_chart_data: 'Asset distribution with percentages',
                  summary: 'Department statistics summary',
                  filter_info: 'Applied filters and metadata'
               },
               example: '/dashboard/assets-by-plant?plant_code=P001'
            },
            '/growth-trends': {
               method: 'GET',
               description: 'Get growth trends by department/location (Line Chart data)',
               parameters: {
                  dept_code: 'Filter by department (optional)',
                  location_code: 'Filter by location (optional)',
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
            '/location-analytics': {
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
            '/audit-progress': {
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

         master_data: {
            '/locations': {
               method: 'GET',
               description: 'Get locations for dropdown filters',
               parameters: {
                  plant_code: 'Filter by plant (optional)'
               },
               response: {
                  locations: 'Array of location objects with code and description'
               }
            }
         }
      },

      query_parameters: {
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

         filters: {
            plant_code: 'Plant code filter (alphanumeric, 1-10 chars)',
            dept_code: 'Department code filter (alphanumeric, 1-10 chars)',
            location_code: 'Location code filter (alphanumeric, 1-10 chars)',
            audit_status: 'Audit status filter: audited|never_audited|overdue',
            include_details: 'Include detailed data: true|false',
            include_trends: 'Include trend analysis: true|false'
         },

         date_range: {
            start_date: 'Start date in YYYY-MM-DD format',
            end_date: 'End date in YYYY-MM-DD format',
            year: 'Year for quarterly/yearly data (2020-2025)',
            note: 'Custom date range cannot exceed 2 years'
         }
      },

      response_format: {
         success: 'boolean - Request success status',
         message: 'string - Response message',
         timestamp: 'string - ISO timestamp',
         data: 'object|array - Response data',
         meta: 'object - Additional metadata (pagination, etc.)'
      },

      error_codes: {
         400: 'Bad Request - Invalid parameters or validation failed',
         401: 'Unauthorized - Authentication required',
         403: 'Forbidden - Access denied',
         404: 'Not Found - Resource not found',
         429: 'Too Many Requests - Rate limit exceeded',
         500: 'Internal Server Error - Server error'
      },

      database_tables: {
         asset_master: 'Main asset data with status tracking',
         asset_scan_log: 'RFID scan activity logs',
         asset_status_history: 'Asset status change history',
         export_history: 'Export job tracking',
         mst_plant: 'Plant master data',
         mst_location: 'Location master data',
         mst_department: 'Department master data',
         mst_user: 'User master data',
         user_login_log: 'User activity logs'
      },

      status_codes: {
         asset_status: {
            'A': 'Active',
            'I': 'Inactive',
            'C': 'Created'
         },
         export_status: {
            'P': 'Pending',
            'C': 'Completed',
            'F': 'Failed'
         },
         audit_status: {
            'audited': 'Audited within last 12 months',
            'never_audited': 'Never been audited',
            'overdue': 'Audit overdue (more than 12 months)'
         }
      }
   };

   res.status(200).json(dashboardDocs);
});

module.exports = router;