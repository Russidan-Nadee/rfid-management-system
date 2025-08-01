// Path: backend/src/validators/validator.js
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
         }))
      });
   }
   next();
};

// Common validation rules
const commonValidations = {
   code: (fieldName, required = true) => {
      const validation = param(fieldName)
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage(`${fieldName} must be between 1 and 50 characters`)
         .matches(/^[A-Za-z0-9_-]+$/)
         .withMessage(`${fieldName} must contain only alphanumeric characters, hyphens, and underscores`);

      return required ? validation.notEmpty().withMessage(`${fieldName} is required`) : validation;
   },

   epcCode: (fieldName, required = true) => {
      const validation = param(fieldName)
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage(`${fieldName} must be between 1 and 50 characters`)
         .matches(/^[A-Za-z0-9_-]+$/)
         .withMessage(`${fieldName} must contain only alphanumeric characters, hyphens, and underscores`);

      return required ? validation.notEmpty().withMessage(`${fieldName} is required`) : validation;
   },

   id: (fieldName, required = true) => {
      const validation = param(fieldName)
         .trim()
         .isLength({ min: 1, max: 100 })
         .withMessage(`${fieldName} must be between 1 and 100 characters`);

      return required ? validation.notEmpty().withMessage(`${fieldName} is required`) : validation;
   },

   searchTerm: () => {
      return query('search')
         .optional()
         .trim()
         .isLength({ max: 100 })
         .withMessage('Search term must not exceed 100 characters');
   },

   pagination: () => {
      return [
         query('page')
            .optional()
            .isInt({ min: 1 })
            .withMessage('Page must be a positive integer')
            .toInt(),
         query('limit')
            .optional()
            .isInt({ min: 1, max: 1000 })
            .withMessage('Limit must be between 1 and 1000')
            .toInt()
      ];
   },

   // Asset status validation - only for assets
   assetStatus: () => {
      return query('status')
         .optional()
         .isIn(['C', 'A', 'I'])
         .withMessage('Status must be C (Created), A (Active), or I (Inactive)');
   }
};

// Plant validators - No status field
const plantValidators = {
   getPlantByCode: [
      commonValidations.code('plant_code'),
      handleValidationErrors
   ],

   getPlants: [
      ...commonValidations.pagination(),
      handleValidationErrors
   ]
};

// Location validators - No status field
const locationValidators = {
   getLocationByCode: [
      commonValidations.code('location_code'),
      handleValidationErrors
   ],

   getLocationsByPlant: [
      commonValidations.code('plant_code'),
      handleValidationErrors
   ],

   getLocations: [
      query('plant_code')
         .optional()
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage('Plant code must be between 1 and 50 characters'),
      ...commonValidations.pagination(),
      handleValidationErrors
   ]
};

// Unit validators - No status field
const unitValidators = {
   getUnitByCode: [
      commonValidations.code('unit_code'),
      handleValidationErrors
   ],

   getUnits: [
      ...commonValidations.pagination(),
      handleValidationErrors
   ]
};

// User validators - No status field
const userValidators = {
   getUserById: [
      commonValidations.id('user_id'),
      handleValidationErrors
   ],

   getUserByUsername: [
      param('username')
         .trim()
         .notEmpty()
         .withMessage('Username is required')
         .isLength({ min: 1, max: 50 })
         .withMessage('Username must be between 1 and 50 characters')
         .matches(/^[A-Za-z0-9_.@-]+$/)
         .withMessage('Username contains invalid characters'),
      handleValidationErrors
   ],

   getUsers: [
      ...commonValidations.pagination(),
      handleValidationErrors
   ]
};

