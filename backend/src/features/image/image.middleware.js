// Path: backend/src/features/image/image.middleware.js
const multer = require('multer');
const path = require('path');

// Memory storage - ไม่เก็บไฟล์ในดิสก์
const storage = multer.memoryStorage();

// File filter - รองรับเฉพาะรูปภาพ
const fileFilter = (req, file, cb) => {
   const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];

   if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
   } else {
      cb(new Error('Invalid file type. Only JPG, PNG, and WebP are allowed.'), false);
   }
};

// Multer configuration
const uploadConfig = {
   storage: storage,
   fileFilter: fileFilter,
   limits: {
      fileSize: 10 * 1024 * 1024, // 10MB max
      files: 1 // Single file only
   }
};

// Middleware functions
const uploadSingle = multer(uploadConfig).single('image');

// Error handler middleware
const handleUploadError = (err, req, res, next) => {
   if (err instanceof multer.MulterError) {
      if (err.code === 'LIMIT_FILE_SIZE') {
         return res.status(400).json({
            success: false,
            message: 'File too large. Maximum size is 10MB.'
         });
      }
      if (err.code === 'LIMIT_UNEXPECTED_FILE') {
         return res.status(400).json({
            success: false,
            message: 'Unexpected file field. Use "image" field name.'
         });
      }
   }

   if (err.message.includes('Invalid file type')) {
      return res.status(400).json({
         success: false,
         message: err.message
      });
   }

   next(err);
};

module.exports = {
   uploadSingle,
   handleUploadError
};