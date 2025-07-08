// Path: backend/src/features/export/exportService.js
const ExportModel = require('./exportModel');
const prisma = require('../../core/database/prisma');
const path = require('path');
const fs = require('fs').promises;
const XLSX = require('xlsx');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

class ExportService {
   constructor() {
      this.exportModel = new ExportModel();
   }

   /**
    * สร้าง export job ใหม่
    * @param {Object} params - พารามิเตอร์การ export
    * @returns {Promise<Object>} export job ที่สร้างแล้ว
    */
   async createExportJob(params) {
      const { userId, exportType, exportConfig } = params;

      // ตรวจสอบว่า user มี pending jobs หรือไม่
      const hasPending = await this.exportModel.hasPendingJobs(userId);
      if (hasPending) {
         throw new Error('You already have a pending export job. Please wait for it to complete.');
      }

      // สร้าง export job
      const jobData = {
         user_id: userId,
         export_type: exportType,
         export_config: exportConfig,
         status: 'P',
         expires_at: this._calculateExpiryDate()
      };

      const exportJob = await this.exportModel.createExportJob(jobData);

      // เริ่มประมวลผลแบบ background (asynchronous)
      setImmediate(() => this._processExportJob(exportJob.export_id));

      return exportJob;
   }

   /**
    * ประมวลผล export job
    * @param {number} exportId - Export ID
    * @private
    */
   async _processExportJob(exportId) {
      try {
         console.log(`🔄 Processing export job ${exportId}`);

         const exportJob = await this.exportModel.getExportJobById(exportId);
         if (!exportJob) {
            throw new Error('Export job not found');
         }

         // Ensure directory exists
         const uploadsDir = path.join(process.cwd(), 'uploads', 'exports');
         await this._ensureDirectoryExists(uploadsDir);

         // Fetch data
         const data = await this._fetchExportData(exportJob);
         console.log(`📊 Fetched ${data.length} records`);

         // Generate file
         const filePath = await this._generateExportFile(exportJob, data);
         console.log(`💾 File created: ${filePath}`);

         // Verify file exists
         const fileSize = await this._getFileSize(filePath);
         if (fileSize === 0) {
            throw new Error('Generated file is empty');
         }

         // Update job status
         await this.exportModel.updateExportJob(exportId, {
            status: 'C',
            file_path: filePath,
            file_size: fileSize,
            total_records: data.length
         });

         console.log(`✅ Export job ${exportId} completed`);

      } catch (error) {
         console.error(`❌ Export job ${exportId} failed:`, error);

         await this.exportModel.updateExportJob(exportId, {
            status: 'F',
            error_message: error.message
         });
      }
   }

   async _ensureDirectoryExists(dirPath) {
      try {
         await fs.access(dirPath);
      } catch {
         await fs.mkdir(dirPath, { recursive: true });
         console.log(`📁 Created directory: ${dirPath}`);
      }
   }

   async _generateExportFile(exportJob, data) {
      const config = exportJob.export_config || {};
      const format = config.format || 'xlsx';

      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const fileName = `${exportJob.export_type}_${exportJob.export_id}_${timestamp}.${format}`;

      const uploadsDir = path.join(process.cwd(), 'uploads', 'exports');
      const filePath = path.join(uploadsDir, fileName);

      if (format === 'xlsx') {
         await this._generateExcelFile(filePath, data);
      } else if (format === 'csv') {
         await this._generateCsvFile(filePath, data);
      } else {
         throw new Error(`Unsupported format: ${format}`);
      }

      return filePath;
   }

   /**
    * ดึงข้อมูลสำหรับ export ตาม type
    * @param {Object} exportJob - Export job
    * @returns {Promise<Array>} ข้อมูลที่จะ export
    * @private
    */
   async _fetchExportData(exportJob) {
      const { export_type, export_config } = exportJob;
      const config = export_config || {};

      switch (export_type) {
         case 'assets':
            return this._fetchAssetData(config);
         case 'scan_logs':
            return this._fetchScanLogData(config);
         case 'status_history':
            return this._fetchStatusHistoryData(config);
         default:
            throw new Error(`Unsupported export type: ${export_type}`);
      }
   }

