// Path: backend/src/validators/dashboardValidator.js
const { query, validationResult } = require('express-validator');

// Validation error handler
const handleValidationErrors = (req, res, next) => {
   const errors = validationResult(req);
   if (!errors.isEmpty()) {
      return res.status(400).json({
         success: false,
         message: 'Dashboard validation failed',
         errors: errors.array().map(error => ({
            field: error.path,
            message: error.msg,
            value: error.value
         })),
         timestamp: new Date().toISOString()
      });
   }
   next();
};

/**
 * Dashboard Stats Validator
 * GET /api/v1/dashboard/stats?period=today|7d|30d
 */
const dashboardStatsValidator = [
   query('period')
      .optional()
      .trim()
      .isIn(['today', '7d', '30d'])
      .withMessage('Period must be one of: today, 7d, 30d'),

   handleValidationErrors
];

/**
 * Dashboard Alerts Validator
 * GET /api/v1/dashboard/alerts
 */
const dashboardAlertsValidator = [
   // No specific validation needed for alerts endpoint
   handleValidationErrors
];

/**
 * Dashboard Recent Activities Validator
 * GET /api/v1/dashboard/recent?period=today|7d|30d
 */
const dashboardRecentValidator = [
   query('period')
      .optional()
      .trim()
      .isIn(['today', '7d', '30d'])
      .withMessage('Period must be one of: today, 7d, 30d'),

   handleValidationErrors
];

/**
 * Dashboard Overview Validator
 * GET /api/v1/dashboard/overview?period=today|7d|30d
 */
const dashboardOverviewValidator = [
   query('period')
      .optional()
      .trim()
      .isIn(['today', '7d', '30d'])
      .withMessage('Period must be one of: today, 7d, 30d'),

   handleValidationErrors
];

/**
 * Dashboard Quick Stats Validator
 * GET /api/v1/dashboard/quick-stats?period=today|7d|30d
 */
const dashboardQuickStatsValidator = [
   query('period')
      .optional()
      .trim()
      .isIn(['today', '7d', '30d'])
      .withMessage('Period must be one of: today, 7d, 30d'),

   handleValidationErrors
];

/**
 * Assets by Department Validator
 * GET /api/v1/dashboard/assets-by-plant?plant_code=xxx
 */
const assetsByDepartmentValidator = [
   query('plant_code')
      .optional()
      .trim()
      .isLength({ min: 1, max: 10 })
      .withMessage('Plant code must be between 1 and 10 characters')
      .matches(/^[A-Za-z0-9_-]+$/)
      .withMessage('Plant code must contain only alphanumeric characters, hyphens, and underscores'),

   handleValidationErrors
];

/**
 * Growth Trends Validator
 * GET /api/v1/dashboard/growth-trends?dept_code=xxx&period=Q1|Q2|Q3|Q4|1Y|custom&start_date=2024-01-01&end_date=2024-06-30&year=2024
 */
const growthTrendsValidator = [
   query('dept_code')
      .optional()
      .trim()
      .isLength({ min: 1, max: 10 })
      .withMessage('Department code must be between 1 and 10 characters')
      .matches(/^[A-Za-z0-9_-]+$/)
      .withMessage('Department code must contain only alphanumeric characters, hyphens, and underscores'),

   query('period')
      .optional()
      .trim()
      .isIn(['Q1', 'Q2', 'Q3', 'Q4', '1Y', 'custom'])
      .withMessage('Period must be one of: Q1, Q2, Q3, Q4, 1Y, custom'),

   query('year')
      .optional()
      .isInt({ min: 2020, max: new Date().getFullYear() + 1 })
      .withMessage(`Year must be between 2020 and ${new Date().getFullYear() + 1}`)
      .toInt(),

   query('start_date')
      .optional()
      .isISO8601({ strict: true })
      .withMessage('start_date must be in YYYY-MM-DD format')
      .custom((value, { req }) => {
         if (req.query.period === 'custom' && !value) {
            throw new Error('start_date is required when period is custom');
         }
         return true;
      }),

   query('end_date')
      .optional()
      .isISO8601({ strict: true })
      .withMessage('end_date must be in YYYY-MM-DD format')
      .custom((value, { req }) => {
         if (req.query.period === 'custom' && !value) {
            throw new Error('end_date is required when period is custom');
         }
         if (req.query.start_date && value) {
            const startDate = new Date(req.query.start_date);
            const endDate = new Date(value);
            if (endDate <= startDate) {
               throw new Error('end_date must be after start_date');
            }
            // Check 2 year limit
            const twoYearsMs = 2 * 365 * 24 * 60 * 60 * 1000;
            if (endDate - startDate > twoYearsMs) {
               throw new Error('Date range cannot exceed 2 years');
            }
         }
         return true;
      }),

   handleValidationErrors
];

