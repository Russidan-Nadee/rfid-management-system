// Path: backend/src/features/export/exportValidator.js
const { body, param, query, validationResult } = require('express-validator');

// Validation error handler
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

/**
 * Validator สำหรับสร้าง export job
 * POST /api/v1/export/jobs
 */
const createExportValidator = [
   body('exportType')
      .trim()
      .notEmpty()
      .withMessage('Export type is required')
      .equals('assets')
      .withMessage('Only assets export is supported'),

   body('exportConfig')
      .notEmpty()
      .withMessage('Export configuration is required')
      .isObject()
      .withMessage('Export configuration must be an object'),

   body('exportConfig.format')
      .optional()
      .trim()
      .isIn(['xlsx', 'csv'])
      .withMessage('Format must be xlsx or csv'),

   body('exportConfig.filters')
      .optional()
      .isObject()
      .withMessage('Filters must be an object'),

   body('exportConfig.filters.plant_codes')
      .optional()
      .isArray()
      .withMessage('Plant codes must be an array')
      .custom((plantCodes) => {
         if (plantCodes.length > 0) {
            const isValid = plantCodes.every(code =>
               typeof code === 'string' && code.trim().length > 0
            );
            if (!isValid) {
               throw new Error('Plant codes must be non-empty strings');
            }
         }
         return true;
      }),

   body('exportConfig.filters.location_codes')
      .optional()
      .isArray()
      .withMessage('Location codes must be an array')
      .custom((locationCodes) => {
         if (locationCodes.length > 0) {
            const isValid = locationCodes.every(code =>
               typeof code === 'string' && code.trim().length > 0
            );
            if (!isValid) {
               throw new Error('Location codes must be non-empty strings');
            }
         }
         return true;
      }),

   body('exportConfig.filters.status')
      .optional()
      .isArray()
      .withMessage('Status must be an array')
      .custom((statuses) => {
         if (statuses.length > 0) {
            const validStatuses = ['C', 'A', 'I'];
            const isValid = statuses.every(status => validStatuses.includes(status));
            if (!isValid) {
               throw new Error('Status values must be C, A, or I');
            }
         }
         return true;
      }),

   body('exportConfig.columns')
      .optional()
      .isArray()
      .withMessage('Columns must be an array')
      .custom((columns) => {
         if (columns.length > 0) {
            const isValid = columns.every(column =>
               typeof column === 'string' && column.trim().length > 0
            );
            if (!isValid) {
               throw new Error('Columns must be non-empty strings');
            }
         }
         return true;
      }),

   handleValidationErrors
];

/**
 * Validator สำหรับดึงข้อมูล export job
 * GET /api/v1/export/jobs/:jobId
 */
const getExportJobValidator = [
   param('jobId')
      .isInt({ min: 1 })
      .withMessage('Job ID must be a positive integer')
      .toInt(),

   handleValidationErrors
];

/**
 * Validator สำหรับ download export
 * GET /api/v1/export/download/:jobId
 */
const downloadExportValidator = [
   param('jobId')
      .isInt({ min: 1 })
      .withMessage('Job ID must be a positive integer')
      .toInt(),

   handleValidationErrors
];

/**
 * Validator สำหรับดึงประวัติ export
 * GET /api/v1/export/history
 */
const getExportHistoryValidator = [
   query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Page must be a positive integer')
      .toInt(),

   query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1 and 100')
      .toInt(),

   query('status')
      .optional()
      .trim()
      .isIn(['P', 'C', 'F'])
      .withMessage('Status must be P, C, or F'),

   handleValidationErrors
];

/**
 * Validator สำหรับยกเลิก export job
 * DELETE /api/v1/export/jobs/:jobId
 */
const cancelExportValidator = [
   param('jobId')
      .isInt({ min: 1 })
      .withMessage('Job ID must be a positive integer')
      .toInt(),

   handleValidationErrors
];

/**
 * Custom validator สำหรับตรวจสอบ export config ตาม type
 */
const validateExportConfigByType = (req, res, next) => {
   const { exportType, exportConfig } = req.body;

   if (!exportType || !exportConfig) {
      return next();
   }

   const errors = [];

   // ตรวจสอบเฉพาะ assets export
   if (exportType !== 'assets') {
      errors.push({
         path: 'exportType',
         msg: 'Only assets export is supported',
         value: exportType
      });
   }

   if (errors.length > 0) {
      return res.status(400).json({
         success: false,
         message: 'Export configuration validation failed',
         errors,
         timestamp: new Date().toISOString()
      });
   }

   next();
};

/**
 * Middleware สำหรับตรวจสอบขนาดของ export (ไม่มี date range แล้ว)
 */
const validateExportSize = async (req, res, next) => {
   try {
      const { exportType, exportConfig } = req.body;

      // สำหรับ assets export
      const maxRecordsLimit = {
         assets: 100000,        // สูงสุด 100,000 assets
      };

      const currentLimit = maxRecordsLimit[exportType];
      if (!currentLimit) {
         return next();
      }

      // ตรวจสอบว่ามี filters หรือไม่ (ไม่รวม date range แล้ว)
      const hasFilters = exportConfig.filters &&
         (exportConfig.filters.plant_codes?.length > 0 ||
            exportConfig.filters.location_codes?.length > 0 ||
            exportConfig.filters.status?.length > 0);

      if (!hasFilters) {
         // แจ้งเตือนว่าจะ export ทั้งหมด
         console.warn(`⚠️  No filters specified, exporting all data for user ${req.user?.userId}`);
         req.exportWarning = 'No filters specified. Exporting all assets data.';
      }

      next();

   } catch (error) {
      next();
   }
};

module.exports = {
   createExportValidator,
   getExportJobValidator,
   downloadExportValidator,
   getExportHistoryValidator,
   cancelExportValidator,
   validateExportConfigByType,
   validateExportSize,
   handleValidationErrors
};