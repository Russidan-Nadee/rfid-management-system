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

         // Fetch data - รองรับเฉพาะ assets
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
    * ดึงข้อมูลสำหรับ export - รองรับเฉพาะ assets
    * @param {Object} exportJob - Export job
    * @returns {Promise<Array>} ข้อมูลที่จะ export
    * @private
    */
   async _fetchExportData(exportJob) {
      const { export_type } = exportJob;

      // รองรับเฉพาะ assets export
      if (export_type === 'assets') {
         return this._fetchAssetData(exportJob.export_config || {});
      } else {
         throw new Error(`Export type '${export_type}' is no longer supported. Only 'assets' export is available.`);
      }
   }

   /**
    * ดึงข้อมูล assets พร้อมทุก field และ master data
    * @param {Object} config - การตั้งค่า export
    * @returns {Promise<Array>} ข้อมูล assets ครบทั้งหมด 24 columns
    * @private
    */
   async _fetchAssetData(config) {
      const { filters = {} } = config;

      // Apply business rules และ default period
      const processedFilters = this._applyBusinessRulesForAssets(filters);

      // Build where conditions
      const whereConditions = {};
      console.log('🗄️ Database whereConditions:', JSON.stringify(whereConditions, null, 2));

      // Plant filter
      if (processedFilters.plant_codes && processedFilters.plant_codes.length > 0) {
         whereConditions.plant_code = { in: processedFilters.plant_codes };
      }

      // Location filter
      if (processedFilters.location_codes && processedFilters.location_codes.length > 0) {
         whereConditions.location_code = { in: processedFilters.location_codes };
      }

      // Status filter
      if (processedFilters.status && processedFilters.status.length > 0) {
         whereConditions.status = { in: processedFilters.status };
      }

      // Period filter - ใช้ created_at field (หลังจาก business rules แล้ว)
      if (processedFilters.date_range) {
         whereConditions.created_at = {};
         if (processedFilters.date_range.from) {
            whereConditions.created_at.gte = new Date(processedFilters.date_range.from);
         }
         if (processedFilters.date_range.to) {
            whereConditions.created_at.lte = new Date(processedFilters.date_range.to);
         }
      }

      // ดึงข้อมูล assets พร้อม include ทุก master tables
      const assets = await prisma.asset_master.findMany({
         where: whereConditions,
         include: {
            mst_plant: {
               select: {
                  plant_code: true,
                  description: true
               }
            },
            mst_location: {
               select: {
                  location_code: true,
                  description: true
               }
            },
            mst_unit: {
               select: {
                  unit_code: true,
                  name: true
               }
            },
            mst_department: {
               select: {
                  dept_code: true,
                  description: true
               }
            },
            mst_category: {
               select: {
                  category_code: true,
                  category_name: true,
                  description: true
               }
            },
            mst_brand: {
               select: {
                  brand_code: true,
                  brand_name: true,
                  description: true
               }
            },
            mst_user: {
               select: {
                  user_id: true,
                  full_name: true
               }
            }
         },
         orderBy: { asset_no: 'asc' }
      });

      // Return ทุก field ครบทั้งหมด 24 columns
      return assets.map(asset => ({
         // Asset Master Fields ทั้งหมด (15 fields)
         asset_no: asset.asset_no,
         description: asset.description,
         plant_code: asset.plant_code,
         location_code: asset.location_code,
         dept_code: asset.dept_code,
         serial_no: asset.serial_no,
         inventory_no: asset.inventory_no,
         quantity: asset.quantity,
         unit_code: asset.unit_code,
         category_code: asset.category_code,
         brand_code: asset.brand_code,
         status: asset.status,
         created_by: asset.created_by,
         created_at: asset.created_at,
         deactivated_at: asset.deactivated_at,

         // Master Data Descriptions (9 fields)
         plant_description: asset.mst_plant?.description,
         location_description: asset.mst_location?.description,
         department_description: asset.mst_department?.description,
         unit_name: asset.mst_unit?.name,
         category_name: asset.mst_category?.category_name,
         category_description: asset.mst_category?.description,
         brand_name: asset.mst_brand?.brand_name,
         brand_description: asset.mst_brand?.description,
         created_by_name: asset.mst_user?.full_name
      }));
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

      XLSX.utils.book_append_sheet(workbook, worksheet, 'Assets Export');
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
    * ใช้ business rules สำหรับ assets export
    * @param {Object} filters - filters จาก request
    * @returns {Object} processed filters
    * @private
    */
   _applyBusinessRulesForAssets(filters) {
      let processedFilters = { ...filters };
      console.log('🔍 Input filters:', JSON.stringify(filters, null, 2));

      // 1. Date Range Validation และ Default Setting
      if (!processedFilters.date_range) {
         console.log('📅 Checking date_range:', processedFilters.date_range);
         // ถ้าไม่มี date_range เซ็ต default เป็น 30 วันล่าสุด
         const now = new Date();
         const thirtyDaysAgo = new Date();
         thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

         processedFilters.date_range = {
            from: thirtyDaysAgo.toISOString(),
            to: now.toISOString()
         };

         console.log('📅 Applied default 30-day period for assets export');
      } else {
         // 2. Re-validate date range สำหรับ security
         const validation = this._validateDateRange(processedFilters.date_range);
         if (!validation.isValid) {
            throw new Error(`Invalid date range: ${validation.errors.join(', ')}`);
         }

         // 3. Log warning สำหรับ large date ranges
         const daysDiff = this._calculateDaysDifference(
            processedFilters.date_range.from,
            processedFilters.date_range.to
         );

         if (daysDiff > 180) { // มากกว่า 6 เดือน
            console.warn(`⚠️  Large date range: ${daysDiff} days in assets export`);
         }
      }

      // 4. Status Filter Default (ถ้าไม่ระบุ ให้ export ทุก status)
      if (!processedFilters.status || processedFilters.status.length === 0) {
         console.log('📊 No status filter specified, exporting all statuses (A, C, I)');
      }

      return processedFilters;
      console.log('✅ Final processed filters:', JSON.stringify(processedFilters, null, 2));
   }

   /**
    * Validate date range (business layer validation)
    * @param {Object} dateRange - {from, to}
    * @returns {Object} {isValid, errors}
    * @private
    */
   _validateDateRange(dateRange) {
      const errors = [];

      try {
         const from = new Date(dateRange.from);
         const to = new Date(dateRange.to);
         const now = new Date();
         const twoYearsAgo = new Date();
         twoYearsAgo.setFullYear(twoYearsAgo.getFullYear() - 2);

         // Check date validity
         if (isNaN(from.getTime()) || isNaN(to.getTime())) {
            errors.push('Invalid date format');
         }

         // Check logical order
         if (from >= to) {
            errors.push('From date must be before to date');
         }

         // Check reasonable bounds
         if (from < twoYearsAgo) {
            errors.push('From date cannot be more than 2 years ago');
         }

         if (to > now) {
            errors.push('To date cannot be in the future');
         }

         // Check range size (1 year limit)
         const daysDiff = (to - from) / (1000 * 60 * 60 * 24);
         if (daysDiff > 365) {
            errors.push('Date range cannot exceed 1 year');
         }

      } catch (error) {
         errors.push('Date processing error');
      }

      return {
         isValid: errors.length === 0,
         errors
      };
   }

   /**
    * Calculate days difference between two dates
    * @param {string} fromDate - ISO date string
    * @param {string} toDate - ISO date string  
    * @returns {number} days difference
    * @private
    */
   _calculateDaysDifference(fromDate, toDate) {
      const from = new Date(fromDate);
      const to = new Date(toDate);
      return Math.ceil((to - from) / (1000 * 60 * 60 * 24));
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