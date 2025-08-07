const prisma = require('../../core/database/prisma');

class AdminModel {
   constructor() {
      this.prisma = prisma;
   }

   // ===== ASSET MANAGEMENT METHODS =====

   async getAllAssetsWithDetails() {
      return await this.prisma.asset_master.findMany({
         include: {
            mst_plant: true,
            mst_location: true,
            mst_unit: true,
            mst_user: true,
            mst_category: true,
            mst_brand: true,
            asset_scan_log: {
               take: 1,
               orderBy: { scanned_at: 'desc' },
               include: { mst_user: true }
            }
         },
         orderBy: { asset_no: 'asc' }
      });
   }

   async getAssetWithDetailsByNo(assetNo) {
      const asset = await this.prisma.asset_master.findUnique({
         where: { asset_no: assetNo },
         include: {
            mst_plant: true,
            mst_location: true,
            mst_unit: true,
            mst_user: true,
            mst_category: true,
            mst_brand: true,
            asset_scan_log: {
               take: 1,
               orderBy: { scanned_at: 'desc' },
               include: { mst_user: true }
            }
         }
      });

      if (!asset) return null;

      // Get scan count
      const scanCount = await this.prisma.asset_scan_log.count({
         where: { asset_no: assetNo }
      });

      // Format response with additional fields
      return {
         ...asset,
         plant_description: asset.mst_plant?.description,
         location_description: asset.mst_location?.description,
         unit_name: asset.mst_unit?.name,
         created_by_name: asset.mst_user?.full_name,
         category_name: asset.mst_category?.category_name,
         brand_name: asset.mst_brand?.brand_name,
         last_scan_at: asset.asset_scan_log[0]?.scanned_at,
         last_scanned_by: asset.asset_scan_log[0]?.mst_user?.full_name,
         total_scans: scanCount
      };
   }

   async searchAssetsWithDetails(searchTerm, filters = {}) {
      console.log('AdminModel.searchAssetsWithDetails called with:', { searchTerm, filters });
      
      const whereConditions = {};

      // Add search conditions
      if (searchTerm) {
         whereConditions.OR = [
            { asset_no: { contains: searchTerm } },
            { description: { contains: searchTerm } },
            { serial_no: { contains: searchTerm } },
            { inventory_no: { contains: searchTerm } },
            { epc_code: { contains: searchTerm } }
         ];
      }

      // Add filter conditions
      if (filters.status) {
         console.log('Adding status filter:', filters.status);
         whereConditions.status = filters.status;
      }
      if (filters.plant_code) {
         whereConditions.plant_code = filters.plant_code;
      }
      if (filters.location_code) {
         whereConditions.location_code = filters.location_code;
      }
      if (filters.unit_code) {
         whereConditions.unit_code = filters.unit_code;
      }
      if (filters.category_code) {
         whereConditions.category_code = filters.category_code;
      }
      if (filters.brand_code) {
         whereConditions.brand_code = filters.brand_code;
      }

      console.log('Final whereConditions:', JSON.stringify(whereConditions, null, 2));
      
      const result = await this.prisma.asset_master.findMany({
         where: whereConditions,
         include: {
            mst_plant: true,
            mst_location: true,
            mst_unit: true,
            mst_user: true,
            mst_category: true,
            mst_brand: true,
            asset_scan_log: {
               take: 1,
               orderBy: { scanned_at: 'desc' },
               include: { mst_user: true }
            }
         },
         orderBy: { asset_no: 'asc' }
      });
      
      console.log('Database query returned:', result.length, 'assets');
      return result;
   }

   async updateAsset(assetNo, updateData, updatedBy) {
      // Start a transaction to update asset and log the change
      return await this.prisma.$transaction(async (tx) => {
         // Get current asset data for history
         const currentAsset = await tx.asset_master.findUnique({
            where: { asset_no: assetNo }
         });

         if (!currentAsset) {
            throw new Error('Asset not found');
         }

         // Update asset
         const updatedAsset = await tx.asset_master.update({
            where: { asset_no: assetNo },
            data: updateData
         });

         // Log status change if status was updated
         if (updateData.status && updateData.status !== currentAsset.status) {
            await tx.asset_status_history.create({
               data: {
                  asset_no: assetNo,
                  old_status: currentAsset.status,
                  new_status: updateData.status,
                  changed_by: updatedBy,
                  changed_at: new Date(),
                  remarks: `Status changed from ${currentAsset.status} to ${updateData.status} via Admin Panel`
               }
            });
         }

         return updatedAsset;
      });
   }

