// Path: backend/src/models/departmentModel.js
const { BaseModel } = require('./model');

class DepartmentModel extends BaseModel {
   constructor() {
      super('mst_department');
   }

   async getAllDepartments() {
      return this.findAll({}, 'dept_code');
   }

   async getDepartmentByCode(deptCode) {
      return this.findById(deptCode, 'dept_code');
   }

   async getDepartmentsByPlant(plantCode) {
      return this.findAll({ plant_code: plantCode }, 'dept_code');
   }

   async getDepartmentsWithPlant() {
      const query = `
         SELECT d.*, p.description as plant_description 
         FROM mst_department d
         LEFT JOIN mst_plant p ON d.plant_code = p.plant_code
         ORDER BY d.dept_code
      `;
      return this.executeQuery(query);
   }

   async getDepartmentStats() {
      const query = `
         SELECT 
            d.dept_code,
            d.description as dept_description,
            d.plant_code,
            p.description as plant_description,
            COUNT(a.asset_no) as asset_count,
            SUM(CASE WHEN a.status = 'A' THEN 1 ELSE 0 END) as active_assets,
            SUM(CASE WHEN a.status = 'I' THEN 1 ELSE 0 END) as inactive_assets,
            SUM(CASE WHEN a.status = 'C' THEN 1 ELSE 0 END) as created_assets
         FROM mst_department d
         LEFT JOIN mst_plant p ON d.plant_code = p.plant_code
         LEFT JOIN asset_master a ON d.dept_code = a.dept_code
         GROUP BY d.dept_code, d.description, d.plant_code, p.description
         ORDER BY d.dept_code
      `;
      return this.executeQuery(query);
   }

   async getAssetGrowthTrends(deptCode = null, startDate, endDate) {
      let query = `
         SELECT 
            DATE_FORMAT(a.created_at, '%Y-%m') as month_year,
            COUNT(*) as asset_count,
            d.dept_code,
            d.description as dept_description
         FROM asset_master a
         LEFT JOIN mst_department d ON a.dept_code = d.dept_code
         WHERE a.created_at >= ? AND a.created_at <= ?
      `;
      const params = [startDate, endDate];

      if (deptCode) {
         query += ` AND a.dept_code = ?`;
         params.push(deptCode);
      }

      query += `
         GROUP BY DATE_FORMAT(a.created_at, '%Y-%m'), d.dept_code, d.description
         ORDER BY month_year, d.dept_code
      `;

      return this.executeQuery(query, params);
   }

   async getQuarterlyGrowth(deptCode = null, year = new Date().getFullYear()) {
      let query = `
         SELECT 
            QUARTER(a.created_at) as quarter,
            COUNT(*) as asset_count,
            d.dept_code,
            d.description as dept_description
         FROM asset_master a
         LEFT JOIN mst_department d ON a.dept_code = d.dept_code
         WHERE YEAR(a.created_at) = ?
      `;
      const params = [year];

      if (deptCode) {
         query += ` AND a.dept_code = ?`;
         params.push(deptCode);
      }

      query += `
         GROUP BY QUARTER(a.created_at), d.dept_code, d.description
         ORDER BY quarter, d.dept_code
      `;

      return this.executeQuery(query, params);
   }

   async getLocationAssetStats(locationCode = null) {
      let query = `
         SELECT 
            l.location_code,
            l.description as location_description,
            l.plant_code,
            p.description as plant_description,
            COUNT(a.asset_no) as total_assets,
            SUM(CASE WHEN a.status = 'A' THEN 1 ELSE 0 END) as active_assets,
            SUM(CASE WHEN a.status = 'I' THEN 1 ELSE 0 END) as inactive_assets,
            SUM(CASE WHEN a.status = 'C' THEN 1 ELSE 0 END) as created_assets,
            COUNT(DISTINCT a.dept_code) as department_count,
            COUNT(s.scan_id) as total_scans,
            MAX(s.scanned_at) as last_scan_date
         FROM mst_location l
         LEFT JOIN mst_plant p ON l.plant_code = p.plant_code
         LEFT JOIN asset_master a ON l.location_code = a.location_code
         LEFT JOIN asset_scan_log s ON a.asset_no = s.asset_no
      `;
      const params = [];

      if (locationCode) {
         query += ` WHERE l.location_code = ?`;
         params.push(locationCode);
      }

      query += `
         GROUP BY l.location_code, l.description, l.plant_code, p.description
         ORDER BY l.location_code
      `;

      return this.executeQuery(query, params);
   }

