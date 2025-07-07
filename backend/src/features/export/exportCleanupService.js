// Path: backend/src/services/exportCleanupService.js
const cron = require('node-cron');
const ExportService = require('./exportService');
const ExportModel = require('./exportModel');

class ExportCleanupService {
   constructor() {
      this.exportService = new ExportService();
      this.exportModel = new ExportModel();
      this.isRunning = false;
   }

   /**
    * เริ่มต้น Auto Cleanup Scheduler
    */
   startScheduler() {
      // ทำงานทุกวันเวลา 02:00 น.
      cron.schedule('0 2 * * *', async () => {
         if (this.isRunning) {
            console.log('Cleanup already running, skipping...');
            return;
         }

         console.log('Starting daily export cleanup...');
         await this.runCleanup();
      });

      console.log('Daily export cleanup scheduler started');
   }

   /**
    * ทำงาน Cleanup
    */
   async runCleanup() {
      if (this.isRunning) {
         console.log('Cleanup already in progress');
         return;
      }

      this.isRunning = true;
      const startTime = Date.now();

      try {
         console.log('=== Export Cleanup Started ===');

         // 1. ลบไฟล์ที่หมดอายุแล้ว
         const expiredCount = await this.cleanupExpiredFiles();
         console.log(`✅ Cleaned up ${expiredCount} expired files`);

         // 2. ลบ job records ที่หมดอายุนานแล้ว (เก็บ history 30 วัน)
         const oldRecordsCount = await this.cleanupOldRecords();
         console.log(`✅ Cleaned up ${oldRecordsCount} old records`);

         // 3. ลบไฟล์ที่ไม่มี record ใน database (orphaned files)
         const orphanedCount = await this.cleanupOrphanedFiles();
         console.log(`✅ Cleaned up ${orphanedCount} orphaned files`);

         const duration = Date.now() - startTime;
         console.log(`=== Export Cleanup Completed in ${duration}ms ===`);

         return {
            expiredFiles: expiredCount,
            oldRecords: oldRecordsCount,
            orphanedFiles: orphanedCount,
            duration
         };

      } catch (error) {
         console.error('Export cleanup failed:', error);
         throw error;
      } finally {
         this.isRunning = false;
      }
   }

   /**
    * ลบไฟล์ที่หมดอายุแล้ว
    */
   async cleanupExpiredFiles() {
      try {
         return await this.exportService.cleanupExpiredFiles();
      } catch (error) {
         console.error('Failed to cleanup expired files:', error);
         return 0;
      }
   }

   /**
    * ลบ records เก่าจาก database (เก็บไว้ 30 วัน)
    */
   async cleanupOldRecords() {
      try {
         const thirtyDaysAgo = new Date();
         thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

         const query = `
            DELETE FROM export_history 
            WHERE expires_at < ? 
            AND status IN ('C', 'F')
            AND created_at < ?
         `;

         const result = await this.exportModel.executeQuery(query, [
            new Date(), // หมดอายุแล้ว
            thirtyDaysAgo // สร้างมานานกว่า 30 วัน
         ]);

         return result.affectedRows || 0;
      } catch (error) {
         console.error('Failed to cleanup old records:', error);
         return 0;
      }
   }

   /**
    * ลบไฟล์ที่ไม่มี record ใน database
    */
   async cleanupOrphanedFiles() {
      try {
         const fs = require('fs').promises;
         const path = require('path');

         const exportDir = path.join(process.cwd(), 'uploads', 'exports');

         // ตรวจสอบว่าโฟลเดอร์มีอยู่หรือไม่
         try {
            await fs.access(exportDir);
         } catch {
            return 0; // ไม่มีโฟลเดอร์
         }

         const files = await fs.readdir(exportDir);
         let deletedCount = 0;

         for (const file of files) {
            try {
               const filePath = path.join(exportDir, file);
               const stats = await fs.stat(filePath);

               // ข้าม directory
               if (stats.isDirectory()) continue;

               // ตรวจสอบว่าไฟล์มี record ใน database หรือไม่
               const hasRecord = await this.checkFileHasRecord(file);

               if (!hasRecord) {
                  // ตรวจสอบว่าไฟล์เก่ากว่า 1 ชั่วโมงหรือไม่ (เพื่อความปลอดภัย)
                  const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);

                  if (stats.mtime < oneHourAgo) {
                     await fs.unlink(filePath);
                     deletedCount++;
                     console.log(`Deleted orphaned file: ${file}`);
                  }
               }
            } catch (error) {
               console.error(`Error processing file ${file}:`, error);
            }
         }

         return deletedCount;
      } catch (error) {
         console.error('Failed to cleanup orphaned files:', error);
         return 0;
      }
   }

   /**
    * ตรวจสอบว่าไฟล์มี record ใน database หรือไม่
    */
   async checkFileHasRecord(fileName) {
      try {
         const query = `
            SELECT COUNT(*) as count 
            FROM export_history 
            WHERE file_path LIKE ?
         `;

         const result = await this.exportModel.executeQuery(query, [`%${fileName}%`]);
         return result[0].count > 0;
      } catch (error) {
         console.error('Error checking file record:', error);
         return true; // ถ้าไม่แน่ใจให้เก็บไฟล์ไว้
      }
   }

   /**
    * Manual cleanup (สำหรับเรียกจาก API)
    */
   async manualCleanup() {
      return await this.runCleanup();
   }

   /**
    * หยุด scheduler
    */
   stopScheduler() {
      // ใน production อาจต้องเก็บ reference ของ cron jobs
      console.log('Export cleanup scheduler stopped');
   }

   /**
    * ดูสถิติการใช้พื้นที่
    */
   async getStorageStats() {
      try {
         const fs = require('fs').promises;
         const path = require('path');

         const exportDir = path.join(process.cwd(), 'uploads', 'exports');

         try {
            await fs.access(exportDir);
         } catch {
            return {
               totalFiles: 0,
               totalSize: 0,
               totalSizeFormatted: '0 B'
            };
         }

         const files = await fs.readdir(exportDir);
         let totalSize = 0;
         let totalFiles = 0;

         for (const file of files) {
            try {
               const filePath = path.join(exportDir, file);
               const stats = await fs.stat(filePath);

               if (stats.isFile()) {
                  totalSize += stats.size;
                  totalFiles++;
               }
            } catch (error) {
               console.error(`Error getting stats for ${file}:`, error);
            }
         }

         return {
            totalFiles,
            totalSize,
            totalSizeFormatted: this.formatFileSize(totalSize)
         };
      } catch (error) {
         console.error('Failed to get storage stats:', error);
         return {
            totalFiles: 0,
            totalSize: 0,
            totalSizeFormatted: '0 B'
         };
      }
   }

   /**
    * Format file size
    */
   formatFileSize(bytes) {
      if (bytes === 0) return '0 B';

      const sizes = ['B', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(1024));
      const size = (bytes / Math.pow(1024, i)).toFixed(1);

      return `${size} ${sizes[i]}`;
   }
}

module.exports = ExportCleanupService;