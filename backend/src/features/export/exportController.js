// Path: backend/src/features/export/exportController.js
const ExportService = require('./exportService');
const fs = require('fs').promises;
const path = require('path');

class ExportController {
   constructor() {
      this.exportService = new ExportService();
   }

   /**
    * Helper function to convert BigInt to Number in nested objects
    */
   convertBigIntToNumber(obj) {
      if (obj === null || obj === undefined) return obj;

      if (typeof obj === 'bigint') {
         return Number(obj);
      }

      if (Array.isArray(obj)) {
         return obj.map(item => this.convertBigIntToNumber(item));
      }

      if (typeof obj === 'object') {
         const converted = {};
         for (const [key, value] of Object.entries(obj)) {
            converted[key] = this.convertBigIntToNumber(value);
         }
         return converted;
      }

      return obj;
   }

   /**
    * สร้าง export job ใหม่ - รองรับเฉพาะ assets
    * POST /api/v1/export/jobs
    */
   async createExport(req, res) {
      try {
         const { exportType, exportConfig } = req.body;
         const { userId } = req.user;

         // Validate export type - รองรับเฉพาะ assets
         if (exportType !== 'assets') {
            return res.status(400).json({
               success: false,
               message: 'Only assets export is supported',
               timestamp: new Date().toISOString()
            });
         }

         // Validate export config
         if (!exportConfig || typeof exportConfig !== 'object') {
            return res.status(400).json({
               success: false,
               message: 'Export configuration is required',
               timestamp: new Date().toISOString()
            });
         }

         // Period validation - ถ้า validator ผ่านแล้วก็ปลอดภัย
         const { filters } = exportConfig;
         if (filters?.date_range) {
            const dateValidation = this._validatePeriodParams(filters.date_range);
            if (!dateValidation.isValid) {
               return res.status(400).json({
                  success: false,
                  message: 'Invalid date range',
                  errors: dateValidation.errors,
                  timestamp: new Date().toISOString()
               });
            }
         }

         // สร้าง export job
         const exportJob = await this.exportService.createExportJob({
            userId,
            exportType,
            exportConfig: JSON.stringify(exportConfig)
         });

         // Convert BigInt before sending response
         const convertedJob = this.convertBigIntToNumber(exportJob);

         // เพิ่ม warning ถ้ามี
         const response = {
            success: true,
            message: 'Export job created successfully',
            data: {
               export_id: convertedJob.export_id,
               export_type: convertedJob.export_type,
               status: convertedJob.status,
               created_at: convertedJob.created_at,
               expires_at: convertedJob.expires_at
            },
            timestamp: new Date().toISOString()
         };

         // เพิ่ม warning ถ้า validator เซ็ต default period
         if (req.exportWarning) {
            response.warning = req.exportWarning;
         }

         res.status(201).json(response);

      } catch (error) {
         console.error('Create export error:', error);

         // Handle specific errors
         let statusCode = 500;
         let errorMessage = error.message;

         if (error.message.includes('pending')) {
            statusCode = 409;
         } else if (error.message.includes('Invalid date range')) {
            statusCode = 400;
         } else if (error.message.includes('Date range cannot exceed')) {
            statusCode = 400;
         }

         res.status(statusCode).json({
            success: false,
            message: errorMessage,
            timestamp: new Date().toISOString()
         });
      }
   }

