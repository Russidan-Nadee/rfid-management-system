// Path: backend/src/features/image/image.routes.js
const express = require('express');
const router = express.Router();

// Import controllers
const ImageController = require('./image.controller');
const imageController = new ImageController();

// Import middleware
const {
   handleMultipleUpload,
   handleSingleUpload,
   uploadRateLimit,
   validateAssetAccess,
   cleanupOnError
} = require('./image.middleware');

// Import validators
const {
   uploadImagesValidator,
   getAssetImagesValidator,
   deleteImageValidator,
   replaceImageValidator,
   updateImageMetadataValidator,
   setPrimaryImageValidator,
   getImageStatsValidator,
   searchImagesValidator,
   getSystemStatsValidator,
   batchUpdateImagesValidator,
   validateAssetOwnership,
   validateRateLimit
} = require('./image.validator');

// Import authentication
const { authenticateToken } = require('../auth/authMiddleware');
const { requireRole } = require('../../core/middleware/roleMiddleware');

// Import rate limiting
const { createRateLimit } = require('../scan/scanMiddleware');

/**
 * 🎯 RATE LIMITING CONFIGURATION
 */
const imageRateLimit = createRateLimit(15 * 60 * 1000, 200);    // 200 requests per 15 minutes
const uploadRateLimitStrict = createRateLimit(5 * 60 * 1000, 20); // 20 uploads per 5 minutes
const adminRateLimit = createRateLimit(60 * 60 * 1000, 10);    // 10 admin operations per hour

/**
 * 🏥 HEALTH CHECK ROUTE
 */
router.get('/health', (req, res) => {
   res.status(200).json({
      success: true,
      message: 'Image service is healthy',
      version: '2.0.0',
      timestamp: new Date().toISOString(),
      features: {
         upload: 'operational',
         external_storage: 'operational',
         search: 'operational',
         admin: 'operational'
      },
      storage_type: 'external'
   });
});

/**
 * 💾 SAVE RESPONSE ROUTES
 * บันทึก response จาก dev server
 */

// POST /assets/:asset_no/images/save - Save dev server response to database
router.post('/assets/:asset_no/images/save',
   imageRateLimit,
   authenticateToken,
   validateAssetOwnership,
   (req, res) => imageController.saveImageResponse(req, res)
);

/**
 * 📤 UPLOAD ROUTES
 * จัดการการอัพโหลดรูปภาพไปยัง external storage
 */

// POST /assets/:asset_no/images - Upload multiple images (max 10) to external storage
router.post('/assets/:asset_no/images',
   imageRateLimit,
   authenticateToken,
   validateAssetOwnership,
   uploadRateLimitStrict,
   cleanupOnError,
   handleMultipleUpload,
   uploadImagesValidator,
   (req, res) => imageController.uploadImages(req, res)
);

/**
 * 📥 RETRIEVAL ROUTES
 * ดึงข้อมูลรูปภาพ (จะได้ external URLs)
 */

// GET /assets/:asset_no/images - Get all images for asset (returns external URLs)
router.get('/assets/:asset_no/images',
   imageRateLimit,
   authenticateToken,
   validateAssetOwnership,
   getAssetImagesValidator,
   (req, res) => imageController.getAssetImages(req, res)
);

// GET /assets/:asset_no/images/stats - Get image statistics for asset
router.get('/assets/:asset_no/images/stats',
   imageRateLimit,
   authenticateToken,
   validateAssetOwnership,
   getImageStatsValidator,
   (req, res) => imageController.getImageStats(req, res)
);

/**
 * 🔄 UPDATE ROUTES
 * แก้ไขและอัพเดทรูปภาพ
 */

// PUT /assets/:asset_no/images/:imageId - Replace existing image in external storage
router.put('/assets/:asset_no/images/:imageId',
   imageRateLimit,
   authenticateToken,
   validateAssetOwnership,
   uploadRateLimitStrict,
   cleanupOnError,
   handleSingleUpload,
   replaceImageValidator,
   (req, res) => imageController.replaceImage(req, res)
);

