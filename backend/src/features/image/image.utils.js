// Path: backend/src/features/image/image.utils.js
const path = require('path');
const crypto = require('crypto');

/**
 * 🔧 IMAGE UTILITIES
 * Helper functions สำหรับ image management
 */
class ImageUtils {

   /**
    * 📁 FILE NAMING UTILITIES
    */

   /**
    * Generate filename ตาม pattern: ABC001_20250130_143022_001.jpg
    * @param {string} assetNo - asset number
    * @param {string} originalName - original filename
    * @param {number} sequence - sequence number
    * @returns {string} generated filename
    */
   static generateFilename(assetNo, originalName, sequence = 1) {
      try {
         // Generate timestamp: YYYYMMDD_HHMMSS
         const now = new Date();
         const date = now.toISOString().slice(0, 10).replace(/-/g, '');
         const time = now.toTimeString().slice(0, 8).replace(/:/g, '');
         const timestamp = `${date}_${time}`;

         // Get file extension
         const ext = path.extname(originalName).toLowerCase();

         // Validate extension
         if (!this.isValidImageExtension(ext)) {
            throw new Error(`Invalid file extension: ${ext}`);
         }

         // Format sequence number with leading zeros
         const sequenceStr = String(sequence).padStart(3, '0');

         // Format: ABC001_20250130_143022_001.jpg
         return `${assetNo}_${timestamp}_${sequenceStr}${ext}`;

      } catch (error) {
         console.error('Generate filename error:', error);
         throw new Error(`Failed to generate filename: ${error.message}`);
      }
   }

   /**
    * Generate thumbnail filename
    * @param {string} originalFilename - original filename
    * @returns {string} thumbnail filename
    */
   static generateThumbnailFilename(originalFilename) {
      const ext = path.extname(originalFilename);
      const basename = path.basename(originalFilename, ext);
      return `thumb_${basename}${ext}`;
   }

   /**
    * Parse filename เพื่อดึงข้อมูล
    * @param {string} filename - filename to parse
    * @returns {Object} parsed data
    */
   static parseFilename(filename) {
      try {
         // Pattern: ABC001_20250130_143022_001.jpg
         const pattern = /^([A-Za-z0-9_-]+)_(\d{8})_(\d{6})_(\d{3})\.(jpg|jpeg|png|webp)$/i;
         const match = filename.match(pattern);

         if (!match) {
            return {
               isValid: false,
               error: 'Filename does not match expected pattern'
            };
         }

         const [, assetNo, dateStr, timeStr, sequenceStr, extension] = match;

         return {
            isValid: true,
            assetNo,
            date: dateStr,
            time: timeStr,
            sequence: parseInt(sequenceStr),
            extension: extension.toLowerCase(),
            timestamp: this.parseTimestamp(dateStr, timeStr)
         };

      } catch (error) {
         return {
            isValid: false,
            error: error.message
         };
      }
   }

   /**
    * Parse timestamp จาก filename
    * @param {string} dateStr - YYYYMMDD
    * @param {string} timeStr - HHMMSS
    * @returns {Date} parsed date
    */
   static parseTimestamp(dateStr, timeStr) {
      try {
         const year = parseInt(dateStr.slice(0, 4));
         const month = parseInt(dateStr.slice(4, 6)) - 1; // Month is 0-indexed
         const day = parseInt(dateStr.slice(6, 8));
         const hour = parseInt(timeStr.slice(0, 2));
         const minute = parseInt(timeStr.slice(2, 4));
         const second = parseInt(timeStr.slice(4, 6));

         return new Date(year, month, day, hour, minute, second);
      } catch (error) {
         console.error('Parse timestamp error:', error);
         return null;
      }
   }

   /**
    * 🔍 FILE VALIDATION UTILITIES
    */

   /**
    * ตรวจสอบว่า extension ถูกต้องหรือไม่
    * @param {string} extension - file extension (with dot)
    * @returns {boolean}
    */
   static isValidImageExtension(extension) {
      const validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
      return validExtensions.includes(extension.toLowerCase());
   }

