// Path: backend/src/features/session/sessionController.js
const SessionModel = require('../../core/session/sessionModel');
const { createLogger } = require('../../core/utils/logger');

const logger = createLogger('SessionController');

const sessionController = {
  /**
   * Get current user's active sessions
   */
  async getUserSessions(req, res) {
    try {
      const userId = req.user?.userId || req.user?.user_id;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'User not authenticated',
          timestamp: new Date().toISOString()
        });
      }

      const sessions = await SessionModel.getUserSessions(userId);

      // Filter sensitive information
      const safeSessions = sessions.map(session => ({
        sessionId: session.session_id,
        deviceType: session.device_type,
        ipAddress: session.ip_address,
        createdAt: session.created_at,
        lastActivity: session.last_activity,
        expiresAt: session.expires_at,
        isCurrent: session.session_id === req.session?.sessionId
      }));

      res.status(200).json({
        success: true,
        message: 'Sessions retrieved successfully',
        data: {
          sessions: safeSessions,
          totalCount: safeSessions.length
        },
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      logger.error('Get user sessions error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to retrieve sessions',
        timestamp: new Date().toISOString()
      });
    }
  },

  /**
   * Terminate a specific session
   */
  async terminateSession(req, res) {
    try {
      const { sessionId } = req.params;
      const userId = req.user?.userId || req.user?.user_id;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'User not authenticated',
          timestamp: new Date().toISOString()
        });
      }

      // Verify session belongs to user
      const session = await SessionModel.getSession(sessionId);
      
      if (!session || session.user_id !== userId) {
        return res.status(404).json({
          success: false,
          message: 'Session not found or access denied',
          timestamp: new Date().toISOString()
        });
      }

      const success = await SessionModel.deactivateSession(sessionId);

      if (!success) {
        return res.status(500).json({
          success: false,
          message: 'Failed to terminate session',
          timestamp: new Date().toISOString()
        });
      }

      res.status(200).json({
        success: true,
        message: 'Session terminated successfully',
        data: { sessionId },
        timestamp: new Date().toISOString()
      });

      logger.info(`Session ${sessionId} terminated by user ${userId}`);

    } catch (error) {
      logger.error('Terminate session error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to terminate session',
        timestamp: new Date().toISOString()
      });
    }
  },

  /**
   * Terminate all other sessions (keep current)
   */
  async terminateOtherSessions(req, res) {
    try {
      const userId = req.user?.userId || req.user?.user_id;
      const currentSessionId = req.session?.sessionId;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'User not authenticated',
          timestamp: new Date().toISOString()
        });
      }

      // Get all user sessions
      const sessions = await SessionModel.getUserSessions(userId);
      
      // Terminate all except current
      let terminatedCount = 0;
      for (const session of sessions) {
        if (session.session_id !== currentSessionId) {
          const success = await SessionModel.deactivateSession(session.session_id);
          if (success) terminatedCount++;
        }
      }

      res.status(200).json({
        success: true,
        message: `${terminatedCount} sessions terminated successfully`,
        data: { 
          terminatedCount,
          currentSession: currentSessionId
        },
        timestamp: new Date().toISOString()
      });

      logger.info(`User ${userId} terminated ${terminatedCount} other sessions`);

    } catch (error) {
      logger.error('Terminate other sessions error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to terminate sessions',
        timestamp: new Date().toISOString()
      });
    }
  },

  /**
   * Get session statistics (admin only)
   */
  async getSessionStats(req, res) {
    try {
      const stats = await SessionModel.getSessionStats();

      res.status(200).json({
        success: true,
        message: 'Session statistics retrieved successfully',
        data: stats,
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      logger.error('Get session stats error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to retrieve session statistics',
        timestamp: new Date().toISOString()
      });
    }
  },

  /**
   * Manual session cleanup (admin only)
   */
  async cleanupSessions(req, res) {
    try {
      const cleanedCount = await SessionModel.cleanupExpiredSessions();

      res.status(200).json({
        success: true,
        message: `Cleaned up ${cleanedCount} expired sessions`,
        data: { cleanedCount },
        timestamp: new Date().toISOString()
      });

      logger.info(`Manual session cleanup completed: ${cleanedCount} sessions removed`);

    } catch (error) {
      logger.error('Session cleanup error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to cleanup sessions',
        timestamp: new Date().toISOString()
      });
    }
  },

  /**
   * Extend current session
   */
  async extendCurrentSession(req, res) {
    try {
      const sessionId = req.session?.sessionId;
      const { minutes = 15 } = req.body;

      if (!sessionId) {
        return res.status(401).json({
          success: false,
          message: 'No active session found',
          timestamp: new Date().toISOString()
        });
      }

      // Validate minutes (max 60 minutes)
      const extendMinutes = Math.min(Math.max(minutes, 1), 60);

      const success = await SessionModel.extendSession(sessionId, extendMinutes);

      if (!success) {
        return res.status(500).json({
          success: false,
          message: 'Failed to extend session',
          timestamp: new Date().toISOString()
        });
      }

      // Update cookie with new expiry
      const cookieOptions = {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        maxAge: extendMinutes * 60 * 1000,
        path: '/'
      };

      res.cookie('session_id', sessionId, cookieOptions);

      res.status(200).json({
        success: true,
        message: `Session extended by ${extendMinutes} minutes`,
        data: { 
          sessionId,
          extendedBy: extendMinutes,
          expiresIn: extendMinutes * 60 // seconds
        },
        timestamp: new Date().toISOString()
      });

      logger.info(`Session ${sessionId} extended by ${extendMinutes} minutes`);

    } catch (error) {
      logger.error('Extend session error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to extend session',
        timestamp: new Date().toISOString()
      });
    }
  },

  /**
   * Get current session info
   */
  async getCurrentSessionInfo(req, res) {
    try {
      const sessionId = req.session?.sessionId;

      if (!sessionId) {
        return res.status(401).json({
          success: false,
          message: 'No active session found',
          timestamp: new Date().toISOString()
        });
      }

      const session = await SessionModel.getSession(sessionId);

      if (!session) {
        return res.status(404).json({
          success: false,
          message: 'Session not found',
          timestamp: new Date().toISOString()
        });
      }

      // Calculate time remaining
      const now = new Date();
      const expiresAt = new Date(session.expires_at);
      const timeRemainingMs = expiresAt.getTime() - now.getTime();
      const timeRemainingSeconds = Math.max(0, Math.floor(timeRemainingMs / 1000));

      res.status(200).json({
        success: true,
        message: 'Session info retrieved successfully',
        data: {
          sessionId: session.session_id,
          userId: session.user_id,
          deviceType: session.device_type,
          ipAddress: session.ip_address,
          createdAt: session.created_at,
          lastActivity: session.last_activity,
          expiresAt: session.expires_at,
          timeRemainingSeconds,
          isActive: session.is_active
        },
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      logger.error('Get session info error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to retrieve session info',
        timestamp: new Date().toISOString()
      });
    }
  }
};

module.exports = sessionController;