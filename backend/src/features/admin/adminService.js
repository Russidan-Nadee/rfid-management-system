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
         console.log('AdminService.searchAssets called with:', { searchTerm, filters });
         
         const assets = await this.adminModel.searchAssetsWithDetails(searchTerm, filters);
         console.log('Raw assets from database:', assets.length, 'found');
         
         const formattedAssets = assets.map(asset => {
            try {
               return this.formatAssetResponse(asset);
            } catch (formatError) {
               console.error('Error formatting asset:', asset.asset_no, formatError);
               throw formatError;
            }
         });

         console.log('Successfully formatted assets:', formattedAssets.length);

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

         // Deactivate asset (soft delete)
         const result = await this.adminModel.deleteAsset(assetNo, deletedBy);

         return {
            success: true,
            message: 'Asset deactivated successfully',
            deactivatedAssetNo: result.deactivatedAssetNo,
            deactivatedAt: result.deactivatedAt
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
         status_text: asset.status === 'A' ? 'Awaiting' : asset.status === 'C' ? 'Checked' : 'Inactive'
      };
   }

   sanitizeUpdateData(updateData) {
      const sanitized = {};
      
      // Handle each field appropriately
      Object.keys(updateData).forEach(key => {
         const value = updateData[key];
         
         // Allow null values for optional fields, but not empty strings for required fields
         if (value !== undefined) {
            // For status field, ensure it's one of the valid values
            if (key === 'status') {
               if (value === 'A' || value === 'C' || value === 'I') {
                  sanitized[key] = value;
               }
            }
            // For other fields, include if not empty string
            else if (value !== '') {
               sanitized[key] = value;
            }
            // Allow explicit null for optional fields
            else if (value === null) {
               sanitized[key] = null;
            }
         }
      });

      return sanitized;
   }

   async canDeleteAsset(assetNo) {
      // Business rules for asset deactivation (soft delete)
      try {
         // Since we're doing soft delete, we can allow deactivation even with recent scans
         // Add any specific business rules here if needed
         
         return {
            allowed: true,
            reason: null
         };
      } catch (error) {
         console.error('Error checking deactivation permission:', error);
         return {
            allowed: false,
            reason: 'Unable to verify deactivation permissions'
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
               awaiting_assets: counts.awaiting,
               checked_assets: counts.checked,
               inactive_assets: counts.inactive,
               awaiting_percentage: counts.total > 0 ? Math.round((counts.awaiting / counts.total) * 100) : 0,
               checked_percentage: counts.total > 0 ? Math.round((counts.checked / counts.total) * 100) : 0
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