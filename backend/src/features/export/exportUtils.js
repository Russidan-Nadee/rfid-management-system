// Path: backend/src/features/export/exportUtils.js
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

class ExportUtils {
   /**
    * สร้าง unique filename สำหรับ export
    * @param {string} exportType - ประเภทการ export
    * @param {number} exportId - Export ID
    * @param {string} format - รูปแบบไฟล์ (xlsx, csv)
    * @returns {string} filename ที่ unique
    */
   static generateFileName(exportType, exportId, format = 'xlsx') {
      const timestamp = new Date().toISOString()
         .replace(/[:.]/g, '-')
         .replace('T', '_')
         .split('.')[0];

      const randomSuffix = crypto.randomBytes(4).toString('hex');

      return `${exportType}_${exportId}_${timestamp}_${randomSuffix}.${format}`;
   }

   /**
    * สร้าง file path แบบสมบูรณ์
    * @param {string} fileName - ชื่อไฟล์
    * @returns {string} path แบบเต็ม
    */
   static generateFilePath(fileName) {
      const uploadsDir = path.join(process.cwd(), 'uploads', 'exports');
      return path.join(uploadsDir, fileName);
   }

   /**
    * ตรวจสอบและสร้าง directory ถ้าไม่มี
    * @param {string} dirPath - path ของ directory
    */
   static async ensureDirectoryExists(dirPath) {
      try {
         await fs.access(dirPath);
      } catch {
         await fs.mkdir(dirPath, { recursive: true });
         console.log(`Created directory: ${dirPath}`);
      }
   }

   /**
    * ดึงขนาดไฟล์
    * @param {string} filePath - path ของไฟล์
    * @returns {Promise<number>} ขนาดไฟล์ (bytes)
    */
   static async getFileSize(filePath) {
      try {
         const stats = await fs.stat(filePath);
         return stats.size;
      } catch (error) {
         console.error(`Error getting file size for ${filePath}:`, error.message);
         return 0;
      }
   }

   /**
    * ลบไฟล์
    * @param {string} filePath - path ของไฟล์
    * @returns {Promise<boolean>} สำเร็จหรือไม่
    */
   static async deleteFile(filePath) {
      try {
         await fs.unlink(filePath);
         console.log(`Deleted file: ${filePath}`);
         return true;
      } catch (error) {
         console.error(`Error deleting file ${filePath}:`, error.message);
         return false;
      }
   }

   /**
    * ตรวจสอบว่าไฟล์มีอยู่หรือไม่
    * @param {string} filePath - path ของไฟล์
    * @returns {Promise<boolean>} มีไฟล์หรือไม่
    */
   static async fileExists(filePath) {
      try {
         await fs.access(filePath);
         return true;
      } catch {
         return false;
      }
   }

   /**
    * แปลงขนาดไฟล์เป็น human readable format
    * @param {number} bytes - ขนาดไฟล์ (bytes)
    * @returns {string} ขนาดไฟล์ในรูปแบบที่อ่านง่าย
    */
   static formatFileSize(bytes) {
      if (bytes === 0) return '0 B';

      const sizes = ['B', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(1024));
      const size = (bytes / Math.pow(1024, i)).toFixed(1);

      return `${size} ${sizes[i]}`;
   }

   /**
    * คำนวณวันหมดอายุ
    * @param {number} days - จำนวนวันที่ต้องการเพิ่ม (default: 7)
    * @returns {Date} วันหมดอายุ
    */
   static calculateExpiryDate(days = 7) {
      const expiryDate = new Date();
      expiryDate.setDate(expiryDate.getDate() + days);
      return expiryDate;
   }

   /**
    * ตรวจสอบว่าไฟล์หมดอายุแล้วหรือไม่
    * @param {Date|string} expiryDate - วันหมดอายุ
    * @returns {boolean} หมดอายุแล้วหรือไม่
    */
   static isExpired(expiryDate) {
      const expiry = new Date(expiryDate);
      const now = new Date();
      return now > expiry;
   }

