// Path: src/services/authService.js
const AuthModel = require('./authModel');
const LoginLogModel = require('../../core/auth/loginLogModel');
const MockLdapService = require('../../services/ldap/mockLdapService');
const MockEmployeeInfoService = require('../../services/employee/mockEmployeeInfoService');
const { generateToken, verifyToken } = require('../../core/auth/jwtUtils');
const authConfig = require('../../core/auth/authConfig');
const crypto = require('crypto');

class AuthService {
   constructor() {
      this.authModel = new AuthModel();
      this.loginLogModel = new LoginLogModel();
      this.ldapService = new MockLdapService();
      this.employeeService = new MockEmployeeInfoService();
   }

   async login(ldapUsername, password, ipAddress, userAgent) {
      try {
         // Check failed login attempts (using ldapUsername for tracking)
         const failedAttempts = await this.loginLogModel.getFailedLoginAttempts(ldapUsername);
         if (failedAttempts >= authConfig.password.maxFailedAttempts) {
            throw new Error('Account temporarily locked due to too many failed attempts');
         }

         // Step 1: LDAP Authentication
         const ldapResult = await this.ldapService.authenticate(ldapUsername, password);
         if (!ldapResult.success) {
            await this.logFailedLogin(null, ldapUsername, ipAddress, userAgent, 'LDAP authentication failed');
            throw new Error('Invalid LDAP credentials');
         }

         // Step 2: Get Employee Information using employee_id from LDAP
         const employeeResult = await this.employeeService.getEmployeeById(ldapResult.employee_id);
         if (!employeeResult.success) {
            await this.logFailedLogin(null, ldapUsername, ipAddress, userAgent, 'Employee not found in EIS');
            throw new Error('Employee information not found');
         }

         // Step 3: Create or update user in database with employee data
         const user = await this.authModel.createOrUpdateUser(employeeResult.employee);

         // Check if user is active
         if (!user.is_active) {
            await this.logFailedLogin(user.user_id, ldapUsername, ipAddress, userAgent, 'User account inactive');
            throw new Error('User account is inactive');
         }

         // Generate session
         const sessionId = crypto.randomUUID();
         const tokenPayload = {
            userId: user.user_id,
            employeeId: user.employee_id,
            role: user.role,
            sessionId: sessionId
         };

         const token = generateToken(tokenPayload);

         // Update last login
         await this.authModel.updateLastLogin(user.user_id);

         // Log successful login (store ldapUsername for tracking, not in user record)
         await this.loginLogModel.logLoginAttempt({
            user_id: user.user_id,
            username: ldapUsername, // LDAP username for logging only
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
               employee_id: user.employee_id,
               full_name: user.full_name,
               department: user.department,
               position: user.position,
               company_role: user.company_role,
               email: user.email,
               role: user.role, // System role for permissions
               is_active: user.is_active
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
      // Password changes are no longer supported since authentication is via LDAP
      throw new Error('Password changes must be done through the company LDAP system');
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