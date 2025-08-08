// Path: backend/src/features/image/image.controller.js
const ImageService = require('./image.service');
const axios = require('axios');

class ImageController {
   constructor() {
      this.imageService = new ImageService();
   }

   // POST /assets/:asset_no/images
   async uploadImage(req, res) {
      try {
         const { asset_no } = req.params;
         const { userId } = req.user;
         const file = req.file;

         if (!file) {
            return res.status(400).json({
               success: false,
               message: 'No file uploaded'
            });
         }

         const savedImage = await this.imageService.uploadImage(asset_no, file, userId);

         res.status(201).json({
            success: true,
            message: 'Image uploaded successfully',
            data: {
               id: savedImage.id,
               asset_no: savedImage.asset_no,
               file_name: savedImage.file_name,
               original_name: savedImage.original_name,
               file_size: Number(savedImage.file_size),
               file_type: savedImage.file_type_external,
               created_at: savedImage.created_at
            }
         });
      } catch (error) {
         console.error('Upload controller error:', error);
         res.status(500).json({
            success: false,
            message: error.message
         });
      }
   }

   // GET /assets/:asset_no/images
   async getAssetImages(req, res) {
      try {
         const { asset_no } = req.params;
         const images = await this.imageService.getAssetImages(asset_no);

         res.json({
            success: true,
            data: { images },
            total: images.length
         });
      } catch (error) {
         console.error('Get images controller error:', error);
         res.status(500).json({
            success: false,
            message: error.message
         });
      }
   }

   // GET /images/:imageId
   async streamImage(req, res) {
      try {
         const { imageId } = req.params;
         const { size } = req.query; // 'thumb' or undefined for original

         const image = await this.imageService.getImageById(imageId);
         const imageUrl = size === 'thumb' ? image.file_thumbnail_url : image.file_url;

         // Stream image จาก dev server
         const response = await axios.get(imageUrl, {
            responseType: 'stream'
         });

         // Set headers
         res.set({
            'Content-Type': response.headers['content-type'] || 'image/jpeg',
            'Content-Length': response.headers['content-length'],
            'Cache-Control': 'public, max-age=86400' // Cache 1 day
         });

         // Stream response
         response.data.pipe(res);
      } catch (error) {
         console.error('Stream image controller error:', error);

         if (error.message === 'Image not found') {
            return res.status(404).json({
               success: false,
               message: 'Image not found'
            });
         }

         res.status(500).json({
            success: false,
            message: 'Failed to load image'
         });
      }
   }

   // DELETE /images/:imageId
   async deleteImage(req, res) {
      try {
         const { imageId } = req.params;

         const result = await this.imageService.deleteImage(imageId);

         res.json({
            success: true,
            message: result.message,
            data: result.deletedImage
         });
      } catch (error) {
         console.error('Delete image controller error:', error);

         if (error.message === 'Image not found') {
            return res.status(404).json({
               success: false,
               message: 'Image not found'
            });
         }

         res.status(500).json({
            success: false,
            message: error.message
         });
      }
   }
}

module.exports = ImageController;