// Asset validators - Has status field
const assetValidators = {
   getAssetByNo: [
      commonValidations.id('asset_no'),
      handleValidationErrors
   ],

   // ===== NEW EPC VALIDATORS =====
   getAssetByEpc: [
      commonValidations.epcCode('epc_code'),
      handleValidationErrors
   ],

   updateAssetStatusByEpc: [
      commonValidations.epcCode('epc_code'),

      body('status')
         .trim()
         .notEmpty()
         .withMessage('Status is required')
         .isIn(['C', 'A', 'I'])
         .withMessage('Status must be C (Created), A (Active), or I (Inactive)'),

      body('updated_by')
         .trim()
         .notEmpty()
         .withMessage('Updated by is required')
         .isLength({ min: 1, max: 100 })
         .withMessage('Updated by must be between 1 and 100 characters'),

      body('remarks')
         .optional()
         .trim()
         .isLength({ max: 500 })
         .withMessage('Remarks must not exceed 500 characters'),

      handleValidationErrors
   ],

   getAssets: [
      commonValidations.assetStatus(), // Only assets have status
      query('plant_code')
         .optional()
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage('Plant code must be between 1 and 50 characters'),
      query('location_code')
         .optional()
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage('Location code must be between 1 and 50 characters'),
      query('unit_code')
         .optional()
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage('Unit code must be between 1 and 50 characters'),
      ...commonValidations.pagination(),
      handleValidationErrors
   ],

   searchAssets: [
      commonValidations.searchTerm(),
      commonValidations.assetStatus(), // Only assets have status
      query('plant_code')
         .optional()
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage('Plant code must be between 1 and 50 characters'),
      query('location_code')
         .optional()
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage('Location code must be between 1 and 50 characters'),
      query('unit_code')
         .optional()
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage('Unit code must be between 1 and 50 characters'),
      ...commonValidations.pagination(),
      handleValidationErrors
   ],

   getAssetsByPlant: [
      commonValidations.code('plant_code'),
      ...commonValidations.pagination(),
      handleValidationErrors
   ],

   getAssetsByLocation: [
      commonValidations.code('location_code'),
      ...commonValidations.pagination(),
      handleValidationErrors
   ],

   createAsset: [
      body('asset_no')
         .trim()
         .notEmpty()
         .withMessage('Asset number is required')
         .isLength({ min: 1, max: 100 })
         .withMessage('Asset number must be between 1 and 100 characters')
         .matches(/^[A-Za-z0-9_-]+$/)
         .withMessage('Asset number must contain only alphanumeric characters, hyphens, and underscores'),

      body('description')
         .trim()
         .notEmpty()
         .withMessage('Description is required')
         .isLength({ min: 1, max: 255 })
         .withMessage('Description must be between 1 and 255 characters'),

      body('plant_code')
         .trim()
         .notEmpty()
         .withMessage('Plant code is required')
         .isLength({ min: 1, max: 50 })
         .withMessage('Plant code must be between 1 and 50 characters'),

      body('location_code')
         .trim()
         .notEmpty()
         .withMessage('Location code is required')
         .isLength({ min: 1, max: 50 })
         .withMessage('Location code must be between 1 and 50 characters'),

      body('unit_code')
         .trim()
         .notEmpty()
         .withMessage('Unit code is required')
         .isLength({ min: 1, max: 50 })
         .withMessage('Unit code must be between 1 and 50 characters'),

      body('created_by')
         .trim()
         .notEmpty()
         .withMessage('Created by is required')
         .isLength({ min: 1, max: 100 })
         .withMessage('Created by must be between 1 and 100 characters'),

      body('quantity')
         .optional()
         .isFloat({ min: 0 })
         .withMessage('Quantity must be a positive number')
         .toFloat(),

      body('serial_no')
         .optional()
         .trim()
         .isLength({ max: 100 })
         .withMessage('Serial number must not exceed 100 characters'),

      body('inventory_no')
         .optional()
         .trim()
         .isLength({ max: 100 })
         .withMessage('Inventory number must not exceed 100 characters'),

      body('epc_code')
         .optional()
         .trim()
         .isLength({ max: 50 })
         .withMessage('EPC code must not exceed 50 characters')
         .matches(/^[A-Za-z0-9_-]*$/)
         .withMessage('EPC code must contain only alphanumeric characters, hyphens, and underscores'),

      body('category_code')
         .optional()
         .trim()
         .isLength({ max: 50 })
         .withMessage('Category code must not exceed 50 characters'),

      body('brand_code')
         .optional()
         .trim()
         .isLength({ max: 50 })
         .withMessage('Brand code must not exceed 50 characters'),

      handleValidationErrors
   ],

   updateAsset: [
      commonValidations.id('asset_no'),

      body('description')
         .optional()
         .trim()
         .isLength({ min: 1, max: 255 })
         .withMessage('Description must be between 1 and 255 characters'),

      body('plant_code')
         .optional()
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage('Plant code must be between 1 and 50 characters'),

      body('location_code')
         .optional()
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage('Location code must be between 1 and 50 characters'),

      body('unit_code')
         .optional()
         .trim()
         .isLength({ min: 1, max: 50 })
         .withMessage('Unit code must be between 1 and 50 characters'),

      body('quantity')
         .optional()
         .isFloat({ min: 0 })
         .withMessage('Quantity must be a positive number')
         .toFloat(),

      body('serial_no')
         .optional()
         .trim()
         .isLength({ max: 100 })
         .withMessage('Serial number must not exceed 100 characters'),

      body('inventory_no')
         .optional()
         .trim()
         .isLength({ max: 100 })
         .withMessage('Inventory number must not exceed 100 characters'),

      body('epc_code')
         .optional()
         .trim()
         .isLength({ max: 50 })
         .withMessage('EPC code must not exceed 50 characters')
         .matches(/^[A-Za-z0-9_-]*$/)
         .withMessage('EPC code must contain only alphanumeric characters, hyphens, and underscores'),

      body('category_code')
         .optional()
         .trim()
         .isLength({ max: 50 })
         .withMessage('Category code must not exceed 50 characters'),

      body('brand_code')
         .optional()
         .trim()
         .isLength({ max: 50 })
         .withMessage('Brand code must not exceed 50 characters'),

      handleValidationErrors
   ],

   updateAssetStatus: [
      commonValidations.id('asset_no'),

      body('status')
         .trim()
         .notEmpty()
         .withMessage('Status is required')
         .isIn(['C', 'A', 'I'])
         .withMessage('Status must be C (Created), A (Active), or I (Inactive)'),

      body('updated_by')
         .trim()
         .notEmpty()
         .withMessage('Updated by is required')
         .isLength({ min: 1, max: 100 })
         .withMessage('Updated by must be between 1 and 100 characters'),

      body('remarks')
         .optional()
         .trim()
         .isLength({ max: 500 })
         .withMessage('Remarks must not exceed 500 characters'),

      handleValidationErrors
   ]
};

// Statistics validators
const statsValidators = {
   getStats: [
      query('type')
         .optional()
         .isIn(['plant', 'location', 'unit', 'asset'])
         .withMessage('Type must be one of: plant, location, unit, asset'),
      handleValidationErrors
   ]
};

// Category validators - No status field
const categoryValidators = {
   getCategoryByCode: [
      commonValidations.code('category_code'),
      handleValidationErrors
   ],

   getCategories: [
      ...commonValidations.pagination(),
      handleValidationErrors
   ]
};

// Brand validators - No status field
const brandValidators = {
   getBrandByCode: [
      commonValidations.code('brand_code'),
      handleValidationErrors
   ],

   getBrands: [
      ...commonValidations.pagination(),
      handleValidationErrors
   ]
};

module.exports = {
   plantValidators,
   locationValidators,
   unitValidators,
   userValidators,
   assetValidators,
   statsValidators,
   handleValidationErrors,
   commonValidations,
   categoryValidators,
   brandValidators
};