   /**
    * ดูสถานะ export job
    * GET /api/v1/export/jobs/:jobId
    */
   async getExportStatus(req, res) {
      try {
         const { jobId } = req.params;
         const { userId } = req.user;

         const exportJob = await this.exportService.getExportJob(parseInt(jobId));

         if (!exportJob) {
            return res.status(404).json({
               success: false,
               message: 'Export job not found',
               timestamp: new Date().toISOString()
            });
         }

         // ตรวจสอบสิทธิ์
         if (exportJob.user_id !== userId) {
            return res.status(403).json({
               success: false,
               message: 'Access denied',
               timestamp: new Date().toISOString()
            });
         }

         // Convert BigInt before sending response
         const convertedJob = this.convertBigIntToNumber(exportJob);

         res.status(200).json({
            success: true,
            message: 'Export job retrieved successfully',
            data: {
               export_id: convertedJob.export_id,
               export_type: convertedJob.export_type,
               status: convertedJob.status,
               filename: path.basename(convertedJob.file_path),
               total_records: convertedJob.total_records,
               file_size: convertedJob.file_size,
               created_at: convertedJob.created_at,
               expires_at: convertedJob.expires_at,
               error_message: convertedJob.error_message,
               download_url: convertedJob.status === 'C' && convertedJob.file_path
                  ? `/api/v1/export/download/${convertedJob.export_id}`
                  : null
            },
            timestamp: new Date().toISOString()
         });

      } catch (error) {
         console.error('Get export status error:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   }

   /**
    * Download ไฟล์ export
    * GET /api/v1/export/download/:jobId
    */
   async downloadExport(req, res) {
      try {
         const { jobId } = req.params;
         const { userId } = req.user;

         const exportJob = await this.exportService.getExportJob(parseInt(jobId));

         if (!exportJob) {
            return res.status(404).json({
               success: false,
               message: 'Export job not found',
               timestamp: new Date().toISOString()
            });
         }

         // Check ownership
         if (exportJob.user_id !== userId) {
            return res.status(403).json({
               success: false,
               message: 'Access denied',
               timestamp: new Date().toISOString()
            });
         }

         // Check status
         if (exportJob.status === 'F') {
            return res.status(400).json({
               success: false,
               message: `Export failed: ${exportJob.error_message || 'Unknown error'}`,
               timestamp: new Date().toISOString()
            });
         }

         if (exportJob.status === 'P') {
            return res.status(202).json({
               success: false,
               message: 'Export is still processing, please wait',
               timestamp: new Date().toISOString()
            });
         }

         if (exportJob.status !== 'C') {
            return res.status(400).json({
               success: false,
               message: `Export not ready. Status: ${exportJob.status}`,
               timestamp: new Date().toISOString()
            });
         }

         // Check file path
         if (!exportJob.file_path) {
            return res.status(404).json({
               success: false,
               message: 'Export file path not found',
               timestamp: new Date().toISOString()
            });
         }

         // Check file exists
         try {
            await fs.access(exportJob.file_path);
         } catch {
            // Update job status to failed
            await this.exportService.exportModel.updateExportJob(parseInt(jobId), {
               status: 'F',
               error_message: 'File not found on disk'
            });

            return res.status(404).json({
               success: false,
               message: 'Export file not found on server',
               timestamp: new Date().toISOString()
            });
         }

         // Check expiry
         if (new Date() > new Date(exportJob.expires_at)) {
            return res.status(410).json({
               success: false,
               message: 'Export file has expired',
               timestamp: new Date().toISOString()
            });
         }

         // Send file
         const fileName = path.basename(exportJob.file_path);
         const fileExtension = path.extname(fileName).toLowerCase();

         let contentType = 'application/octet-stream';
         if (fileExtension === '.xlsx') {
            contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
         } else if (fileExtension === '.csv') {
            contentType = 'text/csv';
         }

         res.setHeader('Content-Type', contentType);
         res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);

         const fileSize = typeof exportJob.file_size === 'bigint'
            ? Number(exportJob.file_size)
            : exportJob.file_size;

         if (fileSize) {
            res.setHeader('Content-Length', fileSize);
         }

         // Stream file
         const fileStream = require('fs').createReadStream(exportJob.file_path);
         fileStream.pipe(res);

         fileStream.on('error', (error) => {
            console.error('File stream error:', error);
            if (!res.headersSent) {
               res.status(500).json({
                  success: false,
                  message: 'Error reading export file',
                  timestamp: new Date().toISOString()
               });
            }
         });

      } catch (error) {
         console.error('Download export error:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   }

   /**
    * ดูประวัติ export ของ user - เฉพาะ assets
    * GET /api/v1/export/history
    */
   async getExportHistory(req, res) {
      try {
         const { userId } = req.user;
         const { page = 1, limit = 20, status } = req.query;

         const offset = (parseInt(page) - 1) * parseInt(limit);
         const options = {
            limit: parseInt(limit),
            offset,
            status
         };

         const history = await this.exportService.getUserExportHistory(userId, options);

         // Filter เฉพาะ assets exports
         const assetsHistory = history.filter(item => item.export_type === 'assets');

         // แปลงข้อมูลให้เหมาะสำหรับ frontend และ convert BigInt
         const formattedHistory = assetsHistory.map(item => {
            const converted = this.convertBigIntToNumber(item);
            return {
               export_id: converted.export_id,
               export_type: converted.export_type,
               status: converted.status,
               total_records: converted.total_records,
               file_size: converted.file_size,
               created_at: converted.created_at,
               expires_at: converted.expires_at,
               download_url: converted.status === 'C' && converted.file_path
                  ? `/api/v1/export/download/${converted.export_id}`
                  : null
            };
         });

         res.status(200).json({
            success: true,
            message: 'Export history retrieved successfully',
            data: formattedHistory,
            meta: {
               pagination: {
                  currentPage: parseInt(page),
                  itemsPerPage: parseInt(limit),
                  totalItems: formattedHistory.length,
                  totalAssetsExports: formattedHistory.length
               }
            },
            timestamp: new Date().toISOString()
         });

      } catch (error) {
         console.error('Get export history error:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   }

   /**
    * ยกเลิก export job
    * DELETE /api/v1/export/jobs/:jobId
    */
   async cancelExport(req, res) {
      try {
         const { jobId } = req.params;
         const { userId } = req.user;

         const success = await this.exportService.cancelExportJob(parseInt(jobId), userId);

         if (success) {
            res.status(200).json({
               success: true,
               message: 'Export job cancelled successfully',
               timestamp: new Date().toISOString()
            });
         } else {
            res.status(404).json({
               success: false,
               message: 'Export job not found',
               timestamp: new Date().toISOString()
            });
         }

      } catch (error) {
         console.error('Cancel export error:', error);

         const statusCode = error.message.includes('not found') ? 404 :
            error.message.includes('Access denied') ? 403 :
               error.message.includes('Cannot cancel') ? 400 : 500;

         res.status(statusCode).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   }

   /**
    * ดึงข้อมูลสถิติ export - เฉพาะ assets
    * GET /api/v1/export/stats
    */
   async getExportStats(req, res) {
      try {
         const { userId } = req.user;
         const { role } = req.user;

         // Admin สามารถดูสถิติทั้งหมด, user อื่นดูแค่ของตัวเอง
         const targetUserId = role === 'admin' ? null : userId;

         const stats = await this.exportService.exportModel.getExportStats(targetUserId);

         // เพิ่มข้อมูลเฉพาะ assets exports
         res.status(200).json({
            success: true,
            message: 'Export statistics retrieved successfully',
            data: {
               pending: stats.P || 0,
               completed: stats.C || 0,
               failed: stats.F || 0,
               total: (stats.P || 0) + (stats.C || 0) + (stats.F || 0),
               export_type: 'assets_only'
            },
            timestamp: new Date().toISOString()
         });

      } catch (error) {
         console.error('Get export stats error:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   }

   /**
    * ทำความสะอาดไฟล์หมดอายุ (Admin only)
    * POST /api/v1/export/cleanup
    */
   async cleanupExpiredFiles(req, res) {
      try {
         const { role } = req.user;

         // ตรวจสอบสิทธิ์ admin
         if (role !== 'admin') {
            return res.status(403).json({
               success: false,
               message: 'Admin access required',
               timestamp: new Date().toISOString()
            });
         }

         // ใช้ cleanup service แทน
         const cleanupService = req.app.locals.cleanupService;
         const result = await cleanupService.manualCleanup();

         res.status(200).json({
            success: true,
            message: 'Cleanup completed successfully',
            data: {
               expired_files: result.expiredFiles,
               old_records: result.oldRecords,
               orphaned_files: result.orphanedFiles,
               duration_ms: result.duration
            },
            timestamp: new Date().toISOString()
         });

      } catch (error) {
         console.error('Cleanup expired files error:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   }

   /**
    * ดูสถิติการใช้พื้นที่ storage (Admin only)
    * GET /api/v1/export/storage-stats
    */
   async getStorageStats(req, res) {
      try {
         const { role } = req.user;

         if (role !== 'admin') {
            return res.status(403).json({
               success: false,
               message: 'Admin access required',
               timestamp: new Date().toISOString()
            });
         }

         const cleanupService = req.app.locals.cleanupService;
         const stats = await cleanupService.getStorageStats();

         // ดึงสถิติจาก database ด้วย
         const dbStats = await this.exportService.exportModel.getExportStats();

         res.status(200).json({
            success: true,
            message: 'Storage statistics retrieved successfully',
            data: {
               files: {
                  total_count: stats.totalFiles,
                  total_size_bytes: stats.totalSize,
                  total_size_formatted: stats.totalSizeFormatted
               },
               database: {
                  pending: dbStats.P || 0,
                  completed: dbStats.C || 0,
                  failed: dbStats.F || 0,
                  total: (dbStats.P || 0) + (dbStats.C || 0) + (dbStats.F || 0)
               },
               export_type: 'assets_only'
            },
            timestamp: new Date().toISOString()
         });

      } catch (error) {
         console.error('Get storage stats error:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   }

   /**
    * Validate period parameters (helper function)
    * @private
    */
   _validatePeriodParams(dateRange) {
      const errors = [];

      try {
         if (!dateRange.from || !dateRange.to) {
            errors.push('Both from and to dates are required');
            return { isValid: false, errors };
         }

         const from = new Date(dateRange.from);
         const to = new Date(dateRange.to);

         if (isNaN(from.getTime()) || isNaN(to.getTime())) {
            errors.push('Invalid date format');
         }

         if (from >= to) {
            errors.push('From date must be before to date');
         }

         const daysDiff = (to - from) / (1000 * 60 * 60 * 24);
         if (daysDiff > 365) {
            errors.push('Date range cannot exceed 1 year');
         }

      } catch (error) {
         errors.push('Date validation error');
      }

      return {
         isValid: errors.length === 0,
         errors
      };
   }
}

module.exports = ExportController;