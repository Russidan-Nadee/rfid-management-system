// =======================
// 1. backend/src/utils/jwtUtils.js
// =======================
const jwt = require('jsonwebtoken');

const generateToken = (payload) => {
   return jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '24h'
   });
};

const verifyToken = (token) => {
   return jwt.verify(token, process.env.JWT_SECRET);
};

const generateRefreshToken = (payload) => {
   return jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
      expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d'
   });
};

module.exports = {
   generateToken,
   verifyToken,
   generateRefreshToken
};