// =======================
// 5. backend/src/models/loginLogModel.js
// =======================
const { BaseModel } = require('./model');

class LoginLogModel extends BaseModel {
   constructor() {
      super('user_login_log');
   }

   async logLoginAttempt(logData) {
      const query = `
            INSERT INTO user_login_log (
                user_id, username, event_type, timestamp, 
                ip_address, user_agent, session_id, success
            ) VALUES (?, ?, ?, NOW(), ?, ?, ?, ?)
        `;
      const params = [
         logData.user_id,
         logData.username,
         logData.event_type,
         logData.ip_address,
         logData.user_agent,
         logData.session_id,
         logData.success
      ];
      return this.executeQuery(query, params);
   }

   async getFailedLoginAttempts(username, timeWindow = 30) {
      const query = `
            SELECT COUNT(*) as attempts 
            FROM user_login_log 
            WHERE username = ? 
            AND event_type = 'failed_login' 
            AND timestamp > DATE_SUB(NOW(), INTERVAL ? MINUTE)
        `;
      const results = await this.executeQuery(query, [username, timeWindow]);
      return results[0]?.attempts || 0;
   }

   async getUserLoginHistory(userId, limit = 50) {
      const query = `
            SELECT * FROM user_login_log 
            WHERE user_id = ? 
            ORDER BY timestamp DESC 
            LIMIT ?
        `;
      return this.executeQuery(query, [userId, limit]);
   }

   async getActiveSessionsCount(userId) {
      const query = `
            SELECT COUNT(DISTINCT session_id) as sessions
            FROM user_login_log 
            WHERE user_id = ? 
            AND event_type = 'login' 
            AND timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR)
        `;
      const results = await this.executeQuery(query, [userId]);
      return results[0]?.sessions || 0;
   }

   async logLogout(userId, sessionId, ipAddress) {
      return this.logLoginAttempt({
         user_id: userId,
         username: null,
         event_type: 'logout',
         ip_address: ipAddress,
         user_agent: null,
         session_id: sessionId,
         success: true
      });
   }
}

module.exports = LoginLogModel;