// Path: backend/src/features/image/image.service.js
const ImageModel = require('./image.model');
const ExternalStorageService = require('./external-storage.service');

/**
 * 🖼️ IMAGE SERVICE
 * Business logic สำหรับ image management ด้วย external storage
 */
class ImageService {
   constructor() {
      this.imageModel = new ImageModel();
      this.externalStorage = new ExternalStorageService();
   }

   /**
    * ตรวจสอบว่า asset มีอยู่จริงหรือไม่
    * @param {string} assetNo - asset number
    * @returns {Promise<boolean>}
    */
   async checkAssetExists(assetNo) {
      try {
         return await this.imageModel.checkAssetExists(assetNo);
      } catch (error) {
         console.error('Check asset exists error:', error);
         throw new Error(`Failed to verify asset: ${error.message}`);
      }
   }

   /**
    * นับจำนวนรูปปัจจุบันของ asset
    * @param {string} assetNo - asset number
    * @returns {Promise<number>}
    */
   async getImageCount(assetNo) {
      try {
         return await this.imageModel.getImageCount(assetNo);
      } catch (error) {
         console.error('Get image count error:', error);
         throw new Error(`Failed to get image count: ${error.message}`);
      }
   }

   /**
    * Upload และ process รูปใหม่ผ่าน external storage
    * @param {string} assetNo - asset number
    * @param {Array} files - uploaded files from multer
    * @param {string} userId - user who uploaded
    * @returns {Promise<Object>} processed images data
    */
   async uploadImages(assetNo, files, userId) {
      const processedImages = [];
      const errors = [];

      try {
         // ตรวจสอบ asset exists
         const assetExists = await this.checkAssetExists(assetNo);
         if (!assetExists) {
            throw new Error('Asset not found');
         }

         // ตรวจสอบ current image count
         const currentCount = await this.getImageCount(assetNo);
         if (currentCount + files.length > 10) {
            throw new Error(`Cannot upload ${files.length} files. Asset already has ${currentCount} images. Maximum 10 allowed.`);
         }

         // Process แต่ละไฟล์
         for (const file of files) {
            try {
               const imageData = await this.processUploadedImage(assetNo, file, userId);
               processedImages.push(imageData);
            } catch (error) {
               console.error(`Error processing file ${file.originalname}:`, error);
               errors.push({
                  filename: file.originalname,
                  error: error.message
               });

               // Cleanup failed file
               await this.externalStorage.cleanupTempFile(file.path);
            }
         }

         // ถ้าไม่มีรูปใดสำเร็จเลย
         if (processedImages.length === 0) {
            throw new Error('Failed to process any images');
         }

         // Set primary image ถ้าเป็นรูปแรกของ asset
         if (currentCount === 0 && processedImages.length > 0) {
            await this.imageModel.setPrimaryImage(assetNo, processedImages[0].id);
            processedImages[0].is_primary = true;
         }

         return {
            success: processedImages,
            errors: errors.length > 0 ? errors : undefined,
            total_processed: processedImages.length,
            total_failed: errors.length
         };

      } catch (error) {
         // Cleanup ไฟล์ทั้งหมดถ้า error
         for (const file of files) {
            await this.externalStorage.cleanupTempFile(file.path);
         }

         console.error('Upload images error:', error);
         throw error;
      }
   }

   /**
    * Process ไฟล์รูปที่ upload มาผ่าน external storage
    * @param {string} assetNo - asset number
    * @param {Object} file - multer file object
    * @param {string} userId - user ID
    * @returns {Promise<Object>} processed image data
    */
   async processUploadedImage(assetNo, file, userId) {
      try {
         // Upload ไปยัง external storage
         const uploadResult = await this.externalStorage.uploadFile(file);

         if (!uploadResult.success) {
            throw new Error('External storage upload failed');
         }

         // บันทึกลง database
         const imageData = {
            asset_no: assetNo,
            file_url: uploadResult.file_url,
            file_thumbnail_url: uploadResult.file_thumbnail_url,
            external_file_path: uploadResult.external_file_path,
            external_thumbnail_path: uploadResult.external_thumbnail_path,
            file_type_external: uploadResult.file_type_external,
            file_name: file.filename,
            original_name: file.originalname,
            file_size: file.size,
            width: null, // Dev server ไม่ได้ส่งข้อมูลนี้มา
            height: null, // Dev server ไม่ได้ส่งข้อมูลนี้มา
            created_by: userId
         };

         const savedImage = await this.imageModel.createImage(imageData);

         // Cleanup temporary file
         await this.externalStorage.cleanupTempFile(file.path);

         return {
            id: savedImage.id,
            asset_no: assetNo,
            file_name: file.filename,
            original_name: file.originalname,
            file_size: file.size,
            file_type: uploadResult.file_type_external,
            width: null,
            height: null,
            image_url: uploadResult.file_url,
            thumbnail_url: uploadResult.file_thumbnail_url,
            created_at: savedImage.created_at,
            is_primary: false
         };

      } catch (error) {
         // Cleanup temporary file on error
         await this.externalStorage.cleanupTempFile(file.path);
         console.error('Process uploaded image error:', error);
         throw new Error(`Failed to process image: ${error.message}`);
      }
   }

