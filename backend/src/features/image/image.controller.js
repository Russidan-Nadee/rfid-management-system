// Path: backend/src/features/image/image.controller.js
const ImageService = require('./image.service');
const ImageUtils = require('./image.utils');

/**
 * 📸 IMAGE CONTROLLER
 * Handle HTTP requests สำหรับ image management
 */
class ImageController {
   constructor() {
      this.imageService = new ImageService();
   }

   /**
    * POST /assets/:asset_no/images
    * Upload images for asset (max 10 files)
    */
   async uploadImages(req, res) {
      const startTime = new Date();

      try {
         const { asset_no } = req.params;
         const files = req.files; // จาก multer middleware
         const { userId } = req.user;

         if (!files || files.length === 0) {
            return this.sendError(res, 400, 'No files uploaded');
         }

         // ตรวจสอบ asset exists
         const assetExists = await this.imageService.checkAssetExists(asset_no);
         if (!assetExists) {
            return this.sendError(res, 404, 'Asset not found');
         }

         // ตรวจสอบจำนวนไฟล์ปัจจุบัน + ใหม่ ไม่เกิน 10
         const currentCount = await this.imageService.getImageCount(asset_no);
         if (currentCount + files.length > 10) {
            return this.sendError(res, 400,
               `Cannot upload ${files.length} files. Asset already has ${currentCount} images. Maximum 10 allowed.`
            );
         }

         // Upload และ process files
         const uploadResults = await this.imageService.uploadImages(asset_no, files, userId);

         return this.sendSuccess(res, 201, 'Images uploaded successfully', {
            uploaded: uploadResults,
            total_images: currentCount + uploadResults.length
         }, {
            performance: ImageUtils.calculatePerformance(startTime),
            asset_no
         });

      } catch (error) {
         console.error('Upload images error:', error);
         return this.sendError(res, 500, error.message || 'Failed to upload images');
      }
   }

