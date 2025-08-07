const AdminModel = require('./adminModel');

class AdminService {
   constructor() {
      this.adminModel = new AdminModel();
   }

   // ===== ASSET MANAGEMENT SERVICES =====

   async getAllAssets() {
      try {
         const assets = await this.adminModel.getAllAssetsWithDetails();
         
         // Format the response with additional computed fields
         const formattedAssets = assets.map(asset => this.formatAssetResponse(asset));

         return {
            success: true,
            data: formattedAssets,
            total: formattedAssets.length
         };
      } catch (error) {
         console.error('Error getting all assets:', error);
         throw new Error('Failed to fetch assets: ' + error.message);
      }
   }

   async getAssetByNo(assetNo) {
      try {
         if (!assetNo) {
            throw new Error('Asset number is required');
         }

         const asset = await this.adminModel.getAssetWithDetailsByNo(assetNo);
         
         if (!asset) {
            return {
               success: false,
               message: 'Asset not found',
               data: null
            };
         }

         return {
            success: true,
            data: this.formatAssetResponse(asset)
         };
      } catch (error) {
         console.error('Error getting asset by number:', error);
         throw new Error('Failed to fetch asset: ' + error.message);
      }
   }

   async searchAssets(searchTerm, filters = {}) {
      try {
         const assets = await this.adminModel.searchAssetsWithDetails(searchTerm, filters);
         
         const formattedAssets = assets.map(asset => this.formatAssetResponse(asset));

         return {
            success: true,
            data: formattedAssets,
            total: formattedAssets.length,
            searchTerm,
            filters
         };
      } catch (error) {
         console.error('Error searching assets:', error);
         throw new Error('Failed to search assets: ' + error.message);
      }
   }

   async updateAsset(assetNo, updateData, updatedBy) {
      try {
         // Validate asset exists
         const assetExists = await this.adminModel.checkAssetExists(assetNo);
         if (!assetExists) {
            throw new Error('Asset not found');
         }

         // Validate unique constraints if updating serial_no, inventory_no, or epc_code
         if (updateData.serial_no) {
            const serialExists = await this.adminModel.checkSerialNoExists(updateData.serial_no, assetNo);
            if (serialExists) {
               throw new Error('Serial number already exists for another asset');
            }
         }

         if (updateData.inventory_no) {
            const inventoryExists = await this.adminModel.checkInventoryNoExists(updateData.inventory_no, assetNo);
            if (inventoryExists) {
               throw new Error('Inventory number already exists for another asset');
            }
         }

         if (updateData.epc_code) {
            const epcExists = await this.adminModel.checkEpcCodeExists(updateData.epc_code, assetNo);
            if (epcExists) {
               throw new Error('EPC code already exists for another asset');
            }
         }

         // Sanitize update data (remove null/undefined values)
         const sanitizedData = this.sanitizeUpdateData(updateData);

         // Update asset
         await this.adminModel.updateAsset(assetNo, sanitizedData, updatedBy);

         // Get updated asset with details
         const updatedAsset = await this.adminModel.getAssetWithDetailsByNo(assetNo);

         return {
            success: true,
            message: 'Asset updated successfully',
            data: this.formatAssetResponse(updatedAsset)
         };
      } catch (error) {
         console.error('Error updating asset:', error);
         throw new Error('Failed to update asset: ' + error.message);
      }
   }

   async deleteAsset(assetNo, deletedBy) {
      try {
         // Validate asset exists
         const assetExists = await this.adminModel.checkAssetExists(assetNo);
         if (!assetExists) {
            throw new Error('Asset not found');
         }

         // Check if asset can be deleted (business rules)
         const canDelete = await this.canDeleteAsset(assetNo);
         if (!canDelete.allowed) {
            throw new Error(canDelete.reason);
         }

         // Delete asset
         await this.adminModel.deleteAsset(assetNo);

         return {
            success: true,
            message: 'Asset deleted successfully',
            deletedAssetNo: assetNo
         };
      } catch (error) {
         console.error('Error deleting asset:', error);
         throw new Error('Failed to delete asset: ' + error.message);
      }
   }

