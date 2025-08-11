const NotificationModel = require('./notificationModel');

const NotificationService = {
  // Submit a problem report
  async submitProblemReport(data) {
    try {
      // Validate required fields
      const { asset_no, reported_by, problem_type, subject, description } = data;
      
      if (!reported_by) {
        throw new Error('Reporter user ID is required');
      }

      if (!problem_type) {
        throw new Error('Problem type is required');
      }

      if (!subject || subject.trim().length < 5) {
        throw new Error('Subject is required and must be at least 5 characters');
      }

      if (!description || description.trim().length < 10) {
        throw new Error('Description is required and must be at least 10 characters');
      }

      // Validate problem type
      const validProblemTypes = [
        'asset_damage',
        'asset_missing', 
        'location_issue',
        'data_error',
        'urgent_issue',
        'other'
      ];
      
      if (!validProblemTypes.includes(problem_type)) {
        throw new Error('Invalid problem type');
      }

      // Validate priority if provided
      if (data.priority) {
        const validPriorities = ['low', 'normal', 'high', 'critical'];
        if (!validPriorities.includes(data.priority)) {
          throw new Error('Invalid priority level');
        }
      }

      const notification = await NotificationModel.createNotification({
        asset_no,
        reported_by,
        problem_type,
        priority: data.priority || 'normal',
        subject: subject.trim(),
        description: description.trim()
      });

      return {
        success: true,
        notification_id: notification.notification_id,
        message: 'Problem report submitted successfully'
      };

    } catch (error) {
      throw new Error(`Failed to submit problem report: ${error.message}`);
    }
  },

  // Get all notifications for admin
  async getNotifications(filters, userRole) {
    try {
      // Only admin and manager can view all notifications
      if (!['admin', 'manager'].includes(userRole)) {
        throw new Error('Insufficient permissions to view notifications');
      }

      const result = await NotificationModel.getAllNotifications(filters);
      return result;

    } catch (error) {
      throw new Error(`Failed to get notifications: ${error.message}`);
    }
  },

  // Get notification by ID
  async getNotificationById(id, userRole) {
    try {
      if (!['admin', 'manager'].includes(userRole)) {
        throw new Error('Insufficient permissions to view notification details');
      }

      const notification = await NotificationModel.getNotificationById(id);
      
      if (!notification) {
        throw new Error('Notification not found');
      }

      return notification;

    } catch (error) {
      throw new Error(`Failed to get notification: ${error.message}`);
    }
  },

  // Update notification status (admin only)
  async updateNotificationStatus(id, updates, userId, userRole) {
    try {
      if (!['admin', 'manager'].includes(userRole)) {
        throw new Error('Insufficient permissions to update notifications');
      }

      // Validate status if provided
      if (updates.status) {
        const validStatuses = ['pending', 'acknowledged', 'in_progress', 'resolved', 'cancelled'];
        if (!validStatuses.includes(updates.status)) {
          throw new Error('Invalid status');
        }
      }

      const notification = await NotificationModel.updateNotificationStatus(id, updates, userId);
      
      if (!notification) {
        throw new Error('Notification not found');
      }

      return {
        success: true,
        notification,
        message: 'Notification updated successfully'
      };

    } catch (error) {
      throw new Error(`Failed to update notification: ${error.message}`);
    }
  },

  // Get notification counts for admin dashboard
  async getNotificationsCounts(userRole) {
    try {
      if (!['admin', 'manager'].includes(userRole)) {
        throw new Error('Insufficient permissions to view notification counts');
      }

      const counts = await NotificationModel.getNotificationsCounts();
      return counts;

    } catch (error) {
      throw new Error(`Failed to get notification counts: ${error.message}`);
    }
  },

  // Get notifications for a specific asset
  async getAssetNotifications(assetNo, userRole) {
    try {
      if (!['admin', 'manager'].includes(userRole)) {
        throw new Error('Insufficient permissions to view asset notifications');
      }

      const notifications = await NotificationModel.getNotificationsByAsset(assetNo);
      return notifications;

    } catch (error) {
      throw new Error(`Failed to get asset notifications: ${error.message}`);
    }
  },

  // Get reports submitted by a specific user
  async getUserReports(userId) {
    try {
      if (!userId) {
        throw new Error('User ID is required');
      }

      const reports = await NotificationModel.getNotificationsByUser(userId);
      return reports;

    } catch (error) {
      throw new Error(`Failed to get user reports: ${error.message}`);
    }
  }
};

module.exports = NotificationService;