const NotificationService = require('./notificationService');

const NotificationController = {
  // POST /api/notifications/report-problem
  async reportProblem(req, res) {
    try {
      const { asset_no, problem_type, priority, subject, description } = req.body;
      const reported_by = req.user.userId;
      
      console.log('🔍 Controller: Report problem request received');
      console.log('🔍 Controller: User from token:', req.user);
      console.log('🔍 Controller: Reported by (userId):', reported_by);
      console.log('🔍 Controller: Request body:', req.body);
      
      // Temporary fix: Map user IDs to database format
      let mappedUserId = reported_by;
      if (reported_by === 'admin' || !reported_by || reported_by === 'undefined') {
        mappedUserId = 'USR_999999'; // Use the known working user ID
        console.log('🔍 Controller: Mapped user ID from', reported_by, 'to', mappedUserId);
      }

      const result = await NotificationService.submitProblemReport({
        asset_no,
        reported_by: mappedUserId,
        problem_type,
        priority,
        subject,
        description
      });

      res.status(201).json(result);

    } catch (error) {
      console.error('Report Problem Error:', error);
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // GET /api/notifications
  async getNotifications(req, res) {
    try {
      const {
        status,
        priority,
        problem_type,
        asset_no,
        page = 1,
        limit = 20,
        sortBy = 'created_at',
        sortOrder = 'desc'
      } = req.query;

      const filters = {
        status,
        priority,
        problem_type,
        asset_no,
        page: parseInt(page),
        limit: parseInt(limit),
        sortBy,
        sortOrder
      };

      const result = await NotificationService.getNotifications(filters, req.user.role);

      res.json({
        success: true,
        data: result
      });

    } catch (error) {
      console.error('Get Notifications Error:', error);
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // GET /api/notifications/:id
  async getNotificationById(req, res) {
    try {
      const { id } = req.params;
      
      const notification = await NotificationService.getNotificationById(id, req.user.role);

      res.json({
        success: true,
        data: notification
      });

    } catch (error) {
      console.error('Get Notification By ID Error:', error);
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // PATCH /api/notifications/:id/status
  async updateNotificationStatus(req, res) {
    try {
      const { id } = req.params;
      const updates = req.body;
      const userId = req.user.userId;
      const userRole = req.user.role;

      const result = await NotificationService.updateNotificationStatus(
        id,
        updates,
        userId,
        userRole
      );

      res.json(result);

    } catch (error) {
      console.error('Update Notification Status Error:', error);
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // GET /api/notifications/counts
  async getNotificationsCounts(req, res) {
    try {
      const counts = await NotificationService.getNotificationsCounts(req.user.role);

      res.json({
        success: true,
        data: counts
      });

    } catch (error) {
      console.error('Get Notifications Counts Error:', error);
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // GET /api/notifications/asset/:assetNo
  async getAssetNotifications(req, res) {
    try {
      const { assetNo } = req.params;
      
      const notifications = await NotificationService.getAssetNotifications(
        assetNo,
        req.user.role
      );

      res.json({
        success: true,
        data: notifications
      });

    } catch (error) {
      console.error('Get Asset Notifications Error:', error);
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // GET /api/notifications/my-reports
  async getMyReports(req, res) {
    try {
      const { userId } = req.user;

      const reports = await NotificationService.getUserReports(userId);

      res.json({
        success: true,
        data: reports
      });

    } catch (error) {
      console.error('Get My Reports Error:', error);
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }
};

module.exports = NotificationController;