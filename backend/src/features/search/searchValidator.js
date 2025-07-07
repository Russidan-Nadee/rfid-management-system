// Path: backend/src/features/search/searchValidator.js
const { query, validationResult } = require('express-validator');

/**
 * 🛡️ VALIDATION ERROR HANDLER
 * Handle และ format validation errors ให้สวยงาม
 */
const handleValidationErrors = (req, res, next) => {
   const errors = validationResult(req);
   if (!errors.isEmpty()) {
      return res.status(400).json({
         success: false,
         message: 'Search validation failed',
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
 * 💡 ERROR SUGGESTION HELPER
 * ให้คำแนะนำเมื่อ validation fail
 */
const getSuggestionForError = (error) => {
   const suggestions = {
      'q': 'Search query is required. Try: ?q=ABC123 or ?q=pump',
      'entities': 'Valid entities: assets,plants,locations,users,departments',
      'limit': 'Limit should be between 1-50 for instant search, 1-100 for others',
      'type': 'Valid types: all,asset_no,description,serial_no,inventory_no,dept_code'
   };

   return suggestions[error.path] || 'Please check the parameter format';
};

/**
 * ⚡ INSTANT SEARCH VALIDATOR
 * สำหรับ /search/instant - ต้องเร็วมาก
 */
const instantSearchValidator = [
   // Query parameter - บังคับมี อย่างน้อย 1 ตัวอักษร
   query('q')
      .trim()
      .notEmpty()
      .withMessage('Search query is required')
      .isLength({ min: 1, max: 100 })
      .withMessage('Search query must be 1-100 characters')
      .matches(/^[^<>{}()[\]\\\/]*$/)
      .withMessage('Search query contains invalid characters'),

   // Entities - เลือกได้ว่าจะค้นหาใน table ไหน  
   query('entities')
      .optional()
      .trim()
      .custom((value) => {
         if (!value) return true;

         const validEntities = ['assets', 'plants', 'locations', 'users', 'departments'];
         const requestedEntities = value.split(',').map(e => e.trim());

         // ตรวจสอบว่าทุก entity ที่ขอมาถูกต้อง
         const invalidEntities = requestedEntities.filter(e => !validEntities.includes(e));
         if (invalidEntities.length > 0) {
            throw new Error(`Invalid entities: ${invalidEntities.join(', ')}. Valid options: ${validEntities.join(', ')}`);
         }

         // จำกัดไม่เกิน 4 entities พร้อมกัน
         if (requestedEntities.length > 5) {
            throw new Error('Maximum 5 entities allowed for instant search');
         }

         return true;
      }),

   // Limit - จำกัดผลลัพธ์ต่อ entity
   query('limit')
      .optional()
      .isInt({ min: 1, max: 10 })
      .withMessage('Limit must be between 1-10 for instant search')
      .toInt(),

   // Include details - ว่าจะให้ข้อมูลครบหรือแค่ basic
   query('include_details')
      .optional()
      .isBoolean()
      .withMessage('include_details must be true or false')
      .toBoolean(),

   handleValidationErrors
];

/**
 * 💭 SUGGESTIONS VALIDATOR  
 * สำหรับ autocomplete suggestions
 */
const suggestionsValidator = [
   // Query - อย่างน้อย 1 ตัวอักษร
   query('q')
      .trim()
      .notEmpty()
      .withMessage('Search query is required for suggestions')
      .isLength({ min: 1, max: 50 })
      .withMessage('Search query must be 1-50 characters for suggestions')
      .matches(/^[^<>{}()[\]\\\/]*$/)
      .withMessage('Search query contains invalid characters'),

   // Type - ประเภทของ suggestion
   query('type')
      .optional()
      .trim()
      .isIn(['all', 'asset_no', 'description', 'serial_no', 'inventory_no', 'plant_code', 'location_code', 'username', 'dept_code'])
      .withMessage('Invalid suggestion type'),

   // Limit - จำนวน suggestions
   query('limit')
      .optional()
      .isInt({ min: 1, max: 10 })
      .withMessage('Suggestions limit must be between 1-10')
      .toInt(),

   // Fuzzy matching - ค้นหาแบบคลุมเครือ
   query('fuzzy')
      .optional()
      .isBoolean()
      .withMessage('fuzzy must be true or false')
      .toBoolean(),

   handleValidationErrors
];

/**
 * 🌐 GLOBAL SEARCH VALIDATOR
 * สำหรับ comprehensive search
 */
const globalSearchValidator = [
   // Query - อย่างน้อย 2 ตัวอักษร
   query('q')
      .trim()
      .notEmpty()
      .withMessage('Search query is required')
      .isLength({ min: 2, max: 200 })
      .withMessage('Search query must be 2-200 characters')
      .matches(/^[^<>{}()[\]\\\/]*$/)
      .withMessage('Search query contains invalid characters'),

   // Entities
   query('entities')
      .optional()
      .trim()
      .custom((value) => {
         if (!value) return true;

         const validEntities = ['assets', 'plants', 'locations', 'users', 'departments', 'all'];
         const requestedEntities = value.split(',').map(e => e.trim());

         const invalidEntities = requestedEntities.filter(e => !validEntities.includes(e));
         if (invalidEntities.length > 0) {
            throw new Error(`Invalid entities: ${invalidEntities.join(', ')}`);
         }

         return true;
      }),

   // Pagination
   query('page')
      .optional()
      .isInt({ min: 1, max: 1000 })
      .withMessage('Page must be between 1-1000')
      .toInt(),

   query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1-100')
      .toInt(),

   // Sorting
   query('sort')
      .optional()
      .trim()
      .isIn(['relevance', 'created_date', 'alphabetical', 'recent'])
      .withMessage('Sort must be: relevance, created_date, alphabetical, or recent'),

   // Filters - JSON string
   query('filters')
      .optional()
      .custom((value) => {
         if (!value) return true;

         try {
            const filters = JSON.parse(value);

            // ตรวจสอบ structure ของ filters
            if (typeof filters !== 'object') {
               throw new Error('Filters must be an object');
            }

            // ตรวจสอบ allowed filter keys
            const allowedKeys = [
               'plant_codes', 'location_codes', 'unit_codes', 'status',
               'date_range', 'created_by', 'roles'
            ];

            const invalidKeys = Object.keys(filters).filter(key => !allowedKeys.includes(key));
            if (invalidKeys.length > 0) {
               throw new Error(`Invalid filter keys: ${invalidKeys.join(', ')}`);
            }

            return true;
         } catch (error) {
            throw new Error(`Invalid filters JSON: ${error.message}`);
         }
      }),

   // Exact match mode
   query('exact_match')
      .optional()
      .isBoolean()
      .withMessage('exact_match must be true or false')
      .toBoolean(),

   handleValidationErrors
];

/**
 * 📜 RECENT SEARCH VALIDATOR
 * สำหรับ user search history
 */
const recentSearchValidator = [
   query('limit')
      .optional()
      .isInt({ min: 1, max: 50 })
      .withMessage('Recent searches limit must be between 1-50')
      .toInt(),

   query('days')
      .optional()
      .isInt({ min: 1, max: 90 })
      .withMessage('Days must be between 1-90')
      .toInt(),

   handleValidationErrors
];

/**
 * 📊 SEARCH STATS VALIDATOR
 * สำหรับ admin statistics
 */
const searchStatsValidator = [
   query('period')
      .optional()
      .isIn(['day', 'week', 'month', 'year'])
      .withMessage('Period must be: day, week, month, or year'),

   query('entity')
      .optional()
      .isIn(['assets', 'plants', 'locations', 'users', 'departments', 'all'])
      .withMessage('Entity must be: assets, plants, locations, users, or all'),

   handleValidationErrors
];

/**
 * 🔄 REINDEX VALIDATOR
 * สำหรับ rebuild search index
 */
const reindexValidator = [
   query('entity')
      .optional()
      .isIn(['assets', 'plants', 'locations', 'users', 'all'])
      .withMessage('Entity must be: assets, plants, locations, users, or all'),

   query('force')
      .optional()
      .isBoolean()
      .withMessage('force must be true or false')
      .toBoolean(),

   handleValidationErrors
];

/**
 * 🔧 CUSTOM VALIDATION HELPERS
 */

// ตรวจสอบ SQL injection patterns
const sqlInjectionCheck = (value) => {
   const dangerousPatterns = [
      /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION)\b)/i,
      /(--|\/\*|\*\/|;|'|"|`)/,
      /(\bOR\b|\bAND\b).*(\b=\b|\bLIKE\b)/i
   ];

   return !dangerousPatterns.some(pattern => pattern.test(value));
};

// ตรวจสอบ XSS patterns  
const xssCheck = (value) => {
   const xssPatterns = [
      /<script[\s\S]*?>[\s\S]*?<\/script>/gi,
      /javascript:/gi,
      /on\w+\s*=/gi,
      /<iframe[\s\S]*?>[\s\S]*?<\/iframe>/gi
   ];

   return !xssPatterns.some(pattern => pattern.test(value));
};

// Sanitize search query
const sanitizeSearchQuery = (query) => {
   return query
      .trim()
      .replace(/[<>{}()[\]\\\/]/g, '') // ลบ special characters
      .replace(/\s+/g, ' ') // แปลง multiple spaces เป็น single space
      .substring(0, 200); // จำกัดความยาว
};

module.exports = {
   instantSearchValidator,
   suggestionsValidator,
   globalSearchValidator,
   recentSearchValidator,
   searchStatsValidator,
   reindexValidator,
   handleValidationErrors,

   // Export helper functions
   sqlInjectionCheck,
   xssCheck,
   sanitizeSearchQuery,
   getSuggestionForError
};