   async deleteAsset(assetNo, deletedBy) {
      console.log('AdminModel.deleteAsset called with:', { assetNo, deletedBy });
      
      return await this.prisma.$transaction(async (tx) => {
         try {
            // Check if asset exists
            console.log('Checking if asset exists:', assetNo);
            const asset = await tx.asset_master.findUnique({
               where: { asset_no: assetNo }
            });

            if (!asset) {
               throw new Error('Asset not found');
            }

            console.log('Asset found:', asset.asset_no, 'current status:', asset.status);

            const currentTime = new Date();

            // Set status to 'I' (Inactive) and save deactivation timestamp
            console.log('Updating asset status to I');
            const updatedAsset = await tx.asset_master.update({
               where: { asset_no: assetNo },
               data: {
                  status: 'I',
                  deactivated_at: currentTime
               }
            });

            console.log('Asset updated successfully');

            // Log status change to inactive
            if (asset.status !== 'I') {
               console.log('Creating status history entry');
               
               // Verify user exists before creating status history
               const userExists = await tx.mst_user.findUnique({
                  where: { user_id: deletedBy }
               });
               
               if (userExists) {
                  await tx.asset_status_history.create({
                     data: {
                        asset_no: assetNo,
                        old_status: asset.status,
                        new_status: 'I',
                        changed_by: deletedBy,
                        changed_at: currentTime,
                        remarks: `Asset deactivated via Admin Panel (soft delete)`
                     }
                  });
                  console.log('Status history created');
               } else {
                  console.log('User not found, creating status history without changed_by');
                  await tx.asset_status_history.create({
                     data: {
                        asset_no: assetNo,
                        old_status: asset.status,
                        new_status: 'I',
                        changed_by: null, // Allow null if user doesn't exist
                        changed_at: currentTime,
                        remarks: `Asset deactivated via Admin Panel (soft delete) - User not found`
                     }
                  });
               }
            }

            console.log('Soft delete completed successfully');
            return { success: true, deactivatedAssetNo: assetNo, deactivatedAt: currentTime };
         } catch (error) {
            console.error('Error in deleteAsset transaction:', error);
            throw error;
         }
      });
   }

   // ===== VALIDATION METHODS =====

   async checkAssetExists(assetNo) {
      const asset = await this.prisma.asset_master.findUnique({
         where: { asset_no: assetNo }
      });
      return !!asset;
   }

   async checkSerialNoExists(serialNo, excludeAssetNo = null) {
      const whereCondition = { serial_no: serialNo };
      if (excludeAssetNo) {
         whereCondition.NOT = { asset_no: excludeAssetNo };
      }

      const asset = await this.prisma.asset_master.findFirst({
         where: whereCondition
      });
      return !!asset;
   }

   async checkInventoryNoExists(inventoryNo, excludeAssetNo = null) {
      const whereCondition = { inventory_no: inventoryNo };
      if (excludeAssetNo) {
         whereCondition.NOT = { asset_no: excludeAssetNo };
      }

      const asset = await this.prisma.asset_master.findFirst({
         where: whereCondition
      });
      return !!asset;
   }

   async checkEpcCodeExists(epcCode, excludeAssetNo = null) {
      const whereCondition = { epc_code: epcCode };
      if (excludeAssetNo) {
         whereCondition.NOT = { asset_no: excludeAssetNo };
      }

      const asset = await this.prisma.asset_master.findFirst({
         where: whereCondition
      });
      return !!asset;
   }

   // ===== STATISTICS METHODS =====

   async getAssetCounts() {
      const totalAssets = await this.prisma.asset_master.count();
      const awaitingAssets = await this.prisma.asset_master.count({
         where: { status: 'A' }
      });
      const checkedAssets = await this.prisma.asset_master.count({
         where: { status: 'C' }
      });
      const inactiveAssets = await this.prisma.asset_master.count({
         where: { status: 'I' }
      });

      return {
         total: totalAssets,
         awaiting: awaitingAssets,
         checked: checkedAssets,
         inactive: inactiveAssets
      };
   }

   // ===== MASTER DATA METHODS (for dropdowns/selects) =====

   async getAllPlants() {
      return await this.prisma.mst_plant.findMany({
         orderBy: { plant_code: 'asc' }
      });
   }

   async getAllLocations() {
      return await this.prisma.mst_location.findMany({
         include: { mst_plant: true },
         orderBy: { location_code: 'asc' }
      });
   }

   async getAllUnits() {
      return await this.prisma.mst_unit.findMany({
         orderBy: { unit_code: 'asc' }
      });
   }

   async getAllCategories() {
      return await this.prisma.mst_category.findMany({
         where: { is_active: true },
         orderBy: { category_code: 'asc' }
      });
   }

   async getAllBrands() {
      return await this.prisma.mst_brand.findMany({
         where: { is_active: true },
         orderBy: { brand_code: 'asc' }
      });
   }
}

module.exports = AdminModel;