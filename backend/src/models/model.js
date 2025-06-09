// Path: backend/src/models/model.js
const mysql = require('mysql2/promise');

// Database connection configuration
const dbConfig = {
   host: process.env.DB_HOST || 'localhost',
   user: process.env.DB_USER || 'root',
   password: process.env.DB_PASSWORD || '',
   database: process.env.DB_NAME || 'rfidassetdb',
   waitForConnections: true,
   connectionLimit: 10,
   queueLimit: 0,
   acquireTimeout: 60000,
   timeout: 60000
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

class BaseModel {
   constructor(tableName) {
      this.tableName = tableName;
      this.pool = pool;
   }

   async executeQuery(query, params = []) {
      try {
         const [rows] = await this.pool.execute(query, params);
         return rows;
      } catch (error) {
         console.error(`Database query error: ${error.message}`);
         throw error;
      }
   }

   async findAll(conditions = {}, orderBy = null, limit = null) {
      let query = `SELECT * FROM ${this.tableName}`;
      const params = [];

      // Add WHERE conditions
      if (Object.keys(conditions).length > 0) {
         const whereClause = Object.keys(conditions)
            .map(key => `${key} = ?`)
            .join(' AND ');
         query += ` WHERE ${whereClause}`;
         params.push(...Object.values(conditions));
      }

      // Add ORDER BY
      if (orderBy) {
         query += ` ORDER BY ${orderBy}`;
      }

      // Add LIMIT
      if (limit) {
         query += ` LIMIT ${limit}`;
      }

      return this.executeQuery(query, params);
   }

   async findById(id, idField = 'id') {
      const query = `SELECT * FROM ${this.tableName} WHERE ${idField} = ?`;
      const results = await this.executeQuery(query, [id]);
      return results[0] || null;
   }

   async count(conditions = {}) {
      let query = `SELECT COUNT(*) as total FROM ${this.tableName}`;
      const params = [];

      if (Object.keys(conditions).length > 0) {
         const whereClause = Object.keys(conditions)
            .map(key => `${key} = ?`)
            .join(' AND ');
         query += ` WHERE ${whereClause}`;
         params.push(...Object.values(conditions));
      }

      const result = await this.executeQuery(query, params);
      return result[0].total;
   }
}

// Plant Model - No status field
class PlantModel extends BaseModel {
   constructor() {
      super('mst_plant');
   }

   async getAllPlants() {
      return this.findAll({}, 'plant_code');
   }

   async getPlantByCode(plantCode) {
      return this.findById(plantCode, 'plant_code');
   }
}

// Location Model - No status field
class LocationModel extends BaseModel {
   constructor() {
      super('mst_location');
   }

   async getAllLocations() {
      return this.findAll({}, 'location_code');
   }

   async getLocationsByPlant(plantCode) {
      return this.findAll({ plant_code: plantCode }, 'location_code');
   }

   async getLocationByCode(locationCode) {
      return this.findById(locationCode, 'location_code');
   }

   async getLocationsWithPlant() {
      const query = `
            SELECT l.*, p.description as plant_description 
            FROM mst_location l
            LEFT JOIN mst_plant p ON l.plant_code = p.plant_code
            ORDER BY l.location_code
        `;
      return this.executeQuery(query);
   }
}

// Unit Model - No status field
class UnitModel extends BaseModel {
   constructor() {
      super('mst_unit');
   }

   async getAllUnits() {
      return this.findAll({}, 'unit_code');
   }

   async getUnitByCode(unitCode) {
      return this.findById(unitCode, 'unit_code');
   }
}

// User Model - No status field
class UserModel extends BaseModel {
   constructor() {
      super('mst_user');
   }

   async getAllUsers() {
      return this.findAll({}, 'user_id');
   }

   async getUserById(userId) {
      return this.findById(userId, 'user_id');
   }

   async getUserByUsername(username) {
      const results = await this.findAll({ username: username });
      return results[0] || null;
   }
}

// Asset Model - Has status field
class AssetModel extends BaseModel {
   constructor() {
      super('asset_master');
   }

   async getActiveAssets() {
      return this.findAll({ status: 'A' }, 'asset_no');
   }

   async getAssetByNo(assetNo) {
      return this.findById(assetNo, 'asset_no');
   }

   async getAssetsByPlant(plantCode) {
      return this.findAll({ plant_code: plantCode, status: 'A' }, 'asset_no');
   }

   async getAssetsByLocation(locationCode) {
      return this.findAll({ location_code: locationCode, status: 'A' }, 'asset_no');
   }

   async getAssetsWithDetails() {
      const query = `
            SELECT 
                a.*,
                p.description as plant_description,
                l.description as location_description,
                u.name as unit_name,
                usr.full_name as created_by_name
            FROM asset_master a
            LEFT JOIN mst_plant p ON a.plant_code = p.plant_code
            LEFT JOIN mst_location l ON a.location_code = l.location_code
            LEFT JOIN mst_unit u ON a.unit_code = u.unit_code
            LEFT JOIN mst_user usr ON a.created_by = usr.user_id
            WHERE a.status = 'A'
            ORDER BY a.asset_no
        `;
      return this.executeQuery(query);
   }

   async getAssetWithDetails(assetNo) {
      const query = `
      SELECT 
         a.*,
         p.description as plant_description,
         l.description as location_description,
         u.name as unit_name,
         usr.full_name as created_by_name
      FROM asset_master a
      LEFT JOIN mst_plant p ON a.plant_code = p.plant_code
      LEFT JOIN mst_location l ON a.location_code = l.location_code
      LEFT JOIN mst_unit u ON a.unit_code = u.unit_code
      LEFT JOIN mst_user usr ON a.created_by = usr.user_id
      WHERE a.asset_no = ?
   `;
      const results = await this.executeQuery(query, [assetNo]);
      console.log('Asset query result:', results[0]);
      return results[0] || null;
   }

   async searchAssets(searchTerm, filters = {}) {
      let query = `
            SELECT 
                a.*,
                p.description as plant_description,
                l.description as location_description,
                u.name as unit_name,
                usr.full_name as created_by_name
            FROM asset_master a
            LEFT JOIN mst_plant p ON a.plant_code = p.plant_code
            LEFT JOIN mst_location l ON a.location_code = l.location_code
            LEFT JOIN mst_unit u ON a.unit_code = u.unit_code
            LEFT JOIN mst_user usr ON a.created_by = usr.user_id
            WHERE a.status = 'A'
        `;
      const params = [];

      // Add search term
      if (searchTerm) {
         query += ` AND (a.asset_no LIKE ? OR a.description LIKE ? OR a.serial_no LIKE ? OR a.inventory_no LIKE ?)`;
         const searchPattern = `%${searchTerm}%`;
         params.push(searchPattern, searchPattern, searchPattern, searchPattern);
      }

      // Add filters
      if (filters.plant_code) {
         query += ` AND a.plant_code = ?`;
         params.push(filters.plant_code);
      }

      if (filters.location_code) {
         query += ` AND a.location_code = ?`;
         params.push(filters.location_code);
      }

      if (filters.unit_code) {
         query += ` AND a.unit_code = ?`;
         params.push(filters.unit_code);
      }

      // Allow status filter override
      if (filters.status) {
         query = query.replace("WHERE a.status = 'A'", `WHERE a.status = '${filters.status}'`);
      }

      query += ` ORDER BY a.asset_no`;

      return this.executeQuery(query, params);
   }

   // Asset creation and update methods
   async createAsset(assetData) {
      const query = `
         INSERT INTO asset_master (
            asset_no, description, plant_code, location_code,
            serial_no, inventory_no, quantity, unit_code,
            status, created_by, created_at
         ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `;
      const params = [
         assetData.asset_no,
         assetData.description,
         assetData.plant_code,
         assetData.location_code,
         assetData.serial_no,
         assetData.inventory_no,
         assetData.quantity,
         assetData.unit_code,
         assetData.status,
         assetData.created_by,
         assetData.created_at
      ];

      await this.executeQuery(query, params);
      return this.getAssetWithDetails(assetData.asset_no);
   }

   async checkSerialExists(serialNo) {
      const query = `SELECT asset_no FROM asset_master WHERE serial_no = ?`;
      const result = await this.executeQuery(query, [serialNo]);
      return result.length > 0;
   }

   async checkInventoryExists(inventoryNo) {
      const query = `SELECT asset_no FROM asset_master WHERE inventory_no = ?`;
      const result = await this.executeQuery(query, [inventoryNo]);
      return result.length > 0;
   }

   async updateAsset(assetNo, updateData) {
      const setClause = Object.keys(updateData)
         .map(key => `${key} = ?`)
         .join(', ');

      const query = `UPDATE asset_master SET ${setClause} WHERE asset_no = ?`;
      const params = [...Object.values(updateData), assetNo];

      await this.executeQuery(query, params);
      return this.getAssetWithDetails(assetNo);
   }

   async updateAssetStatus(assetNo, updateData) {
      const setClause = Object.keys(updateData)
         .map(key => `${key} = ?`)
         .join(', ');

      const query = `UPDATE asset_master SET ${setClause} WHERE asset_no = ?`;
      const params = [...Object.values(updateData), assetNo];

      await this.executeQuery(query, params);
      return this.getAssetWithDetails(assetNo);
   }

   async getAssetStatusHistory(assetNo) {
      const query = `
         SELECT 
            h.*,
            u.full_name as changed_by_name
         FROM asset_status_history h
         LEFT JOIN mst_user u ON h.changed_by = u.user_id
         WHERE h.asset_no = ?
         ORDER BY h.changed_at DESC
      `;
      return this.executeQuery(query, [assetNo]);
   }
}

module.exports = {
   PlantModel,
   LocationModel,
   UnitModel,
   UserModel,
   AssetModel,
   BaseModel
};