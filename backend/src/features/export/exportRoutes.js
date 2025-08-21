// Path: backend/src/features/export/exportRoutes.js
const express = require('express');
const router = express.Router();
const ExportController = require('./exportController');
const { authenticateToken } = require('../auth/authMiddleware');
const { requireManagerOrAdmin } = require('../../core/middleware/roleMiddleware');
const { createRateLimit } = require('../scan/scanMiddleware');
const SessionMiddleware = require('../../core/middleware/sessionMiddleware');
const {
   createExportValidator,
   getExportJobValidator,
   downloadExportValidator,
   getExportHistoryValidator,
   cancelExportValidator,
   validateExportConfigByType,
   validateExportSize
} = require('./exportValidator');

const exportController = new ExportController();

// Rate limiting configuration
const generalRateLimit = createRateLimit(15 * 60 * 1000, 1000); // 1000 requests per 15 minutes
const strictRateLimit = createRateLimit(15 * 60 * 1000, 100);   // 100 requests per 15 minutes
const exportRateLimit = createRateLimit(5 * 60 * 1000, 10);     // 10 export jobs per 5 minutes

// Apply authentication and session auto-extension to all routes
router.use(authenticateToken);
router.use(SessionMiddleware.extendActiveSession);

/**
 * =================================
 * ASSETS EXPORT ROUTES
 * =================================
 */

/**
 * Create Assets Export Job
 * POST /api/v1/export/jobs
 * 
 * Body: {
 *   exportType: "assets",
 *   exportConfig: {
 *     format: "xlsx" | "csv",
 *     filters: {
 *       plant_codes: ["P001", "P002"],
 *       location_codes: ["L001"],
 *       status: ["A", "C", "I"],
 *       date_range: {
 *         from: "2024-01-01",
 *         to: "2024-12-31"
 *       }
 *     }
 *   }
 * }
 */
router.post('/jobs',
   exportRateLimit,                    // Strict rate limit for exports
   createExportValidator,              // Input validation
   validateExportConfigByType,         // Business rules validation
   validateExportSize,                 // Size and default period handling
   (req, res) => exportController.createExport(req, res)
);

/**
 * Get Export Job Status
 * GET /api/v1/export/jobs/:jobId
 */
router.get('/jobs/:jobId',
   generalRateLimit,
   getExportJobValidator,
   (req, res) => exportController.getExportStatus(req, res)
);

/**
 * Download Export File
 * GET /api/v1/export/download/:jobId
 */
router.get('/download/:jobId',
   strictRateLimit,                    // Strict limit for downloads
   downloadExportValidator,
   (req, res) => exportController.downloadExport(req, res)
);

/**
 * Get Export History (Assets Only)
 * GET /api/v1/export/history?page=1&limit=20&status=C
 */
router.get('/history',
   generalRateLimit,
   getExportHistoryValidator,
   (req, res) => exportController.getExportHistory(req, res)
);

/**
 * Cancel Export Job
 * DELETE /api/v1/export/jobs/:jobId
 */
router.delete('/jobs/:jobId',
   generalRateLimit,
   cancelExportValidator,
   (req, res) => exportController.cancelExport(req, res)
);

/**
 * Get Export Statistics (Assets Only)
 * GET /api/v1/export/stats
 */
router.get('/stats',
   generalRateLimit,
   (req, res) => exportController.getExportStats(req, res)
);

/**
 * Get Available Date Period Options
 * GET /api/v1/export/date-periods
 */
router.get('/date-periods',
   generalRateLimit,
   (req, res) => exportController.getDatePeriods(req, res)
);

/**
 * =================================
 * ADMIN ROUTES
 * =================================
 */

/**
 * Manual Cleanup Expired Files (Admin and Manager)
 * POST /api/v1/export/cleanup
 */
router.post('/cleanup',
   strictRateLimit,
   requireManagerOrAdmin,
   (req, res) => exportController.cleanupExpiredFiles(req, res)
);

/**
 * Get Storage Statistics (Admin and Manager)
 * GET /api/v1/export/storage-stats
 */
router.get('/storage-stats',
   generalRateLimit,
   requireManagerOrAdmin,
   (req, res) => exportController.getStorageStats(req, res)
);

/**
 * =================================
 * API DOCUMENTATION ROUTE
 * =================================
 */

/**
 * Export API Documentation
 * GET /api/v1/export/docs
 */
