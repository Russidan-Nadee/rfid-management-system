// Path: backend/src/features/auth/authController.js
const AuthService = require('./authService');
const SessionModel = require('../../core/session/sessionModel');
const SessionMiddleware = require('../../core/middleware/sessionMiddleware');
const { createLogger } = require('../../core/utils/logger');

const authService = new AuthService();
const logger = createLogger('AuthController');

const authController = {
   async login(req, res) {
      try {
         const { ldap_username, password } = req.body;
         const deviceInfo = SessionMiddleware.extractDeviceInfo(req);

         if (!ldap_username || !password) {
            return res.status(400).json({
               success: false,
               message: 'LDAP username and password are required',
               timestamp: new Date().toISOString()
            });
         }

         // Authenticate user
         const authResult = await authService.login(ldap_username, password, deviceInfo.ipAddress, deviceInfo.userAgent);

         if (!authResult || !authResult.user) {
            return res.status(401).json({
               success: false,
               message: 'Authentication failed',
               timestamp: new Date().toISOString()
            });
         }

         // Create session
         const session = await SessionModel.createSession({
            userId: authResult.user.user_id,
            ipAddress: deviceInfo.ipAddress,
            userAgent: deviceInfo.userAgent,
            deviceType: deviceInfo.deviceType,
            expiresInMinutes: 15 // 15-minute sessions
         });

         // Set HTTP-only secure cookie
         const cookieOptions = {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'strict',
            maxAge: 15 * 60 * 1000, // 15 minutes
            path: '/'
         };

         res.cookie('session_id', session.session_id, cookieOptions);

         // Return response WITHOUT session ID in body (security)
         res.status(200).json({
            success: true,
            message: 'Login successful',
            data: {
               user: authResult.user,
               sessionId: session.session_id // Include for mobile apps that can't use cookies
            },
            timestamp: new Date().toISOString()
         });

         logger.info(`User ${authResult.user.user_id} logged in from ${deviceInfo.deviceType} (${deviceInfo.ipAddress})`);

      } catch (error) {
         logger.error('Login error:', error);
         res.status(401).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   },

   async logout(req, res) {
      try {
         const sessionId = req.session?.sessionId || SessionMiddleware.extractSessionId(req);
         const userId = req.user?.userId || req.user?.user_id;

         if (sessionId) {
            // Deactivate session in database
            await SessionModel.deactivateSession(sessionId);
            logger.info(`Session ${sessionId} deactivated for user ${userId}`);
         }

         // Clear session cookie
         res.clearCookie('session_id', {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'strict',
            path: '/'
         });

         // Log logout event
         if (userId) {
            await authService.logUserActivity(userId, 'logout', req.ip || req.connection.remoteAddress);
         }

         res.status(200).json({
            success: true,
            message: 'Logout successful',
            timestamp: new Date().toISOString()
         });

      } catch (error) {
         logger.error('Logout error:', error);
         res.status(500).json({
            success: false,
            message: 'Logout failed',
            timestamp: new Date().toISOString()
         });
      }
   },

   async getProfile(req, res) {
      try {
         const userId = req.user?.userId || req.user?.user_id;
         
         if (!userId) {
            return res.status(401).json({
               success: false,
               message: 'User not authenticated',
               timestamp: new Date().toISOString()
            });
         }

         const profile = await authService.getUserProfile(userId);

         // Include session info in profile response
         const sessionInfo = req.session ? {
            sessionCreated: req.session.createdAt,
            sessionExpires: req.session.expiresAt,
            deviceType: req.session.deviceType
         } : null;

         res.status(200).json({
            success: true,
            message: 'Profile retrieved successfully',
            data: {
               ...profile,
               session: sessionInfo
            },
            timestamp: new Date().toISOString()
         });

      } catch (error) {
         logger.error('Get profile error:', error);
         res.status(404).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   },

   async changePassword(req, res) {
      try {
         const { userId } = req.user;
         const { currentPassword, newPassword } = req.body;

         const result = await authService.changePassword(userId, currentPassword, newPassword);

         res.status(200).json({
            success: true,
            message: result.message,
            timestamp: new Date().toISOString()
         });
      } catch (error) {
         console.error('Change password error:', error);
         res.status(400).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   },

   async refreshSession(req, res) {
      try {
         const sessionId = req.session?.sessionId || SessionMiddleware.extractSessionId(req);
         
         if (!sessionId) {
            return res.status(401).json({
               success: false,
               message: 'No active session found',
               timestamp: new Date().toISOString()
            });
         }

         // First validate the session - if expired/invalid, don't try to extend
         const session = await SessionModel.validateSession(sessionId);
         if (!session) {
            // Session is expired or invalid - clear cookies and return error
            res.clearCookie('session_id', {
               httpOnly: true,
               secure: process.env.NODE_ENV === 'production',
               sameSite: 'strict',
               path: '/'
            });
            
            return res.status(401).json({
               success: false,
               message: 'Session expired or invalid',
               error: 'SESSION_EXPIRED',
               timestamp: new Date().toISOString()
            });
         }

         // Session is valid - extend it by 15 minutes
         const extended = await SessionModel.extendSession(sessionId, 15);
         
         if (!extended) {
            return res.status(401).json({
               success: false,
               message: 'Failed to extend session',
               timestamp: new Date().toISOString()
            });
         }

         // Update cookie expiry
         const cookieOptions = {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'strict',
            maxAge: 15 * 60 * 1000, // 15 minutes
            path: '/'
         };

         res.cookie('session_id', sessionId, cookieOptions);

         res.status(200).json({
            success: true,
            message: 'Session extended successfully',
            data: {
               sessionId: sessionId,
               expiresIn: 15 * 60 // seconds
            },
            timestamp: new Date().toISOString()
         });

         logger.info(`Session ${sessionId} extended for user ${req.user?.user_id}`);

      } catch (error) {
         logger.error('Session refresh error:', error);
         res.status(500).json({
            success: false,
            message: 'Session refresh failed',
            timestamp: new Date().toISOString()
         });
      }
   },

   // Legacy token refresh endpoint for backward compatibility
   async refreshToken(req, res) {
      try {
         const { token } = req.body;
         const result = await authService.verifyToken(token);

         res.status(200).json({
            success: true,
            message: 'Token is valid',
            data: result,
            timestamp: new Date().toISOString()
         });
      } catch (error) {
         logger.error('Token verification error:', error);
         res.status(401).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   },

   // Lightweight authentication check endpoint
   async checkAuth(req, res) {
      try {
         // If we reach this point, the middleware has already validated the session/token
         const userId = req.user?.userId || req.user?.user_id;
         
         if (!userId) {
            return res.status(401).json({
               success: false,
               message: 'User not authenticated',
               code: 'NOT_AUTHENTICATED',
               timestamp: new Date().toISOString()
            });
         }

         res.status(200).json({
            success: true,
            message: 'Authentication valid',
            data: {
               userId: userId,
               authenticated: true
            },
            timestamp: new Date().toISOString()
         });

      } catch (error) {
         logger.error('Auth check error:', error);
         res.status(401).json({
            success: false,
            message: 'Authentication check failed',
            code: 'AUTH_CHECK_FAILED',
            timestamp: new Date().toISOString()
         });
      }
   }
};

module.exports = authController;