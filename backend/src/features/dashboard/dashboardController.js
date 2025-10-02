// Path: backend/src/controllers/dashboardController.js
const { PlantService, LocationService, UnitService, UserService, AssetService } = require('../scan/scanService');
const DepartmentService = require('./dashboardService');
const ExportModel = require('../export/exportModel');
const prisma = require('../../core/database/prisma');

// Initialize services
const plantService = new PlantService();
const locationService = new LocationService();
const unitService = new UnitService();
const userService = new UserService();
const assetService = new AssetService();
const departmentService = new DepartmentService();
const exportModel = new ExportModel();

const locationController = {
   async getLocations(req, res) {
      try {
         const { page = 1, limit = 50, plant_code } = req.query;

         let locations;
         let totalCount;

         if (plant_code) {
            locations = await locationService.getLocationsByPlant(plant_code);
            totalCount = locations.length;
         } else {
            locations = await locationService.getLocationsWithPlant();
            totalCount = locations.length;
         }

         const paginatedLocations = applyPagination(locations, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), totalCount);

         return sendResponse(res, 200, true, 'Locations retrieved successfully', paginatedLocations, meta);
      } catch (error) {
         console.error('Get locations error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getLocationByCode(req, res) {
      try {
         const { location_code } = req.params;
         const location = await locationService.getLocationByCode(location_code);

         return sendResponse(res, 200, true, 'Location retrieved successfully', location);
      } catch (error) {
         console.error('Get location by code error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   },

   async getLocationsByPlant(req, res) {
      try {
         const { plant_code } = req.params;
         const { page = 1, limit = 50 } = req.query;

         const locations = await locationService.getLocationsByPlant(plant_code);
         const paginatedLocations = applyPagination(locations, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), locations.length);

         return sendResponse(res, 200, true, 'Locations by plant retrieved successfully', paginatedLocations, meta);
      } catch (error) {
         console.error('Get locations by plant error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   }
};

// Response helper function
const sendResponse = (res, statusCode, success, message, data = null, meta = null) => {
   const response = {
      success,
      message,
      timestamp: new Date().toISOString()
   };

   if (data !== null) {
      response.data = data;
   }

   if (meta !== null) {
      response.meta = meta;
   }

   return res.status(statusCode).json(response);
};

// Time period helper function
const getDateRange = (period = 'today') => {
   const now = new Date();
   let startDate, endDate = now;

   switch (period) {
      case 'today':
         startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
         break;
      case '7d':
         startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
         break;
      case '30d':
         startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
         break;
      default:
         startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
   }

   return { startDate, endDate };
};

// Calculate percentage change helper - แก้ BigInt issue
const calculatePercentageChange = (current, previous) => {
   // Convert BigInt to Number
   const currentNum = typeof current === 'bigint' ? Number(current) : current;
   const previousNum = typeof previous === 'bigint' ? Number(previous) : previous;

   if (previousNum === 0) return currentNum > 0 ? 100 : 0;
   return Math.round(((currentNum - previousNum) / previousNum) * 100);
};

// Standalone helper functions (moved outside object to avoid binding issues)
const formatRelativeTime = (date) => {
   if (!date) return '-';

   const now = new Date();
   const past = new Date(date);
   const diffMs = now - past;
   const diffMins = Math.floor(diffMs / 60000);
   const diffHours = Math.floor(diffMs / 3600000);
   const diffDays = Math.floor(diffMs / 86400000);

   if (diffMins < 1) return 'Just now';
   if (diffMins < 60) return `${diffMins} minute${diffMins > 1 ? 's' : ''} ago`;
   if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
   if (diffDays < 7) return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`;
   return past.toLocaleDateString();
};

const getStatusLabel = (status) => {
   const statusLabels = {
      'P': 'Pending',
      'C': 'Completed',
      'F': 'Failed'
   };
   return statusLabels[status] || status;
};

const getExportTypeLabel = (exportType) => {
   const typeLabels = {
      'assets': 'Assets Export',
      'scan_logs': 'Scan Logs Export',
      'status_history': 'Status History Export'
   };
   return typeLabels[exportType] || exportType;
};

const formatFileSize = (bytes) => {
   if (!bytes || bytes === 0) return '0 B';
   const sizes = ['B', 'KB', 'MB', 'GB'];
   const i = Math.floor(Math.log(bytes) / Math.log(1024));
   const size = (bytes / Math.pow(1024, i)).toFixed(1);
   return `${size} ${sizes[i]}`;
};

// Dashboard Controller
const dashboardController = {
   /**
    * Get enhanced dashboard statistics with percentage changes
    * GET /api/v1/dashboard/stats?period=today|7d|30d
    */
   async getDashboardStats(req, res) {
      try {
         const { period = 'today' } = req.query;
         const { startDate, endDate } = getDateRange(period);

         // Get previous period for comparison
         const periodDays = period === 'today' ? 1 : period === '7d' ? 7 : 30;
         const prevStartDate = new Date(startDate.getTime() - (periodDays * 24 * 60 * 60 * 1000));
         const prevEndDate = new Date(startDate.getTime() - 1000);

         // Parallel execution for better performance
         const [
            // Current period data - Asset counts
            totalAssets,
            activeAssets,
            inactiveAssets,
            createdAssets,

            // Current period - Scans (asset_scan_log table exists)
            currentScans,

            // Current period - Exports (export_history table exists)
            currentExportSuccess,
            currentExportFailed,

            // Previous period data for comparison
            prevScans,
            prevExportSuccess,
            prevExportFailed,

            // Chart data
            assetStatusBreakdown,
            scanTrendData,

            // Additional stats
            totalPlants,
            totalLocations,
            totalUsers
         ] = await Promise.all([
            // Asset counts (asset_master table)
            prisma.$queryRaw`SELECT COUNT(*) as count FROM asset_master`,
            prisma.$queryRaw`SELECT COUNT(*) as count FROM asset_master WHERE status = 'A'`,
            prisma.$queryRaw`SELECT COUNT(*) as count FROM asset_master WHERE status = 'I'`,
            prisma.$queryRaw`SELECT COUNT(*) as count FROM asset_master WHERE YEAR(created_at) = YEAR(NOW())`,

            // Current period - Scans (asset_scan_log table)
            prisma.$queryRaw`
               SELECT COUNT(*) as count FROM asset_scan_log 
               WHERE scanned_at >= ${startDate} AND scanned_at <= ${endDate}`,

            // Current period - Exports (export_history table)
            exportModel.executeQuery(
               'SELECT COUNT(*) as count FROM export_history WHERE status = ? AND created_at >= ? AND created_at <= ?',
               ['C', startDate, endDate]
            ),
            exportModel.executeQuery(
               'SELECT COUNT(*) as count FROM export_history WHERE status = ? AND created_at >= ? AND created_at <= ?',
               ['F', startDate, endDate]
            ),

            // Previous period - Scans
            prisma.$queryRaw`
               SELECT COUNT(*) as count FROM asset_scan_log 
               WHERE scanned_at >= ${prevStartDate} AND scanned_at <= ${prevEndDate}`,

            // Previous period - Exports
            exportModel.executeQuery(
               'SELECT COUNT(*) as count FROM export_history WHERE status = ? AND created_at >= ? AND created_at <= ?',
               ['C', prevStartDate, prevEndDate]
            ),
            exportModel.executeQuery(
               'SELECT COUNT(*) as count FROM export_history WHERE status = ? AND created_at >= ? AND created_at <= ?',
               ['F', prevStartDate, prevEndDate]
            ),

            // Chart data - Asset status breakdown
            prisma.$queryRaw`SELECT status, COUNT(*) as count FROM asset_master GROUP BY status`,

            // Scan trend data (last 7 days)
            prisma.$queryRaw`
               SELECT 
                  DATE(scanned_at) as scan_date,
                  COUNT(*) as scan_count
               FROM asset_scan_log
               WHERE scanned_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
               GROUP BY DATE(scanned_at)
               ORDER BY scan_date DESC
               LIMIT 7
            `,

            // Additional master data counts
            prisma.$queryRaw`SELECT COUNT(*) as count FROM mst_plant`,
            prisma.$queryRaw`SELECT COUNT(*) as count FROM mst_location`,
            prisma.$queryRaw`SELECT COUNT(*) as count FROM mst_user`
         ]);

         // Process current period results - Convert BigInt
         const currentScansCount = Number(currentScans[0]?.count || 0);
         const currentExportSuccessCount = Number(currentExportSuccess[0]?.count || 0);
         const currentExportFailedCount = Number(currentExportFailed[0]?.count || 0);

         // Process previous period results - Convert BigInt
         const prevScansCount = Number(prevScans[0]?.count || 0);
         const prevExportSuccessCount = Number(prevExportSuccess[0]?.count || 0);
         const prevExportFailedCount = Number(prevExportFailed[0]?.count || 0);

         // Calculate percentage changes
         const scansChange = calculatePercentageChange(currentScansCount, prevScansCount);
         const exportSuccessChange = calculatePercentageChange(currentExportSuccessCount, prevExportSuccessCount);
         const exportFailedChange = calculatePercentageChange(currentExportFailedCount, prevExportFailedCount);

         // Process asset status breakdown
         const statusBreakdown = { active: 0, inactive: 0, created: 0 };
         assetStatusBreakdown.forEach(item => {
            const count = Number(item.count);
            switch (item.status) {
               case 'A': statusBreakdown.active = count; break;
               case 'I': statusBreakdown.inactive = count; break;
               case 'C': statusBreakdown.created = count; break;
            }
         });

         // Process scan trend data for chart
         const scanTrend = [];
         for (let i = 6; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            const dateStr = date.toISOString().split('T')[0];

            const dayData = scanTrendData.find(item =>
               item.scan_date && item.scan_date.toISOString().split('T')[0] === dateStr
            );

            scanTrend.push({
               date: dateStr,
               count: dayData ? Number(dayData.scan_count) : 0,
               day_name: date.toLocaleDateString('en-US', { weekday: 'short' })
            });
         }

         // Prepare enhanced dashboard data
         const dashboardData = {
            overview: {
               total_assets: {
                  value: Number(totalAssets[0]?.count || 0),
                  change_percent: 0, // Asset totals don't change frequently
                  trend: 'stable'
               },
               active_assets: {
                  value: Number(activeAssets[0]?.count || 0),
                  change_percent: 0,
                  trend: 'stable'
               },
               inactive_assets: {
                  value: Number(inactiveAssets[0]?.count || 0),
                  change_percent: 0,
                  trend: 'stable'
               },
               created_assets: {
                  value: Number(createdAssets[0]?.count || 0),
                  change_percent: 0,
                  trend: 'stable'
               },
               scans: {
                  value: currentScansCount,
                  change_percent: scansChange,
                  trend: scansChange > 0 ? 'up' : scansChange < 0 ? 'down' : 'stable',
                  previous_value: prevScansCount
               },
               export_success: {
                  value: currentExportSuccessCount,
                  change_percent: exportSuccessChange,
                  trend: exportSuccessChange > 0 ? 'up' : exportSuccessChange < 0 ? 'down' : 'stable',
                  previous_value: prevExportSuccessCount
               },
               export_failed: {
                  value: currentExportFailedCount,
                  change_percent: exportFailedChange,
                  trend: exportFailedChange > 0 ? 'up' : exportFailedChange < 0 ? 'down' : 'stable',
                  previous_value: prevExportFailedCount
               },
               total_plants: Number(totalPlants[0]?.count || 0),
               total_locations: Number(totalLocations[0]?.count || 0),
               total_users: Number(totalUsers[0]?.count || 0)
            },
            charts: {
               asset_status_pie: {
                  active: statusBreakdown.active,
                  inactive: statusBreakdown.inactive,
                  created: statusBreakdown.created,
                  total: Number(totalAssets[0]?.count || 0)
               },
               scan_trend_7d: scanTrend
            },
            period_info: {
               period,
               start_date: startDate.toISOString(),
               end_date: endDate.toISOString(),
               comparison_period: {
                  start_date: prevStartDate.toISOString(),
                  end_date: prevEndDate.toISOString()
               }
            }
         };

         return sendResponse(res, 200, true, 'Dashboard statistics retrieved successfully', dashboardData);

      } catch (error) {
         console.error('Dashboard stats error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   /**
    * Get dashboard alerts for important notifications
    * GET /api/v1/dashboard/alerts
    */
   async getDashboardAlerts(req, res) {
      try {
         const alerts = [];

         // Check for failed exports in last 24 hours (export_history table)
         const failedExports = await exportModel.executeQuery(
            'SELECT COUNT(*) as count FROM export_history WHERE status = ? AND created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)',
            ['F']
         );

         if (Number(failedExports[0]?.count || 0) > 0) {
            alerts.push({
               id: 'failed-exports',
               type: 'export',
               message: `${Number(failedExports[0].count)} export job(s) failed in the last 24 hours`,
               severity: 'warning',
               count: Number(failedExports[0].count),
               created_at: new Date().toISOString()
            });
         }

         // Check for inactive assets (asset_master table)
         const inactiveAssets = await prisma.$queryRaw`
            SELECT COUNT(*) as count FROM asset_master WHERE status = 'I'
         `;

         if (Number(inactiveAssets[0]?.count || 0) > 0) {
            alerts.push({
               id: 'inactive-assets',
               type: 'asset',
               message: `${Number(inactiveAssets[0].count)} asset(s) are currently inactive`,
               severity: 'info',
               count: Number(inactiveAssets[0].count),
               created_at: new Date().toISOString()
            });
         }

         // Check for pending exports (export_history table)
         const stuckExports = await exportModel.executeQuery(
            'SELECT COUNT(*) as count FROM export_history WHERE status = ? AND created_at <= DATE_SUB(NOW(), INTERVAL 1 HOUR)',
            ['P']
         );

         if (Number(stuckExports[0]?.count || 0) > 0) {
            alerts.push({
               id: 'stuck-exports',
               type: 'export',
               message: `${Number(stuckExports[0].count)} export job(s) have been pending for over 1 hour`,
               severity: 'error',
               count: Number(stuckExports[0].count),
               created_at: new Date().toISOString()
            });
         }

         // Check for low scan activity (asset_scan_log table)
         const todayScans = await prisma.$queryRaw`
            SELECT COUNT(*) as count FROM asset_scan_log WHERE DATE(scanned_at) = CURDATE()
         `;

         if (Number(todayScans[0]?.count || 0) < 10) {
            alerts.push({
               id: 'low-scan-activity',
               type: 'scan',
               message: `Low scan activity today: only ${Number(todayScans[0]?.count || 0)} scans recorded`,
               severity: 'warning',
               count: Number(todayScans[0]?.count || 0),
               created_at: new Date().toISOString()
            });
         }

         // Check for assets without recent scans (asset_scan_log + asset_master)
         const unscannedAssets = await prisma.$queryRaw`
            SELECT COUNT(DISTINCT a.asset_no) as count
            FROM asset_master a
            LEFT JOIN asset_scan_log s ON a.asset_no = s.asset_no 
               AND s.scanned_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
            WHERE a.status = 'A' AND s.asset_no IS NULL
         `;

         if (Number(unscannedAssets[0]?.count || 0) > 0) {
            alerts.push({
               id: 'unscanned-assets',
               type: 'asset',
               message: `${Number(unscannedAssets[0].count)} active asset(s) haven't been scanned in 30+ days`,
               severity: 'warning',
               count: Number(unscannedAssets[0].count),
               created_at: new Date().toISOString()
            });
         }

         // Check for assets with null location or plant (data quality alert)
         const orphanedAssets = await prisma.$queryRaw`
            SELECT COUNT(*) as count FROM asset_master 
            WHERE (plant_code IS NULL OR location_code IS NULL) AND status = 'A'
         `;

         if (Number(orphanedAssets[0]?.count || 0) > 0) {
            alerts.push({
               id: 'orphaned-assets',
               type: 'data_quality',
               message: `${Number(orphanedAssets[0].count)} active asset(s) have missing plant or location information`,
               severity: 'warning',
               count: Number(orphanedAssets[0].count),
               created_at: new Date().toISOString()
            });
         }

         // Default healthy system alert if no issues
         if (alerts.length === 0) {
            alerts.push({
               id: 'system-healthy',
               type: 'system',
               message: 'All systems are operating normally',
               severity: 'info',
               count: 0,
               created_at: new Date().toISOString()
            });
         }

         // Sort alerts by severity (error > warning > info)
         const severityOrder = { error: 0, warning: 1, info: 2 };
         alerts.sort((a, b) => severityOrder[a.severity] - severityOrder[b.severity]);

         return sendResponse(res, 200, true, 'Dashboard alerts retrieved successfully', alerts);

      } catch (error) {
         console.error('Dashboard alerts error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   /**
    * Get recent activities for dashboard
    * GET /api/v1/dashboard/recent?period=today|7d|30d
    */
   async getDashboardRecent(req, res) {
      try {
         const { period = '7d' } = req.query;
         const { startDate } = getDateRange(period);

         const [recentScans, recentExports] = await Promise.all([
            // Recent scans (asset_scan_log with joins)
            prisma.$queryRaw`
               SELECT 
                  s.scan_id,
                  s.asset_no,
                  s.scanned_at,
                  s.ip_address,
                  a.description as asset_description,
                  u.full_name as scanned_by_name,
                  l.description as location_description,
                  p.description as plant_description
               FROM asset_scan_log s
               LEFT JOIN asset_master a ON s.asset_no = a.asset_no
               LEFT JOIN mst_user u ON s.scanned_by = u.user_id
               LEFT JOIN mst_location l ON s.location_code = l.location_code
               LEFT JOIN mst_plant p ON l.plant_code = p.plant_code
               WHERE s.scanned_at >= ${startDate}
               ORDER BY s.scanned_at DESC
               LIMIT 5
            `,

            // Recent exports (export_history with user join)
            exportModel.executeQuery(`
               SELECT 
                  e.export_id,
                  e.export_type,
                  e.status,
                  e.total_records,
                  e.created_at,
                  e.file_size,
                  u.full_name as user_name
               FROM export_history e
               LEFT JOIN mst_user u ON e.user_id = u.user_id
               WHERE e.created_at >= ?
               ORDER BY e.created_at DESC
               LIMIT 5
            `, [startDate])
         ]);

         // Format recent scans using standalone helper functions
         const formattedScans = recentScans.map(scan => ({
            id: Number(scan.scan_id),
            asset_no: scan.asset_no,
            asset_description: scan.asset_description || 'Unknown Asset',
            scanned_at: scan.scanned_at,
            scanned_by: scan.scanned_by_name || 'Unknown User',
            location: scan.location_description || 'Unknown Location',
            plant: scan.plant_description || 'Unknown Plant',
            ip_address: scan.ip_address,
            formatted_time: new Date(scan.scanned_at).toLocaleString()
         }));

         // Format recent exports using standalone helper functions
         const formattedExports = recentExports.map(exportJob => ({
            id: exportJob.export_id,
            type: exportJob.export_type,
            type_label: getExportTypeLabel(exportJob.export_type),
            status: exportJob.status,
            status_label: getStatusLabel(exportJob.status),
            total_records: exportJob.total_records || 0,
            file_size: exportJob.file_size ? formatFileSize(Number(exportJob.file_size)) : null,
            created_at: exportJob.created_at,
            user_name: exportJob.user_name || 'Unknown User',
            formatted_time: new Date(exportJob.created_at).toLocaleString()
         }));

         const recentData = {
            recent_scans: formattedScans,
            recent_exports: formattedExports,
            period_info: {
               period,
               start_date: startDate.toISOString(),
               total_scans: recentScans.length,
               total_exports: recentExports.length
            }
         };

         return sendResponse(res, 200, true, 'Recent activities retrieved successfully', recentData);

      } catch (error) {
         console.error('Dashboard recent activities error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   /**
    * Get dashboard overview with period support
    * GET /api/v1/dashboard/overview?period=today|7d|30d
    */
   async getOverview(req, res) {
      try {
         const { period = '7d' } = req.query;
         const { startDate } = getDateRange(period);

         const [
            assetsByPlant,
            assetsByLocation,
            recentAssets,
            scanTrendData,
            statusHistoryData
         ] = await Promise.all([
            // Assets by plant (mst_plant + asset_master)
            prisma.$queryRaw`
               SELECT 
                  p.plant_code,
                  p.description as plant_description,
                  COUNT(a.asset_no) as asset_count
               FROM mst_plant p
               LEFT JOIN asset_master a ON p.plant_code = a.plant_code AND a.status IN ('A', 'C')
               GROUP BY p.plant_code, p.description
               ORDER BY p.plant_code
            `,

            // Assets by location (mst_location + asset_master + mst_plant)
            prisma.$queryRaw`
               SELECT 
                  l.location_code,
                  l.description as location_description,
                  l.plant_code,
                  p.description as plant_description,
                  COUNT(a.asset_no) as asset_count
               FROM mst_location l
               LEFT JOIN mst_plant p ON l.plant_code = p.plant_code
               LEFT JOIN asset_master a ON l.location_code = a.location_code AND a.status IN ('A', 'C')
               GROUP BY l.location_code, l.description, l.plant_code, p.description
               ORDER BY l.location_code
            `,

            // Recent assets (asset_master with joins)
            prisma.$queryRaw`
               SELECT 
                  a.*,
                  p.description as plant_description,
                  l.description as location_description,
                  u2.name as unit_name,
                  usr.full_name as created_by_name
               FROM asset_master a
               LEFT JOIN mst_plant p ON a.plant_code = p.plant_code
               LEFT JOIN mst_location l ON a.location_code = l.location_code
               LEFT JOIN mst_unit u2 ON a.unit_code = u2.unit_code
               LEFT JOIN mst_user usr ON a.created_by = usr.user_id
               WHERE a.status IN ('A', 'C')
               ORDER BY a.created_at DESC
               LIMIT 5
            `,

            // Scan trend data for the selected period (asset_scan_log)
            prisma.$queryRaw`
               SELECT 
                  DATE(scanned_at) as scan_date,
                  COUNT(*) as scan_count
               FROM asset_scan_log
               WHERE scanned_at >= ${startDate}
               GROUP BY DATE(scanned_at)
               ORDER BY scan_date DESC
            `,

            // Status change activity (asset_status_history)
            prisma.$queryRaw`
               SELECT 
                  DATE(changed_at) as change_date,
                  COUNT(*) as change_count
               FROM asset_status_history
               WHERE changed_at >= ${startDate}
               GROUP BY DATE(changed_at)
               ORDER BY change_date DESC
               LIMIT 7
            `
         ]);

         const overviewData = {
            assets_by_plant: assetsByPlant.map(item => ({
               ...item,
               asset_count: Number(item.asset_count)
            })),
            assets_by_location: assetsByLocation.map(item => ({
               ...item,
               asset_count: Number(item.asset_count)
            })),
            recent_assets: recentAssets,
            scan_trend: scanTrendData.map(item => ({
               date: item.scan_date.toISOString().split('T')[0],
               count: Number(item.scan_count)
            })),
            status_change_activity: statusHistoryData.map(item => ({
               date: item.change_date.toISOString().split('T')[0],
               count: Number(item.change_count)
            })),
            period_info: {
               period,
               start_date: startDate.toISOString()
            }
         };

         return sendResponse(res, 200, true, 'System overview retrieved successfully', overviewData);

      } catch (error) {
         console.error('Dashboard overview error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   /**
    * Get quick statistics with period support
    * GET /api/v1/dashboard/quick-stats?period=today|7d|30d
    */
   async getQuickStats(req, res) {
      try {
         const { period = 'today' } = req.query;
         const { startDate, endDate } = getDateRange(period);

         const [
            assetStats,
            scanStats,
            exportStats,
            userActivityStats
         ] = await Promise.all([
            // Asset statistics (asset_master)
            Promise.all([
               prisma.$queryRaw`SELECT COUNT(*) as count FROM asset_master`,
               prisma.$queryRaw`SELECT COUNT(*) as count FROM asset_master WHERE status = 'A'`,
               prisma.$queryRaw`SELECT COUNT(*) as count FROM asset_master WHERE status = 'I'`,
               prisma.$queryRaw`SELECT COUNT(*) as count FROM asset_master WHERE status = 'C'`
            ]),

            // Period-specific scan stats (asset_scan_log)
            prisma.$queryRaw`
               SELECT COUNT(*) as period_scans FROM asset_scan_log 
               WHERE scanned_at >= ${startDate} AND scanned_at <= ${endDate}
            `,

            // Period-specific export stats (export_history)
            Promise.all([
               exportModel.executeQuery(
                  'SELECT COUNT(*) as count FROM export_history WHERE status = ? AND created_at >= ? AND created_at <= ?',
                  ['P', startDate, endDate]
               ),
               exportModel.executeQuery(
                  'SELECT COUNT(*) as count FROM export_history WHERE status = ? AND created_at >= ? AND created_at <= ?',
                  ['C', startDate, endDate]
               ),
               exportModel.executeQuery(
                  'SELECT COUNT(*) as count FROM export_history WHERE status = ? AND created_at >= ? AND created_at <= ?',
                  ['F', startDate, endDate]
               )
            ]),

            // User activity stats (user_login_log)
            prisma.$queryRaw`
               SELECT COUNT(DISTINCT user_id) as active_users FROM user_login_log 
               WHERE timestamp >= ${startDate} AND timestamp <= ${endDate} AND event_type = 'login'
            `
         ]);

         const quickStats = {
            assets: {
               total: Number(assetStats[0][0]?.count || 0),
               active: Number(assetStats[1][0]?.count || 0),
               inactive: Number(assetStats[2][0]?.count || 0),
               created: Number(assetStats[3][0]?.count || 0)
            },
            scans: {
               period_count: Number(scanStats[0]?.period_scans || 0),
               period: period
            },
            exports: {
               pending: Number(exportStats[0][0]?.count || 0),
               completed: Number(exportStats[1][0]?.count || 0),
               failed: Number(exportStats[2][0]?.count || 0),
               total: Number(exportStats[0][0]?.count || 0) + Number(exportStats[1][0]?.count || 0) + Number(exportStats[2][0]?.count || 0),
               period: period
            },
            users: {
               active_in_period: Number(userActivityStats[0]?.active_users || 0),
               period: period
            },
            period_info: {
               period,
               start_date: startDate.toISOString(),
               end_date: endDate.toISOString()
            }
         };

         return sendResponse(res, 200, true, 'Quick statistics retrieved successfully', quickStats);

      } catch (error) {
         console.error('Quick stats error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   /**
   * Get assets distribution by department (Pie Chart data)
   * GET /api/v1/dashboard/assets-by-plant?plant_code=xxx&dept_code=xxx
   *
   * Returns ALL departments sorted by asset count for frontend to manage display
   */
   async getAssetsByDepartment(req, res) {
      try {
         const { plant_code, dept_code } = req.query;

         let departmentStats;
         let unassignedAssets;

         if (plant_code || dept_code) {
            // Use departmentService with filters
            let whereConditions = [];
            let params = [];

            if (plant_code) {
               whereConditions.push('d.plant_code = ?');
               params.push(plant_code);
            }

            if (dept_code) {
               whereConditions.push('d.dept_code = ?');
               params.push(dept_code);
            }

            const whereClause = whereConditions.length > 0
               ? `WHERE ${whereConditions.join(' AND ')}`
               : '';

            departmentStats = await prisma.$queryRawUnsafe(`
               SELECT
                  d.dept_code,
                  d.description as dept_description,
                  d.plant_code,
                  p.description as plant_description,
                  COUNT(a.asset_no) as asset_count
               FROM mst_department d
               LEFT JOIN mst_plant p ON d.plant_code = p.plant_code
               LEFT JOIN asset_master a ON d.dept_code = a.dept_code AND a.status IN ('A', 'C')
               ${whereClause}
               GROUP BY d.dept_code, d.description, d.plant_code, p.description
               ORDER BY asset_count DESC
            `, ...params);

            // Count unassigned assets (dept_code is null) with plant filter
            if (plant_code) {
               unassignedAssets = await prisma.$queryRawUnsafe(`
                  SELECT COUNT(*) as asset_count
                  FROM asset_master
                  WHERE dept_code IS NULL
                     AND status IN ('A', 'C')
                     AND plant_code = ?
               `, plant_code);
            } else {
               unassignedAssets = await prisma.$queryRaw`
                  SELECT COUNT(*) as asset_count
                  FROM asset_master
                  WHERE dept_code IS NULL AND status IN ('A', 'C')
               `;
            }
         } else {
            // Get all departments
            departmentStats = await prisma.$queryRaw`
               SELECT
                  d.dept_code,
                  d.description as dept_description,
                  d.plant_code,
                  p.description as plant_description,
                  COUNT(a.asset_no) as asset_count
               FROM mst_department d
               LEFT JOIN mst_plant p ON d.plant_code = p.plant_code
               LEFT JOIN asset_master a ON d.dept_code = a.dept_code AND a.status IN ('A', 'C')
               GROUP BY d.dept_code, d.description, d.plant_code, p.description
               ORDER BY asset_count DESC
            `;

            // Count unassigned assets (dept_code is null)
            unassignedAssets = await prisma.$queryRaw`
               SELECT COUNT(*) as asset_count
               FROM asset_master
               WHERE dept_code IS NULL AND status IN ('A', 'C')
            `;
         }

         // Calculate totals
         const unassignedCount = Number(unassignedAssets[0]?.asset_count || 0);
         const assignedTotal = departmentStats.reduce((sum, dept) => sum + Number(dept.asset_count || 0), 0);
         const grandTotal = assignedTotal + unassignedCount;

         // Calculate percentages (keep original logic for departments only)
         const allDepartments = departmentStats.map(dept => ({
            name: dept.dept_description || dept.dept_code,
            value: Number(dept.asset_count || 0),
            percentage: assignedTotal > 0 ? Number(((Number(dept.asset_count || 0) / assignedTotal) * 100).toFixed(2)) : 0,
            dept_code: dept.dept_code,
            plant_code: dept.plant_code,
            plant_description: dept.plant_description
         }));

         // Sort by asset count descending
         allDepartments.sort((a, b) => b.value - a.value);

         const responseData = {
            all_departments: allDepartments,
            summary: {
               total_assets: grandTotal, // Total (assigned + unassigned)
               assigned_assets: assignedTotal, // Assets with dept_code (not null)
               unassigned_assets: unassignedCount, // Assets without dept_code (null)
               total_departments: departmentStats.length,
               plant_filter: plant_code || 'all',
               dept_filter: dept_code || 'all'
            },
            filter_info: {
               applied_filters: {
                  plant_code: plant_code || null,
                  dept_code: dept_code || null
               }
            }
         };

         return sendResponse(res, 200, true, 'Assets by department retrieved successfully', responseData);

      } catch (error) {
         console.error('Get assets by department error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   /**
    * Get growth trends by department/location (Line Chart data)  
    * GET /api/v1/dashboard/growth-trends?dept_code=xxx&period=Q2&year=2024
    */
   async getGrowthTrends(req, res) {
      try {
         const {
            dept_code,
            location_code,
            period = 'Q2',
            year,
            start_date,
            end_date,
            group_by = 'day'
         } = req.query;

         // Validate parameters
         if (dept_code && location_code) {
            return sendResponse(res, 400, false, 'Cannot filter by both department and location simultaneously');
         }

         let trendsData;
         if (period === 'custom' && start_date && end_date) {
            if (location_code) {
               trendsData = await departmentService.getLocationAssetGrowthTrends(
                  location_code,
                  period,
                  year,
                  start_date,
                  end_date
               );
            } else {
               trendsData = await departmentService.getAssetGrowthTrends(
                  dept_code,
                  period,
                  year,
                  start_date,
                  end_date
               );
            }
         } else {
            if (location_code) {
               trendsData = await departmentService.getLocationAssetGrowthTrends(
                  location_code,
                  period,
                  year
               );
            } else {
               trendsData = await departmentService.getAssetGrowthTrends(
                  dept_code,
                  period,
                  year
               );
            }
         }

         // Process trends for line chart
         const lineChartData = trendsData.trends.map(trend => ({
            period: trend.month_year || `${year || new Date().getFullYear()}-${trend.quarter || 'Q1'}`,
            asset_count: trend.asset_count || 0,
            growth_percentage: trend.growth_percentage || 0,
            cumulative_count: trend.cumulative_count || 0,
            dept_code: trend.dept_code || '',
            dept_description: trend.dept_description || '',
            location_code: trend.location_code || '',
            location_description: trend.location_description || ''
         }));

         const responseData = {
            trends: lineChartData,
            period_info: trendsData.period_info,
            summary: {
               total_periods: lineChartData.length,
               total_growth: trendsData.period_info.total_growth || 0,
               average_growth: lineChartData.length > 0
                  ? Math.round(lineChartData.reduce((sum, item) => sum + (item.growth_percentage || 0), 0) / lineChartData.length)
                  : 0
            }
         };

         return sendResponse(res, 200, true, 'Growth trends retrieved successfully', responseData);

      } catch (error) {
         console.error('Get growth trends error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   /**
    * Get location analytics and utilization data
    * GET /api/v1/dashboard/location-analytics?location_code=xxx&include_trends=true
    */
   async getLocationAnalytics(req, res) {
      try {
         const {
            location_code,
            period = 'Q2',
            year,
            start_date,
            end_date,
            include_trends = 'true'
         } = req.query;

         // Get location analytics
         const locationAnalytics = await departmentService.getLocationAnalytics(location_code);

         // Calculate analytics summary
         const totalLocations = locationAnalytics.length;
         const totalAssets = locationAnalytics.reduce((sum, loc) => sum + (loc.total_assets || 0), 0);
         const averageUtilization = totalLocations > 0
            ? Math.round(locationAnalytics.reduce((sum, loc) => sum + (loc.utilization_rate || 0), 0) / totalLocations)
            : 0;

         let growthTrends = null;
         if (include_trends === 'true' && location_code) {
            const yearToUse = year ? parseInt(year) : new Date().getFullYear();

            try {
               if (period === 'custom' && start_date && end_date) {
                  growthTrends = await departmentService.getLocationGrowthTrends(
                     location_code,
                     period,
                     yearToUse,
                     start_date,
                     end_date
                  );
               } else {
                  growthTrends = await departmentService.getLocationGrowthTrends(
                     location_code,
                     period,
                     yearToUse
                  );
               }
            } catch (trendError) {
               console.warn('Failed to get location trends:', trendError.message);
               growthTrends = { location_trends: [], period_info: {} };
            }
         }

         const responseData = {
            location_analytics: locationAnalytics,
            analytics_summary: {
               total_locations: totalLocations,
               total_assets: totalAssets,
               average_utilization_rate: averageUtilization,
               high_utilization_locations: locationAnalytics.filter(loc => (loc.utilization_rate || 0) > 80).length,
               low_activity_locations: locationAnalytics.filter(loc => (loc.scan_frequency || 0) < 1).length
            },
            growth_trends: growthTrends
         };

         return sendResponse(res, 200, true, 'Location analytics retrieved successfully', responseData);

      } catch (error) {
         console.error('Get location analytics error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   /**
    * Get audit progress and completion status
    * GET /api/v1/dashboard/audit-progress?dept_code=xxx&include_details=true
    */
   async getAuditProgress(req, res) {
      try {
         const {
            dept_code,
            include_details = 'false',
            audit_status
         } = req.query;

         // Get audit progress
         const auditProgress = await departmentService.getAuditProgress(dept_code);

         let detailedAudit = null;
         if (include_details === 'true') {
            try {
               detailedAudit = await departmentService.getDetailedAuditProgress(dept_code, audit_status);
            } catch (detailError) {
               console.warn('Failed to get detailed audit:', detailError.message);
               detailedAudit = { detailed_audit_data: [], summary: {} };
            }
         }

         // Generate recommendations based on audit progress
         const recommendations = [];

         if (auditProgress.overall_progress) {
            const overallCompletion = auditProgress.overall_progress.completion_percentage || 0;

            if (overallCompletion < 50) {
               recommendations.push({
                  type: 'critical',
                  message: 'Audit completion rate is below 50%. Immediate action required.',
                  action: 'Schedule intensive audit sessions'
               });
            } else if (overallCompletion < 80) {
               recommendations.push({
                  type: 'warning',
                  message: 'Audit completion rate needs improvement.',
                  action: 'Focus on unaudited departments'
               });
            } else {
               recommendations.push({
                  type: 'success',
                  message: 'Good audit progress. Maintain current pace.',
                  action: 'Complete remaining items'
               });
            }
         }

         // Check for departments with low completion rates
         auditProgress.department_progress.forEach(dept => {
            const completion = dept.completion_percentage || 0;
            if (completion < 30) {
               recommendations.push({
                  type: 'department_alert',
                  message: `Department ${dept.dept_description} has very low audit completion (${completion}%)`,
                  action: `Prioritize ${dept.dept_code} department audit`,
                  dept_code: dept.dept_code
               });
            }
         });

         const responseData = {
            audit_progress: auditProgress.department_progress,
            overall_progress: auditProgress.overall_progress,
            detailed_audit: detailedAudit,
            recommendations: recommendations,
            audit_info: {
               audit_period: auditProgress.audit_period,
               generated_at: auditProgress.generated_at,
               filters_applied: {
                  dept_code: dept_code || null,
                  audit_status: audit_status || null,
                  include_details: include_details === 'true'
               }
            }
         };

         return sendResponse(res, 200, true, 'Audit progress retrieved successfully', responseData);

      } catch (error) {
         console.error('Get audit progress error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },
   async getLocations(req, res) {
      try {
         const { plant_code } = req.query;


         let locations;
         if (plant_code) {
            locations = await locationService.getLocationsByPlant(plant_code);
         } else {
            locations = await locationService.getLocationsWithPlant();
         }

         return sendResponse(res, 200, true, 'Locations retrieved successfully', { locations });
      } catch (error) {
         console.error('Get locations error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   }


};

module.exports = dashboardController;