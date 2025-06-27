// Path: backend/src/models/searchModel.js
const prisma = require('../lib/prisma');
const SearchUtils = require('../utils/searchUtils');

/**
 * 🔍 SEARCH MODEL
 * จัดการ database queries สำหรับ search functionality
 * - Optimized สำหรับความเร็ว
 * - Support หลาย entity types
 * - ใช้ Prisma แทน raw SQL
 */
class SearchModel {
   constructor() {
      // ไม่ระบุ table เพราะจะค้นหาหลาย tables
   }

   /**
    * ⚡ INSTANT SEARCH METHODS
    * สำหรับ real-time search - เน้นความเร็ว
    */

   /**
 * ค้นหา assets แบบละเอียด พร้อม nested description search
 * @param {string} query - คำค้นหา
 * @param {Object} options - ตัวเลือก
 * @returns {Promise<Object>} ผลลัพธ์พร้อม pagination และข้อมูลครบถ้วน
 */
   async comprehensiveSearchAssets(query, options = {}) {
      const {
         page = 1,
         limit = 20,
         sort = 'relevance',
         filters = {},
         exactMatch = false,
         includeDetails = true
      } = options;

      const offset = (page - 1) * limit;
      const actualLimit = Math.min(limit, 100);

      try {
         // Build enhanced search conditions
         const searchConditions = {
            AND: [
               {
                  status: { in: ['A', 'C'] }
               }
            ]
         };

         // Add search query conditions
         if (query) {
            if (exactMatch) {
               searchConditions.AND.push({
                  OR: [
                     { asset_no: query },
                     { description: query },
                     { serial_no: query },
                     { inventory_no: query },
                     { mst_plant: { description: query } },
                     { mst_location: { description: query } },
                     { mst_department: { description: query } },
                     { mst_unit: { name: query } },
                     { mst_user: { full_name: query } }
                  ]
               });
            } else {
               searchConditions.AND.push({
                  OR: [
                     // Original asset fields
                     { asset_no: { contains: query } },
                     { description: { contains: query } },
                     { serial_no: { contains: query } },
                     { inventory_no: { contains: query } },

                     // Nested relation searches
                     { mst_plant: { description: { contains: query } } },
                     { mst_location: { description: { contains: query } } },
                     { mst_department: { description: { contains: query } } },
                     { mst_unit: { name: { contains: query } } },
                     { mst_user: { full_name: { contains: query } } }
                  ]
               });
            }
         }

         // Add filters
         if (filters.plant_codes && filters.plant_codes.length > 0) {
            searchConditions.AND.push({ plant_code: { in: filters.plant_codes } });
         }
         if (filters.location_codes && filters.location_codes.length > 0) {
            searchConditions.AND.push({ location_code: { in: filters.location_codes } });
         }
         if (filters.dept_codes && filters.dept_codes.length > 0) {
            searchConditions.AND.push({ dept_code: { in: filters.dept_codes } });
         }
         if (filters.status && filters.status.length > 0) {
            searchConditions.AND.push({ status: { in: filters.status } });
         }

         // Build orderBy
         let orderBy = [{ asset_no: 'asc' }];
         switch (sort) {
            case 'created_date':
               orderBy = [{ created_at: 'desc' }];
               break;
            case 'alphabetical':
               orderBy = [{ description: 'asc' }, { asset_no: 'asc' }];
               break;
            case 'recent':
               orderBy = [{ created_at: 'desc' }];
               break;
         }

         // Enhanced include - เหมือนกับ instantSearchAssets
         const includeOptions = {
            mst_plant: {
               select: {
                  plant_code: true,
                  description: true
               }
            },
            mst_location: {
               select: {
                  location_code: true,
                  description: true
               }
            },
            mst_department: {
               select: {
                  dept_code: true,
                  description: true
               }
            },
            mst_unit: {
               select: {
                  unit_code: true,
                  name: true
               }
            },
            mst_user: {
               select: {
                  user_id: true,
                  full_name: true,
                  role: true
               }
            }
         };

         const [results, total] = await Promise.all([
            prisma.asset_master.findMany({
               where: searchConditions,
               include: includeOptions,
               orderBy,
               skip: offset,
               take: actualLimit
            }),
            prisma.asset_master.count({
               where: searchConditions
            })
         ]);

         const totalPages = Math.ceil(total / actualLimit);

         return {
            data: results.map(asset => ({
               // Basic asset fields
               asset_no: asset.asset_no,
               description: asset.description,
               plant_code: asset.plant_code,
               location_code: asset.location_code,
               dept_code: asset.dept_code,
               serial_no: asset.serial_no,
               inventory_no: asset.inventory_no,
               quantity: asset.quantity,
               unit_code: asset.unit_code,
               status: asset.status,
               created_by: asset.created_by,
               created_at: asset.created_at,
               deactivated_at: asset.deactivated_at,

               // Enhanced relation fields - flattened
               plant_description: asset.mst_plant?.description || null,
               location_description: asset.mst_location?.description || null,
               dept_description: asset.mst_department?.description || null,
               unit_name: asset.mst_unit?.name || null,
               created_by_name: asset.mst_user?.full_name || null,
               created_by_role: asset.mst_user?.role || null,

               // Entity type for compatibility
               entity_type: 'asset'
            })) || [],
            pagination: {
               page,
               limit: actualLimit,
               total,
               totalPages,
               hasNext: page < totalPages,
               hasPrev: page > 1
            }
         };
      } catch (error) {
         console.error('Enhanced comprehensive search assets with nested search error:', error);
         return {
            data: [],
            pagination: { page, limit: actualLimit, total: 0, totalPages: 0 }
         };
      }
   }