   /**
    * GET /assets/:asset_no/images
    * Get all images for asset
    */
   async getAssetImages(req, res) {
      try {
         const { asset_no } = req.params;
         const { include_thumbnails = 'true' } = req.query;

         const images = await this.imageService.getAssetImages(asset_no, {
            includeThumbnails: include_thumbnails === 'true'
         });

         return this.sendSuccess(res, 200, 'Asset images retrieved successfully', {
            images,
            total: images.length,
            primary_image: images.find(img => img.is_primary) || null
         }, {
            asset_no,
            include_thumbnails: include_thumbnails === 'true'
         });

      } catch (error) {
         console.error('Get asset images error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return this.sendError(res, statusCode, error.message || 'Failed to get asset images');
      }
   }

   /**
    * GET /images/:imageId
    * Serve specific image file
    */
   async serveImage(req, res) {
      try {
         const { imageId } = req.params;
         const { size = 'original', quality = 'high' } = req.query;

         const imageResult = await this.imageService.serveImage(imageId, { size, quality });

         if (!imageResult) {
            return this.sendError(res, 404, 'Image not found');
         }

         // Set appropriate headers
         res.set({
            'Content-Type': imageResult.mimeType,
            'Content-Length': imageResult.size,
            'Cache-Control': 'public, max-age=31536000', // 1 year cache
            'ETag': imageResult.etag,
            'Last-Modified': imageResult.lastModified
         });

         // ตรวจสอบ conditional requests
         if (req.headers['if-none-match'] === imageResult.etag) {
            return res.status(304).end();
         }

         return res.sendFile(imageResult.filePath);

      } catch (error) {
         console.error('Serve image error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return this.sendError(res, statusCode, error.message || 'Failed to serve image');
      }
   }

   /**
    * DELETE /assets/:asset_no/images/:imageId
    * Delete specific image
    */
   async deleteImage(req, res) {
      try {
         const { asset_no, imageId } = req.params;
         const { userId } = req.user;

         const deleted = await this.imageService.deleteImage(asset_no, imageId, userId);

         if (!deleted) {
            return this.sendError(res, 404, 'Image not found');
         }

         return this.sendSuccess(res, 200, 'Image deleted successfully', {
            deleted_image_id: parseInt(imageId),
            remaining_images: await this.imageService.getImageCount(asset_no)
         }, {
            asset_no,
            deleted_by: userId
         });

      } catch (error) {
         console.error('Delete image error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return this.sendError(res, statusCode, error.message || 'Failed to delete image');
      }
   }

   /**
    * PUT /assets/:asset_no/images/:imageId
    * Replace existing image
    */
   async replaceImage(req, res) {
      try {
         const { asset_no, imageId } = req.params;
         const file = req.file; // single file จาก multer
         const { userId } = req.user;

         if (!file) {
            return this.sendError(res, 400, 'No file uploaded');
         }

         const replacedImage = await this.imageService.replaceImage(asset_no, imageId, file, userId);

         if (!replacedImage) {
            return this.sendError(res, 404, 'Image not found');
         }

         return this.sendSuccess(res, 200, 'Image replaced successfully', replacedImage, {
            asset_no,
            replaced_by: userId
         });

      } catch (error) {
         console.error('Replace image error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return this.sendError(res, statusCode, error.message || 'Failed to replace image');
      }
   }

   /**
    * PATCH /assets/:asset_no/images/:imageId
    * Update image metadata
    */
   async updateImageMetadata(req, res) {
      try {
         const { asset_no, imageId } = req.params;
         const { alt_text, description, category } = req.body;
         const { userId } = req.user;

         const updatedImage = await this.imageService.updateImageMetadata(asset_no, imageId, {
            alt_text,
            description,
            category,
            updated_by: userId
         });

         if (!updatedImage) {
            return this.sendError(res, 404, 'Image not found');
         }

         return this.sendSuccess(res, 200, 'Image metadata updated successfully', updatedImage, {
            asset_no,
            updated_by: userId
         });

      } catch (error) {
         console.error('Update image metadata error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return this.sendError(res, statusCode, error.message || 'Failed to update image metadata');
      }
   }

   /**
    * POST /assets/:asset_no/images/:imageId/primary
    * Set image as primary for asset
    */
   async setPrimaryImage(req, res) {
      try {
         const { asset_no, imageId } = req.params;
         const { userId } = req.user;

         const result = await this.imageService.setPrimaryImage(asset_no, imageId, userId);

         if (!result) {
            return this.sendError(res, 404, 'Image not found');
         }

         return this.sendSuccess(res, 200, 'Primary image set successfully', {
            primary_image_id: parseInt(imageId),
            asset_no
         }, {
            updated_by: userId,
            previous_primary: result.previousPrimary
         });

      } catch (error) {
         console.error('Set primary image error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return this.sendError(res, statusCode, error.message || 'Failed to set primary image');
      }
   }

   /**
    * GET /assets/:asset_no/images/stats
    * Get image statistics for asset
    */
   async getImageStats(req, res) {
      try {
         const { asset_no } = req.params;

         const stats = await this.imageService.getImageStats(asset_no);

         return this.sendSuccess(res, 200, 'Image statistics retrieved successfully', stats, {
            asset_no
         });

      } catch (error) {
         console.error('Get image stats error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return this.sendError(res, statusCode, error.message || 'Failed to get image statistics');
      }
   }

   /**
    * POST /images/cleanup
    * Admin: Cleanup orphaned files (admin only)
    */
   async cleanupOrphanedFiles(req, res) {
      try {
         const { userId, role } = req.user;

         if (role !== 'admin') {
            return this.sendError(res, 403, 'Admin access required');
         }

         const { dry_run = 'true' } = req.body;
         const isDryRun = dry_run === 'true';

         console.log(`Admin ${userId} initiated image cleanup (dry_run: ${isDryRun})`);

         const cleanupResult = await this.imageService.cleanupOrphanedFiles(isDryRun);

         return this.sendSuccess(res, 200,
            isDryRun ? 'Cleanup preview completed' : 'Cleanup completed successfully',
            cleanupResult,
            {
               executed_by: userId,
               dry_run: isDryRun
            }
         );

      } catch (error) {
         console.error('Cleanup orphaned files error:', error);
         return this.sendError(res, 500, error.message || 'Failed to cleanup orphaned files');
      }
   }

   /**
    * 🔧 HELPER METHODS
    */

   /**
    * Send success response
    * @param {Object} res - Express response
    * @param {number} statusCode - HTTP status code
    * @param {string} message - Success message
    * @param {*} data - Response data
    * @param {Object} meta - Additional metadata
    */
   sendSuccess(res, statusCode, message, data = null, meta = null) {
      const response = {
         success: true,
         message,
         timestamp: new Date().toISOString()
      };

      if (data !== null) {
         response.data = data;
      }

      if (meta !== null) {
         response.meta = meta;
      }

      return res.status(statusCode).json(response);
   }

   /**
    * Send error response
    * @param {Object} res - Express response
    * @param {number} statusCode - HTTP status code
    * @param {string} message - Error message
    * @param {Object} details - Error details
    */
   sendError(res, statusCode, message, details = null) {
      const response = {
         success: false,
         message,
         timestamp: new Date().toISOString()
      };

      if (details !== null) {
         response.details = details;
      }

      return res.status(statusCode).json(response);
   }

   /**
    * Handle multer errors
    * @param {Error} error - Multer error
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    * @param {Function} next - Express next
    */
   handleMulterError(error, req, res, next) {
      if (error.code === 'LIMIT_FILE_SIZE') {
         return this.sendError(res, 400, 'File too large', {
            max_size: '10MB per file'
         });
      }

      if (error.code === 'LIMIT_FILE_COUNT') {
         return this.sendError(res, 400, 'Too many files', {
            max_files: 10
         });
      }

      if (error.code === 'LIMIT_UNEXPECTED_FILE') {
         return this.sendError(res, 400, 'Unexpected file field', {
            allowed_fields: ['images', 'image']
         });
      }

      if (error.message.includes('Invalid file type')) {
         return this.sendError(res, 400, 'Invalid file type', {
            allowed_types: ['jpg', 'jpeg', 'png', 'webp']
         });
      }

      console.error('Multer error:', error);
      return this.sendError(res, 500, 'File upload error');
   }
}

module.exports = ImageController;