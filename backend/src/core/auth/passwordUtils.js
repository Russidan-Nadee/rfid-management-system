// =======================
// 2. backend/src/utils/passwordUtils.js
// =======================
const bcrypt = require('bcrypt');

const hashPassword = async (password) => {
   const saltRounds = 12;
   return await bcrypt.hash(password, saltRounds);
};

const comparePassword = async (password, hashedPassword) => {
   return await bcrypt.compare(password, hashedPassword);
};

const validatePasswordStrength = (password) => {
   const minLength = 8;
   const hasUpperCase = /[A-Z]/.test(password);
   const hasLowerCase = /[a-z]/.test(password);
   const hasNumbers = /\d/.test(password);
   const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);

   return {
      isValid: password.length >= minLength && hasUpperCase && hasLowerCase && hasNumbers,
      errors: {
         length: password.length < minLength ? `Password must be at least ${minLength} characters` : null,
         uppercase: !hasUpperCase ? 'Password must contain uppercase letter' : null,
         lowercase: !hasLowerCase ? 'Password must contain lowercase letter' : null,
         numbers: !hasNumbers ? 'Password must contain number' : null
      }
   };
};

module.exports = {
   hashPassword,
   comparePassword,
   validatePasswordStrength
};