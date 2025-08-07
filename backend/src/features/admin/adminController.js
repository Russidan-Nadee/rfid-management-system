const AdminService = require('./adminService');

class AdminController {
   constructor() {
      this.adminService = new AdminService();
   }

   // ===== ASSET MANAGEMENT ENDPOINTS =====

   // GET /admin/assets - Get all assets
   getAllAssets = async (req, res) => {
      try {
         const result = await this.adminService.getAllAssets();
         
         res.status(200).json({
            success: true,
            message: 'Assets retrieved successfully',
            data: result.data,
            total: result.total
         });
      } catch (error) {
         console.error('Error in getAllAssets:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            data: null
         });
      }
   };

   // GET /admin/assets/search - Search assets
   searchAssets = async (req, res) => {
      try {
         const { search, status, plant_code, location_code, unit_code, category_code, brand_code } = req.query;
         
         const filters = {
            status,
            plant_code,
            location_code,
            unit_code,
            category_code,
            brand_code
         };

         // Remove undefined values
         Object.keys(filters).forEach(key => {
            if (filters[key] === undefined || filters[key] === '') {
               delete filters[key];
            }
         });

         const result = await this.adminService.searchAssets(search, filters);
         
         res.status(200).json({
            success: true,
            message: 'Asset search completed successfully',
            data: result.data,
            total: result.total,
            search_term: result.searchTerm,
            filters: result.filters
         });
      } catch (error) {
         console.error('Error in searchAssets:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            data: null
         });
      }
   };

   // GET /admin/assets/:assetNo - Get specific asset
   getAssetByNo = async (req, res) => {
      try {
         const { assetNo } = req.params;
         
         if (!assetNo) {
            return res.status(400).json({
               success: false,
               message: 'Asset number is required',
               data: null
            });
         }

         const result = await this.adminService.getAssetByNo(assetNo);
         
         if (!result.success) {
            return res.status(404).json({
               success: false,
               message: result.message,
               data: null
            });
         }
         
         res.status(200).json({
            success: true,
            message: 'Asset retrieved successfully',
            data: result.data
         });
      } catch (error) {
         console.error('Error in getAssetByNo:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            data: null
         });
      }
   };

   // PUT /admin/assets/:assetNo - Update asset
   updateAsset = async (req, res) => {
      try {
         const { assetNo } = req.params;
         const updateData = req.body;
         const updatedBy = req.user?.user_id || 'admin';

         if (!assetNo) {
            return res.status(400).json({
               success: false,
               message: 'Asset number is required',
               data: null
            });
         }

         // Validate update data
         if (!updateData || Object.keys(updateData).length === 0) {
            return res.status(400).json({
               success: false,
               message: 'Update data is required',
               data: null
            });
         }

         const result = await this.adminService.updateAsset(assetNo, updateData, updatedBy);
         
         res.status(200).json({
            success: true,
            message: result.message,
            data: result.data
         });
      } catch (error) {
         console.error('Error in updateAsset:', error);
         
         // Handle specific error types
         const statusCode = error.message.includes('not found') ? 404 :
                           error.message.includes('already exists') ? 409 : 500;
         
         res.status(statusCode).json({
            success: false,
            message: error.message,
            data: null
         });
      }
   };

   // DELETE /admin/assets/:assetNo - Delete asset
   deleteAsset = async (req, res) => {
      try {
         const { assetNo } = req.params;
         const deletedBy = req.user?.user_id || 'admin';

         if (!assetNo) {
            return res.status(400).json({
               success: false,
               message: 'Asset number is required',
               data: null
            });
         }

         const result = await this.adminService.deleteAsset(assetNo, deletedBy);
         
         res.status(200).json({
            success: true,
            message: result.message,
            deleted_asset_no: result.deletedAssetNo
         });
      } catch (error) {
         console.error('Error in deleteAsset:', error);
         
         // Handle specific error types
         const statusCode = error.message.includes('not found') ? 404 :
                           error.message.includes('recently') ? 409 : 500;
         
         res.status(statusCode).json({
            success: false,
            message: error.message,
            data: null
         });
      }
   };

   // ===== STATISTICS ENDPOINTS =====

   // GET /admin/statistics - Get asset statistics
   getAssetStatistics = async (req, res) => {
      try {
         const result = await this.adminService.getAssetStatistics();
         
         res.status(200).json({
            success: true,
            message: 'Statistics retrieved successfully',
            data: result.data
         });
      } catch (error) {
         console.error('Error in getAssetStatistics:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            data: null
         });
      }
   };

   // ===== MASTER DATA ENDPOINTS =====

   // GET /admin/master-data - Get all master data for dropdowns
   getMasterData = async (req, res) => {
      try {
         const result = await this.adminService.getMasterData();
         
         res.status(200).json({
            success: true,
            message: 'Master data retrieved successfully',
            data: result.data
         });
      } catch (error) {
         console.error('Error in getMasterData:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            data: null
         });
      }
   };

   // ===== BULK OPERATIONS =====

   // PUT /admin/assets/bulk-update - Bulk update assets
   bulkUpdateAssets = async (req, res) => {
      try {
         const { asset_numbers, update_data } = req.body;
         const updatedBy = req.user?.user_id || 'admin';

         if (!asset_numbers || !Array.isArray(asset_numbers) || asset_numbers.length === 0) {
            return res.status(400).json({
               success: false,
               message: 'Asset numbers array is required',
               data: null
            });
         }

         if (!update_data || Object.keys(update_data).length === 0) {
            return res.status(400).json({
               success: false,
               message: 'Update data is required',
               data: null
            });
         }

         const results = [];
         const errors = [];

         // Process each asset
         for (const assetNo of asset_numbers) {
            try {
               const result = await this.adminService.updateAsset(assetNo, update_data, updatedBy);
               results.push({
                  asset_no: assetNo,
                  success: true,
                  data: result.data
               });
            } catch (error) {
               errors.push({
                  asset_no: assetNo,
                  success: false,
                  error: error.message
               });
            }
         }

         res.status(200).json({
            success: true,
            message: `Bulk update completed. ${results.length} successful, ${errors.length} failed.`,
            data: {
               successful_updates: results,
               failed_updates: errors,
               total_processed: asset_numbers.length,
               successful_count: results.length,
               failed_count: errors.length
            }
         });
      } catch (error) {
         console.error('Error in bulkUpdateAssets:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            data: null
         });
      }
   };

   // DELETE /admin/assets/bulk-delete - Bulk delete assets
   bulkDeleteAssets = async (req, res) => {
      try {
         const { asset_numbers } = req.body;
         const deletedBy = req.user?.user_id || 'admin';

         if (!asset_numbers || !Array.isArray(asset_numbers) || asset_numbers.length === 0) {
            return res.status(400).json({
               success: false,
               message: 'Asset numbers array is required',
               data: null
            });
         }

         const results = [];
         const errors = [];

         // Process each asset
         for (const assetNo of asset_numbers) {
            try {
               await this.adminService.deleteAsset(assetNo, deletedBy);
               results.push({
                  asset_no: assetNo,
                  success: true
               });
            } catch (error) {
               errors.push({
                  asset_no: assetNo,
                  success: false,
                  error: error.message
               });
            }
         }

         res.status(200).json({
            success: true,
            message: `Bulk delete completed. ${results.length} successful, ${errors.length} failed.`,
            data: {
               successful_deletes: results,
               failed_deletes: errors,
               total_processed: asset_numbers.length,
               successful_count: results.length,
               failed_count: errors.length
            }
         });
      } catch (error) {
         console.error('Error in bulkDeleteAssets:', error);
         res.status(500).json({
            success: false,
            message: error.message,
            data: null
         });
      }
   };
}

module.exports = AdminController;