// Path: backend/src/models/exportModel.js
const { BaseModel } = require('./model');

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
      const query = `
         INSERT INTO export_history (
            user_id, export_type, status, export_config,
            total_records, created_at, expires_at
         ) VALUES (?, ?, ?, ?, ?, NOW(), ?)
      `;

      // แปลง export_config เป็น JSON string อย่างปลอดภัย
      const configJson = typeof exportData.export_config === 'string'
         ? exportData.export_config
         : JSON.stringify(exportData.export_config || {});

      const params = [
         exportData.user_id,
         exportData.export_type,
         exportData.status || 'P',
         configJson,
         exportData.total_records || 0,
         exportData.expires_at
      ];

      const result = await this.executeQuery(query, params);
      return this.getExportJobById(result.insertId);
   }

   /**
    * ดึงข้อมูล export job ตาม ID
    * @param {number} exportId - Export ID
    * @returns {Promise<Object|null>} export job หรือ null
    */
   async getExportJobById(exportId) {
      const query = `
         SELECT e.*, u.full_name as user_name 
         FROM export_history e
         LEFT JOIN mst_user u ON e.user_id = u.user_id
         WHERE e.export_id = ?
      `;

      const results = await this.executeQuery(query, [exportId]);
      return results[0] || null;
   }

   /**
    * อัพเดท export job
    * @param {number} exportId - Export ID
    * @param {Object} updateData - ข้อมูลที่ต้องการอัพเดท
    * @returns {Promise<Object>} export job ที่อัพเดทแล้ว
    */
   async updateExportJob(exportId, updateData) {
      const setClause = Object.keys(updateData)
         .map(key => `${key} = ?`)
         .join(', ');

      const query = `UPDATE export_history SET ${setClause} WHERE export_id = ?`;
      const params = [...Object.values(updateData), exportId];

      await this.executeQuery(query, params);
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

      let query = `
         SELECT e.*, u.full_name as user_name
         FROM export_history e
         LEFT JOIN mst_user u ON e.user_id = u.user_id
         WHERE e.user_id = ?
      `;

      const params = [userId];

      if (status) {
         query += ` AND e.status = ?`;
         params.push(status);
      }

      query += ` ORDER BY e.created_at DESC LIMIT ? OFFSET ?`;
      params.push(limit, offset);

      return this.executeQuery(query, params);
   }

   /**
    * ดึง export jobs ที่กำลัง process
    * @returns {Promise<Array>} รายการ jobs ที่ status = 'P'
    */
   async getPendingJobs() {
      const query = `
         SELECT * FROM export_history 
         WHERE status = 'P' 
         ORDER BY created_at ASC
      `;
      return this.executeQuery(query);
   }

   /**
    * ดึง export jobs ที่หมดอายุแล้ว
    * @returns {Promise<Array>} รายการ jobs ที่หมดอายุ
    */
   async getExpiredJobs() {
      const query = `
         SELECT * FROM export_history 
         WHERE expires_at < NOW() 
         AND status = 'C'
         AND file_path IS NOT NULL
      `;
      return this.executeQuery(query);
   }

   /**
    * ลบ export job
    * @param {number} exportId - Export ID
    * @returns {Promise<boolean>} สำเร็จหรือไม่
    */
   async deleteExportJob(exportId) {
      const query = `DELETE FROM export_history WHERE export_id = ?`;
      const result = await this.executeQuery(query, [exportId]);
      return result.affectedRows > 0;
   }

   /**
    * นับจำนวน export jobs ตาม status
    * @param {string} userId - User ID (optional)
    * @returns {Promise<Object>} จำนวนแยกตาม status
    */
   async getExportStats(userId = null) {
      let query = `
         SELECT 
            status,
            COUNT(*) as count
         FROM export_history
      `;

      const params = [];

      if (userId) {
         query += ` WHERE user_id = ?`;
         params.push(userId);
      }

      query += ` GROUP BY status`;

      const results = await this.executeQuery(query, params);

      // แปลงเป็น object
      const stats = { P: 0, C: 0, F: 0 };
      results.forEach(row => {
         stats[row.status] = row.count;
      });

      return stats;
   }

   /**
    * ตรวจสอบว่า user มี pending jobs หรือไม่
    * @param {string} userId - User ID
    * @returns {Promise<boolean>} มี pending jobs หรือไม่
    */
   async hasPendingJobs(userId) {
      const query = `
         SELECT COUNT(*) as count 
         FROM export_history 
         WHERE user_id = ? AND status = 'P'
      `;

      const result = await this.executeQuery(query, [userId]);
      return result[0].count > 0;
   }
}

module.exports = ExportModel;