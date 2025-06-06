// Path: backend/src/services/exportService.js
const ExportModel = require('../models/exportModel');
const { AssetModel, PlantModel, LocationModel, UnitModel, UserModel } = require('../models/model');
const path = require('path');
const fs = require('fs').promises;
const XLSX = require('xlsx');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

class ExportService {
   constructor() {
      this.exportModel = new ExportModel();
      this.assetModel = new AssetModel();
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
         const exportJob = await this.exportModel.getExportJobById(exportId);
         if (!exportJob) {
            throw new Error('Export job not found');
         }

         console.log(`Processing export job ${exportId}...`);

         // ดึงข้อมูลตาม export type
         const data = await this._fetchExportData(exportJob);

         // สร้างไฟล์
         const filePath = await this._generateExportFile(exportJob, data);

         // อัพเดท job เป็น completed
         await this.exportModel.updateExportJob(exportId, {
            status: 'C',
            file_path: filePath,
            file_size: await this._getFileSize(filePath),
            total_records: data.length
         });

         console.log(`Export job ${exportId} completed successfully`);

      } catch (error) {
         console.error(`Export job ${exportId} failed:`, error);

         // อัพเดท job เป็น failed
         await this.exportModel.updateExportJob(exportId, {
            status: 'F',
            error_message: error.message
         });
      }
   }

   /**
    * ดึงข้อมูลสำหรับ export ตาม type
    * @param {Object} exportJob - Export job
    * @returns {Promise<Array>} ข้อมูลที่จะ export
    * @private
    */
   async _fetchExportData(exportJob) {
      const { export_type, export_config } = exportJob;

      // Parse JSON config อย่างปลอดภัย
      let config;
      try {
         config = typeof export_config === 'string'
            ? JSON.parse(export_config)
            : export_config || {};
      } catch (error) {
         throw new Error(`Invalid export configuration: ${error.message}`);
      }

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

      // สร้าง WHERE clause จาก filters
      let whereClause = "a.status = 'A'";
      const params = [];

      if (filters.plant_codes && filters.plant_codes.length > 0) {
         whereClause += ` AND a.plant_code IN (${filters.plant_codes.map(() => '?').join(',')})`;
         params.push(...filters.plant_codes);
      }

      if (filters.location_codes && filters.location_codes.length > 0) {
         whereClause += ` AND a.location_code IN (${filters.location_codes.map(() => '?').join(',')})`;
         params.push(...filters.location_codes);
      }

      if (filters.status && filters.status.length > 0) {
         whereClause = whereClause.replace("a.status = 'A'",
            `a.status IN (${filters.status.map(() => '?').join(',')})`);
         params.push(...filters.status);
      }

      if (filters.date_range) {
         if (filters.date_range.from) {
            whereClause += ` AND a.created_at >= ?`;
            params.push(filters.date_range.from);
         }
         if (filters.date_range.to) {
            whereClause += ` AND a.created_at <= ?`;
            params.push(filters.date_range.to);
         }
      }

      // สร้าง SELECT columns
      const defaultColumns = [
         'a.asset_no', 'a.description', 'a.serial_no', 'a.inventory_no',
         'a.quantity', 'a.status', 'a.created_at',
         'p.description as plant_description',
         'l.description as location_description',
         'u.name as unit_name',
         'usr.full_name as created_by_name'
      ];

      const selectColumns = columns.length > 0 ? columns : defaultColumns;

      const query = `
         SELECT ${selectColumns.join(', ')}
         FROM asset_master a
         LEFT JOIN mst_plant p ON a.plant_code = p.plant_code
         LEFT JOIN mst_location l ON a.location_code = l.location_code
         LEFT JOIN mst_unit u ON a.unit_code = u.unit_code
         LEFT JOIN mst_user usr ON a.created_by = usr.user_id
         WHERE ${whereClause}
         ORDER BY a.asset_no
      `;

      return this.exportModel.executeQuery(query, params);
   }

   /**
    * ดึงข้อมูล scan logs
    * @param {Object} config - การตั้งค่า export
    * @returns {Promise<Array>} ข้อมูล scan logs
    * @private
    */
   async _fetchScanLogData(config) {
      const { filters = {} } = config;

      let whereClause = "1=1";
      const params = [];

      if (filters.date_range) {
         if (filters.date_range.from) {
            whereClause += ` AND s.scanned_at >= ?`;
            params.push(filters.date_range.from);
         }
         if (filters.date_range.to) {
            whereClause += ` AND s.scanned_at <= ?`;
            params.push(filters.date_range.to);
         }
      }

      const query = `
         SELECT 
            s.scan_id, s.asset_no, s.scanned_at,
            a.description as asset_description,
            u.full_name as scanned_by_name,
            l.description as location_description
         FROM asset_scan_log s
         LEFT JOIN asset_master a ON s.asset_no = a.asset_no
         LEFT JOIN mst_user u ON s.scanned_by = u.user_id
         LEFT JOIN mst_location l ON s.location_code = l.location_code
         WHERE ${whereClause}
         ORDER BY s.scanned_at DESC
      `;

      return this.exportModel.executeQuery(query, params);
   }

   /**
    * ดึงข้อมูล status history
    * @param {Object} config - การตั้งค่า export
    * @returns {Promise<Array>} ข้อมูล status history
    * @private
    */
   async _fetchStatusHistoryData(config) {
      const { filters = {} } = config;

      let whereClause = "1=1";
      const params = [];

      if (filters.date_range) {
         if (filters.date_range.from) {
            whereClause += ` AND h.changed_at >= ?`;
            params.push(filters.date_range.from);
         }
         if (filters.date_range.to) {
            whereClause += ` AND h.changed_at <= ?`;
            params.push(filters.date_range.to);
         }
      }

      const query = `
         SELECT 
            h.history_id, h.asset_no, h.old_status, h.new_status,
            h.changed_at, h.remarks,
            a.description as asset_description,
            u.full_name as changed_by_name
         FROM asset_status_history h
         LEFT JOIN asset_master a ON h.asset_no = a.asset_no
         LEFT JOIN mst_user u ON h.changed_by = u.user_id
         WHERE ${whereClause}
         ORDER BY h.changed_at DESC
      `;

      return this.assetModel.executeQuery(query, params);
   }

   /**
    * สร้างไฟล์ export
    * @param {Object} exportJob - Export job
    * @param {Array} data - ข้อมูลที่จะ export
    * @returns {Promise<string>} path ของไฟล์ที่สร้าง
    * @private
    */
   async _generateExportFile(exportJob, data) {
      const config = JSON.parse(exportJob.export_config);
      const format = config.format || 'xlsx';

      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const fileName = `${exportJob.export_type}_${exportJob.export_id}_${timestamp}.${format}`;

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
            await fs.unlink(job.file_path);

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
    * คำนวณวันหมดอายุ (7 วันจากตอนนี้)
    * @returns {Date} วันหมดอายุ
    * @private
    */
   _calculateExpiryDate() {
      const expiryDate = new Date();
      expiryDate.setDate(expiryDate.getDate() + 7);
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