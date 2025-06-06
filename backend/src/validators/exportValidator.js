// Path: backend/src/validators/exportValidator.js
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
 * POST /api/v1/export/assets
 */
const createExportValidator = [
   body('exportType')
      .trim()
      .notEmpty()
      .withMessage('Export type is required')
      .isIn(['assets', 'scan_logs', 'status_history'])
      .withMessage('Export type must be one of: assets, scan_logs, status_history'),

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

   body('exportConfig.filters.date_range')
      .optional()
      .isObject()
      .withMessage('Date range must be an object'),

   body('exportConfig.filters.date_range.from')
      .optional()
      .isISO8601()
      .withMessage('From date must be a valid ISO 8601 date'),

   body('exportConfig.filters.date_range.to')
      .optional()
      .isISO8601()
      .withMessage('To date must be a valid ISO 8601 date')
      .custom((toDate, { req }) => {
         const fromDate = req.body.exportConfig?.filters?.date_range?.from;
         if (fromDate && toDate && new Date(toDate) < new Date(fromDate)) {
            throw new Error('To date must be after from date');
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

   switch (exportType) {
      case 'assets':
         // Assets export สามารถมี filters ทั้งหมด
         break;

      case 'scan_logs':
         // Scan logs ควรมี date_range
         if (!exportConfig.filters?.date_range) {
            errors.push({
               path: 'exportConfig.filters.date_range',
               msg: 'Date range is recommended for scan logs export',
               value: exportConfig.filters?.date_range
            });
         }
         break;

      case 'status_history':
         // Status history ควรมี date_range
         if (!exportConfig.filters?.date_range) {
            errors.push({
               path: 'exportConfig.filters.date_range',
               msg: 'Date range is recommended for status history export',
               value: exportConfig.filters?.date_range
            });
         }
         break;
   }

   // ตรวจสอบขนาดของ date range ไม่เกิน 1 ปี
   const dateRange = exportConfig.filters?.date_range;
   if (dateRange && dateRange.from && dateRange.to) {
      const fromDate = new Date(dateRange.from);
      const toDate = new Date(dateRange.to);
      const diffYears = (toDate - fromDate) / (1000 * 60 * 60 * 24 * 365);

      if (diffYears > 1) {
         errors.push({
            path: 'exportConfig.filters.date_range',
            msg: 'Date range cannot exceed 1 year',
            value: dateRange
         });
      }
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
 * Middleware สำหรับตรวจสอบขนาดของ export
 */
const validateExportSize = async (req, res, next) => {
   try {
      const { exportType, exportConfig } = req.body;

      // สำหรับ production ควรมีการ estimate ขนาดข้อมูลก่อน export
      // ตัวอย่างนี้เป็นการตรวจสอบพื้นฐาน

      const maxRecordsLimit = {
         assets: 100000,        // สูงสุด 100,000 assets
         scan_logs: 500000,     // สูงสุด 500,000 scan logs
         status_history: 200000  // สูงสุด 200,000 history records
      };

      const currentLimit = maxRecordsLimit[exportType];
      if (!currentLimit) {
         return next();
      }

      // ถ้าไม่มี filters แสดงว่าจะ export ทั้งหมด
      const hasFilters = exportConfig.filters &&
         (exportConfig.filters.plant_codes?.length > 0 ||
            exportConfig.filters.location_codes?.length > 0 ||
            exportConfig.filters.status?.length > 0 ||
            exportConfig.filters.date_range);

      if (!hasFilters) {
         // ควรมี warning สำหรับการ export ทั้งหมด
         req.exportWarning = `Exporting all ${exportType} without filters may result in large file size`;
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