   /**
 * ค้นหา assets แบบ instant พร้อม nested description search
 * @param {string} query - คำค้นหา
 * @param {Object} options - ตัวเลือก
 * @returns {Promise<Array>} ผลลัพธ์ assets พร้อมข้อมูลครบถ้วน
 */
   async instantSearchAssets(query, options = {}) {
      const { limit = 5, includeDetails = true } = options;
      const actualLimit = Math.min(limit, 10);

      try {
         // Enhanced search conditions - รวม nested fields
         const searchConditions = {
            AND: [
               {
                  OR: [
                     // Original asset fields
                     { asset_no: { contains: query } },
                     { description: { contains: query } },
                     { serial_no: { contains: query } },
                     { inventory_no: { contains: query } },

                     // Nested relation searches
                     { mst_plant: { description: { contains: query } } },
                     { mst_location: { description: { contains: query } } },
                     { mst_department: { description: { contains: query } } },
                     { mst_unit: { name: { contains: query } } },
                     { mst_user: { full_name: { contains: query } } }
                  ]
               },
               {
                  status: { in: ['A', 'C'] }
               }
            ]
         };

         // Enhanced include - ดึงข้อมูล relations ครบถ้วน
         const includeOptions = {
            mst_plant: {
               select: {
                  plant_code: true,
                  description: true
               }
            },
            mst_location: {
               select: {
                  location_code: true,
                  description: true
               }
            },
            mst_department: {
               select: {
                  dept_code: true,
                  description: true
               }
            },
            mst_unit: {
               select: {
                  unit_code: true,
                  name: true
               }
            },
            mst_user: {
               select: {
                  user_id: true,
                  full_name: true,
                  role: true
               }
            }
         };

         const results = await prisma.asset_master.findMany({
            where: searchConditions,
            include: includeOptions,
            take: actualLimit,
            orderBy: [
               { asset_no: 'asc' }
            ]
         });

         // Enhanced mapping - flatten relations และเพิ่ม fields ที่ต้องการ
         return results.map(asset => ({
            // Basic asset fields
            asset_no: asset.asset_no,
            description: asset.description,
            plant_code: asset.plant_code,
            location_code: asset.location_code,
            dept_code: asset.dept_code,
            serial_no: asset.serial_no,
            inventory_no: asset.inventory_no,
            quantity: asset.quantity,
            unit_code: asset.unit_code,
            status: asset.status,
            created_by: asset.created_by,
            created_at: asset.created_at,
            deactivated_at: asset.deactivated_at,

            // Enhanced relation fields - flattened
            plant_description: asset.mst_plant?.description || null,
            location_description: asset.mst_location?.description || null,
            dept_description: asset.mst_department?.description || null,
            unit_name: asset.mst_unit?.name || null,
            created_by_name: asset.mst_user?.full_name || null,
            created_by_role: asset.mst_user?.role || null,

            // Entity type for compatibility
            entity_type: 'asset'
         })) || [];

      } catch (error) {
         console.error('Enhanced instant search assets with nested search error:', error);
         return [];
      }
   }

