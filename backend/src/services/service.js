// Path: backend/src/services/service.js
const { PlantModel, LocationModel, UnitModel, UserModel, AssetModel } = require('../models/model');
const DepartmentService = require('./departmentService');

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
         const inactiveAssets = await this.model.count({ status: 'I' });

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
                GROUP BY l.location_code, l.description, l.plant_code, p.description
                ORDER BY l.location_code
            `;
         return await this.model.executeQuery(query);
      } catch (error) {
         throw new Error(`Error fetching asset statistics by location: ${error.message}`);
      }
   }

   async getAssetNumbers(limit = 5) {
      try {
         const query = `
         SELECT asset_no 
         FROM asset_master 
         WHERE status = 'A' 
         ORDER BY RAND()
         LIMIT ${parseInt(limit)}
      `;
         const result = await this.model.executeQuery(query);
         return result.map(row => row.asset_no);
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

         // Get current asset
         const currentAsset = await this.getAssetByNo(assetNo);
         const oldStatus = currentAsset.status;

         const updateData = { status };

         if (status === 'I') {
            updateData.deactivated_at = new Date();
         }

         // Begin transaction
         const connection = await this.model.pool.getConnection();

         try {
            await connection.beginTransaction();

            // Update asset status
            const updateQuery = `
            UPDATE asset_master 
            SET ${Object.keys(updateData).map(key => `${key} = ?`).join(', ')}
            WHERE asset_no = ?
         `;
            const updateParams = [...Object.values(updateData), assetNo];
            await connection.execute(updateQuery, updateParams);

            // Insert status history
            const historyQuery = `
            INSERT INTO asset_status_history (
               asset_no, old_status, new_status, 
               changed_at, changed_by, remarks
            ) VALUES (?, ?, ?, NOW(), ?, ?)
         `;
            await connection.execute(historyQuery, [
               assetNo, oldStatus, status, updatedBy, remarks
            ]);

            await connection.commit();
            return await this.getAssetWithDetails(assetNo);

         } catch (error) {
            await connection.rollback();
            throw error;
         } finally {
            connection.release();
         }

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
         const query = `
            INSERT INTO asset_scan_log (
               asset_no, scanned_by, location_code, 
               ip_address, user_agent, scanned_at
            ) VALUES (?, ?, ?, ?, ?, NOW())
         `;

         await this.model.executeQuery(query, [assetNo, scannedBy, locationCode, ipAddress, userAgent]);
         return { success: true };
      } catch (error) {
         throw new Error(`Error logging asset scan: ${error.message}`);
      }
   }

   async getMockScanAssets(count = 7) {
      try {
         const query = `
            SELECT 
               a.asset_no,
               a.description,
               a.serial_no,
               a.inventory_no,
               a.quantity,
               u.name as unit_name,
               usr.full_name as created_by_name,
               a.created_at,
               a.status,
               CASE 
                  WHEN RAND() < 0.1 THEN 'Unknown'
                  WHEN RAND() < 0.2 THEN 'Checked'
                  ELSE 'Available'
               END as scan_status
            FROM asset_master a
            LEFT JOIN mst_unit u ON a.unit_code = u.unit_code
            LEFT JOIN mst_user usr ON a.created_by = usr.user_id
            WHERE a.status = 'A'
            ORDER BY RAND()
            LIMIT ?
         `;

         return await this.model.executeQuery(query, [count]);
      } catch (error) {
         throw new Error(`Error getting mock scan assets: ${error.message}`);
      }
   }
}

module.exports = {
   PlantService,
   LocationService,
   UnitService,
   UserService,
   AssetService,
   DepartmentService
};