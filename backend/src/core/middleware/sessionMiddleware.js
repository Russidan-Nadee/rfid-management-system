// Path: backend/src/core/middleware/sessionMiddleware.js
const SessionModel = require('../session/sessionModel');
const { createLogger } = require('../utils/logger');

const logger = createLogger('SessionMiddleware');

/**
 * Session middleware for validating HTTP-only cookie sessions
 */
class SessionMiddleware {
  /**
   * Extract session ID from cookies
   * @param {Object} req - Express request object
   * @returns {string|null} Session ID or null
   */
  static extractSessionId(req) {
    // Check for session_id cookie
    if (req.cookies && req.cookies.session_id) {
      return req.cookies.session_id;
    }

    // Fallback: Check for custom session header (for mobile apps)
    if (req.headers['x-session-id']) {
      return req.headers['x-session-id'];
    }

    return null;
  }

  /**
   * Extract device information from request
   * @param {Object} req - Express request object
   * @returns {Object} Device information
   */
  static extractDeviceInfo(req) {
    const userAgent = req.get('User-Agent') || '';
    let deviceType = 'unknown';

    if (userAgent.includes('Mobile') || userAgent.includes('Android') || userAgent.includes('iPhone')) {
      deviceType = 'mobile';
    } else if (userAgent.includes('Electron')) {
      deviceType = 'desktop';
    } else if (userAgent.includes('Mozilla') || userAgent.includes('Chrome') || userAgent.includes('Safari')) {
      deviceType = 'web';
    }

    return {
      userAgent,
      deviceType,
      ipAddress: req.ip || req.connection.remoteAddress || 'unknown'
    };
  }

  /**
   * Middleware to validate session and populate req.user
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Next middleware function
   */
  static async validateSession(req, res, next) {
    try {
      const sessionId = SessionMiddleware.extractSessionId(req);

      if (!sessionId) {
        return res.status(401).json({
          success: false,
          message: 'No session found',
          error: 'MISSING_SESSION'
        });
      }

      // Validate session
      const session = await SessionModel.validateSession(sessionId);

      if (!session) {
        // Clear invalid session cookie
        res.clearCookie('session_id', {
          httpOnly: true,
          secure: process.env.NODE_ENV === 'production',
          sameSite: 'strict'
        });

        return res.status(401).json({
          success: false,
          message: 'Invalid or expired session',
          error: 'INVALID_SESSION'
        });
      }

      // Update session activity
      await SessionModel.updateActivity(sessionId);

      // Populate request with user and session info
      req.user = session.mst_user;
      req.session = {
        sessionId: session.session_id,
        createdAt: session.created_at,
        lastActivity: session.last_activity,
        expiresAt: session.expires_at,
        deviceType: session.device_type
      };

      logger.debug(`Session validated for user: ${req.user.user_id}`);
      next();

    } catch (error) {
      logger.error('Session validation error:', error);
      res.status(500).json({
        success: false,
        message: 'Session validation failed',
        error: 'SESSION_VALIDATION_ERROR'
      });
    }
  }

  /**
   * Optional session middleware - doesn't block if no session
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Next middleware function
   */
  static async optionalSession(req, res, next) {
    try {
      const sessionId = SessionMiddleware.extractSessionId(req);

      if (sessionId) {
        const session = await SessionModel.validateSession(sessionId);
        
        if (session) {
          await SessionModel.updateActivity(sessionId);
          req.user = session.mst_user;
          req.session = {
            sessionId: session.session_id,
            createdAt: session.created_at,
            lastActivity: session.last_activity,
            expiresAt: session.expires_at,
            deviceType: session.device_type
          };
        }
      }

      next();
    } catch (error) {
      logger.error('Optional session error:', error);
      // Don't block request on optional session error
      next();
    }
  }

  /**
   * Role-based authorization middleware
   * @param {Array} allowedRoles - Array of allowed roles
   * @returns {Function} Middleware function
   */
  static requireRole(allowedRoles = []) {
    return async (req, res, next) => {
      try {
        if (!req.user) {
          return res.status(401).json({
            success: false,
            message: 'Authentication required',
            error: 'NO_USER'
          });
        }

        if (allowedRoles.length > 0 && !allowedRoles.includes(req.user.role)) {
          return res.status(403).json({
            success: false,
            message: 'Insufficient permissions',
            error: 'INSUFFICIENT_ROLE',
            required: allowedRoles,
            current: req.user.role
          });
        }

        next();
      } catch (error) {
        logger.error('Role authorization error:', error);
        res.status(500).json({
          success: false,
          message: 'Authorization failed',
          error: 'AUTHORIZATION_ERROR'
        });
      }
    };
  }

  /**
   * Admin-only middleware
   */
  static requireAdmin = SessionMiddleware.requireRole(['admin']);

  /**
   * Manager or Admin middleware
   */
  static requireManager = SessionMiddleware.requireRole(['admin', 'manager']);

  /**
   * Staff or higher middleware
   */
  static requireStaff = SessionMiddleware.requireRole(['admin', 'manager', 'staff']);

  /**
   * Session extension middleware for active users
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Next middleware function
   */
  static async extendActiveSession(req, res, next) {
    try {
      if (req.session && req.session.sessionId) {
        const now = new Date();
        const expiresAt = new Date(req.session.expiresAt);
        const timeUntilExpiry = expiresAt.getTime() - now.getTime();
        const fiveMinutes = 5 * 60 * 1000; // 5 minutes in milliseconds

        // If session expires in less than 5 minutes, extend it
        if (timeUntilExpiry < fiveMinutes) {
          await SessionModel.extendSession(req.session.sessionId, 15);
          logger.debug(`Session auto-extended for user: ${req.user.user_id}`);
        }
      }
      next();
    } catch (error) {
      logger.error('Session extension error:', error);
      // Don't block request on extension error
      next();
    }
  }

  /**
   * Session cleanup middleware (run periodically)
   */
  static async cleanupSessions(req, res, next) {
    try {
      // Only run cleanup on certain endpoints or scheduled
      if (req.path === '/api/admin/cleanup' || req.headers['x-cleanup-trigger']) {
        const cleanedCount = await SessionModel.cleanupExpiredSessions();
        logger.info(`Cleaned up ${cleanedCount} expired sessions`);
      }
      next();
    } catch (error) {
      logger.error('Session cleanup error:', error);
      next();
    }
  }

  /**
   * Development middleware to bypass session validation
   * Only works in development mode
   */
  static bypassInDevelopment(req, res, next) {
    if (process.env.NODE_ENV === 'development' && process.env.BYPASS_SESSION === 'true') {
      // Create a mock user for development
      req.user = {
        user_id: 'DEV_USER',
        full_name: 'Development User',
        role: 'admin',
        email: 'dev@example.com',
        is_active: true
      };
      
      req.session = {
        sessionId: 'DEV_SESSION',
        createdAt: new Date(),
        lastActivity: new Date(),
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 hours
        deviceType: 'web'
      };

      logger.warn('Session validation bypassed for development');
      return next();
    }

    // In production or when bypass is disabled, use normal validation
    return SessionMiddleware.validateSession(req, res, next);
  }
}

module.exports = SessionMiddleware;