   /**
    * สร้าง WHERE clause สำหรับ SQL query จาก filters
    * @param {Object} filters - filters object
    * @returns {Object} { whereClause, params }
    */
   static buildWhereClause(filters = {}) {
      const conditions = [];
      const params = [];

      // Plant codes filter
      if (filters.plant_codes && filters.plant_codes.length > 0) {
         const placeholders = filters.plant_codes.map(() => '?').join(',');
         conditions.push(`a.plant_code IN (${placeholders})`);
         params.push(...filters.plant_codes);
      }

      // Location codes filter
      if (filters.location_codes && filters.location_codes.length > 0) {
         const placeholders = filters.location_codes.map(() => '?').join(',');
         conditions.push(`a.location_code IN (${placeholders})`);
         params.push(...filters.location_codes);
      }

      // Status filter
      if (filters.status && filters.status.length > 0) {
         const placeholders = filters.status.map(() => '?').join(',');
         conditions.push(`a.status IN (${placeholders})`);
         params.push(...filters.status);
      }

      // Date range filter
      if (filters.date_range) {
         if (filters.date_range.from) {
            conditions.push('a.created_at >= ?');
            params.push(filters.date_range.from);
         }
         if (filters.date_range.to) {
            conditions.push('a.created_at <= ?');
            params.push(filters.date_range.to);
         }
      }

      const whereClause = conditions.length > 0 ? conditions.join(' AND ') : '1=1';

      return { whereClause, params };
   }

   /**
    * Sanitize column names สำหรับ SQL query
    * @param {Array} columns - array ของ column names
    * @param {Array} allowedColumns - columns ที่อนุญาต
    * @returns {Array} columns ที่ sanitized แล้ว
    */
   static sanitizeColumns(columns, allowedColumns) {
      if (!columns || columns.length === 0) {
         return allowedColumns;
      }

      return columns.filter(column => {
         // ตรวจสอบว่า column อยู่ใน allowed list
         const isAllowed = allowedColumns.includes(column);

         // ตรวจสอบว่าไม่มี SQL injection
         const isSafe = /^[a-zA-Z_][a-zA-Z0-9_.]*$/.test(column);

         return isAllowed && isSafe;
      });
   }

   /**
    * แปลง status code เป็น label
    * @param {string} status - status code (P, C, F)
    * @returns {string} status label
    */
   static getStatusLabel(status) {
      const statusLabels = {
         'P': 'Pending',
         'C': 'Completed',
         'F': 'Failed'
      };
      return statusLabels[status] || status;
   }

   /**
    * แปลง export type เป็น label
    * @param {string} exportType - export type
    * @returns {string} export type label
    */
   static getExportTypeLabel(exportType) {
      const typeLabels = {
         'assets': 'Assets Export',
         'scan_logs': 'Scan Logs Export',
         'status_history': 'Status History Export'
      };
      return typeLabels[exportType] || exportType;
   }

   /**
    * สร้าง download URL
    * @param {number} exportId - Export ID
    * @param {string} baseUrl - Base URL (optional)
    * @returns {string} download URL
    */
   static generateDownloadUrl(exportId, baseUrl = '') {
      return `${baseUrl}/api/v1/export/download/${exportId}`;
   }

   /**
    * ตรวจสอบ content type จากนามสกุลไฟล์
    * @param {string} fileName - ชื่อไฟล์
    * @returns {string} content type
    */
   static getContentType(fileName) {
      const extension = path.extname(fileName).toLowerCase();

      const contentTypes = {
         '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
         '.csv': 'text/csv',
         '.pdf': 'application/pdf',
         '.zip': 'application/zip'
      };

      return contentTypes[extension] || 'application/octet-stream';
   }

   /**
    * สร้าง error response object
    * @param {string} message - error message
    * @param {number} statusCode - HTTP status code
    * @returns {Object} error response object
    */
   static createErrorResponse(message, statusCode = 500) {
      return {
         success: false,
         message,
         timestamp: new Date().toISOString(),
         statusCode
      };
   }

   /**
    * สร้าง success response object
    * @param {string} message - success message
    * @param {*} data - response data
    * @param {Object} meta - metadata (optional)
    * @returns {Object} success response object
    */
   static createSuccessResponse(message, data = null, meta = null) {
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

      return response;
   }

   /**
    * Log export activity
    * @param {string} action - การกระทำ
    * @param {Object} details - รายละเอียด
    */
   static logExportActivity(action, details = {}) {
      const logData = {
         timestamp: new Date().toISOString(),
         action,
         ...details
      };

      console.log(`[EXPORT] ${JSON.stringify(logData)}`);
   }

   /**
    * ตรวจสอบและจำกัดจำนวน records สำหรับ export
    * @param {string} exportType - ประเภทการ export
    * @param {number} estimatedCount - จำนวน records ที่คาดว่าจะ export
    * @returns {Object} { allowed: boolean, limit: number, message?: string }
    */
   static validateExportLimit(exportType, estimatedCount) {
      const limits = {
         'assets': 100000,
         'scan_logs': 500000,
         'status_history': 200000
      };

      const limit = limits[exportType] || 50000;

      if (estimatedCount > limit) {
         return {
            allowed: false,
            limit,
            message: `Export limit exceeded. Maximum ${limit.toLocaleString()} records allowed for ${exportType}.`
         };
      }

      return { allowed: true, limit };
   }
}

module.exports = ExportUtils;