// Path: backend/src/features/image/image.service.js
const ImageModel = require('./image.model');
const ImageUtils = require('./image.utils');
const sharp = require('sharp');
const fs = require('fs').promises;
const path = require('path');

/**
 * 🖼️ IMAGE SERVICE
 * Business logic สำหรับ image management
 */
class ImageService {
   constructor() {
      this.imageModel = new ImageModel();
      this.uploadsPath = path.join(process.cwd(), 'uploads', 'assets');
      this.thumbsPath = path.join(this.uploadsPath, 'thumbs');
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
    * Upload และ process รูปใหม่
    * @param {string} assetNo - asset number
    * @param {Array} files - uploaded files from multer
    * @param {string} userId - user who uploaded
    * @returns {Promise<Array>} processed images data
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
               await this.cleanupFile(file.path);
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
            await this.cleanupFile(file.path);
         }

         console.error('Upload images error:', error);
         throw error;
      }
   }

   /**
    * Process ไฟล์รูปที่ upload มา
    * @param {string} assetNo - asset number
    * @param {Object} file - multer file object
    * @param {string} userId - user ID
    * @returns {Promise<Object>} processed image data
    */
   async processUploadedImage(assetNo, file, userId) {
      try {
         // สร้าง thumbnail
         const thumbnailData = await this.createThumbnail(file.path, file.filename);

         // Get image metadata
         const metadata = await this.getImageMetadata(file.path);

         // บันทึกลง database
         const imageData = {
            asset_no: assetNo,
            file_path: file.path,
            file_name: file.filename,
            file_type: file.mimetype,
            file_size: file.size,
            original_name: file.originalname,
            thumbnail_path: thumbnailData.path,
            thumbnail_size: thumbnailData.size,
            width: metadata.width,
            height: metadata.height,
            created_by: userId
         };

         const savedImage = await this.imageModel.createImage(imageData);

         return {
            id: savedImage.id,
            asset_no: assetNo,
            file_name: file.filename,
            original_name: file.originalname,
            file_size: file.size,
            file_type: file.mimetype,
            width: metadata.width,
            height: metadata.height,
            thumbnail_url: `/images/${savedImage.id}?size=thumb`,
            image_url: `/images/${savedImage.id}`,
            created_at: savedImage.created_at,
            is_primary: false
         };

      } catch (error) {
         console.error('Process uploaded image error:', error);
         throw new Error(`Failed to process image: ${error.message}`);
      }
   }

   /**
    * สร้าง thumbnail จากรูปต้นฉบับ
    * @param {string} originalPath - path ของรูปต้นฉบับ
    * @param {string} originalFilename - ชื่อไฟล์ต้นฉบับ
    * @returns {Promise<Object>} thumbnail data
    */
   async createThumbnail(originalPath, originalFilename) {
      try {
         // สร้าง thumbs directory ถ้ายังไม่มี
         await this.ensureDirectory(this.thumbsPath);

         const thumbnailFilename = `thumb_${originalFilename}`;
         const thumbnailPath = path.join(this.thumbsPath, thumbnailFilename);

         // สร้าง thumbnail ขนาด 300x300 (maintain aspect ratio)
         await sharp(originalPath)
            .resize(300, 300, {
               fit: sharp.fit.inside,
               withoutEnlargement: true
            })
            .jpeg({ quality: 85 })
            .toFile(thumbnailPath);

         // Get thumbnail file size
         const stats = await fs.stat(thumbnailPath);

         return {
            path: thumbnailPath,
            filename: thumbnailFilename,
            size: stats.size
         };

      } catch (error) {
         console.error('Create thumbnail error:', error);
         throw new Error(`Failed to create thumbnail: ${error.message}`);
      }
   }

   /**
    * ดึง metadata ของรูป
    * @param {string} imagePath - path ของรูป
    * @returns {Promise<Object>} image metadata
    */
   async getImageMetadata(imagePath) {
      try {
         const metadata = await sharp(imagePath).metadata();

         return {
            width: metadata.width,
            height: metadata.height,
            format: metadata.format,
            channels: metadata.channels,
            density: metadata.density
         };

      } catch (error) {
         console.error('Get image metadata error:', error);
         return {
            width: null,
            height: null,
            format: null,
            channels: null,
            density: null
         };
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
            file_type: image.file_type,
            width: image.width,
            height: image.height,
            is_primary: image.is_primary,
            alt_text: image.alt_text,
            description: image.description,
            category: image.category,
            image_url: `/images/${image.id}`,
            thumbnail_url: includeThumbnails ? `/images/${image.id}?size=thumb` : null,
            created_at: image.created_at,
            created_by: image.created_by
         }));

      } catch (error) {
         console.error('Get asset images error:', error);
         throw new Error(`Failed to get asset images: ${error.message}`);
      }
   }

   /**
    * Serve รูปตาม ID
    * @param {number} imageId - image ID
    * @param {Object} options - serving options
    * @returns {Promise<Object>} image file data
    */
   async serveImage(imageId, options = {}) {
      try {
         const { size = 'original', quality = 'high' } = options;

         const image = await this.imageModel.getImageById(imageId);
         if (!image) {
            throw new Error('Image not found');
         }

         let filePath;
         let mimeType = image.file_type;

         if (size === 'thumb' || size === 'thumbnail') {
            filePath = image.thumbnail_path;

            // ถ้าไม่มี thumbnail ให้สร้างใหม่
            if (!filePath || !(await this.fileExists(filePath))) {
               const thumbnailData = await this.createThumbnail(image.file_path, image.file_name);
               await this.imageModel.updateImage(imageId, { thumbnail_path: thumbnailData.path });
               filePath = thumbnailData.path;
            }
         } else {
            filePath = image.file_path;
         }

         // ตรวจสอบว่าไฟล์มีอยู่จริง
         if (!(await this.fileExists(filePath))) {
            throw new Error('Image file not found on disk');
         }

         const stats = await fs.stat(filePath);

         return {
            filePath,
            mimeType,
            size: stats.size,
            lastModified: stats.mtime.toUTCString(),
            etag: `"${stats.mtime.getTime()}-${stats.size}"`,
            filename: image.file_name
         };

      } catch (error) {
         console.error('Serve image error:', error);
         throw error;
      }
   }

   /**
    * ลบรูป
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

         // ลบไฟล์จาก disk
         await this.cleanupFile(image.file_path);
         if (image.thumbnail_path) {
            await this.cleanupFile(image.thumbnail_path);
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

         // Process รูปใหม่
         const newImageData = await this.processUploadedImage(assetNo, newFile, userId);

         // ลบไฟล์เก่า
         await this.cleanupFile(existingImage.file_path);
         if (existingImage.thumbnail_path) {
            await this.cleanupFile(existingImage.thumbnail_path);
         }

         // Update database record
         const updatedData = {
            file_path: newFile.path,
            file_name: newFile.filename,
            file_type: newFile.mimetype,
            file_size: newFile.size,
            original_name: newFile.originalname,
            thumbnail_path: newImageData.thumbnail_path,
            width: newImageData.width,
            height: newImageData.height,
            updated_at: new Date(),
            updated_by: userId
         };

         await this.imageModel.updateImage(imageId, updatedData);

         // Return updated image data
         return await this.imageModel.getImageById(imageId);

      } catch (error) {
         // Cleanup new file on error
         await this.cleanupFile(newFile.path);
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
            updated_at: new Date(),
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
    * Cleanup orphaned files (admin function)
    * @param {boolean} dryRun - preview mode
    * @returns {Promise<Object>} cleanup result
    */
   async cleanupOrphanedFiles(dryRun = true) {
      try {
         console.log(`Starting orphaned files cleanup (dry_run: ${dryRun})`);

         const orphanedFiles = await this.findOrphanedFiles();

         if (dryRun) {
            return {
               dry_run: true,
               orphaned_files: orphanedFiles,
               total_orphaned: orphanedFiles.length,
               total_size: orphanedFiles.reduce((sum, file) => sum + file.size, 0)
            };
         }

         // Actually delete files
         let deletedCount = 0;
         let deletedSize = 0;
         const errors = [];

         for (const file of orphanedFiles) {
            try {
               await fs.unlink(file.path);
               deletedCount++;
               deletedSize += file.size;
               console.log(`🗑️ Deleted orphaned file: ${file.path}`);
            } catch (error) {
               errors.push({ file: file.path, error: error.message });
               console.error(`Failed to delete ${file.path}:`, error);
            }
         }

         return {
            dry_run: false,
            deleted_files: deletedCount,
            deleted_size: deletedSize,
            total_scanned: orphanedFiles.length,
            errors: errors.length > 0 ? errors : undefined
         };

      } catch (error) {
         console.error('Cleanup orphaned files error:', error);
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
    * หาไฟล์ที่ orphaned (มีในระบบแต่ไม่มีใน database)
    */
   async findOrphanedFiles() {
      try {
         const filesInDb = await this.imageModel.getAllFilePaths();
         const dbPaths = new Set([
            ...filesInDb.map(f => f.file_path),
            ...filesInDb.map(f => f.thumbnail_path).filter(Boolean)
         ]);

         const filesOnDisk = await this.scanDirectory(this.uploadsPath);
         const orphaned = [];

         for (const file of filesOnDisk) {
            if (!dbPaths.has(file.path)) {
               orphaned.push(file);
            }
         }

         return orphaned;

      } catch (error) {
         console.error('Find orphaned files error:', error);
         return [];
      }
   }

   /**
    * Scan directory สำหรับไฟล์ทั้งหมด
    */
   async scanDirectory(dirPath) {
      const files = [];

      try {
         const items = await fs.readdir(dirPath, { withFileTypes: true });

         for (const item of items) {
            const fullPath = path.join(dirPath, item.name);

            if (item.isDirectory()) {
               const subFiles = await this.scanDirectory(fullPath);
               files.push(...subFiles);
            } else if (item.isFile()) {
               const stats = await fs.stat(fullPath);
               files.push({
                  path: fullPath,
                  name: item.name,
                  size: stats.size,
                  modified: stats.mtime
               });
            }
         }
      } catch (error) {
         console.error(`Error scanning directory ${dirPath}:`, error);
      }

      return files;
   }

   /**
    * ตรวจสอบว่าไฟล์มีอยู่
    */
   async fileExists(filePath) {
      try {
         await fs.access(filePath);
         return true;
      } catch {
         return false;
      }
   }

   /**
    * สร้าง directory ถ้ายังไม่มี
    */
   async ensureDirectory(dirPath) {
      try {
         await fs.mkdir(dirPath, { recursive: true });
      } catch (error) {
         if (error.code !== 'EEXIST') {
            throw error;
         }
      }
   }

   /**
    * ลบไฟล์
    */
   async cleanupFile(filePath) {
      try {
         if (await this.fileExists(filePath)) {
            await fs.unlink(filePath);
            console.log(`🗑️ Cleaned up file: ${filePath}`);
         }
      } catch (error) {
         console.error(`Failed to cleanup file ${filePath}:`, error);
      }
   }
}

module.exports = ImageService;