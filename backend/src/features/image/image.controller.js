// Path: backend/src/features/image/image.controller.js
const ImageService = require('./image.service');

/**
 * 📸 SIMPLE IMAGE CONTROLLER
 * รับ response จาก dev server มาเก็บใน database เท่านั้น
 */
class ImageController {
   constructor() {
      this.imageService = new ImageService();
   }

   /**
    * POST /assets/:asset_no/images/save
    * บันทึก response จาก dev server ลง database
    */
   async saveImageResponse(req, res) {
      try {
         const { asset_no } = req.params;
         const { userId } = req.user;
         const devServerResponse = req.body;

         console.log('💾 Saving dev server response for asset:', asset_no);
         console.log('📄 Response data:', devServerResponse);

         // Validate response data
         if (!devServerResponse.FileUrl || !devServerResponse.FileThumbnailUrl) {
            return this.sendError(res, 400, 'Invalid dev server response - missing required URLs');
         }

         if (!devServerResponse.IsSuccess) {
            return this.sendError(res, 400, `Dev server error: ${devServerResponse.ErrorMessage}`);
         }

         // ตรวจสอบ asset exists
         const assetExists = await this.imageService.checkAssetExists(asset_no);
         if (!assetExists) {
            return this.sendError(res, 404, 'Asset not found');
         }

         // ตรวจสอบจำนวนรูปไม่เกิน 10
         const currentCount = await this.imageService.getImageCount(asset_no);
         if (currentCount >= 10) {
            return this.sendError(res, 400, `Asset already has ${currentCount} images. Maximum 10 allowed.`);
         }

         // บันทึกลง database
         const savedImage = await this.imageService.saveImageFromResponse(asset_no, devServerResponse, userId);

         // Set เป็น primary ถ้าเป็นรูปแรก
         if (currentCount === 0) {
            await this.imageService.setPrimaryImage(asset_no, savedImage.id, userId);
            savedImage.is_primary = true;
         }

         return this.sendSuccess(res, 201, 'Image saved successfully', {
            id: savedImage.id,
            asset_no: savedImage.asset_no,
            file_url: savedImage.file_url,
            thumbnail_url: savedImage.file_thumbnail_url,
            original_name: savedImage.original_name,
            file_type: savedImage.file_type_external,
            is_primary: savedImage.is_primary,
            created_at: savedImage.created_at
         }, {
            asset_no,
            saved_by: userId,
            total_images: currentCount + 1
         });

      } catch (error) {
         console.error('Save image response error:', error);
         return this.sendError(res, 500, error.message || 'Failed to save image');
      }
   }

   /**
    * GET /assets/:asset_no/images
    * ดึงรายการรูปของ asset (ให้ Frontend ไป get รูปเอง)
    */
   async getAssetImages(req, res) {
      try {
         const { asset_no } = req.params;

         const images = await this.imageService.getAssetImages(asset_no);

         return this.sendSuccess(res, 200, 'Asset images retrieved successfully', {
            images: images.map(image => ({
               id: image.id,
               asset_no: image.asset_no,
               file_url: image.file_url,           // Frontend ใช้ URL นี้เรียกรูปโดยตรง
               thumbnail_url: image.file_thumbnail_url, // Frontend ใช้ URL นี้เรียก thumbnail
               original_name: image.original_name,
               file_type: image.file_type_external,
               file_size: image.file_size,
               is_primary: image.is_primary,
               alt_text: image.alt_text,
               description: image.description,
               category: image.category,
               created_at: image.created_at,
               created_by: image.created_by
            })),
            total: images.length,
            primary_image: images.find(img => img.is_primary) || null
         }, {
            asset_no,
            note: 'Frontend should use file_url and thumbnail_url directly'
         });

      } catch (error) {
         console.error('Get asset images error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return this.sendError(res, statusCode, error.message || 'Failed to get asset images');
      }
   }

   /**
    * DELETE /assets/:asset_no/images/:imageId
    * ลบรูปจาก database (Frontend ต้องลบจาก dev server เอง)
    */
   async deleteImage(req, res) {
      try {
         const { asset_no, imageId } = req.params;
         const { userId } = req.user;

         const deleted = await this.imageService.deleteImageRecord(asset_no, imageId, userId);

         if (!deleted) {
            return this.sendError(res, 404, 'Image not found');
         }

         return this.sendSuccess(res, 200, 'Image record deleted successfully from database', {
            deleted_image_id: parseInt(imageId),
            remaining_images: await this.imageService.getImageCount(asset_no),
            note: 'Please delete the actual file from dev server manually'
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

         return this.sendSuccess(res, 200, 'Image metadata updated successfully', {
            id: updatedImage.id,
            asset_no: updatedImage.asset_no,
            alt_text: updatedImage.alt_text,
            description: updatedImage.description,
            category: updatedImage.category,
            file_url: updatedImage.file_url,
            thumbnail_url: updatedImage.file_thumbnail_url,
            updated_at: updatedImage.updated_at
         }, {
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
    * Set image as primary
    */
   async setPrimaryImage(req, res) {
      try {
         const { asset_no, imageId } = req.params;
         const { userId } = req.user;

         const result = await this.imageService.setPrimaryImage(asset_no, imageId, userId);

         if (!result.success) {
            return this.sendError(res, 404, 'Image not found');
         }

         return this.sendSuccess(res, 200, 'Primary image set successfully', {
            primary_image_id: parseInt(imageId),
            asset_no,
            previous_primary_id: result.previousPrimary
         }, {
            updated_by: userId
         });

      } catch (error) {
         console.error('Set primary image error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return this.sendError(res, statusCode, error.message || 'Failed to set primary image');
      }
   }

   /**
    * GET /assets/:asset_no/images/stats
    * Get image statistics
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
    * 🔧 HELPER METHODS
    */

   /**
    * Send success response
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
}

module.exports = ImageController;