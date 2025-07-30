// Path: backend/src/features/image/image.model.js
const prisma = require('../../core/database/prisma');

/**
 * 🗄️ IMAGE MODEL
 * Database operations สำหรับ image management
 */
class ImageModel {
   constructor() {
      this.prisma = prisma;
   }

   /**
    * ตรวจสอบว่า asset มีอยู่ในระบบหรือไม่
    * @param {string} assetNo - asset number
    * @returns {Promise<boolean>}
    */
   async checkAssetExists(assetNo) {
      try {
         const asset = await this.prisma.asset_master.findUnique({
            where: { asset_no: assetNo },
            select: { asset_no: true }
         });

         return !!asset;
      } catch (error) {
         console.error('Check asset exists database error:', error);
         throw new Error(`Database error checking asset: ${error.message}`);
      }
   }

   /**
    * นับจำนวนรูปของ asset
    * @param {string} assetNo - asset number
    * @returns {Promise<number>}
    */
   async getImageCount(assetNo) {
      try {
         const count = await this.prisma.asset_image.count({
            where: { asset_no: assetNo }
         });

         return count;
      } catch (error) {
         console.error('Get image count database error:', error);
         throw new Error(`Database error getting image count: ${error.message}`);
      }
   }

   /**
    * สร้าง record ใหม่ใน asset_image table
    * @param {Object} imageData - image data
    * @returns {Promise<Object>}
    */
   async createImage(imageData) {
      try {
         const image = await this.prisma.asset_image.create({
            data: {
               asset_no: imageData.asset_no,
               file_path: imageData.file_path,
               file_name: imageData.file_name,
               file_type: imageData.file_type,
               file_size: imageData.file_size,
               original_name: imageData.original_name,
               thumbnail_path: imageData.thumbnail_path,
               thumbnail_size: imageData.thumbnail_size,
               width: imageData.width,
               height: imageData.height,
               alt_text: imageData.alt_text || null,
               description: imageData.description || null,
               category: imageData.category || null,
               is_primary: imageData.is_primary || false,
               created_by: imageData.created_by,
               created_at: new Date()
            }
         });

         return image;
      } catch (error) {
         console.error('Create image database error:', error);
         throw new Error(`Database error creating image: ${error.message}`);
      }
   }

   /**
    * ดึงรูปทั้งหมดของ asset
    * @param {string} assetNo - asset number
    * @returns {Promise<Array>}
    */
   async getAssetImages(assetNo) {
      try {
         const images = await this.prisma.asset_image.findMany({
            where: { asset_no: assetNo },
            orderBy: [
               { is_primary: 'desc' }, // Primary image first
               { created_at: 'asc' }   // Then by creation time
            ]
         });

         return images;
      } catch (error) {
         console.error('Get asset images database error:', error);
         throw new Error(`Database error getting asset images: ${error.message}`);
      }
   }

   /**
    * ดึงรูปตาม ID
    * @param {number} imageId - image ID
    * @returns {Promise<Object|null>}
    */
   async getImageById(imageId) {
      try {
         const image = await this.prisma.asset_image.findUnique({
            where: { id: parseInt(imageId) }
         });

         return image;
      } catch (error) {
         console.error('Get image by ID database error:', error);
         throw new Error(`Database error getting image: ${error.message}`);
      }
   }

   /**
    * ดึง primary image ของ asset
    * @param {string} assetNo - asset number
    * @returns {Promise<Object|null>}
    */
   async getPrimaryImage(assetNo) {
      try {
         const primaryImage = await this.prisma.asset_image.findFirst({
            where: {
               asset_no: assetNo,
               is_primary: true
            }
         });

         return primaryImage;
      } catch (error) {
         console.error('Get primary image database error:', error);
         throw new Error(`Database error getting primary image: ${error.message}`);
      }
   }

   /**
    * Update image record
    * @param {number} imageId - image ID
    * @param {Object} updateData - data to update
    * @returns {Promise<Object>}
    */
   async updateImage(imageId, updateData) {
      try {
         const updatedImage = await this.prisma.asset_image.update({
            where: { id: parseInt(imageId) },
            data: {
               ...updateData,
               updated_at: new Date()
            }
         });

         return updatedImage;
      } catch (error) {
         console.error('Update image database error:', error);

         if (error.code === 'P2025') {
            throw new Error('Image not found');
         }

         throw new Error(`Database error updating image: ${error.message}`);
      }
   }

   /**
    * ลบ image record
    * @param {number} imageId - image ID
    * @returns {Promise<boolean>}
    */
   async deleteImage(imageId) {
      try {
         await this.prisma.asset_image.delete({
            where: { id: parseInt(imageId) }
         });

         return true;
      } catch (error) {
         console.error('Delete image database error:', error);

         if (error.code === 'P2025') {
            return false; // Record not found
         }

         throw new Error(`Database error deleting image: ${error.message}`);
      }
   }

