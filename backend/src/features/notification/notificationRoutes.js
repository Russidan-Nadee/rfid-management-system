const express = require('express');
const { validationResult } = require('express-validator');
const NotificationController = require('./notificationController');
const NotificationValidator = require('./notificationValidator');
const { authenticateToken } = require('../auth/authMiddleware');

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
  NotificationValidator.getNotifications,
  handleValidationErrors,
  NotificationController.getNotifications
);

// GET /api/notifications/counts - Get notification counts (admin/manager only)
router.get(
  '/counts',
  authenticateToken,
  NotificationController.getNotificationsCounts
);

// GET /api/notifications/my-reports - Get current user's submitted reports
router.get(
  '/my-reports',
  authenticateToken,
  NotificationController.getMyReports
);

// GET /api/notifications/:id - Get specific notification (admin/manager only)
router.get(
  '/:id',
  authenticateToken,
  NotificationValidator.notificationId,
  handleValidationErrors,
  NotificationController.getNotificationById
);

// PATCH /api/notifications/:id/status - Update notification status (admin/manager only)
router.patch(
  '/:id/status',
  authenticateToken,
  NotificationValidator.updateStatus,
  handleValidationErrors,
  NotificationController.updateNotificationStatus
);

// GET /api/notifications/asset/:assetNo - Get notifications for specific asset (admin/manager only)
router.get(
  '/asset/:assetNo',
  authenticateToken,
  NotificationValidator.assetNo,
  handleValidationErrors,
  NotificationController.getAssetNotifications
);

module.exports = router;