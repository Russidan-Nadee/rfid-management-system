// Path: backend/src/features/export/exportRoutes.js
const express = require('express');
const router = express.Router();
const ExportController = require('./exportController');
const { authenticateToken } = require('../auth/authMiddleware');
const { createRateLimit } = require('../../middlewares/middleware');
const {
   createExportValidator,
   getExportJobValidator,
   downloadExportValidator,
   getExportHistoryValidator,
   cancelExportValidator,
   validateExportConfigByType,
   validateExportSize
} = require('./exportValidator');

const exportController = new ExportController();
const generalRateLimit = createRateLimit(15 * 60 * 1000, 1000);
const strictRateLimit = createRateLimit(15 * 60 * 1000, 100);

router.use(authenticateToken);

router.post('/jobs',
   generalRateLimit,
   createExportValidator,
   validateExportConfigByType,
   validateExportSize,
   (req, res) => exportController.createExport(req, res)
);

router.get('/jobs/:jobId',
   generalRateLimit,
   getExportJobValidator,
   (req, res) => exportController.getExportStatus(req, res)
);

router.get('/download/:jobId',
   strictRateLimit,
   downloadExportValidator,
   (req, res) => exportController.downloadExport(req, res)
);

router.get('/history',
   generalRateLimit,
   getExportHistoryValidator,
   (req, res) => exportController.getExportHistory(req, res)
);

router.delete('/jobs/:jobId',
   generalRateLimit,
   cancelExportValidator,
   (req, res) => exportController.cancelExport(req, res)
);

router.get('/stats',
   generalRateLimit,
   (req, res) => exportController.getExportStats(req, res)
);

router.post('/cleanup',
   strictRateLimit,
   (req, res) => exportController.cleanupExpiredFiles(req, res)
);

module.exports = router;