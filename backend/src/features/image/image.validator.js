// Path: backend/src/features/image/image.validator.js
const { body, param, query, validationResult } = require('express-validator');

/**
 * 🛡️ IMAGE VALIDATOR
 * Validation rules สำหรับ image management endpoints
 */

/**
 * Validation error handler
 * จัดการ validation errors ให้เป็นรูปแบบเดียวกัน
 */
const handleValidationErrors = (req, res, next) => {
   const errors = validationResult(req);
   if (!errors.isEmpty()) {
      return res.status(400).json({
         success: false,
         message: 'Image validation failed',
         errors: errors.array().map(error => ({
            field: error.path,
            message: error.msg,
            value: error.value,
            suggestion: getSuggestionForError(error)
         })),
         timestamp: new Date().toISOString()
      });
   }
   next();
};

/**
 * Error suggestion helper
 * ให้คำแนะนำเมื่อ validation fail
 */
const getSuggestionForError = (error) => {
   const suggestions = {
      'asset_no': 'Asset number should be alphanumeric, e.g., ABC001, XYZ123',
      'imageId': 'Image ID should be a positive integer',
      'alt_text': 'Alt text should be descriptive for accessibility',
      'description': 'Description should be clear and concise',
      'category': 'Valid categories: main, detail, before, after, damage, repair',
      'size': 'Valid sizes: original, thumb, thumbnail, small, medium, large',
      'quality': 'Valid quality: low, medium, high'
   };

   return suggestions[error.path] || 'Please check the parameter format and requirements';
};

/**
 * 🎯 COMMON VALIDATION RULES
 */
const commonValidations = {
   // Asset number validation
   assetNo: () => {
      return param('asset_no')
         .trim()
         .notEmpty()
         .withMessage('Asset number is required')
         .isLength({ min: 1, max: 20 })
         .withMessage('Asset number must be 1-20 characters')
         .matches(/^[A-Za-z0-9_-]+$/)
         .withMessage('Asset number must contain only alphanumeric characters, hyphens, and underscores');
   },

   // Image ID validation
   imageId: () => {
      return param('imageId')
         .isInt({ min: 1 })
         .withMessage('Image ID must be a positive integer')
         .toInt();
   },

   // Query parameters for pagination
   pagination: () => {
      return [
         query('page')
            .optional()
            .isInt({ min: 1, max: 1000 })
            .withMessage('Page must be between 1-1000')
            .toInt(),
         query('limit')
            .optional()
            .isInt({ min: 1, max: 100 })
            .withMessage('Limit must be between 1-100')
            .toInt()
      ];
   },

   // Image serving options
   imageServing: () => {
      return [
         query('size')
            .optional()
            .isIn(['original', 'thumb', 'thumbnail', 'small', 'medium', 'large'])
            .withMessage('Size must be: original, thumb, thumbnail, small, medium, or large'),

         query('quality')
            .optional()
            .isIn(['low', 'medium', 'high'])
            .withMessage('Quality must be: low, medium, or high'),

         query('format')
            .optional()
            .isIn(['jpeg', 'jpg', 'png', 'webp'])
            .withMessage('Format must be: jpeg, jpg, png, or webp')
      ];
   }
};

/**
 * 📤 UPLOAD VALIDATION
 */

/**
 * POST /assets/:asset_no/images
 * Validate multiple image upload
 */
const uploadImagesValidator = [
   commonValidations.assetNo(),

   // File validation is handled by multer middleware
   // Additional validation for request body
   body('description')
      .optional()
      .trim()
      .isLength({ max: 500 })
      .withMessage('Description must not exceed 500 characters'),

   body('category')
      .optional()
      .trim()
      .isIn(['main', 'detail', 'before', 'after', 'damage', 'repair', 'maintenance', 'inspection'])
      .withMessage('Category must be: main, detail, before, after, damage, repair, maintenance, or inspection'),

   body('alt_text')
      .optional()
      .trim()
      .isLength({ max: 255 })
      .withMessage('Alt text must not exceed 255 characters'),

   handleValidationErrors
];

/**
 * 📥 RETRIEVAL VALIDATION
 */

/**
 * GET /assets/:asset_no/images
 * Validate get asset images
 */
const getAssetImagesValidator = [
   commonValidations.assetNo(),

   query('include_thumbnails')
      .optional()
      .isBoolean()
      .withMessage('include_thumbnails must be true or false')
      .toBoolean(),

   query('include_metadata')
      .optional()
      .isBoolean()
      .withMessage('include_metadata must be true or false')
      .toBoolean(),

   query('category')
      .optional()
      .isIn(['main', 'detail', 'before', 'after', 'damage', 'repair', 'maintenance', 'inspection'])
      .withMessage('Category filter must be valid category'),

   ...commonValidations.pagination(),
   handleValidationErrors
];

/**
 * GET /images/:imageId
 * Validate serve image
 */
const serveImageValidator = [
   commonValidations.imageId(),
   ...commonValidations.imageServing(),

   // Cache control headers
   query('cache')
      .optional()
      .isBoolean()
      .withMessage('Cache must be true or false')
      .toBoolean(),

   handleValidationErrors
];

