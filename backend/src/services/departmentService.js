// Path: backend/src/services/departmentService.js
const DepartmentModel = require('../models/departmentModel');

class DepartmentService {
   constructor() {
      this.model = new DepartmentModel();
   }

   async getAllDepartments() {
      try {
         return await this.model.getAllDepartments();
      } catch (error) {
         throw new Error(`Error fetching departments: ${error.message}`);
      }
   }

   async getDepartmentByCode(deptCode) {
      try {
         const department = await this.model.getDepartmentByCode(deptCode);
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
         return await this.model.getDepartmentsByPlant(plantCode);
      } catch (error) {
         throw new Error(`Error fetching departments by plant: ${error.message}`);
      }
   }

   async getDepartmentsWithPlant() {
      try {
         return await this.model.getDepartmentsWithPlant();
      } catch (error) {
         throw new Error(`Error fetching departments with plant details: ${error.message}`);
      }
   }

   async getDepartmentStats() {
      try {
         return await this.model.getDepartmentStats();
      } catch (error) {
         throw new Error(`Error fetching department statistics: ${error.message}`);
      }
   }

   async count(filters = {}) {
      try {
         return await this.model.count(filters);
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

   // Calculate growth percentage
   calculateGrowthPercentage(current, previous) {
      if (previous === 0) return current > 0 ? 100 : 0;
      return Math.round(((current - previous) / previous) * 100);
   }

   // Path: backend/src/services/departmentService.js - getAssetGrowthTrends method

   async getAssetGrowthTrends(deptCode = null, period = 'Q2', year = null, startDate = null, endDate = null) {
      try {
         // สำหรับ yearly comparison - ใช้ 5 ปีย้อนหลัง
         const currentYear = new Date().getFullYear();
         const startYear = currentYear - 4; // 5 ปีย้อนหลัง (รวมปีปัจจุบัน)
         const endYear = currentYear;

         // Query เพื่อดึงข้อมูลสะสมสำหรับแต่ละปี
         const trends = await this.model.executeQuery(`
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
         ${deptCode ? 'AND a.dept_code = ?' : ''}
         LEFT JOIN mst_department d ON ${deptCode ? 'a.dept_code = d.dept_code' : 'd.dept_code IS NOT NULL'}
         ${deptCode ? 'WHERE a.dept_code = ?' : ''}
         GROUP BY year_range.year, d.dept_code, d.description
         ORDER BY year_range.year
      `, deptCode ? [deptCode, deptCode] : []);

         // กรณีที่ไม่มี department code หรือไม่มีข้อมูล ให้ใช้ query แบบง่าย
         let finalTrends = [];
         if (!deptCode || trends.length === 0) {
            // Query สำหรับ all departments หรือกรณีไม่มีข้อมูล
            const allAssetTrends = await this.model.executeQuery(`
            SELECT 
               year_range.year,
               COALESCE(COUNT(a.asset_no), 0) as asset_count
            FROM (
               SELECT ${startYear} as year
               UNION SELECT ${startYear + 1}
               UNION SELECT ${startYear + 2}
               UNION SELECT ${startYear + 3}
               UNION SELECT ${startYear + 4}
            ) year_range
            LEFT JOIN asset_master a ON YEAR(a.created_at) <= year_range.year
            ${deptCode ? 'AND a.dept_code = ?' : ''}
            GROUP BY year_range.year
            ORDER BY year_range.year
         `, deptCode ? [deptCode] : []);

            finalTrends = allAssetTrends;
         } else {
            finalTrends = trends;
         }

         // สร้างข้อมูลสำหรับแต่ละปี
         const processedTrends = [];
         let previousCount = 0;

         for (let currentYearLoop = startYear; currentYearLoop <= endYear; currentYearLoop++) {
            // หาข้อมูลของปีนี้
            const yearData = finalTrends.find(trend => trend.year === currentYearLoop) || {
               year: currentYearLoop,
               asset_count: 0,
               dept_code: deptCode || '',
               dept_description: ''
            };

            // คำนวณ growth percentage (เปรียบเทียบกับปีก่อนหน้า)
            const currentCount = yearData.asset_count || 0;
            const growthPercentage = currentYearLoop === startYear ? 0 :
               this.calculateGrowthPercentage(currentCount, previousCount);

            processedTrends.push({
               period: currentYearLoop.toString(), // แสดงเป็นปี เช่น "2021", "2022"
               month_year: currentYearLoop.toString(),
               asset_count: currentCount, // จำนวนสะสมถึงปีนี้
               growth_percentage: growthPercentage,
               cumulative_count: currentCount, // เหมือนกับ asset_count สำหรับ yearly
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

   // Path: backend/src/services/departmentService.js - getLocationAssetGrowthTrends method

   async getLocationAssetGrowthTrends(locationCode = null, period = 'Q2', year = null, startDate = null, endDate = null) {
      try {
         // สำหรับ yearly comparison - ใช้ 5 ปีย้อนหลัง
         const currentYear = new Date().getFullYear();
         const startYear = currentYear - 4; // 5 ปีย้อนหลัง (รวมปีปัจจุบัน)
         const endYear = currentYear;

         // Query เพื่อดึงข้อมูลสะสมสำหรับแต่ละปี โดย filter ตาม location
         const trends = await this.model.executeQuery(`
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
         ${locationCode ? 'AND a.location_code = ?' : ''}
         LEFT JOIN mst_location l ON ${locationCode ? 'a.location_code = l.location_code' : 'l.location_code IS NOT NULL'}
         LEFT JOIN mst_plant p ON l.plant_code = p.plant_code
         ${locationCode ? 'WHERE a.location_code = ?' : ''}
         GROUP BY year_range.year, l.location_code, l.description, p.plant_code, p.description
         ORDER BY year_range.year
      `, locationCode ? [locationCode, locationCode] : []);

         // กรณีที่ไม่มี location code หรือไม่มีข้อมูล ให้ใช้ query แบบง่าย
         let finalTrends = [];
         if (!locationCode || trends.length === 0) {
            // Query สำหรับ all locations หรือกรณีไม่มีข้อมูล
            const allAssetTrends = await this.model.executeQuery(`
            SELECT 
               year_range.year,
               COALESCE(COUNT(a.asset_no), 0) as asset_count,
               COALESCE(SUM(CASE WHEN a.status = 'A' THEN 1 ELSE 0 END), 0) as active_count
            FROM (
               SELECT ${startYear} as year
               UNION SELECT ${startYear + 1}
               UNION SELECT ${startYear + 2}
               UNION SELECT ${startYear + 3}
               UNION SELECT ${startYear + 4}
            ) year_range
            LEFT JOIN asset_master a ON YEAR(a.created_at) <= year_range.year
            ${locationCode ? 'AND a.location_code = ?' : ''}
            GROUP BY year_range.year
            ORDER BY year_range.year
         `, locationCode ? [locationCode] : []);

            finalTrends = allAssetTrends;
         } else {
            finalTrends = trends;
         }

         // สร้างข้อมูลสำหรับแต่ละปี
         const processedTrends = [];
         let previousCount = 0;

         for (let currentYearLoop = startYear; currentYearLoop <= endYear; currentYearLoop++) {
            // หาข้อมูลของปีนี้
            const yearData = finalTrends.find(trend => trend.year === currentYearLoop) || {
               year: currentYearLoop,
               asset_count: 0,
               active_count: 0,
               location_code: locationCode || '',
               location_description: '',
               plant_code: '',
               plant_description: ''
            };

            // คำนวณ growth percentage (เปรียบเทียบกับปีก่อนหน้า)
            const currentCount = yearData.asset_count || 0;
            const growthPercentage = currentYearLoop === startYear ? 0 :
               this.calculateGrowthPercentage(currentCount, previousCount);

            processedTrends.push({
               period: currentYearLoop.toString(), // แสดงเป็นปี เช่น "2021", "2022"
               month_year: currentYearLoop.toString(),
               asset_count: currentCount, // จำนวนสะสมถึงปีนี้
               active_count: yearData.active_count || 0,
               growth_percentage: growthPercentage,
               cumulative_count: currentCount, // เหมือนกับ asset_count สำหรับ yearly
               location_code: yearData.location_code || '',
               location_description: yearData.location_description || '',
               plant_code: yearData.plant_code || '',
               plant_description: yearData.plant_description || '',
               // เพิ่มข้อมูล dept สำหรับ compatibility
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
         const quarterlyData = await this.model.getQuarterlyGrowth(deptCode, year);

         // Process quarterly data with growth calculations
         const processedData = [];
         let previousQuarterCount = 0;

         for (let quarter = 1; quarter <= 4; quarter++) {
            const quarterData = quarterlyData.find(q => q.quarter === quarter) || {
               quarter,
               asset_count: 0,
               dept_code: deptCode,
               dept_description: null
            };

            const growthPercentage = quarter === 1 ? 0 :
               this.calculateGrowthPercentage(quarterData.asset_count, previousQuarterCount);

            processedData.push({
               quarter: `Q${quarter}`,
               asset_count: quarterData.asset_count,
               growth_percentage: growthPercentage,
               dept_code: quarterData.dept_code,
               dept_description: quarterData.dept_description
            });

            previousQuarterCount = quarterData.asset_count;
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
         const locationStats = await this.model.getLocationAssetStats(locationCode);

         // Calculate analytics metrics
         const analytics = locationStats.map(location => ({
            ...location,
            utilization_rate: location.total_assets > 0 ?
               Math.round((location.active_assets / location.total_assets) * 100) : 0,
            scan_frequency: location.total_scans > 0 && location.total_assets > 0 ?
               Math.round(location.total_scans / location.total_assets) : 0,
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

         const trends = await this.model.getLocationGrowthTrends(
            locationCode,
            dateRange.startDate,
            dateRange.endDate
         );

         // Calculate growth percentages for location trends
         const processedTrends = [];
         let previousCount = 0;

         trends.forEach((trend, index) => {
            const growthPercentage = index === 0 ? 0 :
               this.calculateGrowthPercentage(trend.asset_count, previousCount);

            processedTrends.push({
               ...trend,
               growth_percentage: growthPercentage,
               active_growth_percentage: index === 0 ? 0 :
                  this.calculateGrowthPercentage(trend.active_count, trends[index - 1]?.active_count || 0)
            });

            previousCount = trend.asset_count;
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
         const auditData = await this.model.getAuditProgress(deptCode);

         // Calculate overall progress if multiple departments
         let overallProgress = null;
         if (!deptCode && auditData.length > 1) {
            const totalAssets = auditData.reduce((sum, dept) => sum + (dept.total_assets || 0), 0);
            const totalAudited = auditData.reduce((sum, dept) => sum + (dept.audited_assets || 0), 0);

            overallProgress = {
               total_assets: totalAssets,
               audited_assets: totalAudited,
               pending_audit: totalAssets - totalAudited,
               completion_percentage: totalAssets > 0 ?
                  Math.round((totalAudited / totalAssets) * 100) : 0
            };
         }

         return {
            department_progress: auditData,
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
         const detailedData = await this.model.getDetailedAuditProgress(deptCode);

         // Filter by audit status if specified
         let filteredData = detailedData;
         if (auditStatus) {
            filteredData = detailedData.filter(asset => asset.audit_status === auditStatus);
         }

         // Group by audit status
         const groupedData = {
            audited: filteredData.filter(asset => asset.audit_status === 'audited'),
            never_audited: filteredData.filter(asset => asset.audit_status === 'never_audited'),
            overdue: filteredData.filter(asset => asset.audit_status === 'overdue')
         };

         return {
            detailed_audit_data: filteredData,
            grouped_by_status: groupedData,
            summary: {
               total_assets: filteredData.length,
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