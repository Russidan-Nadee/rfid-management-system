const express = require('express');
const { validationResult } = require('express-validator');
const NotificationController = require('./notificationController');
const NotificationValidator = require('./notificationValidator');
const { authenticateToken } = require('../auth/authMiddleware');
const { requireManagerOrAdmin } = require('../../core/middleware/roleMiddleware');

const router = express.Router();

// Middleware to handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    console.error('🔍 Validation Error Details:', {
      body: req.body,
      errors: errors.array(),
      user: req.user ? req.user.user_id : 'No user'
    });
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array()
    });
  }
  next();
};

// Routes

// POST /api/notifications/report-problem - Submit a problem report
router.post(
  '/report-problem',
  authenticateToken, // Requires authentication
  NotificationValidator.reportProblem,
  handleValidationErrors,
  NotificationController.reportProblem
);

// GET /api/notifications - Get all notifications (admin/manager only)
router.get(
  '/',
  authenticateToken,
  requireManagerOrAdmin,
  NotificationValidator.getNotifications,
  handleValidationErrors,
  NotificationController.getNotifications
);

// GET /api/notifications/counts - Get notification counts (admin/manager only)
router.get(
  '/counts',
  authenticateToken,
  requireManagerOrAdmin,
  NotificationController.getNotificationsCounts
);

// GET /api/notifications/my-reports - Get current user's submitted reports
router.get(
  '/my-reports',
  authenticateToken,
  NotificationController.getMyReports
);

// GET /api/notifications/all-reports - Get all reports for admin (admin/manager only)
router.get(
  '/all-reports',
  authenticateToken,
  requireManagerOrAdmin,
  NotificationValidator.getNotifications,
  handleValidationErrors,
  NotificationController.getAllReports
);

// GET /api/notifications/:id - Get specific notification (admin/manager only)
// This must come AFTER specific routes like /my-reports and /all-reports
router.get(
  '/:id',
  authenticateToken,
  requireManagerOrAdmin,
  NotificationValidator.notificationId,
  handleValidationErrors,
  NotificationController.getNotificationById
);

// PATCH /api/notifications/:id/status - Update notification status (admin/manager only)
router.patch(
  '/:id/status',
  authenticateToken,
  requireManagerOrAdmin,
  NotificationValidator.updateStatus,
  handleValidationErrors,
  NotificationController.updateNotificationStatus
);

// GET /api/notifications/asset/:assetNo - Get notifications for specific asset (admin/manager only)
router.get(
  '/asset/:assetNo',
  authenticateToken,
  requireManagerOrAdmin,
  NotificationValidator.assetNo,
  handleValidationErrors,
  NotificationController.getAssetNotifications
);

module.exports = router;