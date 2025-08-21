// Path: backend/src/features/auth/authRoutes.js
const express = require('express');
const router = express.Router();
const authController = require('./authController');
const { authenticateToken } = require('./authMiddleware');
const SessionMiddleware = require('../../core/middleware/sessionMiddleware');
const { logActivity } = require('../../core/middleware/loginLogMiddleware');
const { loginValidator, changePasswordValidator, refreshTokenValidator } = require('./authValidator');

// Public routes
router.post('/login', loginValidator, authController.login);

// Session-based routes
// Refresh session endpoint - no validation middleware since we need to handle expired sessions
router.post('/refresh-session', authController.refreshSession);

// Legacy token-based routes (for backward compatibility)
router.post('/refresh', refreshTokenValidator, authController.refreshToken);

// Protected routes (require session authentication)
router.use(SessionMiddleware.validateSession);

router.post('/logout', logActivity('logout'), authController.logout);
router.get('/me', authController.getProfile);
router.get('/check', authController.checkAuth);

// Test endpoint to verify session extension is working
router.get('/test-session', (req, res) => {
  const now = new Date();
  res.json({
    success: true,
    message: 'Session test endpoint - this should extend your session',
    user: req.user?.user_id || 'No user',
    sessionExpiry: req.session?.expiresAt || 'No session',
    currentTime: now.toISOString(),
    timestamp: now.toISOString()
  });
});

router.post('/change-password', changePasswordValidator, logActivity('password_change'), authController.changePassword);

// Include session management routes
router.use('/sessions', require('../session/sessionRoutes'));

module.exports = router;