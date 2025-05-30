// Path: backend/src/services/service.js
const { PlantModel, LocationModel, UnitModel, UserModel, AssetModel } = require('../models/model');

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

   async getActivePlants() {
      try {
         return await this.model.getActivePlants();
      } catch (error) {
         throw new Error(`Error fetching active plants: ${error.message}`);
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
         const activePlants = await this.model.count({ status: 'A' });
         const inactivePlants = totalPlants - activePlants;

         return {
            total: totalPlants,
            active: activePlants,
            inactive: inactivePlants
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

   async getActiveLocations() {
      try {
         return await this.model.getActiveLocations();
      } catch (error) {
         throw new Error(`Error fetching active locations: ${error.message}`);
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

   async getActiveUnits() {
      try {
         return await this.model.getActiveUnits();
      } catch (error) {
         throw new Error(`Error fetching active units: ${error.message}`);
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

   async getActiveUsers() {
      try {
         return await this.model.getActiveUsers();
      } catch (error) {
         throw new Error(`Error fetching active users: ${error.message}`);
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
         const totalAssets = await this.model.count();
         const activeAssets = await this.model.count({ status: 'A' });
         const createdAssets = await this.model.count({ status: 'C' });
         const inactiveAssets = totalAssets - activeAssets - createdAssets;

         return {
            total: totalAssets,
            active: activeAssets,
            created: createdAssets,
            inactive: inactiveAssets
         };
      } catch (error) {
         throw new Error(`Error fetching asset statistics: ${error.message}`);
      }
   }

   async getAssetStatsByPlant() {
      try {
         const query = `
                SELECT 
                    p.plant_code,
                    p.description as plant_description,
                    COUNT(a.asset_no) as asset_count
                FROM mst_plant p
                LEFT JOIN asset_master a ON p.plant_code = a.plant_code AND a.status IN ('A', 'C')
                WHERE p.status = 'A'
                GROUP BY p.plant_code, p.description
                ORDER BY p.plant_code
            `;
         return await this.model.executeQuery(query);
      } catch (error) {
         throw new Error(`Error fetching asset statistics by plant: ${error.message}`);
      }
   }

   async getAssetStatsByLocation() {
      try {
         const query = `
                SELECT 
                    l.location_code,
                    l.description as location_description,
                    l.plant_code,
                    p.description as plant_description,
                    COUNT(a.asset_no) as asset_count
                FROM mst_location l
                LEFT JOIN mst_plant p ON l.plant_code = p.plant_code
                LEFT JOIN asset_master a ON l.location_code = a.location_code AND a.status IN ('A', 'C')
                WHERE l.status = 'A'
                GROUP BY l.location_code, l.description, l.plant_code, p.description
                ORDER BY l.location_code
            `;
         return await this.model.executeQuery(query);
      } catch (error) {
         throw new Error(`Error fetching asset statistics by location: ${error.message}`);
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

   async updateAsset(assetNo, updateData) {
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

         return await this.model.updateAsset(assetNo, updateData);
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

         return await this.model.updateAssetStatus(assetNo, updateData);
      } catch (error) {
         throw new Error(`Error updating asset status: ${error.message}`);
      }
   }
}

module.exports = {
   PlantService,
   LocationService,
   UnitService,
   UserService,
   AssetService
};