   /**
 * ค้นหา assets แบบ instant (เร็วที่สุด) - Enhanced Version
 * @param {string} query - คำค้นหา
 * @param {Object} options - ตัวเลือก
 * @returns {Promise<Array>} ผลลัพธ์ assets พร้อมข้อมูลครบถ้วน
 */
   async instantSearchAssets(query, options = {}) {
      const { limit = 5, includeDetails = true } = options; // เปลี่ยน default เป็น true
      const actualLimit = Math.min(limit, 10);

      try {
         const searchConditions = {
            OR: [
               { asset_no: { contains: query } },
               { description: { contains: query } },
               { serial_no: { contains: query } },
               { inventory_no: { contains: query } }
            ],
            status: { in: ['A', 'C'] }
         };

         // Enhanced include - ดึงข้อมูล relations ครบถ้วน
         const includeOptions = {
            mst_plant: {
               select: {
                  plant_code: true,
                  description: true
               }
            },
            mst_location: {
               select: {
                  location_code: true,
                  description: true
               }
            },
            mst_department: {
               select: {
                  dept_code: true,
                  description: true
               }
            },
            mst_unit: {
               select: {
                  unit_code: true,
                  name: true
               }
            },
            mst_user: {
               select: {
                  user_id: true,
                  full_name: true,
                  role: true
               }
            }
         };

         const results = await prisma.asset_master.findMany({
            where: searchConditions,
            include: includeOptions,
            take: actualLimit,
            orderBy: [
               { asset_no: 'asc' }
            ]
         });

         // Enhanced mapping - flatten relations และเพิ่ม fields ที่ต้องการ
         return results.map(asset => ({
            // Basic asset fields
            asset_no: asset.asset_no,
            description: asset.description,
            plant_code: asset.plant_code,
            location_code: asset.location_code,
            dept_code: asset.dept_code,
            serial_no: asset.serial_no,
            inventory_no: asset.inventory_no,
            quantity: asset.quantity,
            unit_code: asset.unit_code,
            status: asset.status,
            created_by: asset.created_by,
            created_at: asset.created_at,
            deactivated_at: asset.deactivated_at,

            // Enhanced relation fields - flattened
            plant_description: asset.mst_plant?.description || null,
            location_description: asset.mst_location?.description || null,
            dept_description: asset.mst_department?.description || null,
            unit_name: asset.mst_unit?.name || null,
            created_by_name: asset.mst_user?.full_name || null,
            created_by_role: asset.mst_user?.role || null,

            // Entity type for compatibility
            entity_type: 'asset'
         })) || [];

      } catch (error) {
         console.error('Enhanced instant search assets error:', error);
         return [];
      }
   }

   /**
    * ค้นหา plants แบบ instant
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} ผลลัพธ์ plants
    */
   async instantSearchPlants(query, options = {}) {
      const { limit = 5 } = options;
      const actualLimit = Math.min(limit, 10);

      try {
         const results = await prisma.mst_plant.findMany({
            where: {
               OR: [
                  { plant_code: { contains: query } },
                  { description: { contains: query } }
               ]
            },
            take: actualLimit,
            orderBy: [
               { plant_code: 'asc' }
            ]
         });

         return results.map(plant => ({
            ...plant,
            entity_type: 'plant'
         })) || [];
      } catch (error) {
         console.error('Instant search plants error:', error);
         return [];
      }
   }

   /**
    * ค้นหา locations แบบ instant
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} ผลลัพธ์ locations
    */
   async instantSearchLocations(query, options = {}) {
      const { limit = 5 } = options;
      const actualLimit = Math.min(limit, 10);

      try {
         const results = await prisma.mst_location.findMany({
            where: {
               OR: [
                  { location_code: { contains: query } },
                  { description: { contains: query } }
               ]
            },
            include: {
               mst_plant: { select: { description: true } }
            },
            take: actualLimit,
            orderBy: [
               { location_code: 'asc' }
            ]
         });

         return results.map(location => ({
            ...location,
            plant_description: location.mst_plant?.description,
            entity_type: 'location'
         })) || [];
      } catch (error) {
         console.error('Instant search locations error:', error);
         return [];
      }
   }

