// Path: backend/src/core/session/sessionModel.js
const crypto = require('crypto');
const { PrismaClient } = require('@prisma/client');
const { createLogger } = require('../utils/logger');

const prisma = new PrismaClient();
const logger = createLogger('SessionModel');

class SessionModel {
  /**
   * Generate a secure session ID
   * @returns {string} Secure session ID
   */
  static generateSessionId() {
    return crypto.randomBytes(32).toString('hex');
  }

  /**
   * Create a new session
   * @param {Object} sessionData - Session data
   * @param {string} sessionData.userId - User ID
   * @param {string} sessionData.ipAddress - Client IP address
   * @param {string} sessionData.userAgent - Client user agent
   * @param {string} sessionData.deviceType - Device type (web, mobile, desktop)
   * @param {string} sessionData.locationInfo - Location information
   * @param {number} sessionData.expiresInMinutes - Session expiry in minutes (default: 2)
   * @returns {Promise<Object>} Created session
   */
  static async createSession({
    userId,
    ipAddress,
    userAgent,
    deviceType = 'web',
    locationInfo = null,
    expiresInMinutes = 2
  }) {
    try {
      const sessionId = this.generateSessionId();
      const now = new Date();
      const expiresAt = new Date(now.getTime() + (expiresInMinutes * 60 * 1000));

      const session = await prisma.user_sessions.create({
        data: {
          session_id: sessionId,
          user_id: userId,
          created_at: now,
          last_activity: now,
          expires_at: expiresAt,
          ip_address: ipAddress,
          user_agent: userAgent,
          device_type: deviceType,
          location_info: locationInfo,
          is_active: true
        },
        include: {
          mst_user: {
            select: {
              user_id: true,
              full_name: true,
              role: true,
              email: true,
              is_active: true
            }
          }
        }
      });

      logger.info(`Session created for user ${userId}: ${sessionId}`);
      return session;
    } catch (error) {
      logger.error('Error creating session:', error);
      throw new Error('Failed to create session');
    }
  }

  /**
   * Get session by session ID
   * @param {string} sessionId - Session ID
   * @returns {Promise<Object|null>} Session data or null
   */
  static async getSession(sessionId) {
    try {
      const session = await prisma.user_sessions.findUnique({
        where: {
          session_id: sessionId
        },
        include: {
          mst_user: {
            select: {
              user_id: true,
              full_name: true,
              role: true,
              email: true,
              is_active: true
            }
          }
        }
      });

      return session;
    } catch (error) {
      logger.error('Error getting session:', error);
      return null;
    }
  }

  /**
   * Validate session and check if it's active and not expired
   * @param {string} sessionId - Session ID
   * @returns {Promise<Object|null>} Valid session data or null
   */
  static async validateSession(sessionId) {
    try {
      const session = await this.getSession(sessionId);

      if (!session) {
        return null;
      }

      const now = new Date();

      // Check if session is expired or inactive
      if (!session.is_active || session.expires_at < now) {
        await this.deactivateSession(sessionId);
        return null;
      }

      // Check if user is still active
      if (!session.mst_user.is_active) {
        await this.deactivateSession(sessionId);
        return null;
      }

      return session;
    } catch (error) {
      logger.error('Error validating session:', error);
      return null;
    }
  }

  /**
   * Update session activity timestamp
   * @param {string} sessionId - Session ID
   * @returns {Promise<boolean>} Success status
   */
  static async updateActivity(sessionId) {
    try {
      await prisma.user_sessions.update({
        where: {
          session_id: sessionId
        },
        data: {
          last_activity: new Date()
        }
      });

      return true;
    } catch (error) {
      logger.error('Error updating session activity:', error);
      return false;
    }
  }

  /**
   * Extend session expiry
   * @param {string} sessionId - Session ID
   * @param {number} additionalMinutes - Additional minutes to extend
   * @returns {Promise<boolean>} Success status
   */
  static async extendSession(sessionId, additionalMinutes = 2) {
    try {
      const now = new Date();
      const newExpiresAt = new Date(now.getTime() + (additionalMinutes * 60 * 1000));

      await prisma.user_sessions.update({
        where: {
          session_id: sessionId
        },
        data: {
          expires_at: newExpiresAt,
          last_activity: now
        }
      });

      logger.info(`Session extended: ${sessionId} for ${additionalMinutes} minutes`);
      return true;
    } catch (error) {
      logger.error('Error extending session:', error);
      return false;
    }
  }

  /**
   * Deactivate a session
   * @param {string} sessionId - Session ID
   * @returns {Promise<boolean>} Success status
   */
  static async deactivateSession(sessionId) {
    try {
      await prisma.user_sessions.update({
        where: {
          session_id: sessionId
        },
        data: {
          is_active: false
        }
      });

      logger.info(`Session deactivated: ${sessionId}`);
      return true;
    } catch (error) {
      logger.error('Error deactivating session:', error);
      return false;
    }
  }

  /**
   * Deactivate all sessions for a user
   * @param {string} userId - User ID
   * @returns {Promise<boolean>} Success status
   */
  static async deactivateUserSessions(userId) {
    try {
      const result = await prisma.user_sessions.updateMany({
        where: {
          user_id: userId,
          is_active: true
        },
        data: {
          is_active: false
        }
      });

      logger.info(`Deactivated ${result.count} sessions for user: ${userId}`);
      return true;
    } catch (error) {
      logger.error('Error deactivating user sessions:', error);
      return false;
    }
  }

  /**
   * Get active sessions for a user
   * @param {string} userId - User ID
   * @returns {Promise<Array>} Array of active sessions
   */
  static async getUserSessions(userId) {
    try {
      const sessions = await prisma.user_sessions.findMany({
        where: {
          user_id: userId,
          is_active: true,
          expires_at: {
            gt: new Date()
          }
        },
        orderBy: {
          last_activity: 'desc'
        }
      });

      return sessions;
    } catch (error) {
      logger.error('Error getting user sessions:', error);
      return [];
    }
  }

  /**
   * Clean up expired sessions
   * @returns {Promise<number>} Number of cleaned up sessions
   */
  static async cleanupExpiredSessions() {
    try {
      const result = await prisma.user_sessions.deleteMany({
        where: {
          OR: [
            {
              expires_at: {
                lt: new Date()
              }
            },
            {
              is_active: false
            }
          ]
        }
      });

      logger.info(`Cleaned up ${result.count} expired sessions`);
      return result.count;
    } catch (error) {
      logger.error('Error cleaning up expired sessions:', error);
      return 0;
    }
  }

  /**
   * Get session statistics
   * @returns {Promise<Object>} Session statistics
   */
  static async getSessionStats() {
    try {
      const totalActive = await prisma.user_sessions.count({
        where: {
          is_active: true,
          expires_at: {
            gt: new Date()
          }
        }
      });

      const totalExpired = await prisma.user_sessions.count({
        where: {
          OR: [
            {
              expires_at: {
                lt: new Date()
              }
            },
            {
              is_active: false
            }
          ]
        }
      });

      const deviceStats = await prisma.user_sessions.groupBy({
        by: ['device_type'],
        where: {
          is_active: true,
          expires_at: {
            gt: new Date()
          }
        },
        _count: {
          session_id: true
        }
      });

      return {
        totalActive,
        totalExpired,
        deviceBreakdown: deviceStats
      };
    } catch (error) {
      logger.error('Error getting session stats:', error);
      return {
        totalActive: 0,
        totalExpired: 0,
        deviceBreakdown: []
      };
    }
  }
}

module.exports = SessionModel;