   /**
    * ตรวจสอบว่า MIME type ถูกต้องหรือไม่
    * @param {string} mimeType - MIME type
    * @returns {boolean}
    */
   static isValidImageMimeType(mimeType) {
      const validMimeTypes = [
         'image/jpeg',
         'image/jpg',
         'image/png',
         'image/webp'
      ];
      return validMimeTypes.includes(mimeType.toLowerCase());
   }

   /**
    * ตรวจสอบขนาดไฟล์
    * @param {number} fileSize - file size in bytes
    * @param {number} maxSize - maximum size in bytes (default 10MB)
    * @returns {Object} validation result
    */
   static validateFileSize(fileSize, maxSize = 10 * 1024 * 1024) {
      return {
         isValid: fileSize <= maxSize,
         size: fileSize,
         maxSize,
         sizeMB: Math.round(fileSize / 1024 / 1024 * 100) / 100,
         maxSizeMB: Math.round(maxSize / 1024 / 1024 * 100) / 100
      };
   }

   /**
    * 📊 FILE SIZE UTILITIES
    */

   /**
    * Format file size เป็น human readable
    * @param {number} bytes - file size in bytes
    * @param {number} decimals - decimal places
    * @returns {string} formatted size
    */
   static formatFileSize(bytes, decimals = 2) {
      if (!bytes || bytes === 0) return '0 Bytes';

      const k = 1024;
      const dm = decimals < 0 ? 0 : decimals;
      const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];

      const i = Math.floor(Math.log(bytes) / Math.log(k));

