// =======================
// 3. backend/src/config/authConfig.js
// =======================
module.exports = {
   jwt: {
      secret: process.env.JWT_SECRET || 'default_secret_change_in_production',
      expiresIn: process.env.JWT_EXPIRES_IN || '2m', // 2 minutes (1:10 scaled testing)
      refreshSecret: process.env.JWT_REFRESH_SECRET || 'refresh_secret_change_in_production',
      refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '20m' // 20 minutes (1:10 scaled)
   },
   password: {
      minLength: 8,
      maxFailedAttempts: 5,
      lockoutDuration: 30 * 60 * 1000, // 30 minutes
      requireUppercase: true,
      requireLowercase: true,
      requireNumbers: true,
      requireSpecialChars: false
   },
   session: {
      maxConcurrentSessions: 3,
      sessionTimeout: 2 * 60 * 1000 // 2 minutes (1:10 scaled testing)
   },
   security: {
      enableBruteForceProtection: true,
      enableSessionTracking: true,
      enableActivityLogging: true
   }
};