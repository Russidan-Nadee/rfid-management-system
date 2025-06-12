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

module.exports = {
   dashboardStatsValidator,
   dashboardAlertsValidator,
   dashboardRecentValidator,
   dashboardOverviewValidator,
   dashboardQuickStatsValidator,
   handleValidationErrors
};