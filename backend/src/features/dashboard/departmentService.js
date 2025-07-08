// Path: backend/src/services/departmentService.js
const prisma = require('../../lib/prisma');

class DepartmentService {
   constructor() {
      // ใช้ Prisma โดยตรง ไม่ต้องใช้ model แยก
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
         const department = await prisma.mst_department.findUnique({
            where: { dept_code: deptCode }
         });
         if (!department) {
            throw new Error('Department not found');
         }
         return department;
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
         const departments = await prisma.mst_department.findMany({
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

         // Process the data to match expected format
         return departments.map(dept => ({
            dept_code: dept.dept_code,
            dept_description: dept.description,
            plant_code: dept.plant_code,
            plant_description: dept.mst_plant?.description,
            asset_count: dept.asset_master.length,
            active_assets: dept.asset_master.filter(a => a.status === 'A').length,
            inactive_assets: dept.asset_master.filter(a => a.status === 'I').length,
            created_assets: dept.asset_master.filter(a => a.status === 'C').length
         }));
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

   // Parse period parameter into date range
   parsePeriod(period, year = new Date().getFullYear()) {
      const currentYear = new Date().getFullYear();
      const workingYear = year || currentYear;

      switch (period) {
         case 'Q1':
            return {
               startDate: new Date(workingYear, 0, 1), // January 1
               endDate: new Date(workingYear, 2, 31)   // March 31
            };
         case 'Q2':
            return {
               startDate: new Date(workingYear, 3, 1), // April 1
               endDate: new Date(workingYear, 5, 30)   // June 30
            };
         case 'Q3':
            return {
               startDate: new Date(workingYear, 6, 1), // July 1
               endDate: new Date(workingYear, 8, 30)   // September 30
            };
         case 'Q4':
            return {
               startDate: new Date(workingYear, 9, 1),  // October 1
               endDate: new Date(workingYear, 11, 31)   // December 31
            };
         case '1Y':
            return {
               startDate: new Date(workingYear, 0, 1),  // January 1
               endDate: new Date(workingYear, 11, 31)   // December 31
            };
         default:
            throw new Error('Invalid period. Use Q1, Q2, Q3, Q4, or 1Y');
      }
   }


   calculateGrowthPercentage(current, previous) {
      if (previous === 0) return current > 0 ? 100 : 0;
      return Math.round(((current - previous) / previous) * 100);
   }


   async getAssetGrowthTrends(deptCode = null, period = 'Q2', year = null, startDate = null, endDate = null) {
      try {
         const currentYear = new Date().getFullYear();
         const startYear = currentYear - 4;
         const endYear = currentYear;

         let query = `
      SELECT 
         year_range.year,
         COALESCE(COUNT(a.asset_no), 0) as asset_count,
         d.dept_code,
         d.description as dept_description
      FROM (
         SELECT ${startYear} as year
         UNION SELECT ${startYear + 1}
         UNION SELECT ${startYear + 2}
         UNION SELECT ${startYear + 3}
         UNION SELECT ${startYear + 4}
      ) year_range
      LEFT JOIN asset_master a ON YEAR(a.created_at) <= year_range.year
    `;

         const params = [];
         if (deptCode) {
            query += ` AND a.dept_code = ?`;
            params.push(deptCode);
         }

         query += `
      LEFT JOIN mst_department d ON ${deptCode ? 'a.dept_code = d.dept_code' : 'd.dept_code IS NOT NULL'}
    `;

         if (deptCode) {
            query += ` WHERE d.dept_code = ?`;
            params.push(deptCode);
         }

         query += `
      GROUP BY year_range.year, d.dept_code, d.description
      ORDER BY year_range.year
    `;

         const yearlyData = await prisma.$queryRawUnsafe(query, ...params);

         const processedTrends = [];
         let previousCount = 0;

         for (let currentYearLoop = startYear; currentYearLoop <= endYear; currentYearLoop++) {
            const yearData = yearlyData.find(item => Number(item.year) === currentYearLoop) || {
               year: currentYearLoop,
               asset_count: 0,
               dept_code: deptCode || '',
               dept_description: ''
            };

            const currentCount = Number(yearData.asset_count) || 0;

            const growthPercentage = currentYearLoop === startYear ? 0 :
               previousCount === 0 ?
                  (currentCount > 0 ? 100 : 0) :
                  this.calculateGrowthPercentage(currentCount, previousCount);

            processedTrends.push({
               period: currentYearLoop.toString(),
               month_year: currentYearLoop.toString(),
               asset_count: currentCount,
               growth_percentage: growthPercentage,
               cumulative_count: currentCount,
               dept_code: yearData.dept_code || '',
               dept_description: yearData.dept_description || ''
            });

            previousCount = currentCount;
         }

         return {
            trends: processedTrends,
            period_info: {
               period: 'yearly',
               year: currentYear,
               start_date: new Date(startYear, 0, 1).toISOString(),
               end_date: new Date(endYear, 11, 31).toISOString(),
               total_growth: processedTrends.length > 0 ?
                  processedTrends[processedTrends.length - 1].asset_count : 0,
               year_range: `${startYear}-${endYear}`,
               total_years: 5
            }
         };
      } catch (error) {
         throw new Error(`Error fetching asset growth trends: ${error.message}`);
      }
   }

   async getLocationAssetGrowthTrends(locationCode = null, period = 'Q2', year = null, startDate = null, endDate = null) {
      try {
         const currentYear = new Date().getFullYear();
         const startYear = currentYear - 4;
         const endYear = currentYear;

         let query = `
      SELECT 
         year_range.year,
         COALESCE(COUNT(a.asset_no), 0) as asset_count,
         COALESCE(SUM(CASE WHEN a.status = 'A' THEN 1 ELSE 0 END), 0) as active_count,
         l.location_code,
         l.description as location_description,
         p.plant_code,
         p.description as plant_description
      FROM (
         SELECT ${startYear} as year
         UNION SELECT ${startYear + 1}
         UNION SELECT ${startYear + 2}
         UNION SELECT ${startYear + 3}
         UNION SELECT ${startYear + 4}
      ) year_range
      LEFT JOIN asset_master a ON YEAR(a.created_at) <= year_range.year
    `;

         const params = [];
         if (locationCode) {
            query += ` AND a.location_code = ?`;
            params.push(locationCode);
         }

         query += `
      LEFT JOIN mst_location l ON ${locationCode ? 'a.location_code = l.location_code' : 'l.location_code IS NOT NULL'}
      LEFT JOIN mst_plant p ON l.plant_code = p.plant_code
    `;

         if (locationCode) {
            query += ` WHERE a.location_code = ?`;
            params.push(locationCode);
         }

         query += `
      GROUP BY year_range.year, l.location_code, l.description, p.plant_code, p.description
      ORDER BY year_range.year
    `;

         const trends = await prisma.$queryRawUnsafe(query, ...params);

         const processedTrends = [];
         let previousCount = 0;

         for (let currentYearLoop = startYear; currentYearLoop <= endYear; currentYearLoop++) {
            const yearData = trends.find(trend => Number(trend.year) === currentYearLoop) || {
               year: currentYearLoop,
               asset_count: 0,
               active_count: 0,
               location_code: locationCode || '',
               location_description: '',
               plant_code: '',
               plant_description: ''
            };

            const currentCount = Number(yearData.asset_count) || 0;

            const growthPercentage = currentYearLoop === startYear ? 0 :
               this.calculateGrowthPercentage(currentCount, previousCount);

            processedTrends.push({
               period: currentYearLoop.toString(),
               month_year: currentYearLoop.toString(),
               asset_count: currentCount,
               active_count: Number(yearData.active_count) || 0,
               growth_percentage: growthPercentage,
               cumulative_count: currentCount,
               location_code: yearData.location_code || '',
               location_description: yearData.location_description || '',
               plant_code: yearData.plant_code || '',
               plant_description: yearData.plant_description || '',
               dept_code: yearData.location_code || '',
               dept_description: yearData.location_description || ''
            });

            previousCount = currentCount;
         }

         return {
            trends: processedTrends,
            period_info: {
               period: 'yearly',
               year: currentYear,
               start_date: new Date(startYear, 0, 1).toISOString(),
               end_date: new Date(endYear, 11, 31).toISOString(),
               total_growth: processedTrends.length > 0 ?
                  processedTrends[processedTrends.length - 1].asset_count : 0,
               filter_type: 'location',
               filter_code: locationCode,
               year_range: `${startYear}-${endYear}`,
               total_years: 5
            }
         };
      } catch (error) {
         throw new Error(`Error fetching location asset growth trends: ${error.message}`);
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

         const quarterlyData = await prisma.$queryRawUnsafe(query, ...params);

         // Process quarterly data with growth calculations
         const processedData = [];
         let previousQuarterCount = 0;

         for (let quarter = 1; quarter <= 4; quarter++) {
            const quarterData = quarterlyData.find(q => Number(q.quarter) === quarter) || {
               quarter,
               asset_count: 0,
               dept_code: deptCode,
               dept_description: null
            };

            const growthPercentage = quarter === 1 ? 0 :
               this.calculateGrowthPercentage(Number(quarterData.asset_count), previousQuarterCount);

            processedData.push({
               quarter: `Q${quarter}`,
               asset_count: Number(quarterData.asset_count),
               growth_percentage: growthPercentage,
               dept_code: quarterData.dept_code,
               dept_description: quarterData.dept_description
            });

            previousQuarterCount = Number(quarterData.asset_count);
         }

         return {
            quarterly_data: processedData,
            year_info: {
               year,
               total_assets: processedData.reduce((sum, q) => sum + q.asset_count, 0),
               average_growth: Math.round(
                  processedData.slice(1).reduce((sum, q) => sum + q.growth_percentage, 0) / 3
               )
            }
         };
      } catch (error) {
         throw new Error(`Error fetching quarterly growth: ${error.message}`);
      }
   }

   async getLocationAnalytics(locationCode = null) {
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

         const locationStats = await prisma.$queryRawUnsafe(query, ...params);

         // Calculate analytics metrics
         const analytics = locationStats.map(location => ({
            ...location,
            total_assets: Number(location.total_assets),
            active_assets: Number(location.active_assets),
            inactive_assets: Number(location.inactive_assets),
            created_assets: Number(location.created_assets),
            department_count: Number(location.department_count),
            total_scans: Number(location.total_scans),
            utilization_rate: Number(location.total_assets) > 0 ?
               Math.round((Number(location.active_assets) / Number(location.total_assets)) * 100) : 0,
            scan_frequency: Number(location.total_scans) > 0 && Number(location.total_assets) > 0 ?
               Math.round(Number(location.total_scans) / Number(location.total_assets)) : 0,
            days_since_last_scan: location.last_scan_date ?
               Math.floor((new Date() - new Date(location.last_scan_date)) / (1000 * 60 * 60 * 24)) : null
         }));

         return analytics;
      } catch (error) {
         throw new Error(`Error fetching location analytics: ${error.message}`);
      }
   }

   async getLocationGrowthTrends(locationCode, period = 'Q2', year = null, startDate = null, endDate = null) {
      try {
         let dateRange;

         if (period === 'custom' && startDate && endDate) {
            dateRange = {
               startDate: new Date(startDate),
               endDate: new Date(endDate)
            };
         } else {
            dateRange = this.parsePeriod(period, year);
         }

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

         const trends = await prisma.$queryRawUnsafe(query, locationCode, dateRange.startDate, dateRange.endDate);

         // Calculate growth percentages for location trends
         const processedTrends = [];
         let previousCount = 0;

         trends.forEach((trend, index) => {
            const growthPercentage = index === 0 ? 0 :
               this.calculateGrowthPercentage(Number(trend.asset_count), previousCount);

            processedTrends.push({
               ...trend,
               asset_count: Number(trend.asset_count),
               active_count: Number(trend.active_count),
               growth_percentage: growthPercentage,
               active_growth_percentage: index === 0 ? 0 :
                  this.calculateGrowthPercentage(Number(trend.active_count), Number(trends[index - 1]?.active_count) || 0)
            });

            previousCount = Number(trend.asset_count);
         });

         return {
            location_trends: processedTrends,
            period_info: {
               period,
               year: year || new Date().getFullYear(),
               start_date: dateRange.startDate.toISOString(),
               end_date: dateRange.endDate.toISOString(),
               location_code: locationCode
            }
         };
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

         const auditData = await prisma.$queryRawUnsafe(query, ...params);

         // Convert BigInt values to numbers
         const processedData = auditData.map(item => ({
            ...item,
            total_assets: Number(item.total_assets),
            audited_assets: Number(item.audited_assets),
            pending_audit: Number(item.pending_audit),
            completion_percentage: Number(item.completion_percentage)
         }));

         // Calculate overall progress if multiple departments
         let overallProgress = null;
         if (!deptCode && processedData.length > 1) {
            const totalAssets = processedData.reduce((sum, dept) => sum + (dept.total_assets || 0), 0);
            const totalAudited = processedData.reduce((sum, dept) => sum + (dept.audited_assets || 0), 0);

            overallProgress = {
               total_assets: totalAssets,
               audited_assets: totalAudited,
               pending_audit: totalAssets - totalAudited,
               completion_percentage: totalAssets > 0 ?
                  Math.round((totalAudited / totalAssets) * 100) : 0
            };
         }

         return {
            department_progress: processedData,
            overall_progress: overallProgress,
            audit_period: 'Last 12 months',
            generated_at: new Date().toISOString()
         };
      } catch (error) {
         throw new Error(`Error fetching audit progress: ${error.message}`);
      }
   }

   async getDetailedAuditProgress(deptCode = null, auditStatus = null) {
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
         `;

         if (auditStatus) {
            query += ` HAVING audit_status = ?`;
            params.push(auditStatus);
         }

         query += `
            ORDER BY audit_status, days_since_audit DESC
         `;

         const detailedData = await prisma.$queryRawUnsafe(query, ...params);

         // Group by audit status
         const groupedData = {
            audited: detailedData.filter(asset => asset.audit_status === 'audited'),
            never_audited: detailedData.filter(asset => asset.audit_status === 'never_audited'),
            overdue: detailedData.filter(asset => asset.audit_status === 'overdue')
         };

         return {
            detailed_audit_data: detailedData,
            grouped_by_status: groupedData,
            summary: {
               total_assets: detailedData.length,
               audited_count: groupedData.audited.length,
               never_audited_count: groupedData.never_audited.length,
               overdue_count: groupedData.overdue.length
            }
         };
      } catch (error) {
         throw new Error(`Error fetching detailed audit progress: ${error.message}`);
      }
   }
}

module.exports = DepartmentService;