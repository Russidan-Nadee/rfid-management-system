// Path: backend/src/controllers/exportController.js
const ExportService = require('../services/exportService');
const fs = require('fs').promises;
const path = require('path');

class ExportController {
   constructor() {
      this.exportService = new ExportService();
   }

   /**
    * สร้าง export job ใหม่
    * POST /api/v1/export/assets
    */
   async createExport(req, res) {
      try {
         const { exportType, exportConfig } = req.body;
         const { userId } = req.user;

         // Validate export type
         const validTypes = ['assets', 'scan_logs', 'status_history'];
         if (!validTypes.includes(exportType)) {
            return res.status(400).json({
               success: false,
               message: 'Invalid export type',
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

         // สร้าง export job
         const exportJob = await this.exportService.createExportJob({
            userId,
            exportType,
            exportConfig: JSON.stringify(exportConfig)
         });

         res.status(201).json({
            success: true,
            message: 'Export job created successfully',
            data: {
               export_id: exportJob.export_id,
               export_type: exportJob.export_type,
               status: exportJob.status,
               created_at: exportJob.created_at,
               expires_at: exportJob.expires_at
            },
            timestamp: new Date().toISOString()
         });

      } catch (error) {
         console.error('Create export error:', error);

         const statusCode = error.message.includes('pending') ? 409 : 500;

         res.status(statusCode).json({
            success: false,
            message: error.message,
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

         res.status(200).json({
            success: true,
            message: 'Export job retrieved successfully',
            data: {
               export_id: exportJob.export_id,
               export_type: exportJob.export_type,
               status: exportJob.status,
               total_records: exportJob.total_records,
               file_size: exportJob.file_size,
               created_at: exportJob.created_at,
               expires_at: exportJob.expires_at,
               error_message: exportJob.error_message,
               download_url: exportJob.status === 'C' && exportJob.file_path
                  ? `/api/v1/export/download/${exportJob.export_id}`
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

         // ตรวจสอบสิทธิ์
         if (exportJob.user_id !== userId) {
            return res.status(403).json({
               success: false,
               message: 'Access denied',
               timestamp: new Date().toISOString()
            });
         }

         // ตรวจสอบสถานะ
         if (exportJob.status !== 'C') {
            return res.status(400).json({
               success: false,
               message: 'Export job is not completed yet',
               timestamp: new Date().toISOString()
            });
         }

         // ตรวจสอบไฟล์
         if (!exportJob.file_path) {
            return res.status(404).json({
               success: false,
               message: 'Export file not found',
               timestamp: new Date().toISOString()
            });
         }

         // ตรวจสอบว่าไฟล์ยังมีอยู่หรือไม่
         try {
            await fs.access(exportJob.file_path);
         } catch {
            return res.status(404).json({
               success: false,
               message: 'Export file has been deleted or expired',
               timestamp: new Date().toISOString()
            });
         }

         // ตรวจสอบหมดอายุ
         if (new Date() > new Date(exportJob.expires_at)) {
            return res.status(410).json({
               success: false,
               message: 'Export file has expired',
               timestamp: new Date().toISOString()
            });
         }

         // ส่งไฟล์
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
         res.setHeader('Content-Length', exportJob.file_size);

         // Stream ไฟล์ไปยัง client
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
    * ดูประวัติ export ของ user
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

         // แปลงข้อมูลให้เหมาะสำหรับ frontend
         const formattedHistory = history.map(item => ({
            export_id: item.export_id,
            export_type: item.export_type,
            status: item.status,
            total_records: item.total_records,
            file_size: item.file_size,
            created_at: item.created_at,
            expires_at: item.expires_at,
            download_url: item.status === 'C' && item.file_path
               ? `/api/v1/export/download/${item.export_id}`
               : null
         }));

         res.status(200).json({
            success: true,
            message: 'Export history retrieved successfully',
            data: formattedHistory,
            meta: {
               pagination: {
                  currentPage: parseInt(page),
                  itemsPerPage: parseInt(limit),
                  totalItems: history.length
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
    * ดึงข้อมูลสถิติ export
    * GET /api/v1/export/stats
    */
   async getExportStats(req, res) {
      try {
         const { userId } = req.user;
         const { role } = req.user;

         // Admin สามารถดูสถิติทั้งหมด, user อื่นดูแค่ของตัวเอง
         const targetUserId = role === 'admin' ? null : userId;

         const stats = await this.exportService.exportModel.getExportStats(targetUserId);

         res.status(200).json({
            success: true,
            message: 'Export statistics retrieved successfully',
            data: {
               pending: stats.P || 0,
               completed: stats.C || 0,
               failed: stats.F || 0,
               total: (stats.P || 0) + (stats.C || 0) + (stats.F || 0)
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

         const deletedCount = await this.exportService.cleanupExpiredFiles();

         res.status(200).json({
            success: true,
            message: `Cleanup completed. ${deletedCount} files deleted.`,
            data: { deleted_count: deletedCount },
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
}

module.exports = ExportController;