/**
 * 🗑️ DELETE VALIDATION
 */

/**
 * DELETE /assets/:asset_no/images/:imageId
 * Validate delete image
 */
const deleteImageValidator = [
   commonValidations.assetNo(),
   commonValidations.imageId(),

   body('reason')
      .optional()
      .trim()
      .isLength({ max: 255 })
      .withMessage('Deletion reason must not exceed 255 characters'),

   handleValidationErrors
];

/**
 * 🔄 UPDATE VALIDATION
 */

/**
 * PUT /assets/:asset_no/images/:imageId
 * Validate replace image
 */
const replaceImageValidator = [
   commonValidations.assetNo(),
   commonValidations.imageId(),

   // File validation handled by multer
   body('reason')
      .optional()
      .trim()
      .isLength({ max: 255 })
      .withMessage('Replacement reason must not exceed 255 characters'),

   handleValidationErrors
];

/**
 * PATCH /assets/:asset_no/images/:imageId
 * Validate update image metadata
 */
const updateImageMetadataValidator = [
   commonValidations.assetNo(),
   commonValidations.imageId(),

   body('alt_text')
      .optional()
      .trim()
      .isLength({ max: 255 })
      .withMessage('Alt text must not exceed 255 characters'),

   body('description')
      .optional()
      .trim()
      .isLength({ max: 500 })
      .withMessage('Description must not exceed 500 characters'),

   body('category')
      .optional()
      .trim()
      .isIn(['main', 'detail', 'before', 'after', 'damage', 'repair', 'maintenance', 'inspection'])
      .withMessage('Category must be valid option'),

   body('tags')
      .optional()
      .isArray({ max: 10 })
      .withMessage('Tags must be an array with maximum 10 items'),

   body('tags.*')
      .optional()
      .trim()
      .isLength({ min: 1, max: 50 })
      .withMessage('Each tag must be 1-50 characters'),

   handleValidationErrors
];

/**
 * 🌟 PRIMARY IMAGE VALIDATION
 */

/**
 * POST /assets/:asset_no/images/:imageId/primary
 * Validate set primary image
 */
const setPrimaryImageValidator = [
   commonValidations.assetNo(),
   commonValidations.imageId(),

   body('reason')
      .optional()
      .trim()
      .isLength({ max: 255 })
      .withMessage('Reason must not exceed 255 characters'),

   handleValidationErrors
];

/**
 * 📊 STATISTICS VALIDATION
 */

/**
 * GET /assets/:asset_no/images/stats
 * Validate get image statistics
 */
const getImageStatsValidator = [
   commonValidations.assetNo(),

   query('include_breakdown')
      .optional()
      .isBoolean()
      .withMessage('include_breakdown must be true or false')
      .toBoolean(),

   handleValidationErrors
];

/**
 * 🔍 SEARCH VALIDATION
 */

/**
 * GET /images/search
 * Validate image search
 */
const searchImagesValidator = [
   query('asset_no')
      .optional()
      .trim()
      .isLength({ min: 1, max: 20 })
      .withMessage('Asset number must be 1-20 characters'),

   query('file_type')
      .optional()
      .custom((value) => {
         if (typeof value === 'string') {
            const types = value.split(',').map(t => t.trim());
            const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
            const invalidTypes = types.filter(t => !validTypes.includes(t));

            if (invalidTypes.length > 0) {
               throw new Error(`Invalid file types: ${invalidTypes.join(', ')}`);
            }
         }
         return true;
      }),

   query('min_size')
      .optional()
      .isInt({ min: 0 })
      .withMessage('Minimum size must be a non-negative integer')
      .toInt(),

   query('max_size')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Maximum size must be a positive integer')
      .toInt(),

   query('has_primary')
      .optional()
      .isBoolean()
      .withMessage('has_primary must be true or false')
      .toBoolean(),

   query('created_after')
      .optional()
      .isISO8601()
      .withMessage('created_after must be a valid ISO 8601 date')
      .toDate(),

   query('created_before')
      .optional()
      .isISO8601()
      .withMessage('created_before must be a valid ISO 8601 date')
      .toDate(),

   query('category')
      .optional()
      .isIn(['main', 'detail', 'before', 'after', 'damage', 'repair', 'maintenance', 'inspection'])
      .withMessage('Category must be valid option'),

   ...commonValidations.pagination(),
   handleValidationErrors
];

/**
 * 🧹 ADMIN VALIDATION
 */

/**
 * POST /images/cleanup
 * Validate cleanup orphaned files (admin only)
 */
const cleanupOrphanedFilesValidator = [
   body('dry_run')
      .optional()
      .isBoolean()
      .withMessage('dry_run must be true or false')
      .toBoolean(),

   body('confirm')
      .if(body('dry_run').equals(false))
      .equals('DELETE_ORPHANED_FILES')
      .withMessage('Must provide confirmation text "DELETE_ORPHANED_FILES" for actual cleanup'),

   handleValidationErrors
];