   /**
    * Set รูปเป็น primary และ unset รูปอื่น
    * @param {string} assetNo - asset number
    * @param {number} imageId - image ID to set as primary
    * @returns {Promise<boolean>}
    */
   async setPrimaryImage(assetNo, imageId) {
      try {
         // ใช้ transaction เพื่อให้แน่ใจว่า operation atomic
         const result = await this.prisma.$transaction(async (tx) => {
            // Unset primary ของรูปอื่นๆ ใน asset เดียวกัน
            await tx.asset_image.updateMany({
               where: {
                  asset_no: assetNo,
                  is_primary: true
               },
               data: { is_primary: false }
            });

            // Set รูปที่เลือกเป็น primary
            const updatedImage = await tx.asset_image.update({
               where: {
                  id: parseInt(imageId),
                  asset_no: assetNo // Double check ว่าเป็นรูปของ asset นี้
               },
               data: {
                  is_primary: true,
                  updated_at: new Date()
               }
            });

            return updatedImage;
         });

         return !!result;
      } catch (error) {
         console.error('Set primary image database error:', error);

         if (error.code === 'P2025') {
            throw new Error('Image not found');
         }

         throw new Error(`Database error setting primary image: ${error.message}`);
      }
   }

   /**
    * ดึงสถิติของ images ของ asset
    * @param {string} assetNo - asset number
    * @returns {Promise<Object>}
    */
   async getImageStats(assetNo) {
      try {
         const stats = await this.prisma.asset_image.aggregate({
            where: { asset_no: assetNo },
            _count: { id: true },
            _sum: { file_size: true },
            _avg: { file_size: true },
            _max: { file_size: true, created_at: true },
            _min: { file_size: true, created_at: true }
         });

         // ดึงข้อมูลเพิ่มเติม
         const [fileTypes, hasPrimary, largestImage, smallestImage] = await Promise.all([
            // Group by file type
            this.prisma.asset_image.groupBy({
               by: ['file_type'],
               where: { asset_no: assetNo },
               _count: { file_type: true }
            }),

            // Check if has primary
            this.prisma.asset_image.findFirst({
               where: { asset_no: assetNo, is_primary: true },
               select: { id: true }
            }),

            // Largest image
            this.prisma.asset_image.findFirst({
               where: { asset_no: assetNo },
               orderBy: { file_size: 'desc' },
               select: { id: true, file_name: true, file_size: true }
            }),

            // Smallest image
            this.prisma.asset_image.findFirst({
               where: { asset_no: assetNo },
               orderBy: { file_size: 'asc' },
               select: { id: true, file_name: true, file_size: true }
            })
         ]);

         return {
            total: stats._count.id || 0,
            totalSize: Number(stats._sum.file_size) || 0,
            averageSize: Math.round(Number(stats._avg.file_size) || 0),
            hasPrimary: !!hasPrimary,
            fileTypes: fileTypes.map(ft => ({
               type: ft.file_type,
               count: ft._count.file_type
            })),
            largestImage: largestImage ? {
               id: largestImage.id,
               name: largestImage.file_name,
               size: Number(largestImage.file_size)
            } : null,
            smallestImage: smallestImage ? {
               id: smallestImage.id,
               name: smallestImage.file_name,
               size: Number(smallestImage.file_size)
            } : null,
            newestImage: stats._max.created_at,
            oldestImage: stats._min.created_at
         };

      } catch (error) {
         console.error('Get image stats database error:', error);
         throw new Error(`Database error getting image statistics: ${error.message}`);
      }
   }

   /**
    * ดึง file paths ทั้งหมดในระบบ (สำหรับ cleanup)
    * @returns {Promise<Array>}
    */
   async getAllFilePaths() {
      try {
         const images = await this.prisma.asset_image.findMany({
            select: {
               id: true,
               file_path: true,
               thumbnail_path: true,
               file_name: true,
               asset_no: true
            }
         });

         return images;
      } catch (error) {
         console.error('Get all file paths database error:', error);
         throw new Error(`Database error getting file paths: ${error.message}`);
      }
   }

   /**
    * ดึง images หลายๆ assets พร้อมกัน (สำหรับ batch operations)
    * @param {Array} assetNos - array of asset numbers
    * @returns {Promise<Object>} grouped by asset_no
    */
   async getImagesForAssets(assetNos) {
      try {
         if (!Array.isArray(assetNos) || assetNos.length === 0) {
            return {};
         }

         const images = await this.prisma.asset_image.findMany({
            where: {
               asset_no: { in: assetNos }
            },
            orderBy: [
               { asset_no: 'asc' },
               { is_primary: 'desc' },
               { created_at: 'asc' }
            ]
         });

         // Group by asset_no
         const grouped = {};
         images.forEach(image => {
            if (!grouped[image.asset_no]) {
               grouped[image.asset_no] = [];
            }
            grouped[image.asset_no].push(image);
         });

         return grouped;
      } catch (error) {
         console.error('Get images for assets database error:', error);
         throw new Error(`Database error getting images for assets: ${error.message}`);
      }
   }

