// Path: src/services/scanService.js
const { PlantModel, LocationModel, UnitModel, UserModel, AssetModel } = require('./scanModel');
const { CategoryModel, BrandModel } = require('./scanModel');
const DepartmentService = require('../dashboard/dashboardService');
const prisma = require('../../core/database/prisma');

class BaseService {
   constructor(model) {
      this.model = new model();
   }

   async getAll(filters = {}) {
      try {
         return await this.model.findAll(filters);
      } catch (error) {
         throw new Error(`Error fetching data: ${error.message}`);
      }
   }

   async getById(id, idField = 'id') {
      try {
         return await this.model.findById(id, idField);
      } catch (error) {
         throw new Error(`Error fetching data by ID: ${error.message}`);
      }
   }

   async count(filters = {}) {
      try {
         return await this.model.count(filters);
      } catch (error) {
         throw new Error(`Error counting data: ${error.message}`);
      }
   }
}

class PlantService extends BaseService {
   constructor() {
      super(PlantModel);
   }

   async getAllPlants() {
      try {
         return await this.model.getAllPlants();
      } catch (error) {
         throw new Error(`Error fetching plants: ${error.message}`);
      }
   }

   async getPlantByCode(plantCode) {
      try {
         const plant = await this.model.getPlantByCode(plantCode);
         if (!plant) {
            throw new Error('Plant not found');
         }
         return plant;
      } catch (error) {
         throw new Error(`Error fetching plant: ${error.message}`);
      }
   }

   async getPlantStats() {
      try {
         const totalPlants = await this.model.count();

         return {
            total: totalPlants,
            active: totalPlants, // No status field, all are considered active
            inactive: 0
         };
      } catch (error) {
         throw new Error(`Error fetching plant statistics: ${error.message}`);
      }
   }
}

class LocationService extends BaseService {
   constructor() {
      super(LocationModel);
   }

   async getAllLocations() {
      try {
         return await this.model.getAllLocations();
      } catch (error) {
         throw new Error(`Error fetching locations: ${error.message}`);
      }
   }

   async getLocationsByPlant(plantCode) {
      try {
         return await this.model.getLocationsByPlant(plantCode);
      } catch (error) {
         throw new Error(`Error fetching locations by plant: ${error.message}`);
      }
   }

   async getLocationByCode(locationCode) {
      try {
         const location = await this.model.getLocationByCode(locationCode);
         if (!location) {
            throw new Error('Location not found');
         }
         return location;
      } catch (error) {
         throw new Error(`Error fetching location: ${error.message}`);
      }
   }

   async getLocationsWithPlant() {
      try {
         return await this.model.getLocationsWithPlant();
      } catch (error) {
         throw new Error(`Error fetching locations with plant details: ${error.message}`);
      }
   }
}

class UnitService extends BaseService {
   constructor() {
      super(UnitModel);
   }

   async getAllUnits() {
      try {
         return await this.model.getAllUnits();
      } catch (error) {
         throw new Error(`Error fetching units: ${error.message}`);
      }
   }

   async getUnitByCode(unitCode) {
      try {
         const unit = await this.model.getUnitByCode(unitCode);
         if (!unit) {
            throw new Error('Unit not found');
         }
         return unit;
      } catch (error) {
         throw new Error(`Error fetching unit: ${error.message}`);
      }
   }
}

class UserService extends BaseService {
   constructor() {
      super(UserModel);
   }

   async getAllUsers() {
      try {
         return await this.model.getAllUsers();
      } catch (error) {
         throw new Error(`Error fetching users: ${error.message}`);
      }
   }

   async getUserById(userId) {
      try {
         const user = await this.model.getUserById(userId);
         if (!user) {
            throw new Error('User not found');
         }
         return user;
      } catch (error) {
         throw new Error(`Error fetching user: ${error.message}`);
      }
   }

   async getUserByUsername(username) {
      try {
         const user = await this.model.getUserByUsername(username);
         if (!user) {
            throw new Error('User not found');
         }
         return user;
      } catch (error) {
         throw new Error(`Error fetching user by username: ${error.message}`);
      }
   }
}

class AssetService extends BaseService {
   constructor() {
      super(AssetModel);
   }

   async getActiveAssets() {
      try {
         return await this.model.getActiveAssets();
      } catch (error) {
         throw new Error(`Error fetching active assets: ${error.message}`);
      }
   }

   async getAssetByNo(assetNo) {
      try {
         const asset = await this.model.getAssetByNo(assetNo);
         if (!asset) {
            throw new Error('Asset not found');
         }
         return asset;
      } catch (error) {
         throw new Error(`Error fetching asset: ${error.message}`);
      }
   }

   // ===== NEW EPC METHODS =====
   async getAssetByEpc(epcCode) {
      try {
         const asset = await this.model.getAssetByEpc(epcCode);
         if (!asset) {
            throw new Error('Asset not found');
         }
         return asset;
      } catch (error) {
         throw new Error(`Error fetching asset by EPC: ${error.message}`);
      }
   }

