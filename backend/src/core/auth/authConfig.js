// =======================
// 3. backend/src/config/authConfig.js
// =======================
module.exports = {
   jwt: {
      secret: process.env.JWT_SECRET || 'default_secret_change_in_production',
      expiresIn: process.env.JWT_EXPIRES_IN || '15m', // 15 minutes for user inactivity
      refreshSecret: process.env.JWT_REFRESH_SECRET || 'refresh_secret_change_in_production',
      refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' // 7 days for refresh token
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
      sessionTimeout: 15 * 60 * 1000 // 15 minutes for user inactivity
   },
   security: {
      enableBruteForceProtection: true,
      enableSessionTracking: true,
      enableActivityLogging: true
   }
};