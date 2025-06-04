// =======================
// 6. backend/src/services/authService.js
// =======================
const AuthModel = require('../models/authModel');
const LoginLogModel = require('../models/loginLogModel');
const { hashPassword, comparePassword } = require('../utils/passwordUtils');
const { generateToken, verifyToken } = require('../utils/jwtUtils');
const authConfig = require('../config/authConfig');
const crypto = require('crypto');

class AuthService {
   constructor() {
      this.authModel = new AuthModel();
      this.loginLogModel = new LoginLogModel();
   }

   async login(username, password, ipAddress, userAgent) {
      try {
         // Check failed login attempts
         const failedAttempts = await this.loginLogModel.getFailedLoginAttempts(username);
         if (failedAttempts >= authConfig.password.maxFailedAttempts) {
            throw new Error('Account temporarily locked due to too many failed attempts');
         }

         // Find user
         const user = await this.authModel.findUserByUsername(username);
         if (!user) {
            await this.logFailedLogin(null, username, ipAddress, userAgent, 'User not found');
            throw new Error('Invalid username or password');
         }

         // Compare password
         const isValidPassword = await comparePassword(password, user.password);
         if (!isValidPassword) {
            await this.logFailedLogin(user.user_id, username, ipAddress, userAgent, 'Invalid password');
            throw new Error('Invalid username or password');
         }

         // Generate session
         const sessionId = crypto.randomUUID();
         const tokenPayload = {
            userId: user.user_id,
            username: user.username,
            role: user.role,
            sessionId: sessionId
         };

         const token = generateToken(tokenPayload);

         // Update last login
         await this.authModel.updateLastLogin(user.user_id);

         // Log successful login
         await this.loginLogModel.logLoginAttempt({
            user_id: user.user_id,
            username: user.username,
            event_type: 'login',
            ip_address: ipAddress,
            user_agent: userAgent,
            session_id: sessionId,
            success: true
         });

         return {
            token,
            user: {
               user_id: user.user_id,
               username: user.username,
               full_name: user.full_name,
               role: user.role
            },
            sessionId
         };

      } catch (error) {
         throw error;
      }
   }

   async logout(userId, sessionId, ipAddress) {
      try {
         await this.loginLogModel.logLogout(userId, sessionId, ipAddress);
         return { success: true, message: 'Logged out successfully' };
      } catch (error) {
         throw new Error(`Logout failed: ${error.message}`);
      }
   }

   async verifyToken(token) {
      try {
         const decoded = verifyToken(token);
         const user = await this.authModel.findUserById(decoded.userId);

         if (!user) {
            throw new Error('User not found');
         }

         return {
            userId: user.user_id,
            username: user.username,
            role: user.role,
            sessionId: decoded.sessionId
         };
      } catch (error) {
         throw new Error('Invalid or expired token');
      }
   }

   async changePassword(userId, currentPassword, newPassword) {
      try {
         const user = await this.authModel.findUserById(userId);
         if (!user) {
            throw new Error('User not found');
         }

         // Verify current password
         const isValidPassword = await comparePassword(currentPassword, user.password);
         if (!isValidPassword) {
            throw new Error('Current password is incorrect');
         }

         // Hash new password
         const hashedNewPassword = await hashPassword(newPassword);

         // Update password
         await this.authModel.updatePassword(userId, hashedNewPassword);

         // Log password change
         await this.loginLogModel.logLoginAttempt({
            user_id: userId,
            username: user.username,
            event_type: 'password_change',
            ip_address: null,
            user_agent: null,
            session_id: null,
            success: true
         });

         return { success: true, message: 'Password changed successfully' };
      } catch (error) {
         throw error;
      }
   }

   async logFailedLogin(userId, username, ipAddress, userAgent, reason) {
      await this.loginLogModel.logLoginAttempt({
         user_id: userId,
         username: username,
         event_type: 'failed_login',
         ip_address: ipAddress,
         user_agent: userAgent,
         session_id: null,
         success: false
      });
   }

   async getUserProfile(userId) {
      try {
         const user = await this.authModel.findUserById(userId);
         if (!user) {
            throw new Error('User not found');
         }

         return {
            user_id: user.user_id,
            username: user.username,
            full_name: user.full_name,
            role: user.role,
            last_login: user.last_login,
            created_at: user.created_at
         };
      } catch (error) {
         throw error;
      }
   }
}

module.exports = AuthService;