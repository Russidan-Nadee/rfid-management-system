const { body, param, query, validationResult } = require('express-validator');

class AdminValidator {
   // ===== VALIDATION RULES =====

   // Asset number parameter validation
   validateAssetNoParam() {
      return [
         param('assetNo')
            .notEmpty()
            .withMessage('Asset number is required')
            .isLength({ min: 1, max: 50 })
            .withMessage('Asset number must be between 1 and 50 characters')
            .matches(/^[A-Za-z0-9_-]+$/)
            .withMessage('Asset number can only contain letters, numbers, underscores, and hyphens')
      ];
   }

   // Asset update validation
   validateAssetUpdate() {
      return [
         // Description validation
         body('description')
            .optional()
            .isLength({ min: 1, max: 500 })
            .withMessage('Description must be between 1 and 500 characters')
            .trim(),

         // Serial number validation
         body('serial_no')
            .optional()
            .isLength({ min: 1, max: 100 })
            .withMessage('Serial number must be between 1 and 100 characters')
            .trim(),

         // Inventory number validation
         body('inventory_no')
            .optional()
            .isLength({ min: 1, max: 100 })
            .withMessage('Inventory number must be between 1 and 100 characters')
            .trim(),

         // EPC code validation
         body('epc_code')
            .optional()
            .isLength({ min: 1, max: 100 })
            .withMessage('EPC code must be between 1 and 100 characters')
            .matches(/^[A-Fa-f0-9]+$/)
            .withMessage('EPC code must be hexadecimal')
            .trim(),

         // Plant code validation
         body('plant_code')
            .optional()
            .trim(),

         // Location code validation
         body('location_code')
            .optional()
            .isLength({ min: 1, max: 20 })
            .withMessage('Location code must be between 1 and 20 characters')
            .trim(),

         // Unit code validation
         body('unit_code')
            .optional()
            .isLength({ min: 1, max: 10 })
            .withMessage('Unit code must be between 1 and 10 characters')
            .trim(),

         // Department code validation
         body('dept_code')
            .optional()
            .isLength({ min: 1, max: 10 })
            .withMessage('Department code must be between 1 and 10 characters')
            .trim(),

         // Category code validation
         body('category_code')
            .optional()
            .isLength({ min: 1, max: 20 })
            .withMessage('Category code must be between 1 and 20 characters')
            .trim(),

         // Brand code validation
         body('brand_code')
            .optional()
            .isLength({ min: 1, max: 20 })
            .withMessage('Brand code must be between 1 and 20 characters')
            .trim(),

         // Quantity validation
         body('quantity')
            .optional()
            .isInt({ min: 0, max: 999999 })
            .withMessage('Quantity must be a positive integer between 0 and 999999'),

         // Status validation
         body('status')
            .optional()
      ];
   }

   // Search query validation
   validateSearchQuery() {
      return [
         query('search')
            .optional()
            .isLength({ min: 1, max: 100 })
            .withMessage('Search term must be between 1 and 100 characters')
            .trim(),

         query('status')
            .optional()
            .isIn(['A', 'C', 'I'])
            .withMessage('Status filter must be A (Awaiting), C (Checked), or I (Inactive)'),

         query('plant_code')
            .optional()
            .isLength({ min: 1, max: 10 })
            .withMessage('Plant code filter must be between 1 and 10 characters')
            .trim(),

         query('location_code')
            .optional()
            .isLength({ min: 1, max: 20 })
            .withMessage('Location code filter must be between 1 and 20 characters')
            .trim(),

         query('unit_code')
            .optional()
            .isLength({ min: 1, max: 10 })
            .withMessage('Unit code filter must be between 1 and 10 characters')
            .trim(),

         query('category_code')
            .optional()
            .isLength({ min: 1, max: 20 })
            .withMessage('Category code filter must be between 1 and 20 characters')
            .trim(),

         query('brand_code')
            .optional()
            .isLength({ min: 1, max: 20 })
            .withMessage('Brand code filter must be between 1 and 20 characters')
            .trim()
      ];
   }

