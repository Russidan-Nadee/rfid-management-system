// backend/src/features/auth/authMiddleware.js

const { verifyToken } = require('../../core/auth/jwtUtils');

const authenticateToken = (req, res, next) => {
   try {
      console.log('🔍 Auth: Request headers:', req.headers);
      const authHeader = req.headers['authorization'];
      let token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
      console.log('🔍 Auth: Extracted token:', token ? `${token.substring(0, 20)}...` : 'null');

      // Support query parameter authentication for downloads
      if (!token && req.query.access_token) {
         token = req.query.access_token;
      }

      if (!token) {
         console.log('❌ Auth: No token provided');
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
         username: decoded.username,
         role: decoded.role,
         sessionId: decoded.sessionId
      };
      console.log('✅ Auth: Authentication successful for user:', decoded.username);

      next();
   } catch (error) {
      console.error('Authentication error:', error);
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