router.get('/docs', (req, res) => {
   const exportDocs = {
      success: true,
      message: 'Assets Export API Documentation',
      version: '2.0.0',
      timestamp: new Date().toISOString(),

      overview: {
         description: 'Export assets data with period filtering and multiple formats',
         supported_types: ['assets'],
         supported_formats: ['xlsx', 'csv'],
         max_period: '1 year',
         default_period: '30 days (when no filters specified)',
         file_expiry: '24 hours'
      },

      endpoints: {
         create_export: {
            method: 'POST',
            path: '/api/v1/export/jobs',
            description: 'Create new assets export job',
            rate_limit: '10 requests per 5 minutes',
            required_auth: true,
            body_example: {
               exportType: 'assets',
               exportConfig: {
                  format: 'xlsx',
                  filters: {
                     plant_codes: ['P001', 'P002'],
                     location_codes: ['L001'],
                     status: ['A', 'C'],
                     date_range: {
                        from: '2024-01-01',
                        to: '2024-12-31'
                     }
                  }
               }
            }
         },

         get_status: {
            method: 'GET',
            path: '/api/v1/export/jobs/:jobId',
            description: 'Get export job status',
            rate_limit: '1000 requests per 15 minutes'
         },

         download: {
            method: 'GET',
            path: '/api/v1/export/download/:jobId',
            description: 'Download completed export file',
            rate_limit: '100 requests per 15 minutes',
            response_type: 'file stream'
         },

         history: {
            method: 'GET',
            path: '/api/v1/export/history',
            description: 'Get user export history (assets only)',
            query_params: {
               page: 'Page number (default: 1)',
               limit: 'Items per page (default: 20, max: 100)',
               status: 'Filter by status (P/C/F)'
            }
         },

         cancel: {
            method: 'DELETE',
            path: '/api/v1/export/jobs/:jobId',
            description: 'Cancel pending export job'
         },

         stats: {
            method: 'GET',
            path: '/api/v1/export/stats',
            description: 'Get export statistics (assets only)'
         }
      },

      admin_endpoints: {
         cleanup: {
            method: 'POST',
            path: '/api/v1/export/cleanup',
            description: 'Manual cleanup of expired files',
            required_role: 'admin'
         },

         storage_stats: {
            method: 'GET',
            path: '/api/v1/export/storage-stats',
            description: 'Get storage usage statistics',
            required_role: 'admin'
         }
      },

      export_data: {
         description: 'Assets export includes 24 columns',
         columns: {
            asset_fields: [
               'asset_no', 'description', 'plant_code', 'location_code', 'dept_code',
               'serial_no', 'inventory_no', 'quantity', 'unit_code', 'category_code',
               'brand_code', 'status', 'created_by', 'created_at', 'deactivated_at'
            ],
            master_data: [
               'plant_description', 'location_description', 'department_description',
               'unit_name', 'category_name', 'category_description', 'brand_name',
               'brand_description', 'created_by_name'
            ]
         },
         total_columns: 24
      },

      validation_rules: {
         export_type: 'Must be "assets"',
         format: 'Must be "xlsx" or "csv"',
         date_range: {
            max_period: '365 days',
            from_date: 'Cannot be more than 2 years ago',
            to_date: 'Cannot be in the future',
            format: 'ISO 8601 (YYYY-MM-DD or YYYY-MM-DDTHH:mm:ss)'
         },
         status_codes: ['A (Active)', 'C (Created)', 'I (Inactive)'],
         default_behavior: {
            no_filters: 'Auto-set to last 30 days',
            no_status: 'Export all statuses',
            no_format: 'Default to xlsx'
         }
      },

      response_formats: {
         success: {
            success: true,
            message: 'string',
            data: 'object',
            timestamp: 'ISO 8601 string'
         },
         error: {
            success: false,
            message: 'string',
            errors: 'array (optional)',
            timestamp: 'ISO 8601 string'
         }
      },

      job_statuses: {
         P: 'Pending/Processing',
         C: 'Completed',
         F: 'Failed'
      },

      error_codes: {
         400: 'Bad Request - Invalid parameters',
         401: 'Unauthorized - Authentication required',
         403: 'Forbidden - Access denied or admin required',
         404: 'Not Found - Export job not found',
         409: 'Conflict - User already has pending export',
         410: 'Gone - Export file expired',
         429: 'Too Many Requests - Rate limit exceeded',
         500: 'Internal Server Error'
      }
   };

   res.status(200).json(exportDocs);
});

/**
 * =================================
 * LEGACY ROUTE DEPRECATION
 * =================================
 */

// Deprecated routes - return deprecation notice
const deprecatedRoutes = [
   '/assets',
   '/scan-logs',
   '/status-history',
   '/scan_logs',
   '/status_history'
];

deprecatedRoutes.forEach(route => {
   router.all(route, (req, res) => {
      res.status(410).json({
         success: false,
         message: 'This endpoint has been deprecated',
         details: 'Only assets export is supported. Use POST /api/v1/export/jobs with exportType: "assets"',
         migration_guide: {
            old_endpoint: `${req.method} ${req.originalUrl}`,
            new_endpoint: 'POST /api/v1/export/jobs',
            new_body: {
               exportType: 'assets',
               exportConfig: {
                  format: 'xlsx',
                  filters: {}
               }
            }
         },
         documentation: '/api/v1/export/docs',
         timestamp: new Date().toISOString()
      });
   });
});

module.exports = router;