   /**
    * ค้นหา users แบบ instant
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} ผลลัพธ์ users
    */
   async instantSearchUsers(query, options = {}) {
      const { limit = 5 } = options;
      const actualLimit = Math.min(limit, 10);

      try {
         const results = await prisma.mst_user.findMany({
            where: {
               OR: [
                  { username: { contains: query } },
                  { full_name: { contains: query } }
               ]
            },
            select: {
               user_id: true,
               username: true,
               full_name: true,
               role: true
            },
            take: actualLimit,
            orderBy: [
               { username: 'asc' }
            ]
         });

         return results.map(user => ({
            ...user,
            entity_type: 'user'
         })) || [];
      } catch (error) {
         console.error('Instant search users error:', error);
         return [];
      }
   }

   /**
    * 🌐 COMPREHENSIVE SEARCH METHODS
    * สำหรับ detailed search - มีข้อมูลครบถ้วน
    */

   /**
 * ค้นหา assets แบบละเอียด - Enhanced Version
 * @param {string} query - คำค้นหา
 * @param {Object} options - ตัวเลือก
 * @returns {Promise<Object>} ผลลัพธ์พร้อม pagination และข้อมูลครบถ้วน
 */
   async comprehensiveSearchAssets(query, options = {}) {
      const {
         page = 1,
         limit = 20,
         sort = 'relevance',
         filters = {},
         exactMatch = false,
         includeDetails = true // เปลี่ยน default เป็น true
      } = options;

      const offset = (page - 1) * limit;
      const actualLimit = Math.min(limit, 100);

      try {
         // Build search conditions
         const searchConditions = {
            status: { in: ['A', 'C'] }
         };

         if (query) {
            if (exactMatch) {
               searchConditions.OR = [
                  { asset_no: query },
                  { description: query },
                  { serial_no: query },
                  { inventory_no: query }
               ];
            } else {
               searchConditions.OR = [
                  { asset_no: { contains: query } },
                  { description: { contains: query } },
                  { serial_no: { contains: query } },
                  { inventory_no: { contains: query } }
               ];
            }
         }

         // Add filters
         if (filters.plant_codes && filters.plant_codes.length > 0) {
            searchConditions.plant_code = { in: filters.plant_codes };
         }
         if (filters.location_codes && filters.location_codes.length > 0) {
            searchConditions.location_code = { in: filters.location_codes };
         }
         if (filters.dept_codes && filters.dept_codes.length > 0) {
            searchConditions.dept_code = { in: filters.dept_codes };
         }
         if (filters.status && filters.status.length > 0) {
            searchConditions.status = { in: filters.status };
         }

         // Build orderBy
         let orderBy = [{ asset_no: 'asc' }];
         switch (sort) {
            case 'created_date':
               orderBy = [{ created_at: 'desc' }];
               break;
            case 'alphabetical':
               orderBy = [{ description: 'asc' }, { asset_no: 'asc' }];
               break;
            case 'recent':
               orderBy = [{ created_at: 'desc' }];
               break;
         }

         // Enhanced include - เหมือนกับ instantSearchAssets
         const includeOptions = {
            mst_plant: {
               select: {
                  plant_code: true,
                  description: true
               }
            },
            mst_location: {
               select: {
                  location_code: true,
                  description: true
               }
            },
            mst_department: {
               select: {
                  dept_code: true,
                  description: true
               }
            },
            mst_unit: {
               select: {
                  unit_code: true,
                  name: true
               }
            },
            mst_user: {
               select: {
                  user_id: true,
                  full_name: true,
                  role: true
               }
            }
         };

         const [results, total] = await Promise.all([
            prisma.asset_master.findMany({
               where: searchConditions,
               include: includeOptions,
               orderBy,
               skip: offset,
               take: actualLimit
            }),
            prisma.asset_master.count({
               where: searchConditions
            })
         ]);

         const totalPages = Math.ceil(total / actualLimit);

         return {
            data: results.map(asset => ({
               // Basic asset fields
               asset_no: asset.asset_no,
               description: asset.description,
               plant_code: asset.plant_code,
               location_code: asset.location_code,
               dept_code: asset.dept_code,
               serial_no: asset.serial_no,
               inventory_no: asset.inventory_no,
               quantity: asset.quantity,
               unit_code: asset.unit_code,
               status: asset.status,
               created_by: asset.created_by,
               created_at: asset.created_at,
               deactivated_at: asset.deactivated_at,

               // Enhanced relation fields - flattened
               plant_description: asset.mst_plant?.description || null,
               location_description: asset.mst_location?.description || null,
               dept_description: asset.mst_department?.description || null,
               unit_name: asset.mst_unit?.name || null,
               created_by_name: asset.mst_user?.full_name || null,
               created_by_role: asset.mst_user?.role || null,

               // Entity type for compatibility
               entity_type: 'asset'
            })) || [],
            pagination: {
               page,
               limit: actualLimit,
               total,
               totalPages,
               hasNext: page < totalPages,
               hasPrev: page > 1
            }
         };
      } catch (error) {
         console.error('Enhanced comprehensive search assets error:', error);
         return {
            data: [],
            pagination: { page, limit: actualLimit, total: 0, totalPages: 0 }
         };
      }
   }
   /**
    * 💭 SUGGESTIONS METHODS
    * สำหรับ autocomplete suggestions
    */

