// =======================
// 11. backend/src/validators/authValidator.js
// =======================
const { body, validationResult } = require('express-validator');
const { validatePasswordStrength } = require('../../core/auth/passwordUtils');

const handleValidationErrors = (req, res, next) => {
   const errors = validationResult(req);
   if (!errors.isEmpty()) {
      return res.status(400).json({
         success: false,
         message: 'Validation failed',
         errors: errors.array().map(error => ({
            field: error.path,
            message: error.msg,
            value: error.value
         })),
         timestamp: new Date().toISOString()
      });
   }
   next();
};

const loginValidator = [
   body('ldap_username')
      .trim()
      .notEmpty()
      .withMessage('LDAP username is required')
      .isLength({ min: 3, max: 100 })
      .withMessage('LDAP username must be between 3 and 100 characters'),

   body('password')
      .notEmpty()
      .withMessage('Password is required')
      .isLength({ min: 4 })
      .withMessage('Password must be at least 4 characters'),

   handleValidationErrors
];

const changePasswordValidator = [
   body('currentPassword')
      .notEmpty()
      .withMessage('Current password is required'),

   body('newPassword')
      .isLength({ min: 8 })
      .withMessage('New password must be at least 8 characters')
      .custom((value) => {
         const validation = validatePasswordStrength(value);
         if (!validation.isValid) {
            const errorMessages = Object.values(validation.errors)
               .filter(error => error !== null)
               .join(', ');
            throw new Error(errorMessages);
         }
         return true;
      }),

   body('confirmPassword')
      .custom((value, { req }) => {
         if (value !== req.body.newPassword) {
            throw new Error('Password confirmation does not match');
         }
         return true;
      }),

   handleValidationErrors
];

const refreshTokenValidator = [
   body('token')
      .notEmpty()
      .withMessage('Token is required'),

   handleValidationErrors
];

module.exports = {
   loginValidator,
   changePasswordValidator,
   refreshTokenValidator,
   handleValidationErrors
};