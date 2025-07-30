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
   validateAssetAccess
} = require('./image.middleware');

// Import validators
const {
   uploadImagesValidator,
   getAssetImagesValidator,
   serveImageValidator,
   deleteImageValidator,
   replaceImageValidator,
   updateImageMetadataValidator,
   setPrimaryImageValidator,
   getImageStatsValidator,
   searchImagesValidator,
   cleanupOrphanedFilesValidator,
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
 * 📤 UPLOAD ROUTES
 * จัดการการอัพโหลดรูปภาพ
 */

// POST /assets/:asset_no/images - Upload multiple images (max 10)
router.post('/assets/:asset_no/images',
   imageRateLimit,
   authenticateToken,
   validateAssetOwnership,
   uploadRateLimitStrict,
   handleMultipleUpload,
   uploadImagesValidator,
   (req, res) => imageController.uploadImages(req, res)
);

/**
 * 📥 RETRIEVAL ROUTES
 * ดึงข้อมูลและแสดงรูปภาพ
 */

// GET /assets/:asset_no/images - Get all images for asset
router.get('/assets/:asset_no/images',
   imageRateLimit,
   authenticateToken,
   validateAssetOwnership,
   getAssetImagesValidator,
   (req, res) => imageController.getAssetImages(req, res)
);

// GET /images/:imageId - Serve specific image file
router.get('/images/:imageId',
   imageRateLimit,
   serveImageValidator,
   (req, res) => imageController.serveImage(req, res)
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

// PUT /assets/:asset_no/images/:imageId - Replace existing image
router.put('/assets/:asset_no/images/:imageId',
   imageRateLimit,
   authenticateToken,
   validateAssetOwnership,
   uploadRateLimitStrict,
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
 * ลบรูปภาพ
 */

// DELETE /assets/:asset_no/images/:imageId - Delete specific image
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

// GET /images/search - Search images across all assets
router.get('/images/search',
   imageRateLimit,
   authenticateToken,
   searchImagesValidator,
   (req, res) => imageController.searchImages(req, res)
);

/**
 * 📊 STATISTICS & ANALYTICS ROUTES
 * สถิติและการวิเคราะห์
 */

// GET /images/system/stats - Get system-wide image statistics (admin only)
router.get('/images/system/stats',
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

// POST /images/cleanup - Cleanup orphaned files (admin only)
router.post('/images/cleanup',
   adminRateLimit,
   authenticateToken,
   requireRole(['admin']),
   cleanupOrphanedFilesValidator,
   (req, res) => imageController.cleanupOrphanedFiles(req, res)
);

// POST /images/batch/update - Batch update images (admin only)
router.post('/images/batch/update',
   adminRateLimit,
   authenticateToken,
   requireRole(['admin', 'manager']),
   batchUpdateImagesValidator,
   (req, res) => imageController.batchUpdateImages(req, res)
);

// GET /images/system/health - Image system health check (admin only)
router.get('/images/system/health',
   adminRateLimit,
   authenticateToken,
   requireRole(['admin']),
   (req, res) => imageController.getImageSystemHealth(req, res)
);

/**
 * 📋 DOCUMENTATION ROUTES
 * API Documentation
 */

// GET /images/docs - Image API documentation
router.get('/images/docs', (req, res) => {
   const imageDocs = {
      success: true,
      message: 'Image Management API Documentation',
      version: '1.0.0',
      timestamp: new Date().toISOString(),

      features: {
         upload: 'Upload multiple images per asset (max 10)',
         management: 'Full CRUD operations for image metadata',
         serving: 'Optimized image serving with caching',
         thumbnails: 'Automatic thumbnail generation',
         primary_image: 'Primary image designation per asset',
         search: 'Advanced search across all images',
         statistics: 'Detailed analytics and statistics',
         admin: 'System maintenance and cleanup tools'
      },

      endpoints: {
         upload: {
            'POST /assets/:asset_no/images': {
               description: 'Upload multiple images for asset (max 10 files)',
               authentication: 'Required',
               rate_limit: '20 uploads per 5 minutes',
               file_types: ['jpg', 'jpeg', 'png', 'webp'],
               max_file_size: '10MB per file',
               max_total_images: 10,
               example: 'curl -X POST -F "images=@photo1.jpg" -F "images=@photo2.png" /assets/ABC001/images'
            }
         },

         retrieval: {
            'GET /assets/:asset_no/images': {
               description: 'Get all images for specific asset',
               authentication: 'Required',
               parameters: {
                  include_thumbnails: 'Include thumbnail URLs (default: true)',
                  include_metadata: 'Include detailed metadata (default: false)',
                  category: 'Filter by category',
                  page: 'Page number for pagination',
                  limit: 'Items per page (max: 100)'
               }
            },
            'GET /images/:imageId': {
               description: 'Serve image file with optimization',
               authentication: 'Not required for public images',
               parameters: {
                  size: 'Image size (original, thumb, small, medium, large)',
                  quality: 'Image quality (low, medium, high)',
                  format: 'Output format (jpeg, png, webp)'
               },
               caching: 'Images cached for 1 year with ETag support'
            }
         },

         management: {
            'PUT /assets/:asset_no/images/:imageId': 'Replace existing image',
            'PATCH /assets/:asset_no/images/:imageId': 'Update image metadata',
            'POST /assets/:asset_no/images/:imageId/primary': 'Set as primary image',
            'DELETE /assets/:asset_no/images/:imageId': 'Delete image'
         },

         search: {
            'GET /images/search': {
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
            'GET /images/system/stats': 'Get system-wide statistics (admin only)'
         },

         admin: {
            'POST /images/cleanup': 'Cleanup orphaned files (admin only)',
            'POST /images/batch/update': 'Batch update operations (admin only)',
            'GET /images/system/health': 'System health check (admin only)'
         }
      },

      file_specifications: {
         supported_formats: ['JPEG', 'PNG', 'WebP'],
         max_file_size: '10MB per file',
         max_files_per_asset: 10,
         thumbnail_size: '300x300 pixels (aspect ratio maintained)',
         quality_levels: {
            low: 'Optimized for file size',
            medium: 'Balanced quality and size',
            high: 'Maximum quality'
         }
      },

      naming_convention: {
         pattern: '{asset_no}_{YYYYMMDD}_{HHMMSS}_{sequence}.{ext}',
         example: 'ABC001_20250130_143022_001.jpg',
         description: 'Automatic naming ensures uniqueness and organization'
      },

      response_formats: {
         success: {
            success: true,
            message: 'Operation completed successfully',
            data: '/* Response data */',
            meta: '/* Additional metadata */',
            timestamp: '2025-01-30T14:30:22.000Z'
         },
         error: {
            success: false,
            message: 'Error description',
            errors: '/* Detailed error information */',
            timestamp: '2025-01-30T14:30:22.000Z'
         }
      },

      security: {
         authentication: 'JWT token required for most operations',
         authorization: 'Role-based access control',
         file_validation: 'Strict file type and size validation',
         path_traversal_protection: 'Prevents directory traversal attacks',
         rate_limiting: 'Prevents abuse and ensures fair usage'
      },

      performance: {
         caching: {
            images: 'Static files cached for 1 year',
            api_responses: 'Short-term caching for statistics',
            etag_support: 'Conditional requests supported'
         },
         optimization: {
            thumbnails: 'Automatically generated and cached',
            compression: 'Smart compression based on content',
            progressive_jpeg: 'Progressive loading for better UX'
         }
      },

      integration_examples: {
         javascript: {
            upload: `
// Upload multiple images
const formData = new FormData();
formData.append('images', file1);
formData.append('images', file2);

fetch('/api/v1/assets/ABC001/images', {
  method: 'POST',
  headers: { 'Authorization': 'Bearer ' + token },
  body: formData
});`,

            display: `
// Display asset images
fetch('/api/v1/assets/ABC001/images')
  .then(response => response.json())
  .then(data => {
    data.data.images.forEach(image => {
      const img = document.createElement('img');
      img.src = image.thumbnail_url;
      img.onclick = () => window.open(image.image_url);
      container.appendChild(img);
    });
  });`
         }
      },

      troubleshooting: {
         common_errors: {
            'File too large': 'Reduce file size below 10MB',
            'Invalid file type': 'Use only JPG, PNG, or WebP formats',
            'Too many files': 'Maximum 10 images per asset',
            'Asset not found': 'Verify asset exists before uploading',
            'Rate limit exceeded': 'Wait before making more requests'
         },
         performance_tips: {
            'Use appropriate image sizes': 'Dont upload unnecessarily large images',
            'Leverage caching': 'Use ETag headers for efficient caching',
            'Batch operations': 'Use batch APIs for multiple updates',
            'Monitor usage': 'Check system stats regularly'
         }
      }
   };

   res.status(200).json(imageDocs);
});

/**
 * 🏥 HEALTH CHECK ROUTE
 */
router.get('/images/health', (req, res) => {
   res.status(200).json({
      success: true,
      message: 'Image service is healthy',
      version: '1.0.0',
      timestamp: new Date().toISOString(),
      features: {
         upload: 'operational',
         serving: 'operational',
         thumbnails: 'operational',
         search: 'operational',
         admin: 'operational'
      }
   });
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