   /**
    * ดึงข้อมูล assets
    * @param {Object} config - การตั้งค่า export
    * @returns {Promise<Array>} ข้อมูล assets
    * @private
    */
   async _fetchAssetData(config) {
      const { filters = {}, columns = [] } = config;

      // Build where conditions
      const whereConditions = {};

      if (filters.plant_codes && filters.plant_codes.length > 0) {
         whereConditions.plant_code = { in: filters.plant_codes };
      }

      if (filters.location_codes && filters.location_codes.length > 0) {
         whereConditions.location_code = { in: filters.location_codes };
      }

      if (filters.status && filters.status.length > 0) {
         whereConditions.status = { in: filters.status };
      }

      if (filters.date_range) {
         whereConditions.created_at = {};
         if (filters.date_range.from) {
            whereConditions.created_at.gte = new Date(filters.date_range.from);
         }
         if (filters.date_range.to) {
            whereConditions.created_at.lte = new Date(filters.date_range.to);
         }
      }

      const assets = await prisma.asset_master.findMany({
         where: whereConditions,
         include: {
            mst_plant: { select: { description: true } },
            mst_location: { select: { description: true } },
            mst_unit: { select: { name: true } },
            mst_user: { select: { full_name: true } }
         },
         orderBy: { asset_no: 'asc' }
      });

      // Format response to match original structure
      return assets.map(asset => ({
         asset_no: asset.asset_no,
         description: asset.description,
         serial_no: asset.serial_no,
         inventory_no: asset.inventory_no,
         quantity: asset.quantity,
         status: asset.status,
         created_at: asset.created_at,
         plant_description: asset.mst_plant?.description,
         location_description: asset.mst_location?.description,
         unit_name: asset.mst_unit?.name,
         created_by_name: asset.mst_user?.full_name
      }));
   }

   /**
    * ดึงข้อมูล scan logs
    * @param {Object} config - การตั้งค่า export
    * @returns {Promise<Array>} ข้อมูล scan logs
    * @private
    */
   async _fetchScanLogData(config) {
      const { filters = {} } = config;

      const whereConditions = {};

      if (filters.date_range) {
         whereConditions.scanned_at = {};
         if (filters.date_range.from) {
            whereConditions.scanned_at.gte = new Date(filters.date_range.from);
         }
         if (filters.date_range.to) {
            whereConditions.scanned_at.lte = new Date(filters.date_range.to);
         }
      }

      if (filters.plant_codes && filters.plant_codes.length > 0) {
         whereConditions.asset_master = {
            plant_code: { in: filters.plant_codes }
         };
      }

      const scanLogs = await prisma.asset_scan_log.findMany({
         where: whereConditions,
         include: {
            asset_master: {
               select: { description: true }
            },
            mst_user: {
               select: { full_name: true }
            },
            mst_location: {
               include: {
                  mst_plant: {
                     select: { description: true }
                  }
               }
            }
         },
         orderBy: { scanned_at: 'desc' }
      });

      return scanLogs.map(log => ({
         scan_id: log.scan_id,
         asset_no: log.asset_no,
         scanned_at: log.scanned_at,
         asset_description: log.asset_master?.description,
         scanned_by_name: log.mst_user?.full_name,
         location_description: log.mst_location?.description,
         plant_description: log.mst_location?.mst_plant?.description
      }));
   }

   /**
    * ดึงข้อมูล status history
    * @param {Object} config - การตั้งค่า export
    * @returns {Promise<Array>} ข้อมูล status history
    * @private
    */
   async _fetchStatusHistoryData(config) {
      const { filters = {} } = config;

      const whereConditions = {};

      if (filters.date_range) {
         whereConditions.changed_at = {};
         if (filters.date_range.from) {
            whereConditions.changed_at.gte = new Date(filters.date_range.from);
         }
         if (filters.date_range.to) {
            whereConditions.changed_at.lte = new Date(filters.date_range.to);
         }
      }

      if (filters.plant_codes && filters.plant_codes.length > 0) {
         whereConditions.asset_master = {
            plant_code: { in: filters.plant_codes }
         };
      }

      const statusHistory = await prisma.asset_status_history.findMany({
         where: whereConditions,
         include: {
            asset_master: {
               include: {
                  mst_plant: { select: { description: true } },
                  mst_location: { select: { description: true } }
               }
            },
            mst_user: {
               select: { full_name: true }
            }
         },
         orderBy: { changed_at: 'desc' }
      });

      return statusHistory.map(history => ({
         history_id: history.history_id,
         asset_no: history.asset_no,
         old_status: history.old_status,
         new_status: history.new_status,
         changed_at: history.changed_at,
         remarks: history.remarks,
         asset_description: history.asset_master?.description,
         changed_by_name: history.mst_user?.full_name,
         plant_description: history.asset_master?.mst_plant?.description,
         location_description: history.asset_master?.mst_location?.description
      }));
   }

