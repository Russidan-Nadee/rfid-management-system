// Path: src/models/model.js
const prisma = require('../../core/database/prisma');

// Base Model Class for common operations
class BaseModel {
   constructor(modelName) {
      this.modelName = modelName;
      this.prisma = prisma;
   }

   async executeQuery(query, params = []) {
      // For backwards compatibility - convert to Prisma raw query
      return await this.prisma.$queryRawUnsafe(query, ...params);
   }

   async findAll(conditions = {}, orderBy = null, limit = null) {
      const model = this.prisma[this.modelName];
      const options = {
         where: conditions
      };

      if (orderBy) {
         options.orderBy = { [orderBy]: 'asc' };
      }

      if (limit) {
         options.take = limit;
      }

      return await model.findMany(options);
   }

   async findById(id, idField = 'id') {
      const model = this.prisma[this.modelName];
      return await model.findUnique({
         where: { [idField]: id }
      });
   }

   async count(conditions = {}) {
      const model = this.prisma[this.modelName];
      return await model.count({
         where: conditions
      });
   }
}

// Plant Model
class PlantModel extends BaseModel {
   constructor() {
      super('mst_plant');
   }

   async getAllPlants() {
      return await this.prisma.mst_plant.findMany({
         orderBy: { plant_code: 'asc' }
      });
   }

   async getPlantByCode(plantCode) {
      return await this.prisma.mst_plant.findUnique({
         where: { plant_code: plantCode }
      });
   }
}

// Location Model
class LocationModel extends BaseModel {
   constructor() {
      super('mst_location');
   }

   async getAllLocations() {
      return await this.prisma.mst_location.findMany({
         orderBy: { location_code: 'asc' }
      });
   }

   async getLocationsByPlant(plantCode) {
      return await this.prisma.mst_location.findMany({
         where: { plant_code: plantCode },
         orderBy: { location_code: 'asc' }
      });
   }

   async getLocationByCode(locationCode) {
      return await this.prisma.mst_location.findUnique({
         where: { location_code: locationCode }
      });
   }

   async getLocationsWithPlant() {
      return await this.prisma.mst_location.findMany({
         include: {
            mst_plant: true
         },
         orderBy: { location_code: 'asc' }
      });
   }
}

// Unit Model
class UnitModel extends BaseModel {
   constructor() {
      super('mst_unit');
   }

   async getAllUnits() {
      return await this.prisma.mst_unit.findMany({
         orderBy: { unit_code: 'asc' }
      });
   }

   async getUnitByCode(unitCode) {
      return await this.prisma.mst_unit.findUnique({
         where: { unit_code: unitCode }
      });
   }
}

// User Model
class UserModel extends BaseModel {
   constructor() {
      super('mst_user');
   }

   async getAllUsers() {
      return await this.prisma.mst_user.findMany({
         orderBy: { user_id: 'asc' }
      });
   }

   async getUserById(userId) {
      return await this.prisma.mst_user.findUnique({
         where: { user_id: userId }
      });
   }

   async getUserByUsername(username) {
      return await this.prisma.mst_user.findUnique({
         where: { username: username }
      });
   }
}

// Asset Model
class AssetModel extends BaseModel {
   constructor() {
      super('asset_master');
   }

   async getActiveAssets() {
      return await this.prisma.asset_master.findMany({
         where: { status: 'A' },
         orderBy: { asset_no: 'asc' }
      });
   }

   async getAssetByNo(assetNo) {
      return await this.prisma.asset_master.findUnique({
         where: { asset_no: assetNo }
      });
   }

   // ===== NEW EPC METHODS =====
   async getAssetByEpc(epcCode) {
      return await this.prisma.asset_master.findUnique({
         where: { epc_code: epcCode }
      });
   }

   async getAssetWithDetailsByEpc(epcCode) {
      const asset = await this.prisma.asset_master.findUnique({
         where: { epc_code: epcCode },
         include: {
            mst_plant: true,
            mst_location: true,
            mst_unit: true,
            mst_user: true,
            asset_scan_log: {
               take: 1,
               orderBy: { scanned_at: 'desc' },
               include: { mst_user: true }
            }
         }
      });

      if (!asset) return null;

      const scanCount = await this.prisma.asset_scan_log.count({
         where: { asset_no: asset.asset_no }
      });

      return {
         ...asset,
         plant_description: asset.mst_plant?.description,
         location_description: asset.mst_location?.description,
         unit_name: asset.mst_unit?.name,
         created_by_name: asset.mst_user?.full_name,
         last_scan_at: asset.asset_scan_log[0]?.scanned_at,
         last_scanned_by: asset.asset_scan_log[0]?.mst_user?.full_name,
         total_scans: scanCount
      };
   }

   async updateAssetStatusByEpc(epcCode, updateData) {
      // หา asset ก่อน
      const asset = await this.getAssetByEpc(epcCode);
      if (!asset) throw new Error('Asset not found');

      // update ผ่าน asset_no
      await this.prisma.asset_master.update({
         where: { asset_no: asset.asset_no },
         data: updateData
      });

      return this.getAssetWithDetailsByEpc(epcCode);
   }