   async getAssetWithDetailsByEpc(epcCode) {
      try {
         const asset = await this.model.getAssetWithDetailsByEpc(epcCode);
         if (!asset) {
            throw new Error('Asset not found');
         }
         return asset;
      } catch (error) {
         throw new Error(`Error fetching asset with details by EPC: ${error.message}`);
      }
   }

   async updateAssetStatusByEpc(epcCode, status, updatedBy, remarks = null) {
      try {
         const validStatuses = ['C', 'A', 'I'];
         if (!validStatuses.includes(status)) {
            throw new Error('Invalid status. Must be C, A, or I');
         }

         const updateData = { status };
         if (status === 'I') {
            updateData.deactivated_at = new Date();
         }

         // Use the model layer which now includes automatic status logging
         return await this.model.updateAssetStatusByEpc(
            epcCode, 
            updateData, 
            updatedBy, 
            remarks || `Status changed to ${status} via EPC scan`
         );

      } catch (error) {
         throw new Error(`Error updating asset status by EPC: ${error.message}`);
      }
   }

   async getAssetWithDetails(assetNo) {
      try {
         const asset = await this.model.getAssetWithDetails(assetNo);
         if (!asset) {
            throw new Error('Asset not found');
         }
         return asset;
      } catch (error) {
         throw new Error(`Error fetching asset with details: ${error.message}`);
      }
   }

   async getAssetsWithDetails() {
      try {
         return await this.model.getAssetsWithDetails();
      } catch (error) {
         throw new Error(`Error fetching assets with details: ${error.message}`);
      }
   }

   async getAssetsByPlant(plantCode) {
      try {
         return await this.model.getAssetsByPlant(plantCode);
      } catch (error) {
         throw new Error(`Error fetching assets by plant: ${error.message}`);
      }
   }

   async getAssetsByLocation(locationCode) {
      try {
         return await this.model.getAssetsByLocation(locationCode);
      } catch (error) {
         throw new Error(`Error fetching assets by location: ${error.message}`);
      }
   }

   async searchAssets(searchTerm, filters = {}) {
      try {
         return await this.model.searchAssets(searchTerm, filters);
      } catch (error) {
         throw new Error(`Error searching assets: ${error.message}`);
      }
   }

   async getAssetStats() {
      try {
         const [total, active, created, inactive] = await Promise.all([
            prisma.asset_master.count(),
            prisma.asset_master.count({ where: { status: 'A' } }),
            prisma.asset_master.count({ where: { status: 'C' } }),
            prisma.asset_master.count({ where: { status: 'I' } })
         ]);

         return {
            total,
            active,
            created,
            inactive
         };
      } catch (error) {
         throw new Error(`Error fetching asset statistics: ${error.message}`);
      }
   }

   async getAssetStatsByPlant() {
      try {
         const stats = await prisma.mst_plant.findMany({
            select: {
               plant_code: true,
               description: true,
               asset_master: {
                  where: {
                     status: { in: ['A', 'C'] }
                  }
               }
            }
         });

         return stats.map(plant => ({
            plant_code: plant.plant_code,
            plant_description: plant.description,
            asset_count: plant.asset_master.length
         }));
      } catch (error) {
         throw new Error(`Error fetching asset statistics by plant: ${error.message}`);
      }
   }

   async getAssetStatsByLocation() {
      try {
         const stats = await prisma.mst_location.findMany({
            select: {
               location_code: true,
               description: true,
               plant_code: true,
               mst_plant: {
                  select: { description: true }
               },
               asset_master: {
                  where: {
                     status: { in: ['A', 'C'] }
                  }
               }
            }
         });

         return stats.map(location => ({
            location_code: location.location_code,
            location_description: location.description,
            plant_code: location.plant_code,
            plant_description: location.mst_plant?.description,
            asset_count: location.asset_master.length
         }));
      } catch (error) {
         throw new Error(`Error fetching asset statistics by location: ${error.message}`);
      }
   }

   async getAssetNumbers(limit = 5) {
      try {
         const assets = await prisma.asset_master.findMany({
            where: { status: 'A' },
            select: { asset_no: true },
            take: parseInt(limit),
            orderBy: { asset_no: 'asc' }
         });

         return assets.map(asset => asset.asset_no);
      } catch (error) {
         throw new Error(`Error fetching asset numbers: ${error.message}`);
      }
   }

   async createAsset(assetData) {
      try {
         return await this.model.createAsset(assetData);
      } catch (error) {
         throw new Error(`Error creating asset: ${error.message}`);
      }
   }

   async checkAssetExists(assetNo) {
      try {
         const asset = await this.model.getAssetByNo(assetNo);
         return !!asset;
      } catch (error) {
         return false;
      }
   }