   async getLocationGrowthTrends(locationCode, startDate, endDate) {
      const query = `
         SELECT 
            DATE_FORMAT(a.created_at, '%Y-%m') as month_year,
            COUNT(*) as asset_count,
            SUM(CASE WHEN a.status = 'A' THEN 1 ELSE 0 END) as active_count,
            l.location_code,
            l.description as location_description
         FROM asset_master a
         JOIN mst_location l ON a.location_code = l.location_code
         WHERE a.location_code = ? 
           AND a.created_at >= ? 
           AND a.created_at <= ?
         GROUP BY DATE_FORMAT(a.created_at, '%Y-%m'), l.location_code, l.description
         ORDER BY month_year
      `;
      return this.executeQuery(query, [locationCode, startDate, endDate]);
   }

   async getAuditProgress(deptCode = null) {
      // Note: This assumes there's an audit tracking mechanism
      // For now, we'll simulate with asset scan data
      let query = `
         SELECT 
            d.dept_code,
            d.description as dept_description,
            COUNT(DISTINCT a.asset_no) as total_assets,
            COUNT(DISTINCT CASE 
               WHEN s.scanned_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR) 
               THEN a.asset_no 
            END) as audited_assets,
            COUNT(DISTINCT CASE 
               WHEN s.scanned_at < DATE_SUB(NOW(), INTERVAL 1 YEAR) 
                 OR s.scanned_at IS NULL 
               THEN a.asset_no 
            END) as pending_audit,
            ROUND(
               (COUNT(DISTINCT CASE 
                  WHEN s.scanned_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR) 
                  THEN a.asset_no 
               END) * 100.0 / COUNT(DISTINCT a.asset_no)), 2
            ) as completion_percentage
         FROM mst_department d
         LEFT JOIN asset_master a ON d.dept_code = a.dept_code AND a.status IN ('A', 'C')
         LEFT JOIN asset_scan_log s ON a.asset_no = s.asset_no
      `;
      const params = [];

      if (deptCode) {
         query += ` WHERE d.dept_code = ?`;
         params.push(deptCode);
      }

      query += `
         GROUP BY d.dept_code, d.description
         ORDER BY d.dept_code
      `;

      return this.executeQuery(query, params);
   }

   async getDetailedAuditProgress(deptCode = null) {
      let query = `
         SELECT 
            a.asset_no,
            a.description as asset_description,
            a.dept_code,
            d.description as dept_description,
            MAX(s.scanned_at) as last_audit_date,
            CASE 
               WHEN MAX(s.scanned_at) >= DATE_SUB(NOW(), INTERVAL 1 YEAR) THEN 'audited'
               WHEN MAX(s.scanned_at) IS NULL THEN 'never_audited'
               ELSE 'overdue'
            END as audit_status,
            DATEDIFF(NOW(), MAX(s.scanned_at)) as days_since_audit
         FROM asset_master a
         LEFT JOIN mst_department d ON a.dept_code = d.dept_code
         LEFT JOIN asset_scan_log s ON a.asset_no = s.asset_no
         WHERE a.status IN ('A', 'C')
      `;
      const params = [];

      if (deptCode) {
         query += ` AND a.dept_code = ?`;
         params.push(deptCode);
      }

      query += `
         GROUP BY a.asset_no, a.description, a.dept_code, d.description
         ORDER BY audit_status, days_since_audit DESC
      `;

      return this.executeQuery(query, params);
   }
}

module.exports = DepartmentModel;