   // ===== UTILITY METHODS =====

   formatAssetResponse(asset) {
      if (!asset) return null;

      return {
         asset_no: asset.asset_no,
         epc_code: asset.epc_code,
         description: asset.description,
         serial_no: asset.serial_no,
         inventory_no: asset.inventory_no,
         plant_code: asset.plant_code,
         location_code: asset.location_code,
         unit_code: asset.unit_code,
         dept_code: asset.dept_code,
         category_code: asset.category_code,
         brand_code: asset.brand_code,
         quantity: asset.quantity,
         status: asset.status,
         created_by: asset.created_by,
         created_at: asset.created_at,
         
         // Computed fields
         plant_description: asset.plant_description || asset.mst_plant?.description,
         location_description: asset.location_description || asset.mst_location?.description,
         unit_name: asset.unit_name || asset.mst_unit?.name,
         created_by_name: asset.created_by_name || asset.mst_user?.full_name,
         category_name: asset.category_name || asset.mst_category?.category_name,
         brand_name: asset.brand_name || asset.mst_brand?.brand_name,
         last_scan_at: asset.last_scan_at,
         last_scanned_by: asset.last_scanned_by,
         total_scans: asset.total_scans || 0,
         
         // Status helpers
         is_active: asset.status === 'A',
         status_text: asset.status === 'A' ? 'Active' : 'Inactive'
      };
   }

   sanitizeUpdateData(updateData) {
      const sanitized = {};
      
      // Only include fields that are not null, undefined, or empty strings
      Object.keys(updateData).forEach(key => {
         const value = updateData[key];
         if (value !== null && value !== undefined && value !== '') {
            sanitized[key] = value;
         }
      });

      return sanitized;
   }

   async canDeleteAsset(assetNo) {
      // Business rules for asset deletion
      try {
         // Example: Check if asset has been scanned recently (within last 7 days)
         const recentScans = await this.adminModel.prisma.asset_scan_log.count({
            where: {
               asset_no: assetNo,
               scanned_at: {
                  gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) // 7 days ago
               }
            }
         });

         if (recentScans > 0) {
            return {
               allowed: false,
               reason: 'Asset has been scanned recently. Please wait or mark as inactive instead.'
            };
         }

         // Add more business rules here as needed
         
         return {
            allowed: true,
            reason: null
         };
      } catch (error) {
         console.error('Error checking delete permission:', error);
         return {
            allowed: false,
            reason: 'Unable to verify delete permissions'
         };
      }
   }

   // ===== STATISTICS SERVICES =====

   async getAssetStatistics() {
      try {
         const counts = await this.adminModel.getAssetCounts();
         
         return {
            success: true,
            data: {
               total_assets: counts.total,
               active_assets: counts.active,
               inactive_assets: counts.inactive,
               active_percentage: counts.total > 0 ? Math.round((counts.active / counts.total) * 100) : 0
            }
         };
      } catch (error) {
         console.error('Error getting asset statistics:', error);
         throw new Error('Failed to get asset statistics: ' + error.message);
      }
   }

   // ===== MASTER DATA SERVICES =====

   async getMasterData() {
      try {
         const [plants, locations, units, categories, brands] = await Promise.all([
            this.adminModel.getAllPlants(),
            this.adminModel.getAllLocations(),
            this.adminModel.getAllUnits(),
            this.adminModel.getAllCategories(),
            this.adminModel.getAllBrands()
         ]);

         return {
            success: true,
            data: {
               plants,
               locations,
               units,
               categories,
               brands
            }
         };
      } catch (error) {
         console.error('Error getting master data:', error);
         throw new Error('Failed to get master data: ' + error.message);
      }
   }
}

module.exports = AdminService;