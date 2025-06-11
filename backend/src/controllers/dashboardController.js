// Path: backend/src/controllers/dashboardController.js
const { PlantService, LocationService, UnitService, UserService, AssetService } = require('../services/service');
const ExportModel = require('../models/exportModel');

// Initialize services
const plantService = new PlantService();
const locationService = new LocationService();
const unitService = new UnitService();
const userService = new UserService();
const assetService = new AssetService();
const exportModel = new ExportModel();

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

// Dashboard Controller
const dashboardController = {
   /**
    * Get dashboard statistics for overview cards and charts
    * GET /api/v1/dashboard/stats
    */
   async getDashboardStats(req, res) {
      try {
         // Get current date for scan filtering
         const today = new Date();
         const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate());
         const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

         // Parallel execution for better performance
         const [
            // Asset statistics
            totalAssets,
            activeAssets,
            inactiveAssets,
            createdAssets,

            // Scan statistics (today)
            todayScans,

            // Export statistics (7 days)
            exportStats,

            // Chart data
            assetStatusBreakdown
         ] = await Promise.all([
            // Asset counts
            assetService.model.count(),
            assetService.model.count({ status: 'A' }),
            assetService.model.count({ status: 'I' }),
            assetService.model.count({ status: 'C' }),

            // Today's scans
            assetService.model.executeQuery(
               'SELECT COUNT(*) as count FROM asset_scan_log WHERE DATE(scanned_at) = CURDATE()'
            ),

            // Export statistics (7 days)
            Promise.all([
               exportModel.executeQuery(
                  'SELECT COUNT(*) as count FROM export_history WHERE status = ? AND created_at >= ?',
                  ['C', sevenDaysAgo]
               ),
               exportModel.executeQuery(
                  'SELECT COUNT(*) as count FROM export_history WHERE status = ? AND created_at >= ?',
                  ['F', sevenDaysAgo]
               )
            ]),

            // Asset status breakdown for pie chart
            assetService.model.executeQuery(
               'SELECT status, COUNT(*) as count FROM asset_master GROUP BY status'
            )
         ]);

         // Process results
         const todayScansCount = todayScans[0]?.count || 0;
         const exportSuccessCount = exportStats[0][0]?.count || 0;
         const exportFailedCount = exportStats[1][0]?.count || 0;

         // Process asset status breakdown
         const statusBreakdown = {
            active: 0,
            inactive: 0,
            created: 0
         };

         assetStatusBreakdown.forEach(item => {
            switch (item.status) {
               case 'A':
                  statusBreakdown.active = item.count;
                  break;
               case 'I':
                  statusBreakdown.inactive = item.count;
                  break;
               case 'C':
                  statusBreakdown.created = item.count;
                  break;
            }
         });

         // Prepare dashboard data
         const dashboardData = {
            overview: {
               total_assets: totalAssets,
               active_assets: activeAssets,
               inactive_assets: inactiveAssets,
               created_assets: createdAssets,
               today_scans: todayScansCount,
               export_success_7d: exportSuccessCount,
               export_failed_7d: exportFailedCount
            },
            charts: {
               asset_status_pie: {
                  active: statusBreakdown.active,
                  inactive: statusBreakdown.inactive,
                  created: statusBreakdown.created,
                  total: totalAssets
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
    * Get dashboard overview with recent activities
    * GET /api/v1/dashboard/overview
    */
   async getOverview(req, res) {
      try {
         const [
            // Recent activities
            recentAssets,
            recentScans,
            recentExports,

            // Chart data for trends
            scanTrendData
         ] = await Promise.all([
            // Recent assets (5 latest)
            assetService.getAssetsWithDetails(),

            // Recent scans (5 latest)
            assetService.model.executeQuery(`
               SELECT 
                  s.scan_id,
                  s.asset_no,
                  s.scanned_at,
                  a.description as asset_description,
                  u.full_name as scanned_by_name,
                  l.description as location_description
               FROM asset_scan_log s
               LEFT JOIN asset_master a ON s.asset_no = a.asset_no
               LEFT JOIN mst_user u ON s.scanned_by = u.user_id
               LEFT JOIN mst_location l ON s.location_code = l.location_code
               ORDER BY s.scanned_at DESC
               LIMIT 5
            `),

            // Recent exports (5 latest)
            exportModel.executeQuery(`
               SELECT 
                  e.export_id,
                  e.export_type,
                  e.status,
                  e.total_records,
                  e.created_at,
                  u.full_name as user_name
               FROM export_history e
               LEFT JOIN mst_user u ON e.user_id = u.user_id
               ORDER BY e.created_at DESC
               LIMIT 5
            `),

            // Scan trend data (7 days)
            assetService.model.executeQuery(`
               SELECT 
                  DATE(scanned_at) as scan_date,
                  COUNT(*) as scan_count
               FROM asset_scan_log
               WHERE scanned_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
               GROUP BY DATE(scanned_at)
               ORDER BY scan_date DESC
               LIMIT 7
            `)
         ]);

         // Get only top 5 recent assets
         const recentAssetsLimited = recentAssets
            .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
            .slice(0, 5);

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
               count: dayData ? dayData.scan_count : 0,
               day_name: date.toLocaleDateString('th-TH', { weekday: 'short' })
            });
         }

         const overviewData = {
            recent_activities: {
               assets: recentAssetsLimited.map(asset => ({
                  asset_no: asset.asset_no,
                  description: asset.description,
                  status: asset.status,
                  created_at: asset.created_at,
                  plant_description: asset.plant_description,
                  location_description: asset.location_description
               })),
               scans: recentScans.map(scan => ({
                  scan_id: scan.scan_id,
                  asset_no: scan.asset_no,
                  asset_description: scan.asset_description,
                  scanned_at: scan.scanned_at,
                  scanned_by_name: scan.scanned_by_name,
                  location_description: scan.location_description
               })),
               exports: recentExports.map(exportJob => ({
                  export_id: exportJob.export_id,
                  export_type: exportJob.export_type,
                  status: exportJob.status,
                  total_records: exportJob.total_records,
                  created_at: exportJob.created_at,
                  user_name: exportJob.user_name
               }))
            },
            charts: {
               scan_trend_7d: scanTrend
            }
         };

         return sendResponse(res, 200, true, 'Dashboard overview retrieved successfully', overviewData);

      } catch (error) {
         console.error('Dashboard overview error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   /**
    * Get quick statistics for dashboard widgets
    * GET /api/v1/dashboard/quick-stats
    */
   async getQuickStats(req, res) {
      try {
         const [assetStats, scanStats, exportStats] = await Promise.all([
            assetService.getAssetStats(),
            assetService.model.executeQuery(
               'SELECT COUNT(*) as today_scans FROM asset_scan_log WHERE DATE(scanned_at) = CURDATE()'
            ),
            exportModel.getExportStats()
         ]);

         const quickStats = {
            assets: assetStats,
            scans: {
               today: scanStats[0]?.today_scans || 0
            },
            exports: exportStats
         };

         return sendResponse(res, 200, true, 'Quick statistics retrieved successfully', quickStats);

      } catch (error) {
         console.error('Quick stats error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   }
};

module.exports = dashboardController;