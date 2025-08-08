// Path: backend/src/features/image/image.routes.js
const express = require('express');
const router = express.Router();

const ImageController = require('./image.controller');
const { uploadSingle, handleUploadError } = require('./image.middleware');
const { authenticateToken } = require('../auth/authMiddleware');

const imageController = new ImageController();

// POST /assets/:asset_no/images - Upload image
router.post('/assets/:asset_no/images',
   authenticateToken,
   uploadSingle,
   handleUploadError,
   (req, res) => imageController.uploadImage(req, res)
);

// GET /assets/:asset_no/images - Get image list  
router.get('/assets/:asset_no/images',
   authenticateToken,
   (req, res) => imageController.getAssetImages(req, res)
);

// GET /images/:imageId - Stream image (original or thumbnail)
router.get('/images/:imageId',
   (req, res) => imageController.streamImage(req, res)
);

// DELETE /images/:imageId - Delete image
router.delete('/images/:imageId',
   authenticateToken,
   (req, res) => imageController.deleteImage(req, res)
);

module.exports = router;