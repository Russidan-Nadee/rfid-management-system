// backend/src/features/auth/authMiddleware.js

const { verifyToken } = require('../../core/auth/jwtUtils');
const SessionModel = require('../../core/session/sessionModel');
const SessionMiddleware = require('../../core/middleware/sessionMiddleware');

const authenticateToken = async (req, res, next) => {
   try {
      console.log('🔍 Auth: Request headers:', req.headers);
      
      // First try session-based authentication
      const sessionId = SessionMiddleware.extractSessionId(req);
      if (sessionId) {
         console.log('🔍 Auth: Found session ID, checking session...');
         const session = await SessionModel.getSession(sessionId);
         
         if (session && session.mst_user) {
            const now = new Date();
            const isExpired = session.expires_at < now;
            const timeSinceExpiry = now.getTime() - new Date(session.expires_at).getTime();
            const thirtySeconds = 30 * 1000; // 30 seconds grace period
            
            // Allow active sessions OR recently expired sessions (within 30 seconds)
            if (session.is_active && (!isExpired || timeSinceExpiry <= thirtySeconds)) {
               console.log('✅ Auth: Session valid or recently expired - allowing through for extension');
               req.user = {
                  userId: session.user_id,
                  user_id: session.user_id, // For backward compatibility
                  username: session.mst_user.full_name || session.user_id,
                  role: session.mst_user.role,
                  sessionId: sessionId
               };
               req.session = session;
               return next();
            } else {
               console.log('❌ Auth: Session expired too long ago');
               return res.status(401).json({
                  success: false,
                  message: 'Session expired too long ago - please login again',
                  code: 'SESSION_EXPIRED',
                  timestamp: new Date().toISOString()
               });
            }
         } else {
            console.log('❌ Auth: Invalid session or inactive user');
            return res.status(401).json({
               success: false,
               message: 'Invalid session',
               code: 'INVALID_SESSION',
               timestamp: new Date().toISOString()
            });
         }
      }

      // Fallback to token-based authentication
      const authHeader = req.headers['authorization'];
      let token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
      console.log('🔍 Auth: Extracted token:', token ? `${token.substring(0, 20)}...` : 'null');

      // Support query parameter authentication for downloads
      if (!token && req.query.access_token) {
         token = req.query.access_token;
      }

      // Support session ID as query parameter for downloads (Flutter web compatibility)
      if (!sessionId && req.query.session_id) {
         const querySessionId = req.query.session_id;
         console.log('🔍 Auth: Found session ID in query parameter, validating...');
         const querySession = await SessionModel.validateSession(querySessionId);
         
         if (querySession && querySession.mst_user) {
            console.log('✅ Auth: Query session authentication successful for user:', querySession.user_id);
            
            // Update session activity for query-based authentication too
            await SessionModel.updateActivity(querySessionId);
            
            req.user = {
               userId: querySession.user_id,
               user_id: querySession.user_id, // For backward compatibility
               username: querySession.mst_user.full_name || querySession.user_id,
               role: querySession.mst_user.role,
               sessionId: querySessionId
            };
            req.session = querySession;
            return next();
         } else {
            console.log('❌ Auth: Invalid query session');
            return res.status(401).json({
               success: false,
               message: 'Session expired',
               code: 'SESSION_EXPIRED',
               timestamp: new Date().toISOString()
            });
         }
      }

      if (!token) {
         console.log('❌ Auth: No token or session provided');
         return res.status(401).json({
            success: false,
            message: 'Access token required',
            timestamp: new Date().toISOString()
         });
      }

      console.log('🔍 Auth: Verifying token...');
      const decoded = verifyToken(token);
      console.log('🔍 Auth: Token decoded successfully:', { userId: decoded.userId, username: decoded.username, role: decoded.role });
      req.user = {
         userId: decoded.userId,
         user_id: decoded.userId, // For backward compatibility
         username: decoded.username,
         role: decoded.role,
         sessionId: decoded.sessionId
      };
      console.log('✅ Auth: Authentication successful for user:', decoded.username);

      next();
   } catch (error) {
      console.error('Authentication error:', error);
      
      // Check if it's a JWT expiration error
      if (error.name === 'TokenExpiredError') {
         return res.status(401).json({
            success: false,
            message: 'Token expired',
            code: 'TOKEN_EXPIRED',
            timestamp: new Date().toISOString()
         });
      }
      
      return res.status(403).json({
         success: false,
         message: 'Invalid or expired token',
         timestamp: new Date().toISOString()
      });
   }
};

const optionalAuth = (req, res, next) => {
   try {
      const authHeader = req.headers['authorization'];
      let token = authHeader && authHeader.split(' ')[1];

      // Support query parameter authentication for optional auth
      if (!token && req.query.access_token) {
         token = req.query.access_token;
      }

      if (token) {
         try {
            const decoded = verifyToken(token);
            req.user = {
               userId: decoded.userId,
               user_id: decoded.userId, // For backward compatibility
               username: decoded.username,
               role: decoded.role,
               sessionId: decoded.sessionId
            };
         } catch (error) {
            // Token invalid but continue without user
            req.user = null;
         }
      } else {
         req.user = null;
      }

      next();
   } catch (error) {
      req.user = null;
      next();
   }
};

module.exports = {
   authenticateToken,
   optionalAuth
};