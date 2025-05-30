// Path: backend/src/controllers/controller.js
const { PlantService, LocationService, UnitService, UserService, AssetService } = require('../services/service');

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

// Dashboard Controller
const dashboardController = {
   async getDashboardStats(req, res) {
      try {
         const [plantStats, assetStats, locationStats, userStats] = await Promise.all([
            plantService.getPlantStats(),
            assetService.getAssetStats(),
            locationService.count({ status: 'A' }),
            userService.count({ status: 'A' })
         ]);

         const dashboardData = {
            plants: plantStats,
            assets: assetStats,
            locations: { active: locationStats },
            users: { active: userStats }
         };

         return sendResponse(res, 200, true, 'Dashboard statistics retrieved successfully', dashboardData);
      } catch (error) {
         console.error('Dashboard stats error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getOverview(req, res) {
      try {
         const [
            assetsByPlant,
            assetsByLocation,
            recentAssets
         ] = await Promise.all([
            assetService.getAssetStatsByPlant(),
            assetService.getAssetStatsByLocation(),
            assetService.getAssetsWithDetails()
         ]);

         // Get top 5 most recent assets
         const recent = recentAssets
            .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
            .slice(0, 5);

         const overviewData = {
            assetsByPlant,
            assetsByLocation,
            recentAssets: recent
         };

         return sendResponse(res, 200, true, 'System overview retrieved successfully', overviewData);
      } catch (error) {
         console.error('Dashboard overview error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   }
};

// Plant Controller
const plantController = {
   async getPlants(req, res) {
      try {
         const { page = 1, limit = 50, status } = req.query;
         const filters = {};

         if (status) {
            filters.status = status;
         } else {
            filters.status = 'A'; // Default to active only
         }

         const plants = await plantService.getAll(filters);
         const totalCount = await plantService.count(filters);

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
         const { page = 1, limit = 50, status, plant_code } = req.query;

         let locations;
         let totalCount;

         if (plant_code) {
            locations = await locationService.getLocationsByPlant(plant_code);
            totalCount = locations.length;
         } else {
            locations = await locationService.getLocationsWithPlant();
            totalCount = locations.length;

            if (status && status !== 'A') {
               const filters = { status };
               locations = await locationService.getAll(filters);
               totalCount = await locationService.count(filters);
            }
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
         const { page = 1, limit = 50, status } = req.query;
         const filters = {};

         if (status) {
            filters.status = status;
         } else {
            filters.status = 'A'; // Default to active only
         }

         const units = await unitService.getAll(filters);
         const totalCount = await unitService.count(filters);

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

// User Controller
const userController = {
   async getUsers(req, res) {
      try {
         const { page = 1, limit = 50, status } = req.query;
         const filters = {};

         if (status) {
            filters.status = status;
         } else {
            filters.status = 'A'; // Default to active only
         }

         const users = await userService.getAll(filters);
         const totalCount = await userService.count(filters);

         // Remove sensitive information
         const sanitizedUsers = users.map(user => {
            const { password, ...safeUser } = user;
            return safeUser;
         });

         const paginatedUsers = applyPagination(sanitizedUsers, parseInt(page), parseInt(limit));
         const meta = getPaginationMeta(parseInt(page), parseInt(limit), totalCount);

         return sendResponse(res, 200, true, 'Users retrieved successfully', paginatedUsers, meta);
      } catch (error) {
         console.error('Get users error:', error);
         return sendResponse(res, 500, false, error.message);
      }
   },

   async getUserById(req, res) {
      try {
         const { user_id } = req.params;
         const user = await userService.getUserById(user_id);

         // Remove sensitive information
         const { password, ...safeUser } = user;

         return sendResponse(res, 200, true, 'User retrieved successfully', safeUser);
      } catch (error) {
         console.error('Get user by id error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   },

   async getUserByUsername(req, res) {
      try {
         const { username } = req.params;
         const user = await userService.getUserByUsername(username);

         // Remove sensitive information
         const { password, ...safeUser } = user;

         return sendResponse(res, 200, true, 'User retrieved successfully', safeUser);
      } catch (error) {
         console.error('Get user by username error:', error);
         const statusCode = error.message.includes('not found') ? 404 : 500;
         return sendResponse(res, statusCode, false, error.message);
      }
   }
};

// Asset Controller
const assetController = {
   async getAssets(req, res) {
      try {
         const { page = 1, limit = 50, status, plant_code, location_code, unit_code } = req.query;

         let assets;
         let totalCount;

         // If specific filters are provided, use filtered search
         if (plant_code || location_code || unit_code) {
            const filters = {};
            if (plant_code) filters.plant_code = plant_code;
            if (location_code) filters.location_code = location_code;
            if (unit_code) filters.unit_code = unit_code;
            if (status) filters.status = status;
            else filters.status = 'A';

            assets = await assetService.searchAssets('', filters);
            totalCount = assets.length;
         } else {
            // Get all assets with details
            assets = await assetService.getAssetsWithDetails();
            totalCount = assets.length;

            if (status && status !== 'A') {
               const filters = { status };
               assets = await assetService.getAll(filters);
               totalCount = await assetService.count(filters);
            }
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
         const { search, page = 1, limit = 50, plant_code, location_code, unit_code } = req.query;

         const filters = {};
         if (plant_code) filters.plant_code = plant_code;
         if (location_code) filters.location_code = location_code;
         if (unit_code) filters.unit_code = unit_code;

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
   }
};

module.exports = {
   plantController,
   locationController,
   unitController,
   userController,
   assetController,
   dashboardController
};