/**
 * GET /images/system/stats
 * Validate get system image statistics
 */
const getSystemStatsValidator = [
   query('period')
      .optional()
      .isIn(['day', 'week', 'month', 'quarter', 'year'])
      .withMessage('Period must be: day, week, month, quarter, or year'),

   query('include_details')
      .optional()
      .isBoolean()
      .withMessage('include_details must be true or false')
      .toBoolean(),

   handleValidationErrors
];

/**
 * 🔄 BATCH OPERATIONS VALIDATION
 */

/**
 * POST /images/batch/update
 * Validate batch update images
 */
const batchUpdateImagesValidator = [
   body('updates')
      .isArray({ min: 1, max: 50 })
      .withMessage('Updates must be an array with 1-50 items'),

   body('updates.*.id')
      .isInt({ min: 1 })
      .withMessage('Each update must have a valid image ID')
      .toInt(),

   body('updates.*.data')
      .isObject()
      .withMessage('Each update must have a data object'),

   body('updates.*.data.alt_text')
      .optional()
      .trim()
      .isLength({ max: 255 })
      .withMessage('Alt text must not exceed 255 characters'),

   body('updates.*.data.description')
      .optional()
      .trim()
      .isLength({ max: 500 })
      .withMessage('Description must not exceed 500 characters'),

   body('updates.*.data.category')
      .optional()
      .isIn(['main', 'detail', 'before', 'after', 'damage', 'repair', 'maintenance', 'inspection'])
      .withMessage('Category must be valid option'),

   handleValidationErrors
];

/**
 * 🔐 CUSTOM VALIDATION FUNCTIONS
 */

/**
 * Validate file size and type (used in middleware)
 */
const validateFileUpload = (req, res, next) => {
   if (!req.files && !req.file) {
      return res.status(400).json({
         success: false,
         message: 'No files uploaded',
         timestamp: new Date().toISOString()
      });
   }

   const files = req.files || [req.file];
   const errors = [];

   files.forEach((file, index) => {
      // File size validation (10MB max)
      if (file.size > 10 * 1024 * 1024) {
         errors.push(`File ${index + 1}: Size exceeds 10MB limit`);
      }

      // File type validation
      const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
      if (!allowedTypes.includes(file.mimetype)) {
         errors.push(`File ${index + 1}: Invalid type. Only JPG, PNG, and WebP allowed`);
      }

      // Filename validation
      if (!file.originalname || file.originalname.trim() === '') {
         errors.push(`File ${index + 1}: Invalid filename`);
      }
   });

   if (errors.length > 0) {
      return res.status(400).json({
         success: false,
         message: 'File validation failed',
         errors,
         timestamp: new Date().toISOString()
      });
   }

   next();
};

/**
 * Validate asset ownership (if needed for access control)
 */
const validateAssetOwnership = async (req, res, next) => {
   try {
      const { asset_no } = req.params;
      const { userId, role } = req.user;

      // Admin can access all assets
      if (role === 'admin') {
         return next();
      }

      // Additional ownership validation logic can be added here
      // For now, allow all authenticated users
      next();

   } catch (error) {
      console.error('Asset ownership validation error:', error);
      return res.status(500).json({
         success: false,
         message: 'Failed to validate asset ownership',
         timestamp: new Date().toISOString()
      });
   }
};

/**
 * Rate limiting validation
 */
const validateRateLimit = (maxUploads = 20) => {
   return (req, res, next) => {
      const userId = req.user?.userId || req.ip;
      const now = Date.now();

      // Basic rate limiting implementation
      if (!req.app.locals.uploadRates) {
         req.app.locals.uploadRates = new Map();
      }

      const userRate = req.app.locals.uploadRates.get(userId) || { count: 0, resetTime: now + 60000 };

      if (now > userRate.resetTime) {
         userRate.count = 0;
         userRate.resetTime = now + 60000;
      }

      if (userRate.count >= maxUploads) {
         return res.status(429).json({
            success: false,
            message: 'Upload rate limit exceeded',
            details: {
               limit: maxUploads,
               window: '1 minute',
               retry_after: Math.ceil((userRate.resetTime - now) / 1000)
            },
            timestamp: new Date().toISOString()
         });
      }

      userRate.count++;
      req.app.locals.uploadRates.set(userId, userRate);

      next();
   };
};

module.exports = {
   // Upload validators
   uploadImagesValidator,

   // Retrieval validators
   getAssetImagesValidator,
   serveImageValidator,

   // Update validators
   replaceImageValidator,
   updateImageMetadataValidator,
   setPrimaryImageValidator,

   // Delete validators
   deleteImageValidator,

   // Statistics validators
   getImageStatsValidator,
   getSystemStatsValidator,

   // Search validators
   searchImagesValidator,

   // Admin validators
   cleanupOrphanedFilesValidator,

   // Batch validators
   batchUpdateImagesValidator,

   // Custom validators
   validateFileUpload,
   validateAssetOwnership,
   validateRateLimit,

   // Helper functions
   handleValidationErrors,
   getSuggestionForError,
   commonValidations
};