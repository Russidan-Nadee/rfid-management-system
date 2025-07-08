// Path: backend/src/models/departmentModel.js
const prisma = require('../../lib/prisma');

class DepartmentModel {
   constructor() {
      // ไม่ใช้ BaseModel แล้ว ใช้ Prisma โดยตรง
   }

   async getAllDepartments() {
      try {
         return await prisma.mst_department.findMany({
            orderBy: { dept_code: 'asc' }
         });
      } catch (error) {
         throw new Error(`Error fetching departments: ${error.message}`);
      }
   }

   async getDepartmentByCode(deptCode) {
      try {
         return await prisma.mst_department.findUnique({
            where: { dept_code: deptCode }
         });
      } catch (error) {
         throw new Error(`Error fetching department: ${error.message}`);
      }
   }

   async getDepartmentsByPlant(plantCode) {
      try {
         return await prisma.mst_department.findMany({
            where: { plant_code: plantCode },
            orderBy: { dept_code: 'asc' }
         });
      } catch (error) {
         throw new Error(`Error fetching departments by plant: ${error.message}`);
      }
   }

   async getDepartmentsWithPlant() {
      try {
         return await prisma.mst_department.findMany({
            include: {
               mst_plant: {
                  select: {
                     description: true
                  }
               }
            },
            orderBy: { dept_code: 'asc' }
         });
      } catch (error) {
         throw new Error(`Error fetching departments with plant details: ${error.message}`);
      }
   }

   async getDepartmentStats() {
      try {
         return await prisma.mst_department.findMany({
            select: {
               dept_code: true,
               description: true,
               plant_code: true,
               mst_plant: {
                  select: {
                     description: true
                  }
               },
               asset_master: {
                  select: {
                     asset_no: true,
                     status: true
                  }
               }
            },
            orderBy: { dept_code: 'asc' }
         });
      } catch (error) {
         throw new Error(`Error fetching department statistics: ${error.message}`);
      }
   }

   async count(filters = {}) {
      try {
         return await prisma.mst_department.count({
            where: filters
         });
      } catch (error) {
         throw new Error(`Error counting departments: ${error.message}`);
      }
   }

   async getAssetGrowthTrends(deptCode = null, startDate, endDate, groupBy = 'day') {
      try {
         const groupByFormats = {
            'day': '%Y-%m-%d',
            'month': '%Y-%m',
            'year': '%Y'
         };

         const format = groupByFormats[groupBy] || '%Y-%m-%d';

         let query = `
            SELECT 
              period,
              CAST(SUM(daily_count) OVER (ORDER BY period) AS UNSIGNED) as asset_count,
              dept_code,
              dept_description
            FROM (
              SELECT 
                DATE_FORMAT(a.created_at, '${format}') as period,
                COUNT(*) as daily_count,
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
               GROUP BY DATE_FORMAT(a.created_at, '${format}'), d.dept_code, d.description
             ) daily_counts
             ORDER BY period, dept_code
         `;

         // ใช้ raw query เพราะ complex aggregation
         const result = await prisma.$queryRawUnsafe(query, ...params);

         // Convert BigInt to Number
         return result.map(row => ({
            ...row,
            asset_count: Number(row.asset_count)
         }));
      } catch (error) {
         throw new Error(`Error fetching asset growth trends: ${error.message}`);
      }
   }

   async getQuarterlyGrowth(deptCode = null, year = new Date().getFullYear()) {
      try {
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

         const result = await prisma.$queryRawUnsafe(query, ...params);

         // Convert BigInt to Number
         return result.map(row => ({
            ...row,
            quarter: Number(row.quarter),
            asset_count: Number(row.asset_count)
         }));
      } catch (error) {
         throw new Error(`Error fetching quarterly growth: ${error.message}`);
      }
   }

   async getLocationAssetStats(locationCode = null) {
      try {
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

         const result = await prisma.$queryRawUnsafe(query, ...params);

         // Convert BigInt to Number
         return result.map(row => ({
            ...row,
            total_assets: Number(row.total_assets),
            active_assets: Number(row.active_assets),
            inactive_assets: Number(row.inactive_assets),
            created_assets: Number(row.created_assets),
            department_count: Number(row.department_count),
            total_scans: Number(row.total_scans)
         }));
      } catch (error) {
         throw new Error(`Error fetching location asset stats: ${error.message}`);
      }
   }

   async getLocationGrowthTrends(locationCode, startDate, endDate) {
      try {
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

         const result = await prisma.$queryRawUnsafe(query, locationCode, startDate, endDate);

         // Convert BigInt to Number
         return result.map(row => ({
            ...row,
            asset_count: Number(row.asset_count),
            active_count: Number(row.active_count)
         }));
      } catch (error) {
         throw new Error(`Error fetching location growth trends: ${error.message}`);
      }
   }

   async getAuditProgress(deptCode = null) {
      try {
         let query = `
            SELECT 
              d.dept_code,
              d.description as dept_description,
              COUNT(DISTINCT a.asset_no) as total_assets,
              COUNT(DISTINCT CASE WHEN a.status = 'C' THEN a.asset_no END) as audited_assets,
              COUNT(DISTINCT CASE WHEN a.status = 'A' THEN a.asset_no END) as pending_audit,
              ROUND(
                (COUNT(DISTINCT CASE WHEN a.status = 'C' THEN a.asset_no END) * 100.0 / 
                 COUNT(DISTINCT a.asset_no)), 2
              ) as completion_percentage
            FROM mst_department d
            LEFT JOIN asset_master a ON d.dept_code = a.dept_code AND a.status IN ('A', 'C')
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

         const result = await prisma.$queryRawUnsafe(query, ...params);

         // Convert BigInt to Number
         return result.map(row => ({
            ...row,
            total_assets: Number(row.total_assets),
            audited_assets: Number(row.audited_assets),
            pending_audit: Number(row.pending_audit),
            completion_percentage: Number(row.completion_percentage)
         }));
      } catch (error) {
         throw new Error(`Error fetching audit progress: ${error.message}`);
      }
   }

   async getDetailedAuditProgress(deptCode = null) {
      try {
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

         const result = await prisma.$queryRawUnsafe(query, ...params);

         // Convert BigInt to Number
         return result.map(row => ({
            ...row,
            days_since_audit: row.days_since_audit ? Number(row.days_since_audit) : null
         }));
      } catch (error) {
         throw new Error(`Error fetching detailed audit progress: ${error.message}`);
      }
   }

   // Raw query execution for backward compatibility
   async executeQuery(query, params = []) {
      try {
         const result = await prisma.$queryRawUnsafe(query, ...params);

         // Convert BigInt to Number for JSON serialization
         return JSON.parse(JSON.stringify(result, (key, value) =>
            typeof value === 'bigint' ? Number(value) : value
         ));
      } catch (error) {
         throw new Error(`Database query error: ${error.message}`);
      }
   }
}

module.exports = DepartmentModel;