   /**
    * ดึงรูปทั้งหมดของ asset
    * @param {string} assetNo - asset number
    * @param {Object} options - options
    * @returns {Promise<Array>} images data
    */
   async getAssetImages(assetNo, options = {}) {
      try {
         const { includeThumbnails = true } = options;

         const images = await this.imageModel.getAssetImages(assetNo);

         return images.map(image => ({
            id: image.id,
            asset_no: image.asset_no,
            file_name: image.file_name,
            original_name: image.original_name,
            file_size: image.file_size,
            file_type: image.file_type_external,
            width: image.width,
            height: image.height,
            is_primary: image.is_primary,
            alt_text: image.alt_text,
            description: image.description,
            category: image.category,
            // Return external URLs directly
            image_url: image.file_url,
            thumbnail_url: includeThumbnails ? image.file_thumbnail_url : null,
            created_at: image.created_at,
            created_by: image.created_by
         }));

      } catch (error) {
         console.error('Get asset images error:', error);
         throw new Error(`Failed to get asset images: ${error.message}`);
      }
   }

   /**
    * ลบรูปจาก external storage และ database
    * @param {string} assetNo - asset number
    * @param {number} imageId - image ID
    * @param {string} userId - user ID
    * @returns {Promise<boolean>} success
    */
   async deleteImage(assetNo, imageId, userId) {
      try {
         const image = await this.imageModel.getImageById(imageId);
         if (!image || image.asset_no !== assetNo) {
            throw new Error('Image not found');
         }

         // ลบจาก external storage
         if (image.file_url) {
            await this.externalStorage.deleteFile(image.file_url);
         }

         // ลบจาก database
         const deleted = await this.imageModel.deleteImage(imageId);

         // ถ้าลบรูป primary ให้ set รูปอื่นเป็น primary
         if (deleted && image.is_primary) {
            await this.autoSetPrimaryImage(assetNo);
         }

         return deleted;

      } catch (error) {
         console.error('Delete image error:', error);
         throw error;
      }
   }

   /**
    * Replace รูปเดิมด้วยรูปใหม่
    * @param {string} assetNo - asset number
    * @param {number} imageId - image ID
    * @param {Object} newFile - new file from multer
    * @param {string} userId - user ID
    * @returns {Promise<Object>} updated image data
    */
   async replaceImage(assetNo, imageId, newFile, userId) {
      try {
         const existingImage = await this.imageModel.getImageById(imageId);
         if (!existingImage || existingImage.asset_no !== assetNo) {
            throw new Error('Image not found');
         }

         // Upload รูปใหม่ไปยัง external storage
         const uploadResult = await this.externalStorage.uploadFile(newFile);

         if (!uploadResult.success) {
            throw new Error('External storage upload failed');
         }

         // ลบรูปเก่าจาก external storage
         if (existingImage.file_url) {
            await this.externalStorage.deleteFile(existingImage.file_url);
         }

         // Update database record
         const updatedData = {
            file_url: uploadResult.file_url,
            file_thumbnail_url: uploadResult.file_thumbnail_url,
            external_file_path: uploadResult.external_file_path,
            external_thumbnail_path: uploadResult.external_thumbnail_path,
            file_type_external: uploadResult.file_type_external,
            file_name: newFile.filename,
            original_name: newFile.originalname,
            file_size: newFile.size,
            width: null,
            height: null,
            updated_by: userId
         };

         await this.imageModel.updateImage(imageId, updatedData);

         // Cleanup temporary file
         await this.externalStorage.cleanupTempFile(newFile.path);

         // Return updated image data
         return await this.imageModel.getImageById(imageId);

      } catch (error) {
         // Cleanup temporary file on error
         await this.externalStorage.cleanupTempFile(newFile.path);
         console.error('Replace image error:', error);
         throw error;
      }
   }

