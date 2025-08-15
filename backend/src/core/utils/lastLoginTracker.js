const prisma = require('../database/prisma');

/**
 * Last Login Tracker Utility
 * Tracks and updates user's last login activity when they perform actions
 */
class LastLoginTracker {
  /**
   * Update user's last login timestamp
   * @param {string} userId - User ID who performed the action
   * @param {string} action - Description of the action performed
   * @param {string} ipAddress - IP address of the user (optional)
   * @param {string} userAgent - User agent of the request (optional)
   * @returns {Promise<void>}
   */
  static async updateLastLogin(userId, action = 'Activity', ipAddress = null, userAgent = null) {
    if (!userId) {
      console.log('LastLoginTracker: No user ID provided, skipping last login update');
      return;
    }

    try {
      // Update user's last_login timestamp
      await prisma.mst_user.update({
        where: { user_id: userId },
        data: { last_login: new Date() }
      });

      // Optionally log the login activity
      try {
        await prisma.user_login_log.create({
          data: {
            user_id: userId,
            username: null, // Will be filled if needed
            event_type: 'login', // Using login as general activity
            timestamp: new Date(),
            ip_address: ipAddress,
            user_agent: userAgent,
            success: true
          }
        });
      } catch (logError) {
        // Don't fail the main operation if logging fails
        console.warn('Failed to log user activity:', logError.message);
      }

      console.log(`LastLoginTracker: Updated last login for user ${userId} (${action})`);
    } catch (error) {
      console.warn('LastLoginTracker: Failed to update last login:', error.message);
      // Don't throw error to avoid breaking the main operation
    }
  }

  /**
   * Track admin action and update last login
   * @param {string} userId - User ID who performed the admin action
   * @param {string} action - Specific admin action performed
   * @param {string} targetAsset - Asset that was affected (optional)
   * @param {string} ipAddress - IP address (optional)
   * @param {string} userAgent - User agent (optional)
   * @returns {Promise<void>}
   */
  static async trackAdminAction(userId, action, targetAsset = null, ipAddress = null, userAgent = null) {
    const actionDescription = targetAsset ? 
      `Admin: ${action} on asset ${targetAsset}` : 
      `Admin: ${action}`;
    
    await this.updateLastLogin(userId, actionDescription, ipAddress, userAgent);
  }

  /**
   * Track scan action and update last login
   * @param {string} userId - User ID who performed the scan
   * @param {string} assetNo - Asset number that was scanned
   * @param {string} ipAddress - IP address (optional)
   * @param {string} userAgent - User agent (optional)
   * @returns {Promise<void>}
   */
  static async trackScanAction(userId, assetNo, ipAddress = null, userAgent = null) {
    await this.updateLastLogin(
      userId, 
      `Scan: Asset ${assetNo}`, 
      ipAddress, 
      userAgent
    );
  }

  /**
   * Middleware function to automatically track user activity
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Next middleware function
   */
  static trackingMiddleware() {
    return async (req, res, next) => {
      // Store original methods
      const originalSend = res.send;
      const originalJson = res.json;

      // Override response methods to track successful actions
      res.send = function(body) {
        // Track activity if request was successful and user is authenticated
        if (res.statusCode >= 200 && res.statusCode < 300 && req.user?.userId) {
          const action = `${req.method} ${req.originalUrl}`;
          const ipAddress = req.ip || req.connection.remoteAddress;
          const userAgent = req.get('User-Agent');
          
          // Don't await to avoid blocking response
          LastLoginTracker.updateLastLogin(
            req.user.userId, 
            action, 
            ipAddress, 
            userAgent
          ).catch(err => {
            console.warn('Failed to track user activity:', err.message);
          });
        }
        
        return originalSend.call(this, body);
      };

      res.json = function(obj) {
        // Track activity if request was successful and user is authenticated
        if (res.statusCode >= 200 && res.statusCode < 300 && req.user?.userId) {
          const action = `${req.method} ${req.originalUrl}`;
          const ipAddress = req.ip || req.connection.remoteAddress;
          const userAgent = req.get('User-Agent');
          
          // Don't await to avoid blocking response
          LastLoginTracker.updateLastLogin(
            req.user.userId, 
            action, 
            ipAddress, 
            userAgent
          ).catch(err => {
            console.warn('Failed to track user activity:', err.message);
          });
        }
        
        return originalJson.call(this, obj);
      };

      next();
    };
  }
}

module.exports = LastLoginTracker;