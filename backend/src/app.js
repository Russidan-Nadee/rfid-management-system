const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');
require('dotenv').config();

// Import routes
const routes = require('./routes/route');

// Import middleware
const { errorHandler, notFoundHandler } = require('./middlewares/middleware');

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

module.exports = app;