// Path: backend/src/features/auth/authRoutes.js
const express = require('express');
const router = express.Router();
const authController = require('./authController');
const { authenticateToken } = require('../../middlewares/authMiddleware');
const { logActivity } = require('../../middlewares/loginLogMiddleware');
const { loginValidator, changePasswordValidator, refreshTokenValidator } = require('../../validators/authValidator');

// Public routes
router.post('/login', loginValidator, authController.login);
router.post('/refresh', refreshTokenValidator, authController.refreshToken);

// Protected routes (require authentication)
router.use(authenticateToken);

router.post('/logout', logActivity('logout'), authController.logout);
router.get('/me', authController.getProfile);
router.post('/change-password', changePasswordValidator, logActivity('password_change'), authController.changePassword);

module.exports = router;