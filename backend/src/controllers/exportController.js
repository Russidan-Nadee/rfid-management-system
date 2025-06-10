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
               }
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
    * เรียก cleanup แบบ force (Admin only) - ใช้สำหรับทดสอบ
    * POST /api/v1/export/force-cleanup
    */
   async forceCleanup(req, res) {
      try {
         const { role } = req.user;

         if (role !== 'admin') {
            return res.status(403).json({
               success: false,
               message: 'Admin access required',
               timestamp: new Date().toISOString()
            });
         }

         const { cleanup_type } = req.body;
         const cleanupService = req.app.locals.cleanupService;

         let result;

         switch (cleanup_type) {
            case 'expired':
               result = { expiredFiles: await cleanupService.cleanupExpiredFiles() };
               break;
            case 'old_records':
               result = { oldRecords: await cleanupService.cleanupOldRecords() };
               break;
            case 'orphaned':
               result = { orphanedFiles: await cleanupService.cleanupOrphanedFiles() };
               break;
            case 'all':
            default:
               result = await cleanupService.manualCleanup();
               break;
         }

         res.status(200).json({
            success: true,
            message: `Force cleanup completed (${cleanup_type || 'all'})`,
            data: result,
            timestamp: new Date().toISOString()
         });

      } catch (error) {
         console.error('Force cleanup error:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            timestamp: new Date().toISOString()
         });
      }
   }

   /**
    * สร้าง export job ใหม่ (อัพเดทเพื่อลบไฟล์เก่าหลังสร้างใหม่)
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

         // ตรวจสอบและลบไฟล์เก่าของ user นี้ (optional)
         await this._cleanupUserOldFiles(userId);

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
    * ลบไฟล์เก่าของ user (เก็บไว้แค่ 3 ไฟล์ล่าสุด)
    * @private
    */
   async _cleanupUserOldFiles(userId) {
      try {
         const query = `
            SELECT export_id, file_path 
            FROM export_history 
            WHERE user_id = ? 
            AND status = 'C' 
            AND file_path IS NOT NULL
            ORDER BY created_at DESC
            LIMIT 999 OFFSET 3
         `;

         const oldExports = await this.exportService.exportModel.executeQuery(query, [userId]);

         for (const exportJob of oldExports) {
            try {
               // ลบไฟล์
               if (exportJob.file_path) {
                  await fs.unlink(exportJob.file_path);
               }

               // อัพเดท record ให้ file_path เป็น null
               await this.exportService.exportModel.updateExportJob(exportJob.export_id, {
                  file_path: null,
                  file_size: null
               });

               console.log(`Cleaned up old export file: ${exportJob.file_path}`);
            } catch (error) {
               console.error(`Failed to cleanup export ${exportJob.export_id}:`, error);
            }
         }
      } catch (error) {
         console.error('Failed to cleanup user old files:', error);
         // ไม่ throw error เพราะไม่ควรขัดขวางการสร้าง export ใหม่
      }
   }
}

module.exports = ExportController;