   /**
    * Update image metadata
    * @param {string} assetNo - asset number
    * @param {number} imageId - image ID
    * @param {Object} metadata - metadata to update
    * @returns {Promise<Object>} updated image
    */
   async updateImageMetadata(assetNo, imageId, metadata) {
      try {
         const image = await this.imageModel.getImageById(imageId);
         if (!image || image.asset_no !== assetNo) {
            throw new Error('Image not found');
         }

         const updateData = {
            alt_text: metadata.alt_text,
            description: metadata.description,
            category: metadata.category,
            updated_by: metadata.updated_by
         };

         await this.imageModel.updateImage(imageId, updateData);
         return await this.imageModel.getImageById(imageId);

      } catch (error) {
         console.error('Update image metadata error:', error);
         throw error;
      }
   }

   /**
    * Set รูปเป็น primary
    * @param {string} assetNo - asset number
    * @param {number} imageId - image ID
    * @param {string} userId - user ID
    * @returns {Promise<Object>} result
    */
   async setPrimaryImage(assetNo, imageId, userId) {
      try {
         const image = await this.imageModel.getImageById(imageId);
         if (!image || image.asset_no !== assetNo) {
            throw new Error('Image not found');
         }

         // หา primary image ปัจจุบัน
         const currentPrimary = await this.imageModel.getPrimaryImage(assetNo);

         // Update primary status
         const result = await this.imageModel.setPrimaryImage(assetNo, imageId);

         return {
            success: result,
            previousPrimary: currentPrimary?.id || null,
            newPrimary: imageId
         };

      } catch (error) {
         console.error('Set primary image error:', error);
         throw error;
      }
   }

   /**
    * ดึงสถิติรูปของ asset
    * @param {string} assetNo - asset number
    * @returns {Promise<Object>} statistics
    */
   async getImageStats(assetNo) {
      try {
         const stats = await this.imageModel.getImageStats(assetNo);

         return {
            total_images: stats.total || 0,
            total_size: stats.totalSize || 0,
            total_size_mb: Math.round((stats.totalSize || 0) / 1024 / 1024 * 100) / 100,
            has_primary: stats.hasPrimary || false,
            file_types: stats.fileTypes || [],
            average_size: stats.averageSize || 0,
            largest_image: stats.largestImage || null,
            smallest_image: stats.smallestImage || null,
            newest_image: stats.newestImage || null,
            oldest_image: stats.oldestImage || null
         };

      } catch (error) {
         console.error('Get image stats error:', error);
         throw error;
      }
   }

   /**
    * Search images (admin function)
    * @param {Object} criteria - search criteria
    * @returns {Promise<Array>} search results
    */
   async searchImages(criteria = {}) {
      try {
         const images = await this.imageModel.searchImages(criteria);

         return images.map(image => ({
            id: image.id,
            asset_no: image.asset_no,
            file_name: image.file_name,
            original_name: image.original_name,
            file_size: image.file_size,
            file_type: image.file_type_external,
            is_primary: image.is_primary,
            image_url: image.file_url,
            thumbnail_url: image.file_thumbnail_url,
            created_at: image.created_at,
            asset_info: image.asset_master ? {
               description: image.asset_master.description,
               plant_code: image.asset_master.plant_code,
               location_code: image.asset_master.location_code
            } : null
         }));

      } catch (error) {
         console.error('Search images error:', error);
         throw error;
      }
   }

   /**
    * Get system image statistics (admin function)
    * @returns {Promise<Object>} system statistics
    */
   async getSystemImageStats() {
      try {
         return await this.imageModel.getSystemImageStats();
      } catch (error) {
         console.error('Get system image stats error:', error);
         throw error;
      }
   }

   /**
    * 🔧 HELPER METHODS
    */

   /**
    * หา primary image อัตโนมัติเมื่อรูป primary ถูกลบ
    */
   async autoSetPrimaryImage(assetNo) {
      try {
         const images = await this.imageModel.getAssetImages(assetNo);
         if (images.length > 0) {
            // Set รูปแรกเป็น primary
            await this.imageModel.setPrimaryImage(assetNo, images[0].id);
         }
      } catch (error) {
         console.error('Auto set primary image error:', error);
      }
   }

   /**
    * Test external storage connection
    * @returns {Promise<boolean>} connection status
    */
   async testExternalStorage() {
      try {
         return await this.externalStorage.testConnection();
      } catch (error) {
         console.error('Test external storage error:', error);
         return false;
      }
   }

   /**
    * Get external storage info
    * @returns {Object} storage configuration
    */
   getExternalStorageInfo() {
      return this.externalStorage.getServerInfo();
   }
}

module.exports = ImageService;