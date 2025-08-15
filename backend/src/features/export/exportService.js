// Path: backend/src/features/export/exportService.js
const ExportModel = require('./exportModel');
const ExportDateUtils = require('./exportDateUtils');
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

      // Parse and validate export config
      let config;
      try {
         config = typeof exportConfig === 'string' ? JSON.parse(exportConfig) : exportConfig;
      } catch (error) {
         throw new Error('Invalid export configuration format');
      }

      // Validate and normalize date configuration
      try {
         config = ExportDateUtils.validateAndNormalizeDateConfig(config);
      } catch (error) {
         throw new Error(`Date configuration error: ${error.message}`);
      }

      // สร้าง export job
      const jobData = {
         user_id: userId,
         export_type: exportType,
         export_config: JSON.stringify(config),
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
      // Parse export_config ถ้าเป็น string
      let config;
      if (typeof exportJob.export_config === 'string') {
         try {
            config = JSON.parse(exportJob.export_config);
            console.log('🔍 Parsed config from string:', config);
         } catch (error) {
            console.error('Error parsing export_config:', error);
            config = {};
         }
      } else {
         config = exportJob.export_config || {};
      }

      const format = config.format || 'xlsx';
      console.log('🔍 Final format to generate:', format);

      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const fileName = `${exportJob.export_type}_${exportJob.export_id}_${timestamp}.${format}`;

      const uploadsDir = path.join(process.cwd(), 'uploads', 'exports');
      const filePath = path.join(uploadsDir, fileName);

      console.log(`💾 Generating ${format.toUpperCase()} file: ${fileName}`);

      if (format === 'xlsx') {
         await this._generateExcelFile(filePath, data);
      } else if (format === 'csv') {
         await this._generateCsvFile(filePath, data);
      } else {
         throw new Error(`Unsupported format: ${format}`);
      }

      console.log(`✅ File generated successfully: ${filePath}`);
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

      // Parse export_config if it's a string
      let config = exportJob.export_config || {};
      if (typeof config === 'string') {
         try {
            config = JSON.parse(config);
         } catch (error) {
            console.error('Failed to parse export_config:', error);
            config = {};
         }
      }

      // รองรับเฉพาะ assets export
      if (export_type === 'assets') {
         return this._fetchAssetData(config);
      } else {
         throw new Error(`Export type '${export_type}' is no longer supported. Only 'assets' export is available.`);
      }
   }

   /**
    * ดึงข้อมูล assets พร้อมทุก field และ master data (รองรับ date range filtering)
    * @param {Object} config - การตั้งค่า export
    * @returns {Promise<Array>} ข้อมูล assets ครบทั้งหมด 24 columns
    * @private
    */
   async _fetchAssetData(config) {
      const { filters = {} } = config;

      console.log('🗄️ Fetching assets data');
      console.log('🔍 Full config received:', JSON.stringify(config, null, 2));

      // Build where conditions
      const whereConditions = {};

      // Plant filter
      if (filters.plant_codes && filters.plant_codes.length > 0) {
         whereConditions.plant_code = { in: filters.plant_codes };
         console.log(`🏭 Plant filter: ${filters.plant_codes.join(', ')}`);
      }

      // Location filter
      if (filters.location_codes && filters.location_codes.length > 0) {
         whereConditions.location_code = { in: filters.location_codes };
         console.log(`📍 Location filter: ${filters.location_codes.join(', ')}`);
      }

      // Status filter
      if (filters.status && filters.status.length > 0) {
         whereConditions.status = { in: filters.status };
         console.log(`📊 Status filter: ${filters.status.join(', ')}`);
      }

      // Date range filter - now inside filters object
      const dateRange = filters.date_range;
      if (dateRange) {
         console.log('📅 Date range config found:', JSON.stringify(dateRange, null, 2));
         
         // Handle different period types
         // Map frontend field names to database field names
         const fieldMapping = {
            'created_at': 'created_at',
            'updated_at': 'last_update', // Map frontend 'updated_at' to database 'last_update'
            'last_update': 'last_update',
            'deactivated_at': 'deactivated_at',
            'last_scan_date': 'last_scan_date'
         };
         
         if (dateRange.period === 'custom' && dateRange.custom_start_date && dateRange.custom_end_date) {
            // Custom date range
            const frontendField = dateRange.field || 'created_at';
            const dateField = fieldMapping[frontendField] || frontendField;
            ExportDateUtils.applyDateRangeFilter(
               whereConditions, 
               dateField, 
               dateRange.custom_start_date, 
               dateRange.custom_end_date
            );
            console.log(`📅 Custom date range filter on ${frontendField} (${dateField}): ${dateRange.custom_start_date} to ${dateRange.custom_end_date}`);
         } else if (dateRange.period && dateRange.period !== 'custom') {
            // Predefined period - calculate dates
            const frontendField = dateRange.field || 'created_at';
            const dateField = fieldMapping[frontendField] || frontendField;
            const { start_date, end_date } = ExportDateUtils.getDateRangeForPeriod(dateRange.period);
            ExportDateUtils.applyDateRangeFilter(
               whereConditions, 
               dateField, 
               start_date, 
               end_date
            );
            console.log(`📅 Period filter (${dateRange.period}) on ${frontendField} (${dateField}): ${start_date} to ${end_date}`);
         }
      } else {
         console.log('📅 No date range filter - exporting all historical data');
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

      console.log(`✅ Retrieved ${assets.length} assets`);

      // Log status distribution for verification
      const statusCounts = {};
      assets.forEach(asset => {
         statusCounts[asset.status] = (statusCounts[asset.status] || 0) + 1;
      });
      console.log('📊 Status distribution:', statusCounts);

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