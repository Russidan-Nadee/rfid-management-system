// Path: src/models/loginLogModel.js
const { BaseModel } = require('./model');
const prisma = require('../lib/prisma');

class LoginLogModel extends BaseModel {
   constructor() {
      super('user_login_log');
   }

   async logLoginAttempt(logData) {
      return await prisma.user_login_log.create({
         data: {
            user_id: logData.user_id,
            username: logData.username,
            event_type: logData.event_type,
            timestamp: new Date(),
            ip_address: logData.ip_address,
            user_agent: logData.user_agent,
            session_id: logData.session_id,
            success: logData.success
         }
      });
   }

   async getFailedLoginAttempts(username, timeWindow = 30) {
      const timeAgo = new Date();
      timeAgo.setMinutes(timeAgo.getMinutes() - timeWindow);

      const count = await prisma.user_login_log.count({
         where: {
            username: username,
            event_type: 'failed_login',
            timestamp: {
               gt: timeAgo
            }
         }
      });

      return count || 0;
   }

   async getUserLoginHistory(userId, limit = 50) {
      return await prisma.user_login_log.findMany({
         where: { user_id: userId },
         orderBy: { timestamp: 'desc' },
         take: limit
      });
   }

   async getActiveSessionsCount(userId) {
      const oneDayAgo = new Date();
      oneDayAgo.setHours(oneDayAgo.getHours() - 24);

      const count = await prisma.user_login_log.count({
         where: {
            user_id: userId,
            event_type: 'login',
            timestamp: {
               gt: oneDayAgo
            }
         },
         distinct: ['session_id']
      });

      return count || 0;
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