   // Bulk update validation
   validateBulkUpdate() {
      return [
         body('asset_numbers')
            .isArray({ min: 1, max: 100 })
            .withMessage('Asset numbers must be an array with 1-100 items'),

         body('asset_numbers.*')
            .notEmpty()
            .withMessage('Each asset number is required')
            .isLength({ min: 1, max: 50 })
            .withMessage('Each asset number must be between 1 and 50 characters')
            .matches(/^[A-Za-z0-9_-]+$/)
            .withMessage('Each asset number can only contain letters, numbers, underscores, and hyphens'),

         body('update_data')
            .isObject()
            .withMessage('Update data must be an object')
            .custom((value) => {
               if (Object.keys(value).length === 0) {
                  throw new Error('Update data cannot be empty');
               }
               return true;
            }),

         // Apply the same validations as single update for the update_data fields
         ...this.validateAssetUpdate().map(validator => {
            // Modify the validator to check update_data.field instead of field
            const originalPath = validator.builder.fields[0];
            validator.builder.fields = [`update_data.${originalPath}`];
            return validator;
         })
      ];
   }

   // Bulk delete validation
   validateBulkDelete() {
      return [
         body('asset_numbers')
            .isArray({ min: 1, max: 100 })
            .withMessage('Asset numbers must be an array with 1-100 items'),

         body('asset_numbers.*')
            .notEmpty()
            .withMessage('Each asset number is required')
            .isLength({ min: 1, max: 50 })
            .withMessage('Each asset number must be between 1 and 50 characters')
            .matches(/^[A-Za-z0-9_-]+$/)
            .withMessage('Each asset number can only contain letters, numbers, underscores, and hyphens')
      ];
   }

   // ===== MIDDLEWARE FUNCTIONS =====

   // Handle validation results
   handleValidationErrors = (req, res, next) => {
      const errors = validationResult(req);
      
      if (!errors.isEmpty()) {
         const formattedErrors = errors.array().map(error => ({
            field: error.path || error.param,
            message: error.msg,
            value: error.value
         }));

         return res.status(400).json({
            success: false,
            message: 'Validation failed',
            errors: formattedErrors,
            data: null
         });
      }

      next();
   };

   // Sanitize input data
   sanitizeInput = (req, res, next) => {
      // Remove any potentially dangerous fields
      const dangerousFields = ['__proto__', 'constructor', 'prototype'];
      
      const sanitizeObject = (obj) => {
         if (typeof obj !== 'object' || obj === null) return obj;
         
         for (const key of dangerousFields) {
            delete obj[key];
         }
         
         Object.keys(obj).forEach(key => {
            if (typeof obj[key] === 'object') {
               sanitizeObject(obj[key]);
            }
         });
         
         return obj;
      };

      if (req.body) {
         req.body = sanitizeObject(req.body);
      }
      
      if (req.query) {
         req.query = sanitizeObject(req.query);
      }

      next();
   };

   // Custom validation for business rules
   validateBusinessRules = async (req, res, next) => {
      try {
         const { assetNo } = req.params;
         const method = req.method;

         // Add custom business rule validations here
         if (method === 'DELETE' && assetNo) {
            // Example: Prevent deletion of critical assets
            const criticalAssetPrefixes = ['CRITICAL', 'MAIN', 'PRIMARY'];
            const isCritical = criticalAssetPrefixes.some(prefix => 
               assetNo.toUpperCase().startsWith(prefix)
            );

            if (isCritical) {
               return res.status(409).json({
                  success: false,
                  message: 'Cannot delete critical assets. Please contact system administrator.',
                  data: null
               });
            }
         }

         next();
      } catch (error) {
         console.error('Error in business rules validation:', error);
         res.status(500).json({
            success: false,
            message: 'Validation error occurred',
            data: null
         });
      }
   };

   // ===== USER MANAGEMENT VALIDATION RULES =====

   // User ID parameter validation
   validateUserIdParam() {
      return [
         param('userId')
            .notEmpty()
            .withMessage('User ID is required')
            .isLength({ min: 1, max: 20 })
            .withMessage('User ID must be between 1 and 20 characters')
            .matches(/^[A-Za-z0-9_-]+$/)
            .withMessage('User ID can only contain letters, numbers, underscores, and hyphens')
      ];
   }

   // Role update validation
   validateRoleUpdate() {
      return [
         body('role')
            .notEmpty()
            .withMessage('Role is required')
            .isIn(['admin', 'manager', 'staff', 'viewer'])
            .withMessage('Role must be one of: admin, manager, staff, viewer')
      ];
   }

   // Status update validation  
   validateStatusUpdate() {
      return [
         body('is_active')
            .notEmpty()
            .withMessage('Status is required')
            .isBoolean()
            .withMessage('Status must be true or false')
      ];
   }
}

module.exports = AdminValidator;