   /**
    * ดึง suggestions จาก assets
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} suggestions
    */
   async getAssetSuggestions(query, options = {}) {
      const { type = 'all', limit = 5, fuzzy = false } = options;
      const actualLimit = Math.min(limit, 10);

      try {
         let searchConditions = {
            status: { in: ['A', 'C'] }
         };

         const queryPattern = fuzzy
            ? `%${SearchUtils.sanitizeSearchTerm(query).split('').join('%')}%`
            : query;

         switch (type) {
            case 'asset_no':
               searchConditions.asset_no = { contains: queryPattern };
               break;
            case 'description':
               searchConditions.description = { contains: queryPattern };
               break;
            case 'serial_no':
               searchConditions.serial_no = { contains: queryPattern };
               break;
            case 'dept_code':
               return await this.getDepartmentSuggestions(query, options);
               break;
            case 'inventory_no':
               searchConditions.inventory_no = { contains: queryPattern };
               break;
            default: // 'all'
               searchConditions.OR = [
                  { asset_no: { contains: queryPattern } },
                  { description: { contains: queryPattern } },
                  { serial_no: { contains: queryPattern } },
                  { inventory_no: { contains: queryPattern } }
               ];
         }

         const results = await prisma.asset_master.findMany({
            where: searchConditions,
            select: {
               asset_no: true,
               description: true,
               serial_no: true,
               inventory_no: true
            },
            take: actualLimit,
            orderBy: [
               { asset_no: 'asc' }
            ]
         });

         // Format suggestions
         const suggestions = [];
         results.forEach(asset => {
            if (type === 'all') {
               if (asset.asset_no && asset.asset_no.includes(query)) {
                  suggestions.push({
                     value: asset.asset_no,
                     type: 'asset_no',
                     label: `${asset.asset_no} (asset number)`
                  });
               }
               if (asset.description && asset.description.includes(query)) {
                  suggestions.push({
                     value: asset.description,
                     type: 'description',
                     label: `${asset.description} (description)`
                  });
               }
            } else {
               const value = asset[type];
               if (value) {
                  suggestions.push({
                     value,
                     type,
                     label: `${value} (${type.replace('_', ' ')})`
                  });
               }
            }
         });

         return suggestions.slice(0, actualLimit);
      } catch (error) {
         console.error('Get asset suggestions error:', error);
         return [];
      }
   }

   /**
    * ดึง suggestions แบบ global (ทุก entity)
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} mixed suggestions
    */
   async getGlobalSuggestions(query, options = {}) {
      const { limit = 5 } = options;
      const limitPerEntity = Math.ceil(limit / 4);

      try {
         const [assetSuggestions, plantSuggestions, locationSuggestions, userSuggestions] = await Promise.all([
            this.getAssetSuggestions(query, { limit: limitPerEntity }),
            this.getPlantSuggestions(query, { limit: limitPerEntity }),
            this.getLocationSuggestions(query, { limit: limitPerEntity }),
            this.getUserSuggestions(query, { limit: limitPerEntity })
         ]);

         const allSuggestions = [
            ...assetSuggestions.map(s => ({ ...s, entity: 'assets', priority: 1 })),
            ...plantSuggestions.map(s => ({ ...s, entity: 'plants', priority: 2 })),
            ...locationSuggestions.map(s => ({ ...s, entity: 'locations', priority: 3 })),
            ...userSuggestions.map(s => ({ ...s, entity: 'users', priority: 4 }))
         ];

         return allSuggestions
            .sort((a, b) => a.priority - b.priority)
            .slice(0, limit);
      } catch (error) {
         console.error('Get global suggestions error:', error);
         return [];
      }
   }