// PATCH /assets/:asset_no/images/:imageId - Update image metadata
router.patch('/assets/:asset_no/images/:imageId',
   imageRateLimit,
   authenticateToken,
   validateAssetOwnership,
   updateImageMetadataValidator,
   (req, res) => imageController.updateImageMetadata(req, res)
);

// POST /assets/:asset_no/images/:imageId/primary - Set image as primary
router.post('/assets/:asset_no/images/:imageId/primary',
   imageRateLimit,
   authenticateToken,
   validateAssetOwnership,
   setPrimaryImageValidator,
   (req, res) => imageController.setPrimaryImage(req, res)
);

/**
 * 🗑️ DELETE ROUTES
 * ลบรูปภาพจาก external storage
 */

// DELETE /assets/:asset_no/images/:imageId - Delete specific image from external storage
router.delete('/assets/:asset_no/images/:imageId',
   imageRateLimit,
   authenticateToken,
   validateAssetOwnership,
   deleteImageValidator,
   (req, res) => imageController.deleteImage(req, res)
);

/**
 * 🔍 SEARCH ROUTES
 * ค้นหารูปภาพ
 */

// GET /search - Search images across all assets
router.get('/search',
   imageRateLimit,
   authenticateToken,
   searchImagesValidator,
   (req, res) => imageController.searchImages(req, res)
);

/**
 * 📊 STATISTICS & ANALYTICS ROUTES
 * สถิติและการวิเคราะห์
 */

// GET /system/stats - Get system-wide image statistics (admin only)
router.get('/system/stats',
   adminRateLimit,
   authenticateToken,
   requireRole(['admin']),
   getSystemStatsValidator,
   (req, res) => imageController.getSystemImageStats(req, res)
);

/**
 * 🔧 ADMIN ROUTES
 * จัดการระบบสำหรับ admin
 */

// POST /batch/update - Batch update images (admin/manager only)
router.post('/batch/update',
   adminRateLimit,
   authenticateToken,
   requireRole(['admin', 'manager']),
   batchUpdateImagesValidator,
   (req, res) => imageController.batchUpdateImages(req, res)
);

// GET /system/health - Image system health check (admin only)
router.get('/system/health',
   adminRateLimit,
   authenticateToken,
   requireRole(['admin']),
   (req, res) => imageController.getImageSystemHealth(req, res)
);

/**
 * 📋 DOCUMENTATION ROUTES
 * API Documentation
 */

