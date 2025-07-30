// Path: backend/src/app.js
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');
const path = require('path');
require('dotenv').config();

// Import routes
const routes = require('.');

// Import middleware
const { errorHandler, notFoundHandler } = require('./features/scan/scanMiddleware');

// Import cleanup service
const ExportCleanupService = require('./features/export/exportCleanupService');
const app = express();

// Security middleware
app.use(helmet());

// CORS configuration
app.use(cors({
   origin: process.env.CORS_ORIGIN || '*',
   credentials: true
}));

// Logging middleware
app.use(morgan('combined'));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Static file serving for uploaded images
app.use('/uploads', express.static(path.join(__dirname, '../uploads'), {
   maxAge: '1y', // Cache images for 1 year
   etag: true,   // Enable ETag for conditional requests
   lastModified: true,
   setHeaders: (res, path) => {
      // Set appropriate headers for images
      if (path.match(/\.(jpg|jpeg|png|webp)$/i)) {
         res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
         res.setHeader('X-Content-Type-Options', 'nosniff');
      }
   }
}));

// Health check route
app.get('/health', (req, res) => {
   res.status(200).json({
      status: 'OK',
      timestamp: new Date().toISOString(),
      uptime: process.uptime()
   });
});

// API routes
app.use('/api/v1', routes);

// Error handling middleware
app.use((err, req, res, next) => {
   if (err.name === 'UnauthorizedError') {
      return res.status(401).json({
         success: false,
         message: 'Invalid token',
         timestamp: new Date().toISOString()
      });
   }
   next(err);
});

app.use(notFoundHandler);
app.use(errorHandler);

// Initialize Export Cleanup Service
const cleanupService = new ExportCleanupService();

// Start cleanup scheduler when app starts
if (process.env.NODE_ENV === 'production' || process.env.TEST_CLEANUP === 'true') {
   cleanupService.startScheduler();
   console.log('🧹 Export cleanup scheduler started');
} else {
   console.log('🧹 Export cleanup scheduler disabled in development');
}

// Graceful shutdown
process.on('SIGTERM', () => {
   console.log('SIGTERM received, shutting down gracefully');
   cleanupService.stopScheduler();
   process.exit(0);
});

process.on('SIGINT', () => {
   console.log('SIGINT received, shutting down gracefully');
   cleanupService.stopScheduler();
   process.exit(0);
});

// Export cleanup service for use in controllers
app.locals.cleanupService = cleanupService;

module.exports = app;