      return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
   }

   /**
    * Parse size string เป็น bytes
    * @param {string} sizeStr - size string (e.g., "10MB", "500KB")
    * @returns {number} size in bytes
    */
   static parseSizeString(sizeStr) {
      const units = {
         'B': 1,
         'KB': 1024,
         'MB': 1024 * 1024,
         'GB': 1024 * 1024 * 1024
      };

      const match = sizeStr.toUpperCase().match(/^(\d+(?:\.\d+)?)\s*(B|KB|MB|GB)$/);
      if (!match) {
         throw new Error('Invalid size format');
      }

      const [, number, unit] = match;
      return parseFloat(number) * units[unit];
   }

   /**
    * 🖼️ IMAGE PROCESSING UTILITIES
    */

   /**
    * Calculate thumbnail dimensions while maintaining aspect ratio
    * @param {number} originalWidth - original width
    * @param {number} originalHeight - original height
    * @param {number} maxWidth - maximum width
    * @param {number} maxHeight - maximum height
    * @returns {Object} calculated dimensions
    */
   static calculateThumbnailDimensions(originalWidth, originalHeight, maxWidth = 300, maxHeight = 300) {
      const aspectRatio = originalWidth / originalHeight;

      let newWidth = maxWidth;
      let newHeight = maxWidth / aspectRatio;

      if (newHeight > maxHeight) {
         newHeight = maxHeight;
         newWidth = maxHeight * aspectRatio;
      }

      return {
         width: Math.round(newWidth),
         height: Math.round(newHeight),
         aspectRatio: aspectRatio,
         scale: Math.min(newWidth / originalWidth, newHeight / originalHeight)
      };
   }

   /**
    * Get image format from MIME type
    * @param {string} mimeType - MIME type
    * @returns {string} image format
    */
   static getImageFormat(mimeType) {
      const formatMap = {
         'image/jpeg': 'jpeg',
         'image/jpg': 'jpeg',
         'image/png': 'png',
         'image/webp': 'webp'
      };

      return formatMap[mimeType.toLowerCase()] || 'jpeg';
   }

   /**
    * Get Sharp quality settings
    * @param {string} quality - quality level (low, medium, high)
    * @param {string} format - image format
    * @returns {Object} Sharp quality options
    */
   static getQualitySettings(quality = 'high', format = 'jpeg') {
      const settings = {
         jpeg: {
            low: { quality: 60, progressive: true },
            medium: { quality: 80, progressive: true },
            high: { quality: 90, progressive: true }
         },
         png: {
            low: { compressionLevel: 9, quality: 60 },
            medium: { compressionLevel: 6, quality: 80 },
            high: { compressionLevel: 3, quality: 90 }
         },
         webp: {
            low: { quality: 60, effort: 4 },
            medium: { quality: 80, effort: 4 },
            high: { quality: 90, effort: 6 }
         }
      };

      return settings[format]?.[quality] || settings.jpeg.high;
   }

   /**
    * 🔐 SECURITY UTILITIES
    */

   /**
    * Generate ETag สำหรับ caching
    * @param {Object} fileStats - file statistics
    * @returns {string} ETag
    */
   static generateETag(fileStats) {
      const { size, mtime } = fileStats;
      return `"${mtime.getTime().toString(16)}-${size.toString(16)}"`;
   }

   /**
    * Generate secure filename hash
    * @param {string} originalName - original filename
    * @param {string} assetNo - asset number
    * @returns {string} secure hash
    */
   static generateSecureHash(originalName, assetNo) {
      const hash = crypto.createHash('sha256');
      hash.update(`${originalName}-${assetNo}-${Date.now()}`);
      return hash.digest('hex').substring(0, 16);
   }

   /**
    * Sanitize filename สำหรับความปลอดภัย
    * @param {string} filename - filename to sanitize
    * @returns {string} sanitized filename
    */
   static sanitizeFilename(filename) {
      // Remove path traversal attempts
      let sanitized = filename.replace(/\.\./g, '');

      // Remove or replace unsafe characters
      sanitized = sanitized.replace(/[^a-zA-Z0-9._-]/g, '_');

      // Limit length
      if (sanitized.length > 255) {
         const ext = path.extname(sanitized);
         const basename = path.basename(sanitized, ext);
         sanitized = basename.substring(0, 255 - ext.length) + ext;
      }

      return sanitized;
   }

   /**
    * 📈 PERFORMANCE UTILITIES
    */

   /**
    * Calculate performance metrics
    * @param {Date} startTime - operation start time
    * @param {number} fileCount - number of files processed
    * @param {number} totalSize - total size processed
    * @returns {Object} performance metrics
    */
   static calculatePerformance(startTime, fileCount = 0, totalSize = 0) {
      const endTime = new Date();
      const duration = endTime - startTime;

      return {
         duration_ms: duration,
         duration_seconds: Math.round(duration / 1000 * 100) / 100,
         files_processed: fileCount,
         total_size: totalSize,
         total_size_mb: Math.round(totalSize / 1024 / 1024 * 100) / 100,
         throughput_mb_per_sec: fileCount > 0
            ? Math.round((totalSize / 1024 / 1024) / (duration / 1000) * 100) / 100
            : 0,
         files_per_sec: fileCount > 0
            ? Math.round(fileCount / (duration / 1000) * 100) / 100
            : 0,
         performance_grade: this.getPerformanceGrade(duration),
         timestamp: endTime.toISOString()
      };
   }

   /**
    * Get performance grade based on duration
    * @param {number} duration - duration in ms
    * @returns {string} grade (A, B, C, D, F)
    */
   static getPerformanceGrade(duration) {
      if (duration < 1000) return 'A';      // < 1 second
      if (duration < 3000) return 'B';      // < 3 seconds  
      if (duration < 5000) return 'C';      // < 5 seconds
      if (duration < 10000) return 'D';     // < 10 seconds
      return 'F';                           // > 10 seconds
   }

   /**
    * 🗂️ PATH UTILITIES
    */

   /**
    * Build file path
    * @param {string} uploadsDir - uploads directory
    * @param {string} filename - filename
    * @returns {string} full file path
    */
   static buildFilePath(uploadsDir, filename) {
      return path.join(uploadsDir, 'assets', filename);
   }

   /**
    * Build thumbnail path
    * @param {string} uploadsDir - uploads directory
    * @param {string} filename - filename
    * @returns {string} thumbnail path
    */
   static buildThumbnailPath(uploadsDir, filename) {
      const thumbnailFilename = this.generateThumbnailFilename(filename);
      return path.join(uploadsDir, 'assets', 'thumbs', thumbnailFilename);
   }

   /**
    * Get relative URL path
    * @param {string} imageId - image ID
    * @param {string} size - image size (original, thumb)
    * @returns {string} URL path
    */
   static getImageUrl(imageId, size = 'original') {
      const baseUrl = '/images';
      const query = size !== 'original' ? `?size=${size}` : '';
      return `${baseUrl}/${imageId}${query}`;
   }

   /**
    * 🎨 IMAGE METADATA UTILITIES
    */

   /**
    * Extract metadata from image info
    * @param {Object} imageInfo - image information
    * @returns {Object} formatted metadata
    */
   static formatImageMetadata(imageInfo) {
      return {
         dimensions: `${imageInfo.width || 0}x${imageInfo.height || 0}`,
         aspect_ratio: imageInfo.width && imageInfo.height
            ? Math.round((imageInfo.width / imageInfo.height) * 100) / 100
            : null,
         format: imageInfo.format || 'unknown',
         channels: imageInfo.channels || null,
         density: imageInfo.density || null,
         has_alpha: imageInfo.channels === 4,
         color_space: this.getColorSpace(imageInfo.channels),
         estimated_quality: this.estimateImageQuality(imageInfo)
      };
   }

   /**
    * Get color space from channels
    * @param {number} channels - number of channels
    * @returns {string} color space
    */
   static getColorSpace(channels) {
      const colorSpaces = {
         1: 'Grayscale',
         2: 'Grayscale + Alpha',
         3: 'RGB',
         4: 'RGBA'
      };

      return colorSpaces[channels] || 'Unknown';
   }

   /**
    * Estimate image quality
    * @param {Object} imageInfo - image info
    * @returns {string} quality estimate
    */
   static estimateImageQuality(imageInfo) {
      // Simple quality estimation based on file size vs dimensions
      if (!imageInfo.width || !imageInfo.height || !imageInfo.size) {
         return 'Unknown';
      }

      const pixels = imageInfo.width * imageInfo.height;
      const bytesPerPixel = imageInfo.size / pixels;

      if (bytesPerPixel > 3) return 'High';
      if (bytesPerPixel > 1.5) return 'Medium';
      return 'Low';
   }

   /**
    * 🕒 DATE UTILITIES
    */

   /**
    * Format date สำหรับแสดงผล
    * @param {Date} date - date to format
    * @param {string} format - format type
    * @returns {string} formatted date
    */
   static formatDate(date, format = 'datetime') {
      if (!date) return '';

      const d = new Date(date);
      if (isNaN(d.getTime())) return '';

      switch (format) {
         case 'date':
            return d.toLocaleDateString('th-TH');
         case 'time':
            return d.toLocaleTimeString('th-TH');
         case 'datetime':
            return d.toLocaleString('th-TH');
         case 'iso':
            return d.toISOString();
         case 'timestamp':
            return d.getTime();
         default:
            return d.toString();
      }
   }

   /**
    * Calculate time ago
    * @param {Date} date - date to calculate from
    * @returns {string} time ago string
    */
   static timeAgo(date) {
      if (!date) return '';

      const now = new Date();
      const diffMs = now - new Date(date);
      const diffSec = Math.floor(diffMs / 1000);
      const diffMin = Math.floor(diffSec / 60);
      const diffHour = Math.floor(diffMin / 60);
      const diffDay = Math.floor(diffHour / 24);

      if (diffSec < 60) return 'เมื่อสักครู่';
      if (diffMin < 60) return `${diffMin} นาทีที่แล้ว`;
      if (diffHour < 24) return `${diffHour} ชั่วโมงที่แล้ว`;
      if (diffDay < 7) return `${diffDay} วันที่แล้ว`;

      return this.formatDate(date, 'date');
   }

   /**
    * 🎯 UTILITY HELPERS
    */

   /**
    * Deep clone object
    * @param {Object} obj - object to clone
    * @returns {Object} cloned object
    */
   static deepClone(obj) {
      return JSON.parse(JSON.stringify(obj));
   }

   /**
    * Check if object is empty
    * @param {Object} obj - object to check
    * @returns {boolean}
    */
   static isEmpty(obj) {
      return obj === null || obj === undefined ||
         (typeof obj === 'object' && Object.keys(obj).length === 0) ||
         (typeof obj === 'string' && obj.trim() === '') ||
         (Array.isArray(obj) && obj.length === 0);
   }

   /**
    * Generate random string
    * @param {number} length - string length
    * @returns {string} random string
    */
   static generateRandomString(length = 8) {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      let result = '';
      for (let i = 0; i < length; i++) {
         result += chars.charAt(Math.floor(Math.random() * chars.length));
      }
      return result;
   }
}

module.exports = ImageUtils;