// GET /docs - Image API documentation
router.get('/docs', (req, res) => {
   const imageDocs = {
      success: true,
      message: 'Image Management API Documentation (External Storage)',
      version: '2.0.0',
      storage_type: 'external',
      timestamp: new Date().toISOString(),

      features: {
         upload: 'Upload images to external dev server',
         management: 'Full CRUD operations with external storage',
         serving: 'Direct access via external URLs (no backend proxy)',
         search: 'Advanced search across all images',
         statistics: 'Detailed analytics and statistics',
         admin: 'System maintenance and health monitoring'
      },

      endpoints: {
         upload: {
            'POST /assets/:asset_no/images': {
               description: 'Upload multiple images to external storage (max 10 files)',
               authentication: 'Required',
               rate_limit: '20 uploads per 5 minutes',
               file_types: ['jpg', 'jpeg', 'png', 'webp'],
               max_file_size: '10MB per file',
               max_total_images: 10,
               storage: 'External dev server',
               example: 'curl -X POST -F "images=@photo1.jpg" -F "images=@photo2.png" /assets/ABC001/images'
            }
         },

         retrieval: {
            'GET /assets/:asset_no/images': {
               description: 'Get all images for specific asset (returns external URLs)',
               authentication: 'Required',
               response_urls: 'Direct links to external dev server',
               parameters: {
                  include_thumbnails: 'Include thumbnail URLs (default: true)',
                  category: 'Filter by category',
                  page: 'Page number for pagination',
                  limit: 'Items per page (max: 100)'
               },
               example_response: {
                  images: [{
                     id: 1,
                     image_url: 'https://devsever.thaiparker.co.th/TP_Service/File/.../image.jpg',
                     thumbnail_url: 'https://devsever.thaiparker.co.th/TP_Service/File/.../thumbnails/image.jpg'
                  }]
               }
            }
         },

         management: {
            'PUT /assets/:asset_no/images/:imageId': 'Replace existing image in external storage',
            'PATCH /assets/:asset_no/images/:imageId': 'Update image metadata',
            'POST /assets/:asset_no/images/:imageId/primary': 'Set as primary image',
            'DELETE /assets/:asset_no/images/:imageId': 'Delete image from external storage'
         },

         search: {
            'GET /search': {
               description: 'Search images across all assets',
               parameters: {
                  asset_no: 'Filter by asset number (partial match)',
                  file_type: 'Filter by file type',
                  min_size: 'Minimum file size in bytes',
                  max_size: 'Maximum file size in bytes',
                  has_primary: 'Filter primary images only',
                  created_after: 'Filter by creation date',
                  category: 'Filter by category'
               }
            }
         },

         statistics: {
            'GET /assets/:asset_no/images/stats': 'Get statistics for specific asset',
            'GET /system/stats': 'Get system-wide statistics (admin only)'
         },

         admin: {
            'POST /batch/update': 'Batch update operations (admin/manager only)',
            'GET /system/health': 'System health check including external storage (admin only)'
         }
      },

      external_storage: {
         dev_server: 'https://devsever.thaiparker.co.th/tp_service/api/Service_File',
         folder_path: 'intern_test/IMG',
         automatic_thumbnails: 'Generated by dev server',
         direct_access: 'Frontend accesses images directly from dev server',
         no_backend_proxy: 'No image serving through backend'
      },

      file_specifications: {
         supported_formats: ['JPEG', 'PNG', 'WebP'],
         max_file_size: '10MB per file',
         max_files_per_asset: 10,
         thumbnail_generation: 'Automatic by external dev server',
         quality_levels: 'Managed by external dev server',
         temporary_storage: 'Files temporarily stored during upload process only'
      },

      response_formats: {
         success: {
            success: true,
            message: 'Operation completed successfully',
            data: {
               images: [{
                  image_url: 'Direct external URL',
                  thumbnail_url: 'Direct external thumbnail URL'
               }]
            },
            meta: {
               storage_type: 'external'
            },
            timestamp: '2025-01-30T14:30:22.000Z'
         },
         error: {
            success: false,
            message: 'Error description',
            details: 'Detailed error information',
            timestamp: '2025-01-30T14:30:22.000Z'
         }
      },

      security: {
         authentication: 'JWT token required for all operations',
         authorization: 'Role-based access control',
         file_validation: 'Strict file type and size validation',
         temporary_files: 'Automatic cleanup of temporary files',
         rate_limiting: 'Prevents abuse and ensures fair usage',
         external_dependency: 'Requires external dev server availability'
      },

      migration_notes: {
         breaking_changes: [
            'Removed GET /images/:imageId endpoint (use external URLs directly)',
            'All image URLs now point to external dev server',
            'No local file serving through backend',
            'Temporary file storage only during upload process'
         ],
         compatibility: 'Frontend must use external URLs directly',
         performance: 'Improved backend performance, direct CDN-like access'
      },

      troubleshooting: {
         common_errors: {
            'External storage unavailable': 'Check dev server connectivity',
            'File upload timeout': 'Large files may take longer to upload to external storage',
            'Image not loading': 'Check external dev server availability',
            'Rate limit exceeded': 'Wait before making more requests'
         },
         health_check: 'Use GET /system/health to check external storage connectivity',
         monitoring: 'Monitor external dev server uptime for image availability'
      }
   };

   res.status(200).json(imageDocs);
});

/**
 * 🚨 ERROR HANDLING
 * Handle multer and other middleware errors
 */
router.use((error, req, res, next) => {
   // Let the controller handle multer errors
   if (error.code && error.code.startsWith('LIMIT_')) {
      return imageController.handleMulterError(error, req, res, next);
   }

   // Handle other errors
   console.error('Image routes error:', error);
   res.status(500).json({
      success: false,
      message: 'Image service error',
      timestamp: new Date().toISOString()
   });
});

module.exports = router;