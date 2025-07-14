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

   // Period Validation - ใหม่
   body('exportConfig.filters.date_range')
      .optional()
      .isObject()
      .withMessage('Date range must be an object'),

   body('exportConfig.filters.date_range.from')
      .optional()
      .isISO8601()
      .withMessage('From date must be a valid ISO 8601 date (YYYY-MM-DD or YYYY-MM-DDTHH:mm:ss)')
      .custom((fromDate) => {
         if (fromDate) {
            const date = new Date(fromDate);
            const twoYearsAgo = new Date();
            twoYearsAgo.setFullYear(twoYearsAgo.getFullYear() - 2);

            if (date < twoYearsAgo) {
               throw new Error('From date cannot be more than 2 years ago');
            }

            if (date > new Date()) {
               throw new Error('From date cannot be in the future');
            }
         }
         return true;
      }),

   body('exportConfig.filters.date_range.to')
      .optional()
      .isISO8601()
      .withMessage('To date must be a valid ISO 8601 date (YYYY-MM-DD or YYYY-MM-DDTHH:mm:ss)')
      .custom((toDate, { req }) => {
         if (toDate) {
            const date = new Date(toDate);
            const now = new Date();

            // ตรวจสอบไม่เกินวันปัจจุบัน
            if (date > now) {
               throw new Error('To date cannot be in the future');
            }

            // ตรวจสอบ from < to
            const fromDate = req.body.exportConfig?.filters?.date_range?.from;
            if (fromDate && new Date(toDate) <= new Date(fromDate)) {
               throw new Error('To date must be after from date');
            }

            // ตรวจสอบช่วงเวลาไม่เกิน 1 ปี (365 วัน)
            if (fromDate) {
               const daysDifference = (new Date(toDate) - new Date(fromDate)) / (1000 * 60 * 60 * 24);
               if (daysDifference > 365) {
                  throw new Error('Date range cannot exceed 1 year (365 days)');
               }
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

   // ตรวจสอบ date_range สำหรับ assets (ถ้ามี)
   const dateRange = exportConfig.filters?.date_range;
   if (dateRange && dateRange.from && dateRange.to) {
      const fromDate = new Date(dateRange.from);
      const toDate = new Date(dateRange.to);

      // Double-check ช่วงเวลา
      const daysDifference = (toDate - fromDate) / (1000 * 60 * 60 * 24);
      if (daysDifference > 365) {
         errors.push({
            path: 'exportConfig.filters.date_range',
            msg: 'Date range cannot exceed 1 year',
            value: dateRange
         });
      }

      // Warning สำหรับช่วงเวลายาว (มากกว่า 6 เดือน)
      if (daysDifference > 180) {
         console.warn(`⚠️  Large date range detected: ${daysDifference} days for user ${req.user?.userId}`);
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

      // สำหรับ assets export
      const maxRecordsLimit = {
         assets: 100000,        // สูงสุด 100,000 assets
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
         // ถ้าไม่มี filter ให้เซ็ต default date range เป็น 30 วันล่าสุด
         console.warn(`⚠️  No filters specified, setting default 30 days range for user ${req.user?.userId}`);

         const now = new Date();
         const thirtyDaysAgo = new Date();
         thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

         // เซ็ต default date range
         if (!exportConfig.filters) {
            exportConfig.filters = {};
         }

         exportConfig.filters.date_range = {
            from: thirtyDaysAgo.toISOString(),
            to: now.toISOString()
         };

         req.exportWarning = 'No filters specified. Export limited to last 30 days for performance.';
      }

      next();

   } catch (error) {
      next();
   }
};

/**
 * Utility function สำหรับตรวจสอบ date range
 */
const validateDateRange = (fromDate, toDate) => {
   const from = new Date(fromDate);
   const to = new Date(toDate);
   const now = new Date();
   const twoYearsAgo = new Date();
   twoYearsAgo.setFullYear(twoYearsAgo.getFullYear() - 2);

   const validationResult = {
      isValid: true,
      errors: []
   };

   // ตרวจสอบ format
   if (isNaN(from.getTime())) {
      validationResult.isValid = false;
      validationResult.errors.push('Invalid from date format');
   }

   if (isNaN(to.getTime())) {
      validationResult.isValid = false;
      validationResult.errors.push('Invalid to date format');
   }

   if (!validationResult.isValid) {
      return validationResult;
   }

   // ตรวจสอบช่วงเวลา
   if (from >= to) {
      validationResult.isValid = false;
      validationResult.errors.push('From date must be before to date');
   }

   if (from < twoYearsAgo) {
      validationResult.isValid = false;
      validationResult.errors.push('From date cannot be more than 2 years ago');
   }

   if (to > now) {
      validationResult.isValid = false;
      validationResult.errors.push('To date cannot be in the future');
   }

   const daysDifference = (to - from) / (1000 * 60 * 60 * 24);
   if (daysDifference > 365) {
      validationResult.isValid = false;
      validationResult.errors.push('Date range cannot exceed 1 year');
   }

   return validationResult;
};

module.exports = {
   createExportValidator,
   getExportJobValidator,
   downloadExportValidator,
   getExportHistoryValidator,
   cancelExportValidator,
   validateExportConfigByType,
   validateExportSize,
   handleValidationErrors,
   validateDateRange
};