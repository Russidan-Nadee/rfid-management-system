// Path: backend/src/controllers/authController.js
const AuthService = require('../services/authService');

const authService = new AuthService();

const authController = {
   async login(req, res) {
      try {
         const { username, password } = req.body;
         const ipAddress = req.ip || req.connection.remoteAddress;
         const userAgent = req.get('User-Agent');

         const result = await authService.login(username, password, ipAddress, userAgent);

         res.status(200).json({
            success: true,
            message: 'Login successful',
            data: result,
            timestamp: new Date().toISOString()
         });
      } catch (error) {
         console.error('Login error:', error);
         res.status(401).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   },

   async logout(req, res) {
      try {
         const { userId, sessionId } = req.user;
         const ipAddress = req.ip || req.connection.remoteAddress;

         const result = await authService.logout(userId, sessionId, ipAddress);

         res.status(200).json({
            success: true,
            message: result.message,
            timestamp: new Date().toISOString()
         });
      } catch (error) {
         console.error('Logout error:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   },

   async getProfile(req, res) {
      try {
         const { userId } = req.user;
         const profile = await authService.getUserProfile(userId);

         res.status(200).json({
            success: true,
            message: 'Profile retrieved successfully',
            data: profile,
            timestamp: new Date().toISOString()
         });
      } catch (error) {
         console.error('Get profile error:', error);
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
         console.error('Token verification error:', error);
         res.status(401).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   }
};

module.exports = authController;