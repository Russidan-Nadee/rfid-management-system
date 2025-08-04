// Path: backend/src/features/image/image.service.js
const prisma = require('../../core/database/prisma');
const ExternalStorageService = require('./external-storage.service');

class ImageService {
   constructor() {
      this.externalStorage = new ExternalStorageService();
   }

   async uploadImage(assetNo, file, userId) {
      try {
         // Upload ไปยัง dev server
         const uploadResult = await this.externalStorage.uploadFile(file);

         // บันทึกลง database
         const savedImage = await prisma.asset_image.create({
            data: {
               asset_no: assetNo,
               file_url: uploadResult.file_url,
               file_thumbnail_url: uploadResult.file_thumbnail_url,
               external_file_path: uploadResult.external_file_path,
               external_thumbnail_path: uploadResult.external_thumbnail_path,
               file_type_external: uploadResult.file_type_external,
               file_name: file.originalname, // ← แก้จาก file.filename เป็น file.originalname
               original_name: file.originalname,
               file_size: file.size,
               created_by: userId
            }
         });

         return savedImage;
      } catch (error) {
         console.error('Upload image error:', error);
         throw new Error(`Failed to upload image: ${error.message}`);
      }
   }

   async getAssetImages(assetNo) {
      try {
         const images = await prisma.asset_image.findMany({
            where: { asset_no: assetNo },
            orderBy: { created_at: 'desc' }
         });

         return images.map(image => ({
            id: image.id,
            asset_no: image.asset_no,
            file_name: image.file_name,
            original_name: image.original_name,
            file_size: Number(image.file_size),
            file_type: image.file_type_external,
            image_url: image.file_url,
            thumbnail_url: image.file_thumbnail_url,
            created_at: image.created_at
         }));
      } catch (error) {
         console.error('Get asset images error:', error);
         throw new Error(`Failed to get images: ${error.message}`);
      }
   }

   async getImageById(imageId) {
      try {
         const image = await prisma.asset_image.findUnique({
            where: { id: parseInt(imageId) }
         });

         if (!image) {
            throw new Error('Image not found');
         }

         return image;
      } catch (error) {
         console.error('Get image by ID error:', error);
         throw error;
      }
   }
}

module.exports = ImageService;