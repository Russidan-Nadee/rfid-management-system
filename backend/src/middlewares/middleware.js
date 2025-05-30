const rateLimit = require('express-rate-limit');
const slowDown = require('express-slow-down');

// Rate limiting middleware
const createRateLimit = (windowMs = 15 * 60 * 1000, max = 100) => {
   return rateLimit({
      windowMs,
      max,
      message: {
         success: false,
         message: 'Too many requests from this IP, please try again later.',
         timestamp: new Date().toISOString()
      },
      standardHeaders: true,
      legacyHeaders: false,
      handler: (req, res) => {
         res.status(429).json({
            success: false,
            message: 'Too many requests from this IP, please try again later.',
            timestamp: new Date().toISOString()
         });
      }
   });
};

// Speed limiting middleware
const createSpeedLimit = (windowMs = 15 * 60 * 1000, delayAfter = 50) => {
   return slowDown({
      windowMs,
      delayAfter,
      delayMs: 500,
      maxDelayMs: 20000
   });
};

// Request logging middleware
const requestLogger = (req, res, next) => {
   const start = Date.now();

   res.on('finish', () => {
      const duration = Date.now() - start;
      const logData = {
         method: req.method,
         url: req.originalUrl,
         status: res.statusCode,
         duration: `${duration}ms`,
         ip: req.ip || req.connection.remoteAddress,
         userAgent: req.get('User-Agent'),
         timestamp: new Date().toISOString()
      };

      console.log(JSON.stringify(logData));
   });

   next();
};

// CORS middleware
const corsOptions = {
   origin: (origin, callback) => {
      const allowedOrigins = (process.env.ALLOWED_ORIGINS || '*').split(',');

      if (allowedOrigins.includes('*') || !origin || allowedOrigins.includes(origin)) {
         callback(null, true);
      } else {
         callback(new Error('Not allowed by CORS'));
      }
   },
   credentials: true,
   methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
   allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin']
};

// Security headers middleware
const securityHeaders = (req, res, next) => {
   res.setHeader('X-Content-Type-Options', 'nosniff');
   res.setHeader('X-Frame-Options', 'DENY');
   res.setHeader('X-XSS-Protection', '1; mode=block');
   res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
   res.removeHeader('X-Powered-By');
   next();
};

// Request validation middleware
const validateRequest = (req, res, next) => {
   // Check content-type for POST/PUT requests
   if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
      const contentType = req.get('Content-Type');
      if (!contentType || !contentType.includes('application/json')) {
         return res.status(400).json({
            success: false,
            message: 'Content-Type must be application/json',
            timestamp: new Date().toISOString()
         });
      }
   }

   // Check for common attack patterns
   const suspiciousPatterns = [
      /(<script[\s\S]*?>[\s\S]*?<\/script>)/gi,
      /(javascript:)/gi,
      /(<iframe[\s\S]*?>[\s\S]*?<\/iframe>)/gi,
      /(union[\s]+select)/gi,
      /(drop[\s]+table)/gi,
      /(insert[\s]+into)/gi,
      /(delete[\s]+from)/gi
   ];

   const checkString = JSON.stringify(req.body) + req.originalUrl + JSON.stringify(req.query);

   for (const pattern of suspiciousPatterns) {
      if (pattern.test(checkString)) {
         console.warn(`Suspicious request detected from ${req.ip}: ${req.originalUrl}`);
         return res.status(400).json({
            success: false,
            message: 'Invalid request format',
            timestamp: new Date().toISOString()
         });
      }
   }

   next();
};

// Database connection check middleware
const checkDatabaseConnection = async (req, res, next) => {
   try {
      // Simple connection test using a basic query
      const { BaseModel } = require('../models/model');
      const baseModel = new BaseModel('information_schema.tables');
      await baseModel.executeQuery('SELECT 1 as test');
      next();
   } catch (error) {
      console.error('Database connection failed:', error.message);
      return res.status(503).json({
         success: false,
         message: 'Database connection failed',
         timestamp: new Date().toISOString()
      });
   }
};

// Error handling middleware
const errorHandler = (error, req, res, next) => {
   console.error('Error occurred:', {
      message: error.message,
      stack: error.stack,
      url: req.originalUrl,
      method: req.method,
      ip: req.ip,
      timestamp: new Date().toISOString()
   });

   // Default error
   let statusCode = 500;
   let message = 'Internal server error';

   // Handle specific error types
   if (error.name === 'ValidationError') {
      statusCode = 400;
      message = 'Validation failed';
   } else if (error.name === 'CastError') {
      statusCode = 400;
      message = 'Invalid data format';
   } else if (error.message.includes('not found')) {
      statusCode = 404;
      message = error.message;
   } else if (error.message.includes('duplicate') || error.code === 'ER_DUP_ENTRY') {
      statusCode = 409;
      message = 'Duplicate entry found';
   } else if (error.code === 'ER_NO_REFERENCED_ROW_2') {
      statusCode = 400;
      message = 'Referenced record not found';
   } else if (error.code === 'ER_ROW_IS_REFERENCED_2') {
      statusCode = 400;
      message = 'Cannot delete record - it is referenced by other records';
   } else if (error.message.includes('Connection refused') || error.code === 'ECONNREFUSED') {
      statusCode = 503;
      message = 'Database connection failed';
   }

   res.status(statusCode).json({
      success: false,
      message,
      timestamp: new Date().toISOString(),
      ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
   });
};

// 404 handler middleware
const notFoundHandler = (req, res) => {
   res.status(404).json({
      success: false,
      message: `Route ${req.originalUrl} not found`,
      timestamp: new Date().toISOString()
   });
};

// Health check middleware
const healthCheck = (req, res, next) => {
   if (req.path === '/health') {
      return res.status(200).json({
         success: true,
         message: 'Server is healthy',
         timestamp: new Date().toISOString(),
         uptime: process.uptime(),
         memory: process.memoryUsage(),
         version: process.version
      });
   }
   next();
};

// Response time middleware
const responseTime = (req, res, next) => {
   const start = process.hrtime();

   res.on('finish', () => {
      const [seconds, nanoseconds] = process.hrtime(start);
      const duration = seconds * 1000 + nanoseconds / 1000000;
      res.setHeader('X-Response-Time', `${duration.toFixed(2)}ms`);
   });

   next();
};

// Request size limiter
const requestSizeLimiter = (limit = '10mb') => {
   return (req, res, next) => {
      const contentLength = parseInt(req.get('Content-Length') || 0);
      const maxSize = parseSize(limit);

      if (contentLength > maxSize) {
         return res.status(413).json({
            success: false,
            message: `Request too large. Maximum size allowed: ${limit}`,
            timestamp: new Date().toISOString()
         });
      }

      next();
   };
};

// Helper function to parse size strings
const parseSize = (size) => {
   const units = { b: 1, kb: 1024, mb: 1024 * 1024, gb: 1024 * 1024 * 1024 };
   const match = size.toLowerCase().match(/^(\d+)(b|kb|mb|gb)?$/);
   if (!match) return 0;
   return parseInt(match[1]) * (units[match[2]] || 1);
};

module.exports = {
   createRateLimit,
   createSpeedLimit,
   requestLogger,
   corsOptions,
   securityHeaders,
   validateRequest,
   checkDatabaseConnection,
   errorHandler,
   notFoundHandler,
   healthCheck,
   responseTime,
   requestSizeLimiter
};