   async getAssetsByPlant(plantCode) {
      return await this.prisma.asset_master.findMany({
         where: {
            plant_code: plantCode,
            status: 'A'
         },
         orderBy: { asset_no: 'asc' }
      });
   }

   async getAssetsByLocation(locationCode) {
      return await this.prisma.asset_master.findMany({
         where: {
            location_code: locationCode,
            status: 'A'
         },
         orderBy: { asset_no: 'asc' }
      });
   }

   async getAssetsWithDetails() {
      return await this.prisma.asset_master.findMany({
         where: { status: 'A' },
         include: {
            mst_plant: true,
            mst_location: true,
            mst_unit: true,
            mst_user: true
         },
         orderBy: { asset_no: 'asc' }
      });
   }

   async getAssetWithDetails(assetNo) {
      const asset = await this.prisma.asset_master.findUnique({
         where: { asset_no: assetNo },
         include: {
            mst_plant: true,
            mst_location: true,
            mst_unit: true,
            mst_user: true,
            asset_scan_log: {
               take: 1,
               orderBy: { scanned_at: 'desc' },
               include: {
                  mst_user: true
               }
            }
         }
      });

      if (!asset) return null;

      // Add scan count
      const scanCount = await this.prisma.asset_scan_log.count({
         where: { asset_no: assetNo }
      });

      // Format response to match original structure
      return {
         ...asset,
         plant_description: asset.mst_plant?.description,
         location_description: asset.mst_location?.description,
         unit_name: asset.mst_unit?.name,
         created_by_name: asset.mst_user?.full_name,
         last_scan_at: asset.asset_scan_log[0]?.scanned_at,
         last_scanned_by: asset.asset_scan_log[0]?.mst_user?.full_name,
         total_scans: scanCount
      };
   }

   async searchAssets(searchTerm, filters = {}) {
      const whereConditions = {
         status: filters.status || 'A'
      };

      // Add search conditions
      if (searchTerm) {
         whereConditions.OR = [
            { asset_no: { contains: searchTerm } },
            { description: { contains: searchTerm } },
            { serial_no: { contains: searchTerm } },
            { inventory_no: { contains: searchTerm } },
            { epc_code: { contains: searchTerm } } // เพิ่ม EPC search
         ];
      }

      // Add filter conditions
      if (filters.plant_code) {
         whereConditions.plant_code = filters.plant_code;
      }
      if (filters.location_code) {
         whereConditions.location_code = filters.location_code;
      }
      if (filters.unit_code) {
         whereConditions.unit_code = filters.unit_code;
      }

      return await this.prisma.asset_master.findMany({
         where: whereConditions,
         include: {
            mst_plant: true,
            mst_location: true,
            mst_unit: true,
            mst_user: true
         },
         orderBy: { asset_no: 'asc' }
      });
   }

   async createAsset(assetData) {
      const newAsset = await this.prisma.asset_master.create({
         data: assetData
      });
      return this.getAssetWithDetails(newAsset.asset_no);
   }

   async checkSerialExists(serialNo) {
      const asset = await this.prisma.asset_master.findUnique({
         where: { serial_no: serialNo }
      });
      return !!asset;
   }

   async checkInventoryExists(inventoryNo) {
      const asset = await this.prisma.asset_master.findUnique({
         where: { inventory_no: inventoryNo }
      });
      return !!asset;
   }

   async checkEpcExists(epcCode) {
      const asset = await this.prisma.asset_master.findUnique({
         where: { epc_code: epcCode }
      });
      return !!asset;
   }

   async updateAsset(assetNo, updateData) {
      await this.prisma.asset_master.update({
         where: { asset_no: assetNo },
         data: updateData
      });
      return this.getAssetWithDetails(assetNo);
   }

   async updateAssetStatus(assetNo, updateData) {
      await this.prisma.asset_master.update({
         where: { asset_no: assetNo },
         data: updateData
      });
      return this.getAssetWithDetails(assetNo);
   }

   async getAssetStatusHistory(assetNo) {
      return await this.prisma.asset_status_history.findMany({
         where: { asset_no: assetNo },
         include: {
            mst_user: true
         },
         orderBy: { changed_at: 'desc' }
      });
   }
}
// Category Model
class CategoryModel extends BaseModel {
   constructor() {
      super('mst_category');
   }

   async getAllCategories() {
      return await this.prisma.mst_category.findMany({
         where: { is_active: true },
         orderBy: { category_code: 'asc' }
      });
   }

   async getCategoryByCode(categoryCode) {
      return await this.prisma.mst_category.findUnique({
         where: { category_code: categoryCode }
      });
   }
}

// Brand Model
class BrandModel extends BaseModel {
   constructor() {
      super('mst_brand');
   }

   async getAllBrands() {
      return await this.prisma.mst_brand.findMany({
         where: { is_active: true },
         orderBy: { brand_code: 'asc' }
      });
   }

   async getBrandByCode(brandCode) {
      return await this.prisma.mst_brand.findUnique({
         where: { brand_code: brandCode }
      });
   }
}

module.exports = {
   PlantModel,
   LocationModel,
   UnitModel,
   UserModel,
   AssetModel,
   BaseModel,
   CategoryModel,
   BrandModel
};