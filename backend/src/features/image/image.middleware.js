// Path: backend/src/features/image/image.middleware.js
const multer = require('multer');
const path = require('path');
const fs = require('fs');

/**
 * 📁 IMAGE MIDDLEWARE
 * Handle file uploads และ validation สำหรับ image management
 */

// สร้าง upload directory ถ้ายังไม่มี
const ensureUploadDirs = () => {
   const uploadDir = path.join(process.cwd(), 'uploads');
   const assetsDir = path.join(uploadDir, 'assets');
   const thumbsDir = path.join(assetsDir, 'thumbs');

   [uploadDir, assetsDir, thumbsDir].forEach(dir => {
      if (!fs.existsSync(dir)) {
         fs.mkdirSync(dir, { recursive: true });
         console.log(`📁 Created directory: ${dir}`);
      }
   });
};

// เรียกใช้เมื่อ import module
ensureUploadDirs();

/**
 * 🎯 MULTER STORAGE CONFIGURATION
 */
const storage = multer.diskStorage({
   destination: (req, file, cb) => {
      const uploadPath = path.join(process.cwd(), 'uploads', 'assets');
      cb(null, uploadPath);
   },

   filename: (req, file, cb) => {
      try {
         const { asset_no } = req.params;

         if (!asset_no) {
            return cb(new Error('Asset number is required'));
         }

         // Generate timestamp: YYYYMMDD_HHMMSS
         const now = new Date();
         const date = now.toISOString().slice(0, 10).replace(/-/g, '');
         const time = now.toTimeString().slice(0, 8).replace(/:/g, '');
         const timestamp = `${date}_${time}`;

         // Generate sequence number
         const sequence = req.fileSequence || 1;
         req.fileSequence = sequence + 1;

         // Get file extension
         const ext = path.extname(file.originalname).toLowerCase();

         // Format: ABC001_20250130_143022_001.jpg
         const filename = `${asset_no}_${timestamp}_${String(sequence).padStart(3, '0')}${ext}`;

         cb(null, filename);

      } catch (error) {
         cb(error);
      }
   }
});

/**
 * 🔍 FILE FILTER VALIDATION
 */
const fileFilter = (req, file, cb) => {
   try {
      // Check MIME type
      const allowedMimeTypes = [
         'image/jpeg',
         'image/jpg',
         'image/png',
         'image/webp'
      ];

      if (!allowedMimeTypes.includes(file.mimetype)) {
         const error = new Error('Invalid file type. Only JPG, PNG, and WebP are allowed.');
         error.code = 'INVALID_FILE_TYPE';
         return cb(error, false);
      }

      // Check file extension
      const allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
      const fileExt = path.extname(file.originalname).toLowerCase();

      if (!allowedExtensions.includes(fileExt)) {
         const error = new Error('Invalid file extension. Only .jpg, .jpeg, .png, .webp are allowed.');
         error.code = 'INVALID_FILE_EXTENSION';
         return cb(error, false);
      }

      // Check original filename for security
      const filename = file.originalname;
      if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
         const error = new Error('Invalid filename. Path traversal detected.');
         error.code = 'INVALID_FILENAME';
         return cb(error, false);
      }

      cb(null, true);

   } catch (error) {
      cb(error, false);
   }
};

/**
 * 📊 MULTER CONFIGURATION
 */
const multerConfig = {
   storage: storage,
   fileFilter: fileFilter,
   limits: {
      fileSize: 10 * 1024 * 1024, // 10MB per file
      files: 10, // Max 10 files per request
      fieldNameSize: 100, // Max field name size
      fieldSize: 1024 * 1024, // 1MB for non-file fields
      fields: 10 // Max number of non-file fields
   }
};

/**
 * 🔄 MULTER INSTANCES
 */

// Multiple file upload (for POST /assets/:asset_no/images)
const uploadMultiple = multer(multerConfig).array('images', 10);

// Single file upload (for PUT /assets/:asset_no/images/:imageId)
const uploadSingle = multer(multerConfig).single('image');

/**
 * 🛡️ MIDDLEWARE FUNCTIONS
 */

/**
 * Handle multiple file uploads with enhanced error handling
 */
const handleMultipleUpload = (req, res, next) => {
   // Reset sequence counter for each request
   req.fileSequence = 1;

   uploadMultiple(req, res, (error) => {
      if (error) {
         return handleUploadError(error, req, res, next);
      }

      // Validate uploaded files
      if (!req.files || req.files.length === 0) {
         return res.status(400).json({
            success: false,
            message: 'No files uploaded',
            timestamp: new Date().toISOString()
         });
      }

      // Additional validations
      const validationError = validateUploadedFiles(req.files);
      if (validationError) {
         // Clean up uploaded files on validation error
         cleanupFiles(req.files);
         return res.status(400).json({
            success: false,
            message: validationError,
            timestamp: new Date().toISOString()
         });
      }

      next();
   });
};

/**
 * Handle single file upload
 */
const handleSingleUpload = (req, res, next) => {
   req.fileSequence = 1;

   uploadSingle(req, res, (error) => {
      if (error) {
         return handleUploadError(error, req, res, next);
      }

      if (!req.file) {
         return res.status(400).json({
            success: false,
            message: 'No file uploaded',
            timestamp: new Date().toISOString()
         });
      }

      // Additional validation for single file
      const validationError = validateUploadedFiles([req.file]);
      if (validationError) {
         cleanupFiles([req.file]);
         return res.status(400).json({
            success: false,
            message: validationError,
            timestamp: new Date().toISOString()
         });
      }

      next();
   });
};

/**
 * 🚨 ERROR HANDLING
 */

