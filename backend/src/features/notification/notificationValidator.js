const { body, query, param } = require('express-validator');

const NotificationValidator = {
  // Validation for reporting a problem
  reportProblem: [
    body('problem_type')
      .notEmpty()
      .withMessage('Problem type is required')
      .isIn(['asset_damage', 'asset_missing', 'location_issue', 'data_error', 'urgent_issue', 'other'])
      .withMessage('Invalid problem type'),
      
    body('priority')
      .notEmpty()
      .withMessage('Priority is required')
      .isIn(['low', 'normal', 'high', 'critical'])
      .withMessage('Invalid priority level'),
      
    body('subject')
      .trim()
      .notEmpty()
      .withMessage('Subject is required')
      .isLength({ min: 5, max: 255 })
      .withMessage('Subject must be between 5-255 characters'),
      
    body('description')
      .trim()
      .notEmpty()
      .withMessage('Description is required')
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be between 10-1000 characters'),
      
    body('asset_no')
      .optional()
      .isLength({ max: 20 })
      .withMessage('Asset number must be max 20 characters')
      .trim()
  ],

  // Validation for getting notifications (admin)
  getNotifications: [
    query('status')
      .optional()
      .isIn(['pending', 'acknowledged', 'in_progress', 'resolved', 'cancelled'])
      .withMessage('Invalid status filter'),
      
    query('priority')
      .optional()
      .isIn(['low', 'normal', 'high', 'critical'])
      .withMessage('Invalid priority filter'),
      
    query('problem_type')
      .optional()
      .isIn(['asset_damage', 'asset_missing', 'location_issue', 'data_error', 'urgent_issue', 'other'])
      .withMessage('Invalid problem type filter'),

    query('plant_code')
      .optional()
      .isString()
      .withMessage('Plant code must be a string')
      .isLength({ max: 10 })
      .withMessage('Plant code must be max 10 characters'),

    query('location_code')
      .optional()
      .isString()
      .withMessage('Location code must be a string')
      .isLength({ max: 10 })
      .withMessage('Location code must be max 10 characters'),
      
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Page must be a positive integer'),
      
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1-100'),
      
    query('sortBy')
      .optional()
      .isIn(['created_at', 'updated_at', 'priority', 'status'])
      .withMessage('Invalid sort field'),
      
    query('sortOrder')
      .optional()
      .isIn(['asc', 'desc'])
      .withMessage('Sort order must be asc or desc')
  ],

  // Validation for notification ID parameter
  notificationId: [
    param('id')
      .isInt({ min: 1 })
      .withMessage('Notification ID must be a positive integer')
  ],

  // Validation for updating notification status
  updateStatus: [
    param('id')
      .isInt({ min: 1 })
      .withMessage('Notification ID must be a positive integer'),
      
    body('status')
      .optional()
      .isIn(['pending', 'acknowledged', 'in_progress', 'resolved', 'cancelled'])
      .withMessage('Invalid status'),
      
    body('resolution_note')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Resolution note must be max 1000 characters')
      .trim(),
      
    body('rejection_note')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Rejection note must be max 1000 characters')
      .trim()
  ],

  // Validation for asset number parameter
  assetNo: [
    param('assetNo')
      .isLength({ min: 1, max: 20 })
      .withMessage('Asset number must be between 1-20 characters')
      .trim()
  ]
};

module.exports = NotificationValidator;