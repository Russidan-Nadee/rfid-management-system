// Path: backend/src/features/scan/scanController.js
const { PlantService, LocationService, UnitService, UserService, AssetService, DepartmentService } = require('./scanService');

const departmentService = new DepartmentService();

// Initialize services
const plantService = new PlantService();
const locationService = new LocationService();
const unitService = new UnitService();
const userService = new UserService();
const assetService = new AssetService();

// Response helper function
const sendResponse = (res, statusCode, success, message, data = null, meta = null) => {
   const response = {
      success,
      message,
      timestamp: new Date().toISOString()
   };

   if (data !== null) {
      response.data = data;
   }

   if (meta !== null) {
      response.meta = meta;
   }

   return res.status(statusCode).json(response);
};

// Pagination helper function
const getPaginationMeta = (page, limit, totalItems) => {
   const totalPages = Math.ceil(totalItems / limit);
   return {
      pagination: {
         currentPage: page,
         totalPages,
         totalItems,
         itemsPerPage: limit,
         hasNextPage: page < totalPages,
         hasPrevPage: page > 1
      }
   };
};

// Apply pagination to data
const applyPagination = (data, page = 1, limit = 50) => {
   const offset = (page - 1) * limit;
   return data.slice(offset, offset + limit);
};

// Department Controller
const departmentController = {
   async getDepartments(req, res) {
      try {
         const { page = 1, limit = 50, plant_code } = req.query;

         let departments;
         let totalCount;

         if (plant_code) {
            departments = await departmentService.getDepartmentsByPlant(plant_code);
            totalCount = departments.length;
         } else {
            departments = await departmentService.getDepartmentsWithPlant();
            totalCount = departments.length;
         }

         const paginatedDepartments = applyPagination(departments, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), totalCount);

         return sendResponse(res, 200, true, 'Departments retrieved successfully', paginatedDepartments, meta);
      } catch (error) {
         console.error('Get departments error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getDepartmentByCode(req, res) {
      try {
         const { dept_code } = req.params;
         const department = await departmentService.getDepartmentByCode(dept_code);

         return sendResponse(res, 200, true, 'Department retrieved successfully', department);
      } catch (error) {
         console.error('Get department by code error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   }
};

// Plant Controller
const plantController = {
   async getPlants(req, res) {
      try {
         const { page = 1, limit = 50 } = req.query;

         const plants = await plantService.getAllPlants();
         const totalCount = await plantService.count();

         const paginatedPlants = applyPagination(plants, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), totalCount);

         return sendResponse(res, 200, true, 'Plants retrieved successfully', paginatedPlants, meta);
      } catch (error) {
         console.error('Get plants error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getPlantByCode(req, res) {
      try {
         const { plant_code } = req.params;
         const plant = await plantService.getPlantByCode(plant_code);

         return sendResponse(res, 200, true, 'Plant retrieved successfully', plant);
      } catch (error) {
         console.error('Get plant by code error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   },

   async getPlantStats(req, res) {
      try {
         const stats = await plantService.getPlantStats();
         return sendResponse(res, 200, true, 'Plant statistics retrieved successfully', stats);
      } catch (error) {
         console.error('Get plant stats error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   }
};

// Location Controller
const locationController = {
   async getLocations(req, res) {
      try {
         const { page = 1, limit = 50, plant_code } = req.query;

         let locations;
         let totalCount;

         if (plant_code) {
            locations = await locationService.getLocationsByPlant(plant_code);
            totalCount = locations.length;
         } else {
            locations = await locationService.getLocationsWithPlant();
            totalCount = locations.length;
         }

         const paginatedLocations = applyPagination(locations, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), totalCount);

         return sendResponse(res, 200, true, 'Locations retrieved successfully', paginatedLocations, meta);
      } catch (error) {
         console.error('Get locations error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getLocationByCode(req, res) {
      try {
         const { location_code } = req.params;
         const location = await locationService.getLocationByCode(location_code);

         return sendResponse(res, 200, true, 'Location retrieved successfully', location);
      } catch (error) {
         console.error('Get location by code error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   },

   async getLocationsByPlant(req, res) {
      try {
         const { plant_code } = req.params;
         const { page = 1, limit = 50 } = req.query;

         const locations = await locationService.getLocationsByPlant(plant_code);
         const paginatedLocations = applyPagination(locations, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), locations.length);

         return sendResponse(res, 200, true, 'Locations by plant retrieved successfully', paginatedLocations, meta);
      } catch (error) {
         console.error('Get locations by plant error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   }
};

// Unit Controller
const unitController = {
   async getUnits(req, res) {
      try {
         const { page = 1, limit = 50 } = req.query;

         const units = await unitService.getAllUnits();
         const totalCount = await unitService.count();

         const paginatedUnits = applyPagination(units, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), totalCount);

         return sendResponse(res, 200, true, 'Units retrieved successfully', paginatedUnits, meta);
      } catch (error) {
         console.error('Get units error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getUnitByCode(req, res) {
      try {
         const { unit_code } = req.params;
         const unit = await unitService.getUnitByCode(unit_code);

         return sendResponse(res, 200, true, 'Unit retrieved successfully', unit);
      } catch (error) {
         console.error('Get unit by code error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   }
};

const assetController = {
   async getAssets(req, res) {
      try {
         const { page = 1, limit = 50, status, plant_code, location_code, unit_code } = req.query;

         let assets;
         let totalCount;

         // If specific filters are provided, use filtered search
         if (plant_code || location_code || unit_code || status) {
            const filters = {};
            if (plant_code) filters.plant_code = plant_code;
            if (location_code) filters.location_code = location_code;
            if (unit_code) filters.unit_code = unit_code;
            if (status) filters.status = status;

            assets = await assetService.searchAssets('', filters);
            totalCount = assets.length;
         } else {
            // Get all assets with details (default to active assets)
            assets = await assetService.getAssetsWithDetails();
            totalCount = assets.length;
         }

         const paginatedAssets = applyPagination(assets, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), totalCount);

         return sendResponse(res, 200, true, 'Assets retrieved successfully', paginatedAssets, meta);
      } catch (error) {
         console.error('Get assets error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getAssetByNo(req, res) {
      try {
         const { asset_no } = req.params;
         const asset = await assetService.getAssetWithDetails(asset_no);

         return sendResponse(res, 200, true, 'Asset retrieved successfully', asset);
      } catch (error) {
         console.error('Get asset by number error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   },

   async searchAssets(req, res) {
      try {
         const { search, page = 1, limit = 50, plant_code, location_code, unit_code, status } = req.query;

         const filters = {};
         if (plant_code) filters.plant_code = plant_code;
         if (location_code) filters.location_code = location_code;
         if (unit_code) filters.unit_code = unit_code;
         if (status) filters.status = status;

         const assets = await assetService.searchAssets(search, filters);
         const paginatedAssets = applyPagination(assets, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), assets.length);

         return sendResponse(res, 200, true, 'Asset search completed successfully', paginatedAssets, meta);
      } catch (error) {
         console.error('Search assets error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getAssetsByPlant(req, res) {
      try {
         const { plant_code } = req.params;
         const { page = 1, limit = 50 } = req.query;

         const assets = await assetService.getAssetsByPlant(plant_code);
         const paginatedAssets = applyPagination(assets, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), assets.length);

         return sendResponse(res, 200, true, 'Assets by plant retrieved successfully', paginatedAssets, meta);
      } catch (error) {
         console.error('Get assets by plant error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getAssetsByLocation(req, res) {
      try {
         const { location_code } = req.params;
         const { page = 1, limit = 50 } = req.query;

         const assets = await assetService.getAssetsByLocation(location_code);
         const paginatedAssets = applyPagination(assets, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), assets.length);

         return sendResponse(res, 200, true, 'Assets by location retrieved successfully', paginatedAssets, meta);
      } catch (error) {
         console.error('Get assets by location error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getAssetStats(req, res) {
      try {
         const stats = await assetService.getAssetStats();
         return sendResponse(res, 200, true, 'Asset statistics retrieved successfully', stats);
      } catch (error) {
         console.error('Get asset stats error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getAssetStatsByPlant(req, res) {
      try {
         const stats = await assetService.getAssetStatsByPlant();
         return sendResponse(res, 200, true, 'Asset statistics by plant retrieved successfully', stats);
      } catch (error) {
         console.error('Get asset stats by plant error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getAssetStatsByLocation(req, res) {
      try {
         const stats = await assetService.getAssetStatsByLocation();
         return sendResponse(res, 200, true, 'Asset statistics by location retrieved successfully', stats);
      } catch (error) {
         console.error('Get asset stats by location error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getAssetNumbers(req, res) {
      try {
         const { limit = 50 } = req.query;
         const assets = await assetService.getAssetNumbers(parseInt(limit));
         return sendResponse(res, 200, true, 'Asset numbers retrieved successfully', {
            asset_numbers: assets
         });
      } catch (error) {
         console.error('Get asset numbers error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async createAsset(req, res) {
      try {
         const {
            asset_no,
            description,
            plant_code,
            location_code,
            dept_code,
            serial_no,
            inventory_no,
            quantity = 1,
            unit_code,
            created_by
         } = req.body;

         // Check if asset_no already exists
         const existingAsset = await assetService.checkAssetExists(asset_no);
         if (existingAsset) {
            return sendResponse(res, 409, false, 'Asset number already exists');
         }

         // Check if serial_no is unique (if provided)
         if (serial_no) {
            const existingSerial = await assetService.checkSerialExists(serial_no);
            if (existingSerial) {
               return sendResponse(res, 409, false, 'Serial number already exists');
            }
         }

         // Check if inventory_no is unique (if provided)
         if (inventory_no) {
            const existingInventory = await assetService.checkInventoryExists(inventory_no);
            if (existingInventory) {
               return sendResponse(res, 409, false, 'Inventory number already exists');
            }
         }

         // Validate foreign keys exist
         await Promise.all([
            plantService.getPlantByCode(plant_code),
            locationService.getLocationByCode(location_code),
            unitService.getUnitByCode(unit_code),
            userService.getUserById(created_by)
         ]);

         // Create new asset
         const newAsset = await assetService.createAsset({
            asset_no,
            description,
            plant_code,
            location_code,
            dept_code,
            serial_no,
            inventory_no,
            quantity,
            unit_code,
            status: 'C',
            created_by,
            created_at: new Date()
         });

         return sendResponse(res, 201, true, 'Asset created successfully', newAsset);
      } catch (error) {
         console.error('Create asset error:', error);
         const statusCode = error.message.includes('not found') ? 400 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   },

   async updateAsset(req, res) {
      try {
         const { asset_no } = req.params;
         const updateData = req.body;

         // Remove fields that shouldn't be updated
         delete updateData.asset_no;
         delete updateData.created_by;
         delete updateData.created_at;

         // Validate foreign keys if provided
         const validations = [];
         if (updateData.plant_code) {
            validations.push(plantService.getPlantByCode(updateData.plant_code));
         }
         if (updateData.location_code) {
            validations.push(locationService.getLocationByCode(updateData.location_code));
         }
         if (updateData.unit_code) {
            validations.push(unitService.getUnitByCode(updateData.unit_code));
         }

         await Promise.all(validations);

         // Update asset
         const updatedAsset = await assetService.updateAsset(asset_no, updateData);

         return sendResponse(res, 200, true, 'Asset updated successfully', updatedAsset);
      } catch (error) {
         console.error('Update asset error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   },

   async updateAssetStatus(req, res) {
      try {
         const { asset_no } = req.params;
         const { status, updated_by, remarks } = req.body;

         const updatedAsset = await assetService.updateAssetStatus(asset_no, status, updated_by, remarks);

         return sendResponse(res, 200, true, 'Asset status updated successfully', updatedAsset);
      } catch (error) {
         console.error('Update asset status error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   },

   async getAssetStatusHistory(req, res) {
      try {
         const { asset_no } = req.params;
         const { page = 1, limit = 50 } = req.query;

         // Verify asset exists
         await assetService.getAssetByNo(asset_no);

         const history = await assetService.getAssetStatusHistory(asset_no);
         const paginatedHistory = applyPagination(history, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), history.length);

         return sendResponse(res, 200, true, 'Asset status history retrieved successfully', paginatedHistory, meta);
      } catch (error) {
         console.error('Get asset status history error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   }
};

const scanController = {
   async logAssetScan(req, res) {
      try {
         const { asset_no } = req.body;
         const { userId } = req.user;
         const ipAddress = req.ip || req.connection.remoteAddress;
         const userAgent = req.get('User-Agent');

         const asset = await assetService.getAssetByNo(asset_no);
         const scanResult = await assetService.logAssetScan(
            asset_no, userId, asset.location_code, ipAddress, userAgent
         );

         return sendResponse(res, 201, true, 'Asset scan logged successfully', scanResult);
      } catch (error) {
         console.error('Log asset scan error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   },

   async mockRfidScan(req, res) {
      try {
         const { count = 7 } = req.body;
         const mockAssets = await assetService.getMockScanAssets(count);

         return sendResponse(res, 200, true, 'Mock RFID scan completed', {
            scanned_items: mockAssets,
            count: mockAssets.length
         });
      } catch (error) {
         console.error('Mock RFID scan error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   }
};

module.exports = {
   plantController,
   locationController,
   unitController,
   assetController,
   scanController,
   departmentController
};