   /**
    * ดึง plant suggestions
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} plant suggestions
    */
   async getPlantSuggestions(query, options = {}) {
      const { limit = 5 } = options;
      const actualLimit = Math.min(limit, 10);

      try {
         const results = await prisma.mst_plant.findMany({
            where: {
               OR: [
                  { plant_code: { contains: query } },
                  { description: { contains: query } }
               ]
            },
            take: actualLimit,
            orderBy: [
               { plant_code: 'asc' }
            ]
         });

         return results.map(plant => ({
            value: plant.plant_code,
            type: 'plant_code',
            label: `${plant.plant_code}${plant.description ? ` - ${plant.description}` : ''}`
         }));
      } catch (error) {
         console.error('Get plant suggestions error:', error);
         return [];
      }
   }

   /**
    * ดึง location suggestions
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} location suggestions
    */
   async getLocationSuggestions(query, options = {}) {
      const { limit = 5 } = options;
      const actualLimit = Math.min(limit, 10);

      try {
         const results = await prisma.mst_location.findMany({
            where: {
               OR: [
                  { location_code: { contains: query } },
                  { description: { contains: query } }
               ]
            },
            take: actualLimit,
            orderBy: [
               { location_code: 'asc' }
            ]
         });

         return results.map(location => ({
            value: location.location_code,
            type: 'location_code',
            label: `${location.location_code}${location.description ? ` - ${location.description}` : ''}${location.plant_code ? ` (${location.plant_code})` : ''}`
         }));
      } catch (error) {
         console.error('Get location suggestions error:', error);
         return [];
      }
   }

   /**
    * ดึง user suggestions
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} user suggestions
    */
   async getUserSuggestions(query, options = {}) {
      const { limit = 5 } = options;
      const actualLimit = Math.min(limit, 10);

      try {
         const results = await prisma.mst_user.findMany({
            where: {
               OR: [
                  { username: { contains: query } },
                  { full_name: { contains: query } }
               ]
            },
            select: {
               username: true,
               full_name: true,
               role: true
            },
            take: actualLimit,
            orderBy: [
               { username: 'asc' }
            ]
         });

         return results.map(user => ({
            value: user.username,
            type: 'username',
            label: `${user.username}${user.full_name ? ` - ${user.full_name}` : ''}${user.role ? ` (${user.role})` : ''}`
         }));
      } catch (error) {
         console.error('Get user suggestions error:', error);
         return [];
      }
   }

   /**
    * 📊 SEARCH ANALYTICS METHODS
    * Mock implementations (ไม่ใช้ search_activity_log table)
    */

   /**
    * บันทึก search activity (mock implementation)
    * @param {Object} searchData - ข้อมูลการค้นหา
    * @returns {Promise<boolean>} สำเร็จหรือไม่
    */
   async logSearchActivity(searchData) {
      // Mock implementation - ไม่บันทึกลง database
      return true;
   }

   /**
    * ดึง popular search terms (mock implementation)
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} popular searches
    */
   async getPopularSearches(options = {}) {
      // Mock data
      return [
         { query: 'pump', count: 25, avgResults: 15, avgDuration: 120 },
         { query: 'motor', count: 18, avgResults: 12, avgDuration: 95 },
         { query: 'valve', count: 12, avgResults: 8, avgDuration: 110 }
      ];
   }

   /**
    * ดึง user recent searches (mock implementation)
    * @param {string} userId - User ID
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} recent searches
    */
   async getUserRecentSearches(userId, options = {}) {
      // Mock empty array
      return [];
   }

   /**
    * ลบ user search history (mock implementation)
    * @param {string} userId - User ID
    * @returns {Promise<boolean>} สำเร็จหรือไม่
    */
   async clearUserSearchHistory(userId) {
      // Mock success
      return true;
   }