   /**
    * สร้างไฟล์ export
    * @param {Object} exportJob - Export job
    * @param {Array} data - ข้อมูลที่จะ export
    * @returns {Promise<string>} path ของไฟล์ที่สร้าง
    * @private
    */
   async _generateExportFile(exportJob, data) {
      const config = exportJob.export_config || {};
      const format = config.format || 'xlsx';

      console.log('Export format:', format);
      console.log('Export config:', config);

      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const fileName = `${exportJob.export_type}_${exportJob.export_id}_${timestamp}.${format}`;

      console.log('File name:', fileName);

      // สร้าง directory ก่อน
      const uploadsDir = path.join(process.cwd(), 'uploads', 'exports');
      await this._ensureDirectoryExists(uploadsDir);

      const filePath = path.join(uploadsDir, fileName);

      if (format === 'xlsx') {
         await this._generateExcelFile(filePath, data);
      } else if (format === 'csv') {
         await this._generateCsvFile(filePath, data);
      } else {
         throw new Error(`Unsupported format: ${format}`);
      }

      return filePath;
   }

   /**
    * สร้างไฟล์ Excel
    * @param {string} filePath - path ของไฟล์
    * @param {Array} data - ข้อมูล
    * @private
    */
   async _generateExcelFile(filePath, data) {
      const workbook = XLSX.utils.book_new();
      const worksheet = XLSX.utils.json_to_sheet(data);

      XLSX.utils.book_append_sheet(workbook, worksheet, 'Export Data');
      XLSX.writeFile(workbook, filePath);
   }

   /**
    * สร้างไฟล์ CSV
    * @param {string} filePath - path ของไฟล์
    * @param {Array} data - ข้อมูล
    * @private
    */
   async _generateCsvFile(filePath, data) {
      if (data.length === 0) {
         await fs.writeFile(filePath, 'No data to export');
         return;
      }

      const headers = Object.keys(data[0]).map(key => ({
         id: key,
         title: key
      }));

      const csvWriter = createCsvWriter({
         path: filePath,
         header: headers
      });

      await csvWriter.writeRecords(data);
   }

   /**
    * ดึงข้อมูล export job
    * @param {number} exportId - Export ID
    * @returns {Promise<Object>} export job
    */
   async getExportJob(exportId) {
      return this.exportModel.getExportJobById(exportId);
   }

   /**
    * ดึงประวัติ export ของ user
    * @param {string} userId - User ID
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} รายการ export history
    */
   async getUserExportHistory(userId, options = {}) {
      return this.exportModel.getUserExportHistory(userId, options);
   }

   /**
    * ยกเลิก export job
    * @param {number} exportId - Export ID
    * @param {string} userId - User ID
    * @returns {Promise<boolean>} สำเร็จหรือไม่
    */
   async cancelExportJob(exportId, userId) {
      const exportJob = await this.exportModel.getExportJobById(exportId);

      if (!exportJob) {
         throw new Error('Export job not found');
      }

      if (exportJob.user_id !== userId) {
         throw new Error('Access denied');
      }

      if (exportJob.status !== 'P') {
         throw new Error('Cannot cancel completed or failed job');
      }

      return this.exportModel.deleteExportJob(exportId);
   }

   /**
    * ทำความสะอาดไฟล์หมดอายุ
    * @returns {Promise<number>} จำนวนไฟล์ที่ลบ
    */
   async cleanupExpiredFiles() {
      const expiredJobs = await this.exportModel.getExpiredJobs();
      let deletedCount = 0;

      for (const job of expiredJobs) {
         try {
            // ลบไฟล์
            if (job.file_path) {
               await fs.unlink(job.file_path);
            }

            // ลบ record จาก database
            await this.exportModel.deleteExportJob(job.export_id);

            deletedCount++;
            console.log(`Deleted expired export file: ${job.file_path}`);
         } catch (error) {
            console.error(`Failed to delete expired file ${job.file_path}:`, error.message);
         }
      }

      return deletedCount;
   }

   /**
    * @returns {Date} วันหมดอายุ
    * @private
    */
   _calculateExpiryDate() {
      const expiryDate = new Date();
      expiryDate.setHours(expiryDate.getHours() + 24);
      return expiryDate;
   }

   /**
    * สร้าง directory ถ้าไม่มี
    * @param {string} dirPath - path ของ directory
    * @private
    */
   async _ensureDirectoryExists(dirPath) {
      try {
         await fs.access(dirPath);
      } catch {
         await fs.mkdir(dirPath, { recursive: true });
      }
   }

   /**
    * ดึงขนาดไฟล์
    * @param {string} filePath - path ของไฟล์
    * @returns {Promise<number>} ขนาดไฟล์ (bytes)
    * @private
    */
   async _getFileSize(filePath) {
      try {
         const stats = await fs.stat(filePath);
         return stats.size;
      } catch {
         return 0;
      }
   }
}

module.exports = ExportService;