/**
 * Handle multer upload errors
 */
const handleUploadError = (error, req, res, next) => {
   console.error('Upload error:', error);

   let statusCode = 400;
   let message = 'File upload failed';
   let details = {};

   switch (error.code) {
      case 'LIMIT_FILE_SIZE':
         message = 'File too large';
         details = { max_size: '10MB per file' };
         break;

      case 'LIMIT_FILE_COUNT':
         message = 'Too many files';
         details = { max_files: 10 };
         break;

      case 'LIMIT_UNEXPECTED_FILE':
         message = 'Unexpected file field';
         details = { allowed_fields: ['images', 'image'] };
         break;

      case 'INVALID_FILE_TYPE':
      case 'INVALID_FILE_EXTENSION':
      case 'INVALID_FILENAME':
         message = error.message;
         details = { allowed_types: ['jpg', 'jpeg', 'png', 'webp'] };
         break;

      case 'ENOENT':
         message = 'Upload directory not accessible';
         statusCode = 500;
         break;

      case 'ENOSPC':
         message = 'Insufficient storage space';
         statusCode = 507;
         break;

      case 'EMFILE':
      case 'ENFILE':
         message = 'Too many open files';
         statusCode = 500;
         break;

      default:
         message = error.message || 'File upload failed';
         statusCode = 500;
   }

   return res.status(statusCode).json({
      success: false,
      message,
      details,
      timestamp: new Date().toISOString()
   });
};

/**
 * 🔍 FILE VALIDATION
 */

/**
 * Validate uploaded files
 */
const validateUploadedFiles = (files) => {
   for (const file of files) {
      // Check file size
      if (file.size > 10 * 1024 * 1024) {
         return `File ${file.originalname} is too large. Maximum size is 10MB.`;
      }

      // Check if file was actually written
      if (!fs.existsSync(file.path)) {
         return `File ${file.originalname} was not saved properly.`;
      }

      // Check file integrity (basic check)
      const stats = fs.statSync(file.path);
      if (stats.size !== file.size) {
         return `File ${file.originalname} may be corrupted.`;
      }

      // Additional MIME type validation by reading file header
      const mimeValidation = validateFileHeader(file.path, file.mimetype);
      if (!mimeValidation) {
         return `File ${file.originalname} has invalid format or is corrupted.`;
      }
   }

   return null; // No errors
};

/**
 * Validate file header to ensure actual file type matches MIME type
 */
const validateFileHeader = (filePath, expectedMimeType) => {
   try {
      const buffer = fs.readFileSync(filePath, { start: 0, end: 12 });
      const hex = buffer.toString('hex').toUpperCase();

      // File signatures (magic numbers)
      const signatures = {
         'image/jpeg': ['FFD8FF'],
         'image/jpg': ['FFD8FF'],
         'image/png': ['89504E47'],
         'image/webp': ['52494646'] // RIFF format
      };

      const expectedSignatures = signatures[expectedMimeType];
      if (!expectedSignatures) return false;

      return expectedSignatures.some(signature => hex.startsWith(signature));

   } catch (error) {
      console.error('File header validation error:', error);
      return false;
   }
};

/**
 * 🧹 CLEANUP UTILITIES
 */

/**
 * Clean up uploaded files
 */
const cleanupFiles = (files) => {
   files.forEach(file => {
      try {
         if (fs.existsSync(file.path)) {
            fs.unlinkSync(file.path);
            console.log(`🗑️ Cleaned up file: ${file.path}`);
         }
      } catch (error) {
         console.error(`Failed to cleanup file ${file.path}:`, error);
      }
   });
};

/**
 * 🔐 SECURITY MIDDLEWARE
 */

/**
 * Rate limiting for image uploads
 */
const uploadRateLimit = (req, res, next) => {
   // Basic rate limiting (can be enhanced with Redis)
   const userId = req.user?.userId || req.ip;
   const now = Date.now();

   // Initialize rate limit tracking
   if (!req.app.locals.uploadLimits) {
      req.app.locals.uploadLimits = new Map();
   }

   const userLimits = req.app.locals.uploadLimits.get(userId) || { count: 0, resetTime: now + 60000 };

   // Reset if time window passed
   if (now > userLimits.resetTime) {
      userLimits.count = 0;
      userLimits.resetTime = now + 60000; // 1 minute window
   }

   // Check limits
   const maxUploads = req.user?.role === 'admin' ? 50 : 20; // uploads per minute

   if (userLimits.count >= maxUploads) {
      return res.status(429).json({
         success: false,
         message: 'Upload rate limit exceeded',
         details: {
            limit: maxUploads,
            window: '1 minute',
            retry_after: Math.ceil((userLimits.resetTime - now) / 1000)
         },
         timestamp: new Date().toISOString()
      });
   }

   userLimits.count++;
   req.app.locals.uploadLimits.set(userId, userLimits);

   next();
};

/**
 * Validate asset ownership (if needed)
 */
const validateAssetAccess = async (req, res, next) => {
   try {
      const { asset_no } = req.params;
      const { userId, role } = req.user;

      // Admin can access all assets
      if (role === 'admin') {
         return next();
      }

      // Additional access control logic can be added here
      // For now, allow all authenticated users
      next();

   } catch (error) {
      console.error('Asset access validation error:', error);
      return res.status(500).json({
         success: false,
         message: 'Failed to validate asset access',
         timestamp: new Date().toISOString()
      });
   }
};

module.exports = {
   handleMultipleUpload,
   handleSingleUpload,
   handleUploadError,
   uploadRateLimit,
   validateAssetAccess,
   cleanupFiles,
   ensureUploadDirs
};