   /**
    * ดึง search statistics (mock implementation)
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Object>} statistics
    */
   async getSearchStatistics(options = {}) {
      // Mock data
      return {
         period: options.period || 'week',
         totalSearches: 0,
         uniqueUsers: 0,
         uniqueQueries: 0,
         avgDuration: 0,
         avgResults: 0,
         searchTypes: {},
         topQueries: []
      };
   }

   /**
    * Cleanup เก่า search logs (mock implementation)
    * @param {number} daysToKeep - จำนวนวันที่จะเก็บ
    * @returns {Promise<number>} จำนวน records ที่ลบ
    */
   async cleanupOldSearchLogs(daysToKeep = 90) {
      // Mock implementation
      return 0;
   }

   /**
    * สร้าง search indexes สำหรับ performance
    * @returns {Promise<boolean>} สำเร็จหรือไม่
    */
   async createSearchIndexes() {
      // Indexes are managed by Prisma schema
      console.log('Search indexes are managed by Prisma schema');
      return true;
   }

   /**
    * ตรวจสอบ search performance
    * @returns {Promise<Object>} performance metrics
    */
   async checkSearchPerformance() {
      try {
         const startTime = Date.now();

         // Test basic queries
         await Promise.all([
            prisma.asset_master.count({ where: { asset_no: { startsWith: 'A' } } }),
            prisma.asset_master.count({ where: { description: { contains: 'pump' } } }),
            prisma.mst_plant.count({ where: { plant_code: { startsWith: 'P' } } }),
            prisma.mst_location.count({ where: { location_code: { startsWith: 'L' } } })
         ]);

         const duration = Date.now() - startTime;

         return {
            timestamp: new Date().toISOString(),
            results: [{
               query: 'Basic Prisma performance test',
               duration_ms: duration,
               performance: duration < 100 ? 'Good' : duration < 500 ? 'Average' : 'Poor'
            }],
            overall: duration < 500 ? 'Good' : 'Needs Optimization'
         };
      } catch (error) {
         console.error('Check search performance error:', error);
         return {
            timestamp: new Date().toISOString(),
            results: [],
            overall: 'Error',
            error: error.message
         };
      }
   }

   /**
    * Raw query execution for backward compatibility
    * @param {string} query - SQL query
    * @param {Array} params - Query parameters
    * @returns {Promise<Array>} Query results
    */
   async executeQuery(query, params = []) {
      try {
         const result = await prisma.$queryRawUnsafe(query, ...params);

         // Convert BigInt to Number for JSON serialization
         return JSON.parse(JSON.stringify(result, (key, value) =>
            typeof value === 'bigint' ? Number(value) : value
         ));
      } catch (error) {
         throw new Error(`Database query error: ${error.message}`);
      }
   }
   // เพิ่มหลัง instantSearchUsers
   async instantSearchDepartments(query, options = {}) {
      const { limit = 5 } = options;
      const actualLimit = Math.min(limit, 10);

      try {
         const results = await prisma.mst_department.findMany({
            where: {
               OR: [
                  { dept_code: { contains: query } },
                  { description: { contains: query } }
               ]
            },
            include: {
               mst_plant: { select: { description: true } }
            },
            take: actualLimit,
            orderBy: [{ dept_code: 'asc' }]
         });

         return results.map(dept => ({
            ...dept,
            plant_description: dept.mst_plant?.description,
            entity_type: 'department'
         })) || [];
      } catch (error) {
         console.error('Instant search departments error:', error);
         return [];
      }
   }

   // เพิ่มใน getDepartmentSuggestions
   async getDepartmentSuggestions(query, options = {}) {
      const { limit = 5 } = options;
      const actualLimit = Math.min(limit, 10);

      try {
         const results = await prisma.mst_department.findMany({
            where: {
               OR: [
                  { dept_code: { contains: query } },
                  { description: { contains: query } }
               ]
            },
            take: actualLimit,
            orderBy: [{ dept_code: 'asc' }]
         });

         return results.map(dept => ({
            value: dept.dept_code,
            type: 'dept_code',
            label: `${dept.dept_code}${dept.description ? ` - ${dept.description}` : ''}${dept.plant_code ? ` (${dept.plant_code})` : ''}`
         }));
      } catch (error) {
         console.error('Get department suggestions error:', error);
         return [];
      }
   }
}

module.exports = SearchModel;