   /**
    * ค้นหา images ตาม criteria
    * @param {Object} criteria - search criteria
    * @returns {Promise<Array>}
    */
   async searchImages(criteria = {}) {
      try {
         const {
            asset_no,
            file_type,
            min_size,
            max_size,
            has_primary,
            created_after,
            created_before,
            limit = 50,
            offset = 0
         } = criteria;

         const where = {};

         if (asset_no) {
            where.asset_no = { contains: asset_no };
         }

         if (file_type) {
            where.file_type = Array.isArray(file_type)
               ? { in: file_type }
               : file_type;
         }

         if (min_size || max_size) {
            where.file_size = {};
            if (min_size) where.file_size.gte = min_size;
            if (max_size) where.file_size.lte = max_size;
         }

         if (has_primary !== undefined) {
            where.is_primary = has_primary;
         }

         if (created_after || created_before) {
            where.created_at = {};
            if (created_after) where.created_at.gte = new Date(created_after);
            if (created_before) where.created_at.lte = new Date(created_before);
         }

         const images = await this.prisma.asset_image.findMany({
            where,
            include: {
               asset_master: {
                  select: {
                     asset_no: true,
                     description: true,
                     plant_code: true,
                     location_code: true
                  }
               }
            },
            orderBy: { created_at: 'desc' },
            take: Math.min(limit, 100), // จำกัดไม่เกิน 100
            skip: offset
         });

         return images;
      } catch (error) {
         console.error('Search images database error:', error);
         throw new Error(`Database error searching images: ${error.message}`);
      }
   }

   /**
    * ดึงสถิติรวมของระบบ (admin function)
    * @returns {Promise<Object>}
    */
   async getSystemImageStats() {
      try {
         const [totalStats, assetStats, recentStats] = await Promise.all([
            // Overall statistics
            this.prisma.asset_image.aggregate({
               _count: { id: true },
               _sum: { file_size: true },
               _avg: { file_size: true }
            }),

            // Assets with images count
            this.prisma.asset_image.groupBy({
               by: ['asset_no'],
               _count: { asset_no: true }
            }),

            // Recent uploads (last 7 days)
            this.prisma.asset_image.count({
               where: {
                  created_at: {
                     gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
                  }
               }
            })
         ]);

         const fileTypeStats = await this.prisma.asset_image.groupBy({
            by: ['file_type'],
            _count: { file_type: true },
            _sum: { file_size: true }
         });

         return {
            total_images: totalStats._count.id || 0,
            total_size: Number(totalStats._sum.file_size) || 0,
            average_size: Math.round(Number(totalStats._avg.file_size) || 0),
            assets_with_images: assetStats.length,
            recent_uploads_7d: recentStats,
            file_types: fileTypeStats.map(ft => ({
               type: ft.file_type,
               count: ft._count.file_type,
               total_size: Number(ft._sum.file_size) || 0
            })),
            timestamp: new Date().toISOString()
         };

      } catch (error) {
         console.error('Get system image stats database error:', error);
         throw new Error(`Database error getting system statistics: ${error.message}`);
      }
   }

   /**
    * ลบ images ทั้งหมดของ asset (สำหรับเมื่อลบ asset)
    * @param {string} assetNo - asset number
    * @returns {Promise<number>} จำนวนรูปที่ลบ
    */
   async deleteAllAssetImages(assetNo) {
      try {
         const deleteResult = await this.prisma.asset_image.deleteMany({
            where: { asset_no: assetNo }
         });

         return deleteResult.count;
      } catch (error) {
         console.error('Delete all asset images database error:', error);
         throw new Error(`Database error deleting asset images: ${error.message}`);
      }
   }

   /**
    * Batch update images
    * @param {Array} updates - array of {id, data} objects
    * @returns {Promise<number>} จำนวนที่ update สำเร็จ
    */
   async batchUpdateImages(updates) {
      try {
         const results = await Promise.allSettled(
            updates.map(update =>
               this.prisma.asset_image.update({
                  where: { id: update.id },
                  data: {
                     ...update.data,
                     updated_at: new Date()
                  }
               })
            )
         );

         const successCount = results.filter(r => r.status === 'fulfilled').length;
         return successCount;

      } catch (error) {
         console.error('Batch update images database error:', error);
         throw new Error(`Database error batch updating images: ${error.message}`);
      }
   }

   /**
    * Raw query execution สำหรับ complex operations
    * @param {string} query - SQL query
    * @param {Array} params - query parameters
    * @returns {Promise<Array>}
    */
   async executeQuery(query, params = []) {
      try {
         const result = await this.prisma.$queryRawUnsafe(query, ...params);

         // Convert BigInt to Number for JSON serialization
         return JSON.parse(JSON.stringify(result, (key, value) =>
            typeof value === 'bigint' ? Number(value) : value
         ));
      } catch (error) {
         console.error('Execute query database error:', error);
         throw new Error(`Database query error: ${error.message}`);
      }
   }
}

module.exports = ImageModel;