/**
 * Location Analytics Validator
 * GET /api/v1/dashboard/location-analytics?location_code=xxx&period=Q1|Q2|Q3|Q4|1Y|custom&start_date=2024-01-01&end_date=2024-06-30&include_trends=true
 */
const locationAnalyticsValidator = [
   query('location_code')
      .optional()
      .trim()
      .isLength({ min: 1, max: 10 })
      .withMessage('Location code must be between 1 and 10 characters')
      .matches(/^[A-Za-z0-9_-]+$/)
      .withMessage('Location code must contain only alphanumeric characters, hyphens, and underscores'),

   query('period')
      .optional()
      .trim()
      .isIn(['Q1', 'Q2', 'Q3', 'Q4', '1Y', 'custom'])
      .withMessage('Period must be one of: Q1, Q2, Q3, Q4, 1Y, custom'),

   query('year')
      .optional()
      .isInt({ min: 2020, max: new Date().getFullYear() + 1 })
      .withMessage(`Year must be between 2020 and ${new Date().getFullYear() + 1}`)
      .toInt(),

   query('start_date')
      .optional()
      .isISO8601({ strict: true })
      .withMessage('start_date must be in YYYY-MM-DD format')
      .custom((value, { req }) => {
         if (req.query.period === 'custom' && !value) {
            throw new Error('start_date is required when period is custom');
         }
         return true;
      }),

   query('end_date')
      .optional()
      .isISO8601({ strict: true })
      .withMessage('end_date must be in YYYY-MM-DD format')
      .custom((value, { req }) => {
         if (req.query.period === 'custom' && !value) {
            throw new Error('end_date is required when period is custom');
         }
         if (req.query.start_date && value) {
            const startDate = new Date(req.query.start_date);
            const endDate = new Date(value);
            if (endDate <= startDate) {
               throw new Error('end_date must be after start_date');
            }
            const twoYearsMs = 2 * 365 * 24 * 60 * 60 * 1000;
            if (endDate - startDate > twoYearsMs) {
               throw new Error('Date range cannot exceed 2 years');
            }
         }
         return true;
      }),

   query('include_trends')
      .optional()
      .isIn(['true', 'false'])
      .withMessage('include_trends must be true or false'),

   handleValidationErrors
];

/**
 * Audit Progress Validator
 * GET /api/v1/dashboard/audit-progress?dept_code=xxx&include_details=true&audit_status=audited|never_audited|overdue
 */
const auditProgressValidator = [
   query('dept_code')
      .optional()
      .trim()
      .isLength({ min: 1, max: 10 })
      .withMessage('Department code must be between 1 and 10 characters')
      .matches(/^[A-Za-z0-9_-]+$/)
      .withMessage('Department code must contain only alphanumeric characters, hyphens, and underscores'),

   query('include_details')
      .optional()
      .isIn(['true', 'false'])
      .withMessage('include_details must be true or false'),

   query('audit_status')
      .optional()
      .trim()
      .isIn(['audited', 'never_audited', 'overdue'])
      .withMessage('audit_status must be one of: audited, never_audited, overdue'),

   handleValidationErrors
];

module.exports = {
   dashboardStatsValidator,
   dashboardAlertsValidator,
   dashboardRecentValidator,
   dashboardOverviewValidator,
   dashboardQuickStatsValidator,
   assetsByDepartmentValidator,
   growthTrendsValidator,
   locationAnalyticsValidator,
   auditProgressValidator,
   handleValidationErrors
};