   async checkSerialExists(serialNo) {
      try {
         return await this.model.checkSerialExists(serialNo);
      } catch (error) {
         return false;
      }
   }

   async checkInventoryExists(inventoryNo) {
      try {
         return await this.model.checkInventoryExists(inventoryNo);
      } catch (error) {
         return false;
      }
   }

   async checkEpcExists(epcCode) {
      try {
         return await this.model.checkEpcExists(epcCode);
      } catch (error) {
         return false;
      }
   }

   async updateAsset(assetNo, updateData, changedBy = null, remarks = null) {
      try {
         const existingAsset = await this.getAssetByNo(assetNo);

         if (updateData.serial_no && updateData.serial_no !== existingAsset.serial_no) {
            const serialExists = await this.checkSerialExists(updateData.serial_no);
            if (serialExists) {
               throw new Error('Serial number already exists');
            }
         }

         if (updateData.inventory_no && updateData.inventory_no !== existingAsset.inventory_no) {
            const inventoryExists = await this.checkInventoryExists(updateData.inventory_no);
            if (inventoryExists) {
               throw new Error('Inventory number already exists');
            }
         }

         if (updateData.epc_code && updateData.epc_code !== existingAsset.epc_code) {
            const epcExists = await this.checkEpcExists(updateData.epc_code);
            if (epcExists) {
               throw new Error('EPC code already exists');
            }
         }

         return await this.model.updateAsset(assetNo, updateData, changedBy, remarks);
      } catch (error) {
         throw new Error(`Error updating asset: ${error.message}`);
      }
   }

   async updateAssetStatus(assetNo, status, updatedBy, remarks = null) {
      try {
         const validStatuses = ['C', 'A', 'I'];
         if (!validStatuses.includes(status)) {
            throw new Error('Invalid status. Must be C, A, or I');
         }

         const updateData = { status };
         if (status === 'I') {
            updateData.deactivated_at = new Date();
         }

         // Use the model layer which now includes automatic status logging
         return await this.model.updateAssetStatus(
            assetNo, 
            updateData, 
            updatedBy, 
            remarks
         );

      } catch (error) {
         throw new Error(`Error updating asset status: ${error.message}`);
      }
   }

   async getAssetStatusHistory(assetNo) {
      try {
         return await this.model.getAssetStatusHistory(assetNo);
      } catch (error) {
         throw new Error(`Error fetching asset status history: ${error.message}`);
      }
   }

   async logAssetScan(assetNo, scannedBy, locationCode, ipAddress, userAgent) {
      try {
         await prisma.asset_scan_log.create({
            data: {
               asset_no: assetNo,
               scanned_by: scannedBy,
               location_code: locationCode,
               ip_address: ipAddress,
               user_agent: userAgent,
               scanned_at: new Date()
            }
         });

         return { success: true };
      } catch (error) {
         throw new Error(`Error logging asset scan: ${error.message}`);
      }
   }

   async getMockScanAssets(count = 7) {
      try {
         const assets = await prisma.asset_master.findMany({
            where: { status: 'A' },
            include: {
               mst_unit: true,
               mst_user: true
            },
            take: parseInt(count)
         });

         return assets.map(asset => ({
            ...asset,
            unit_name: asset.mst_unit?.name,
            created_by_name: asset.mst_user?.full_name,
            scan_status: Math.random() < 0.1 ? 'Unknown' :
               Math.random() < 0.2 ? 'Checked' : 'Available'
         }));
      } catch (error) {
         throw new Error(`Error getting mock scan assets: ${error.message}`);
      }
   }
}
class CategoryService extends BaseService {
   constructor() {
      super(CategoryModel);
   }

   async getAllCategories() {
      try {
         return await this.model.getAllCategories();
      } catch (error) {
         throw new Error(`Error fetching categories: ${error.message}`);
      }
   }

   async getCategoryByCode(categoryCode) {
      try {
         const category = await this.model.getCategoryByCode(categoryCode);
         if (!category) {
            throw new Error('Category not found');
         }
         return category;
      } catch (error) {
         throw new Error(`Error fetching category: ${error.message}`);
      }
   }
}

class BrandService extends BaseService {
   constructor() {
      super(BrandModel);
   }

   async getAllBrands() {
      try {
         return await this.model.getAllBrands();
      } catch (error) {
         throw new Error(`Error fetching brands: ${error.message}`);
      }
   }

   async getBrandByCode(brandCode) {
      try {
         const brand = await this.model.getBrandByCode(brandCode);
         if (!brand) {
            throw new Error('Brand not found');
         }
         return brand;
      } catch (error) {
         throw new Error(`Error fetching brand: ${error.message}`);
      }
   }
}

module.exports = {
   PlantService,
   LocationService,
   UnitService,
   UserService,
   AssetService,
   DepartmentService,
   CategoryService,
   BrandService
};