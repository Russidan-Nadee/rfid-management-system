const prisma = require('../../core/database/prisma');
const StatusChangeLogger = require('../../core/utils/statusChangeLogger');

class AdminModel {
   constructor() {
      this.prisma = prisma;
   }

   // ===== ASSET MANAGEMENT METHODS =====

   async getAllAssetsWithDetails() {
      const assets = await this.prisma.asset_master.findMany({
         include: {
            mst_plant: true,
            mst_location: true,
            mst_unit: true,
            mst_user: true,
            mst_category: true,
            mst_brand: true,
            mst_department: true,
            asset_scan_log: {
               take: 1,
               orderBy: { scanned_at: 'desc' },
               include: { mst_user: true }
            }
         },
         orderBy: { asset_no: 'asc' }
      });

      // Format each asset with additional fields
      return assets.map(asset => ({
         ...asset,
         plant_description: asset.mst_plant?.description,
         location_description: asset.mst_location?.description,
         dept_description: asset.mst_department?.description,
         unit_name: asset.mst_unit?.name,
         created_by_name: asset.mst_user?.full_name,
         category_name: asset.mst_category?.category_name,
         brand_name: asset.mst_brand?.brand_name,
         last_scan_at: asset.asset_scan_log[0]?.scanned_at,
         last_scanned_by: asset.asset_scan_log[0]?.mst_user?.full_name,
         total_scans: 0 // Will be calculated if needed
      }));
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
         dept_description: asset.mst_department?.description,
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
      
      const assets = await this.prisma.asset_master.findMany({
         where: whereConditions,
         include: {
            mst_plant: true,
            mst_location: true,
            mst_unit: true,
            mst_user: true,
            mst_category: true,
            mst_brand: true,
            mst_department: true,
            asset_scan_log: {
               take: 1,
               orderBy: { scanned_at: 'desc' },
               include: { mst_user: true }
            }
         },
         orderBy: { asset_no: 'asc' }
      });
      
      console.log('Database query returned:', assets.length, 'assets');
      
      // Format each asset with additional fields
      const formattedAssets = assets.map(asset => ({
         ...asset,
         plant_description: asset.mst_plant?.description,
         location_description: asset.mst_location?.description,
         dept_description: asset.mst_department?.description,
         unit_name: asset.mst_unit?.name,
         created_by_name: asset.mst_user?.full_name,
         category_name: asset.mst_category?.category_name,
         brand_name: asset.mst_brand?.brand_name,
         last_scan_at: asset.asset_scan_log[0]?.scanned_at,
         last_scanned_by: asset.asset_scan_log[0]?.mst_user?.full_name,
         total_scans: 0 // Will be calculated if needed
      }));
      
      return formattedAssets;
   }

   async updateAsset(assetNo, updateData, updatedBy) {
      // Use the centralized status change logger for consistency
      return await StatusChangeLogger.updateAssetWithLogging({
         assetNo,
         updateData,
         changedBy: updatedBy,
         remarks: `Asset updated via Admin Panel`
      });
   }

   async deleteAsset(assetNo, deletedBy) {
      console.log('AdminModel.deleteAsset called with:', { assetNo, deletedBy });
      
      // Use the centralized status change logger for soft delete
      const updateData = {
         status: 'I',
         deactivated_at: new Date()
      };
      
      try {
         const updatedAsset = await StatusChangeLogger.updateAssetWithLogging({
            assetNo,
            updateData,
            changedBy: deletedBy,
            remarks: `Asset deactivated via Admin Panel (soft delete)`
         });

         console.log('Soft delete completed successfully');
         return { 
            success: true, 
            deactivatedAssetNo: assetNo, 
            deactivatedAt: updateData.deactivated_at 
         };
      } catch (error) {
         console.error('Error in deleteAsset:', error);
         throw error;
      }
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

   async getAllDepartments() {
      return await this.prisma.mst_department.findMany({
         include: { mst_plant: true },
         orderBy: { dept_code: 'asc' }
      });
   }

   // ===== USER MANAGEMENT METHODS =====

   async getAllUsers() {
      return await this.prisma.mst_user.findMany({
         orderBy: [
            { role: 'asc' },
            { full_name: 'asc' }
         ]
      });
   }

   async getUserById(userId) {
      return await this.prisma.mst_user.findUnique({
         where: { user_id: userId }
      });
   }

   async updateUserRole(userId, role, updatedBy) {
      return await this.prisma.mst_user.update({
         where: { user_id: userId },
         data: {
            role: role,
            updated_at: new Date()
         }
      });
   }

   async updateUserStatus(userId, isActive, updatedBy) {
      return await this.prisma.mst_user.update({
         where: { user_id: userId },
         data: {
            is_active: isActive,
            updated_at: new Date()
         }
      });
   }
}

module.exports = AdminModel;