// =======================
// 10. backend/src/middlewares/loginLogMiddleware.js
// =======================
const LoginLogModel = require('../auth/loginLogModel');

const loginLogModel = new LoginLogModel();

const logActivity = (activityType) => {
   return async (req, res, next) => {
      try {
         if (req.user) {
            const logData = {
               user_id: req.user.userId,
               username: req.user.username,
               event_type: activityType,
               ip_address: req.ip || req.connection.remoteAddress,
               user_agent: req.get('User-Agent'),
               session_id: req.user.sessionId,
               success: true
            };

            // Log asynchronously to not block request
            setImmediate(async () => {
               try {
                  await loginLogModel.logLoginAttempt(logData);
               } catch (error) {
                  console.error('Failed to log activity:', error);
               }
            });
         }

         next();
      } catch (error) {
         console.error('Activity logging error:', error);
         next(); // Continue even if logging fails
      }
   };
};

const logApiAccess = async (req, res, next) => {
   try {
      if (req.user && req.method !== 'OPTIONS') {
         const activityDescription = `${req.method} ${req.originalUrl}`;

         setImmediate(async () => {
            try {
               await loginLogModel.logLoginAttempt({
                  user_id: req.user.userId,
                  username: req.user.username,
                  event_type: 'api_access',
                  ip_address: req.ip || req.connection.remoteAddress,
                  user_agent: req.get('User-Agent'),
                  session_id: req.user.sessionId,
                  success: true,
                  details: activityDescription
               });
            } catch (error) {
               console.error('Failed to log API access:', error);
            }
         });
      }

      next();
   } catch (error) {
      console.error('API access logging error:', error);
      next();
   }
};

module.exports = {
   logActivity,
   logApiAccess
};
