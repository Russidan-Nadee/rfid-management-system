// Path: src/models/exportModel.js
const { BaseModel } = require('../scan/scanModel');
const prisma = require('../../core/database/prisma');

class ExportModel extends BaseModel {
   constructor() {
      super('export_history');
   }

   /**
    * สร้าง export job ใหม่
    * @param {Object} exportData - ข้อมูล export job
    * @returns {Promise<Object>} export job ที่สร้างแล้ว
    */
   async createExportJob(exportData) {
      const newExport = await prisma.export_history.create({
         data: {
            user_id: exportData.user_id,
            export_type: exportData.export_type,
            status: exportData.status || 'P',
            export_config: exportData.export_config, // Prisma handles JSON automatically
            total_records: exportData.total_records || 0,
            created_at: new Date(),
            expires_at: exportData.expires_at
         }
      });

      return this.getExportJobById(newExport.export_id);
   }

   /**
    * ดึงข้อมูล export job ตาม ID
   * @param {number} exportId - Export ID
    * @returns {Promise<Object|null>} export job หรือ null
    */
   async getExportJobById(exportId) {
      return await prisma.export_history.findUnique({
         where: { export_id: exportId },
         include: {
            mst_user: {
               select: {
                  user_id: true,
                  full_name: true
               }
            }
         }
      });
   }

   /**
    * อัพเดท export job
    * @param {number} exportId - Export ID
    * @param {Object} updateData - ข้อมูลที่ต้องการอัพเดท
    * @returns {Promise<Object>} export job ที่อัพเดทแล้ว
    */
   async updateExportJob(exportId, updateData) {
      await prisma.export_history.update({
         where: { export_id: exportId },
         data: updateData
      });

      return this.getExportJobById(exportId);
   }

   /**
    * ดึงประวัติ export ของ user
    * @param {string} userId - User ID
    * @param {Object} options - ตัวเลือก (limit, offset, status)
    * @returns {Promise<Array>} รายการ export history
    */
   async getUserExportHistory(userId, options = {}) {
      const { limit = 50, offset = 0, status } = options;

      const whereConditions = { user_id: userId };
      if (status) {
         whereConditions.status = status;
      }

      return await prisma.export_history.findMany({
         where: whereConditions,
         include: {
            mst_user: {
               select: {
                  full_name: true
               }
            }
         },
         orderBy: { created_at: 'desc' },
         skip: offset,
         take: limit
      });
   }

   /**
    * ดึง export jobs ที่กำลัง process
    * @returns {Promise<Array>} รายการ jobs ที่ status = 'P'
    */
   async getPendingJobs() {
      return await prisma.export_history.findMany({
         where: { status: 'P' },
         orderBy: { created_at: 'asc' }
      });
   }

   /**
    * ดึง export jobs ที่หมดอายุแล้ว
    * @returns {Promise<Array>} รายการ jobs ที่หมดอายุ
    */
   async getExpiredJobs() {
      return await prisma.export_history.findMany({
         where: {
            expires_at: {
               lt: new Date()
            },
            status: 'C',
            file_path: {
               not: null
            }
         }
      });
   }

   /**
    * ลบ export job
    * @param {number} exportId - Export ID
    * @returns {Promise<boolean>} สำเร็จหรือไม่
    */
   async deleteExportJob(exportId) {
      try {
         await prisma.export_history.delete({
            where: { export_id: exportId }
         });
         return true;
      } catch (error) {
         if (error.code === 'P2025') { // Record not found
            return false;
         }
         throw error;
      }
   }

   /**
    * นับจำนวน export jobs ตาม status
    * @param {string} userId - User ID (optional)
    * @returns {Promise<Object>} จำนวนแยกตาม status
    */
   async getExportStats(userId = null) {
      const whereConditions = userId ? { user_id: userId } : {};

      const [pending, completed, failed] = await Promise.all([
         prisma.export_history.count({
            where: { ...whereConditions, status: 'P' }
         }),
         prisma.export_history.count({
            where: { ...whereConditions, status: 'C' }
         }),
         prisma.export_history.count({
            where: { ...whereConditions, status: 'F' }
         })
      ]);

      return {
         P: pending,
         C: completed,
         F: failed
      };
   }

   /**
    * ตรวจสอบว่า user มี pending jobs หรือไม่
    * @param {string} userId - User ID
    * @returns {Promise<boolean>} มี pending jobs หรือไม่
    */
   async hasPendingJobs(userId) {
      const count = await prisma.export_history.count({
         where: {
            user_id: userId,
            status: 'P'
         }
      });

      return count > 0;
   }

   /**
    * Raw query execution for backward compatibility
    * @param {string} query - SQL query
    * @param {Array} params - Query parameters
    * @returns {Promise<Array>} Query results
    */
   async executeQuery(query, params = []) {
      return await prisma.$queryRawUnsafe(query, ...params);
   }
}

module.exports = ExportModel;