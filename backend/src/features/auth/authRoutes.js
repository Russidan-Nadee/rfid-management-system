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
router.post('/refresh-session', SessionMiddleware.validateSession, authController.refreshSession);

// Legacy token-based routes (for backward compatibility)
router.post('/refresh', refreshTokenValidator, authController.refreshToken);

// Protected routes (require session authentication)
router.use(SessionMiddleware.validateSession);

router.post('/logout', logActivity('logout'), authController.logout);
router.get('/me', authController.getProfile);
router.post('/change-password', changePasswordValidator, logActivity('password_change'), authController.changePassword);

// Include session management routes
router.use('/sessions', require('../session/sessionRoutes'));

module.exports = router;