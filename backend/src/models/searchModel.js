// Path: backend/src/models/searchModel.js

const { BaseModel } = require('./model');
const SearchUtils = require('../utils/searchUtils');

/**
 * 🔍 SEARCH MODEL
 * จัดการ database queries สำหรับ search functionality
 * - Optimized สำหรับความเร็ว
 * - Support หลาย entity types
 * - มี caching strategy
 */
class SearchModel extends BaseModel {
   constructor() {
      super(''); // ไม่ระบุ table เพราะจะค้นหาหลาย tables
   }

   /**
    * ⚡ INSTANT SEARCH METHODS
    * สำหรับ real-time search - เน้นความเร็ว
    */

   /**
    * ค้นหา assets แบบ instant (เร็วที่สุด)
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} ผลลัพธ์ assets
    */
   async instantSearchAssets(query, options = {}) {
      const { limit = 5, includeDetails = false } = options;

      // ใช้ LIMIT ต่ำเพื่อความเร็ว
      const actualLimit = Math.min(limit, 10);

      const fields = ['a.asset_no', 'a.description', 'a.serial_no', 'a.inventory_no'];
      const boostFields = ['a.asset_no', 'a.serial_no']; // ให้ความสำคัญกับ fields เหล่านี้

      const { whereClause, params } = SearchUtils.buildSearchWhereClause(
         query,
         fields,
         { boostFields: boostFields }
      );

      let selectFields = `
         a.asset_no, 
         a.description,
         a.status,
         a.plant_code,
         a.location_code
      `;

      // ถ้าต้องการรายละเอียด ให้เพิ่ม JOIN
      let joinClause = '';
      if (includeDetails) {
         selectFields += `,
            p.description as plant_description,
            l.description as location_description,
            u.name as unit_name
         `;
         joinClause = `
            LEFT JOIN mst_plant p ON a.plant_code = p.plant_code
            LEFT JOIN mst_location l ON a.location_code = l.location_code  
            LEFT JOIN mst_unit u ON a.unit_code = u.unit_code
         `;
      }

      const sql = `
         SELECT ${selectFields}
         FROM asset_master a
         ${joinClause}
         WHERE ${whereClause} 
         AND a.status IN ('A', 'C')
         ${SearchUtils.buildOrderByClause('relevance', query, boostFields)}
         LIMIT ${actualLimit}
      `;

      try {
         const results = await this.executeQuery(sql, params);
         return results || [];
      } catch (error) {
         console.error('Instant search assets error:', error);
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

      const fields = ['plant_code', 'description'];
      const { whereClause, params } = SearchUtils.buildSearchWhereClause(query, fields);

      const sql = `
         SELECT 
            plant_code,
            description,
            'plant' as entity_type
         FROM mst_plant
         WHERE ${whereClause}
         ORDER BY 
            CASE WHEN plant_code LIKE ? THEN 1 ELSE 2 END,
            plant_code ASC
         LIMIT ${actualLimit}
      `;

      // เพิ่ม parameter สำหรับ ORDER BY
      const orderParams = [`${SearchUtils.sanitizeSearchTerm(query)}%`];

      try {
         const results = await this.executeQuery(sql, [...params, ...orderParams]);
         return results || [];
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

      const fields = ['l.location_code', 'l.description'];
      const { whereClause, params } = SearchUtils.buildSearchWhereClause(query, fields);

      const sql = `
         SELECT 
            l.location_code,
            l.description,
            l.plant_code,
            p.description as plant_description,
            'location' as entity_type
         FROM mst_location l
         LEFT JOIN mst_plant p ON l.plant_code = p.plant_code
         WHERE ${whereClause}
         ORDER BY 
            CASE WHEN l.location_code LIKE ? THEN 1 ELSE 2 END,
            l.location_code ASC
         LIMIT ${actualLimit}
      `;

      const orderParams = [`${SearchUtils.sanitizeSearchTerm(query)}%`];

      try {
         const results = await this.executeQuery(sql, [...params, ...orderParams]);
         return results || [];
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

      const fields = ['username', 'full_name'];
      const { whereClause, params } = SearchUtils.buildSearchWhereClause(query, fields);

      const sql = `
         SELECT 
            user_id,
            username,
            full_name,
            role,
            'user' as entity_type
         FROM mst_user
         WHERE ${whereClause}
         ORDER BY 
            CASE WHEN username LIKE ? THEN 1 ELSE 2 END,
            username ASC
         LIMIT ${actualLimit}
      `;

      const orderParams = [`${SearchUtils.sanitizeSearchTerm(query)}%`];

      try {
         const results = await this.executeQuery(sql, [...params, ...orderParams]);

         // ลบข้อมูลที่ sensitive ออก
         return results.map(user => ({
            user_id: user.user_id,
            username: user.username,
            full_name: user.full_name,
            role: user.role,
            entity_type: user.entity_type
         }));
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
    * ค้นหา assets แบบละเอียด
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Object>} ผลลัพธ์พร้อม pagination
    */
   async comprehensiveSearchAssets(query, options = {}) {
      const {
         page = 1,
         limit = 20,
         sort = 'relevance',
         filters = {},
         exactMatch = false
      } = options;

      const offset = (page - 1) * limit;
      const actualLimit = Math.min(limit, 100);

      // Build search conditions
      const searchFields = [
         'a.asset_no', 'a.description', 'a.serial_no', 'a.inventory_no'
      ];
      const boostFields = ['a.asset_no', 'a.serial_no'];

      const { whereClause: searchWhere, params: searchParams } = SearchUtils.buildSearchWhereClause(
         query,
         searchFields,
         { exactMatch, boostFields }
      );

      const { whereClause: filtersWhere, params: filterParams } = SearchUtils.buildFiltersWhereClause(filters);

      // Combine conditions
      const combinedWhere = searchWhere === '1=1' && filtersWhere === '1=1'
         ? '1=1'
         : [searchWhere, filtersWhere].filter(w => w !== '1=1').join(' AND ');

      const sql = `
         SELECT 
            a.asset_no,
            a.description,
            a.serial_no,
            a.inventory_no,
            a.quantity,
            a.status,
            a.created_at,
            a.plant_code,
            a.location_code,
            a.unit_code,
            p.description as plant_description,
            l.description as location_description,
            u.name as unit_name,
            usr.full_name as created_by_name
         FROM asset_master a
         LEFT JOIN mst_plant p ON a.plant_code = p.plant_code
         LEFT JOIN mst_location l ON a.location_code = l.location_code
         LEFT JOIN mst_unit u ON a.unit_code = u.unit_code
         LEFT JOIN mst_user usr ON a.created_by = usr.user_id
         WHERE ${combinedWhere}
         AND a.status IN ('A', 'C')
         ${SearchUtils.buildOrderByClause(sort, query, boostFields)}
         LIMIT ${actualLimit} OFFSET ${offset}
      `;

      // Count query สำหรับ pagination
      const countSql = `
         SELECT COUNT(*) as total
         FROM asset_master a
         WHERE ${combinedWhere}
         AND a.status IN ('A', 'C')
      `;

      try {
         const allParams = [...searchParams, ...filterParams];

         const [results, countResult] = await Promise.all([
            this.executeQuery(sql, allParams),
            this.executeQuery(countSql, allParams)
         ]);

         const total = countResult[0]?.total || 0;
         const totalPages = Math.ceil(total / actualLimit);

         return {
            data: results || [],
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
         console.error('Comprehensive search assets error:', error);
         return { data: [], pagination: { page, limit: actualLimit, total: 0, totalPages: 0 } };
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

      let fields = [];
      let selectField = '';

      switch (type) {
         case 'asset_no':
            fields = ['asset_no'];
            selectField = 'asset_no as value, "asset_no" as type';
            break;
         case 'description':
            fields = ['description'];
            selectField = 'description as value, "description" as type';
            break;
         case 'serial_no':
            fields = ['serial_no'];
            selectField = 'serial_no as value, "serial_no" as type';
            break;
         case 'inventory_no':
            fields = ['inventory_no'];
            selectField = 'inventory_no as value, "inventory_no" as type';
            break;
         default: // 'all'
            fields = ['asset_no', 'description', 'serial_no', 'inventory_no'];
            selectField = `
               CASE 
                  WHEN asset_no LIKE ? THEN asset_no
                  WHEN description LIKE ? THEN description
                  WHEN serial_no LIKE ? THEN serial_no
                  WHEN inventory_no LIKE ? THEN inventory_no
               END as value,
               CASE 
                  WHEN asset_no LIKE ? THEN 'asset_no'
                  WHEN description LIKE ? THEN 'description'
                  WHEN serial_no LIKE ? THEN 'serial_no'
                  WHEN inventory_no LIKE ? THEN 'inventory_no'
               END as type
            `;
      }

      const { whereClause, params } = SearchUtils.buildSearchWhereClause(query, fields, { fuzzyMatch: fuzzy });

      let sql;
      let queryParams;

      if (type === 'all') {
         // สำหรับ 'all' ต้องเพิ่ม params เพิ่มเติมสำหรับ CASE statements
         const searchPattern = fuzzy
            ? `%${SearchUtils.sanitizeSearchTerm(query).split('').join('%')}%`
            : `%${SearchUtils.sanitizeSearchTerm(query)}%`;

         sql = `
            SELECT DISTINCT ${selectField}
            FROM asset_master
            WHERE ${whereClause}
            AND status IN ('A', 'C')
            ORDER BY 
               CASE 
                  WHEN value LIKE ? THEN 1
                  ELSE 2
               END,
               LENGTH(value),
               value
            LIMIT ${actualLimit}
         `;

         queryParams = [
            ...Array(8).fill(searchPattern), // สำหรับ CASE statements (4 WHEN conditions x 2)
            ...params,
            `${SearchUtils.sanitizeSearchTerm(query)}%` // สำหรับ ORDER BY
         ];
      } else {
         sql = `
            SELECT DISTINCT ${selectField}
            FROM asset_master
            WHERE ${whereClause}
            AND status IN ('A', 'C')
            AND ${fields[0]} IS NOT NULL
            AND ${fields[0]} != ''
            ORDER BY 
               CASE WHEN ${fields[0]} LIKE ? THEN 1 ELSE 2 END,
               LENGTH(${fields[0]}),
               ${fields[0]}
            LIMIT ${actualLimit}
         `;

         queryParams = [
            ...params,
            `${SearchUtils.sanitizeSearchTerm(query)}%`
         ];
      }

      try {
         const results = await this.executeQuery(sql, queryParams);

         return (results || [])
            .filter(row => row.value && row.value.trim() !== '')
            .map(row => ({
               value: row.value,
               type: row.type,
               label: `${row.value} (${row.type.replace('_', ' ')})`
            }));
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
      const limitPerEntity = Math.ceil(limit / 4); // แบ่งเท่าๆ กันใน 4 entities

      try {
         const [assetSuggestions, plantSuggestions, locationSuggestions, userSuggestions] = await Promise.all([
            this.getAssetSuggestions(query, { limit: limitPerEntity }),
            this.getPlantSuggestions(query, { limit: limitPerEntity }),
            this.getLocationSuggestions(query, { limit: limitPerEntity }),
            this.getUserSuggestions(query, { limit: limitPerEntity })
         ]);

         // รวมและเรียงตาม relevance
         const allSuggestions = [
            ...assetSuggestions.map(s => ({ ...s, entity: 'assets', priority: 1 })),
            ...plantSuggestions.map(s => ({ ...s, entity: 'plants', priority: 2 })),
            ...locationSuggestions.map(s => ({ ...s, entity: 'locations', priority: 3 })),
            ...userSuggestions.map(s => ({ ...s, entity: 'users', priority: 4 }))
         ];

         // เรียงตาม priority และ relevance
         return allSuggestions
            .sort((a, b) => {
               // Exact match first
               const aExact = a.value.toLowerCase() === query.toLowerCase() ? 0 : 1;
               const bExact = b.value.toLowerCase() === query.toLowerCase() ? 0 : 1;
               if (aExact !== bExact) return aExact - bExact;

               // Then by priority
               if (a.priority !== b.priority) return a.priority - b.priority;

               // Then by starts with
               const aStarts = a.value.toLowerCase().startsWith(query.toLowerCase()) ? 0 : 1;
               const bStarts = b.value.toLowerCase().startsWith(query.toLowerCase()) ? 0 : 1;
               if (aStarts !== bStarts) return aStarts - bStarts;

               // Finally by length
               return a.value.length - b.value.length;
            })
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

      const sql = `
         SELECT DISTINCT 
            plant_code as value,
            'plant_code' as type,
            description
         FROM mst_plant
         WHERE (plant_code LIKE ? OR description LIKE ?)
         ORDER BY 
            CASE WHEN plant_code LIKE ? THEN 1 ELSE 2 END,
            LENGTH(plant_code),
            plant_code
         LIMIT ${actualLimit}
      `;

      const searchPattern = `%${SearchUtils.sanitizeSearchTerm(query)}%`;
      const startsWithPattern = `${SearchUtils.sanitizeSearchTerm(query)}%`;

      try {
         const results = await this.executeQuery(sql, [
            searchPattern, searchPattern, startsWithPattern
         ]);

         return (results || []).map(row => ({
            value: row.value,
            type: row.type,
            label: `${row.value}${row.description ? ` - ${row.description}` : ''}`
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

      const sql = `
         SELECT DISTINCT 
            l.location_code as value,
            'location_code' as type,
            l.description,
            l.plant_code
         FROM mst_location l
         WHERE (l.location_code LIKE ? OR l.description LIKE ?)
         ORDER BY 
            CASE WHEN l.location_code LIKE ? THEN 1 ELSE 2 END,
            LENGTH(l.location_code),
            l.location_code
         LIMIT ${actualLimit}
      `;

      const searchPattern = `%${SearchUtils.sanitizeSearchTerm(query)}%`;
      const startsWithPattern = `${SearchUtils.sanitizeSearchTerm(query)}%`;

      try {
         const results = await this.executeQuery(sql, [
            searchPattern, searchPattern, startsWithPattern
         ]);

         return (results || []).map(row => ({
            value: row.value,
            type: row.type,
            label: `${row.value}${row.description ? ` - ${row.description}` : ''}${row.plant_code ? ` (${row.plant_code})` : ''}`
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

      const sql = `
         SELECT DISTINCT 
            username as value,
            'username' as type,
            full_name,
            role
         FROM mst_user
         WHERE (username LIKE ? OR full_name LIKE ?)
         ORDER BY 
            CASE WHEN username LIKE ? THEN 1 ELSE 2 END,
            LENGTH(username),
            username
         LIMIT ${actualLimit}
      `;

      const searchPattern = `%${SearchUtils.sanitizeSearchTerm(query)}%`;
      const startsWithPattern = `${SearchUtils.sanitizeSearchTerm(query)}%`;

      try {
         const results = await this.executeQuery(sql, [
            searchPattern, searchPattern, startsWithPattern
         ]);

         return (results || []).map(row => ({
            value: row.value,
            type: row.type,
            label: `${row.value}${row.full_name ? ` - ${row.full_name}` : ''}${row.role ? ` (${row.role})` : ''}`
         }));
      } catch (error) {
         console.error('Get user suggestions error:', error);
         return [];
      }
   }

   /**
    * 📊 SEARCH ANALYTICS METHODS
    * สำหรับ tracking และ improvement
    */

   /**
    * บันทึก search activity
    * @param {Object} searchData - ข้อมูลการค้นหา
    * @returns {Promise<boolean>} สำเร็จหรือไม่
    */
   async logSearchActivity(searchData) {
      try {
         const sql = `
            INSERT INTO search_activity_log (
               user_id, search_query, search_type, entities_searched,
               results_count, duration_ms, ip_address, user_agent,
               created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
         `;

         await this.executeQuery(sql, [
            searchData.userId || null,
            SearchUtils.sanitizeSearchTerm(searchData.query),
            searchData.searchType || 'instant',
            Array.isArray(searchData.entities) ? searchData.entities.join(',') : 'assets',
            searchData.resultsCount || 0,
            searchData.duration || 0,
            searchData.ipAddress || 'unknown',
            searchData.userAgent || 'unknown'
         ]);

         return true;
      } catch (error) {
         console.error('Log search activity error:', error);
         // ไม่ throw error เพราะไม่ควรขัดขวางการค้นหา
         return false;
      }
   }

   /**
    * ดึง popular search terms
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} popular searches
    */
   async getPopularSearches(options = {}) {
      const { limit = 10, days = 7 } = options;

      try {
         const sql = `
            SELECT 
               search_query,
               COUNT(*) as search_count,
               AVG(results_count) as avg_results,
               AVG(duration_ms) as avg_duration
            FROM search_activity_log
            WHERE created_at > DATE_SUB(NOW(), INTERVAL ? DAY)
            AND search_query IS NOT NULL
            AND search_query != ''
            GROUP BY search_query
            HAVING search_count > 1
            ORDER BY search_count DESC, avg_results DESC
            LIMIT ?
         `;

         const results = await this.executeQuery(sql, [days, limit]);

         return (results || []).map(row => ({
            query: row.search_query,
            count: row.search_count,
            avgResults: Math.round(row.avg_results || 0),
            avgDuration: Math.round(row.avg_duration || 0)
         }));
      } catch (error) {
         console.error('Get popular searches error:', error);
         return [];
      }
   }

   /**
    * ดึง user recent searches
    * @param {string} userId - User ID
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Array>} recent searches
    */
   async getUserRecentSearches(userId, options = {}) {
      const { limit = 10, days = 30 } = options;

      try {
         const sql = `
            SELECT DISTINCT
               search_query,
               search_type,
               entities_searched,
               MAX(created_at) as last_searched,
               COUNT(*) as search_count
            FROM search_activity_log
            WHERE user_id = ?
            AND created_at > DATE_SUB(NOW(), INTERVAL ? DAY)
            AND search_query IS NOT NULL
            AND search_query != ''
            GROUP BY search_query, search_type, entities_searched
            ORDER BY last_searched DESC
            LIMIT ?
         `;

         const results = await this.executeQuery(sql, [userId, days, limit]);

         return (results || []).map(row => ({
            query: row.search_query,
            type: row.search_type,
            entities: row.entities_searched ? row.entities_searched.split(',') : ['assets'],
            lastSearched: row.last_searched,
            count: row.search_count
         }));
      } catch (error) {
         console.error('Get user recent searches error:', error);
         return [];
      }
   }

   /**
    * ลบ user search history
    * @param {string} userId - User ID
    * @returns {Promise<boolean>} สำเร็จหรือไม่
    */
   async clearUserSearchHistory(userId) {
      try {
         const sql = `
            DELETE FROM search_activity_log
            WHERE user_id = ?
         `;

         await this.executeQuery(sql, [userId]);
         return true;
      } catch (error) {
         console.error('Clear user search history error:', error);
         return false;
      }
   }

   /**
    * ดึง search statistics สำหรับ admin
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Object>} statistics
    */
   async getSearchStatistics(options = {}) {
      const { period = 'week' } = options;

      let dateInterval;
      switch (period) {
         case 'day':
            dateInterval = '1 DAY';
            break;
         case 'week':
            dateInterval = '7 DAY';
            break;
         case 'month':
            dateInterval = '30 DAY';
            break;
         case 'year':
            dateInterval = '365 DAY';
            break;
         default:
            dateInterval = '7 DAY';
      }

      try {
         const statsSQL = `
            SELECT 
               COUNT(*) as total_searches,
               COUNT(DISTINCT user_id) as unique_users,
               COUNT(DISTINCT search_query) as unique_queries,
               AVG(duration_ms) as avg_duration,
               AVG(results_count) as avg_results,
               search_type,
               COUNT(*) as type_count
            FROM search_activity_log
            WHERE created_at > DATE_SUB(NOW(), INTERVAL ${dateInterval})
            GROUP BY search_type
         `;

         const topQueriesSQL = `
            SELECT 
               search_query,
               COUNT(*) as count,
               AVG(results_count) as avg_results
            FROM search_activity_log
            WHERE created_at > DATE_SUB(NOW(), INTERVAL ${dateInterval})
            AND search_query IS NOT NULL
            GROUP BY search_query
            ORDER BY count DESC
            LIMIT 10
         `;

         const [statsResults, topQueries] = await Promise.all([
            this.executeQuery(statsSQL),
            this.executeQuery(topQueriesSQL)
         ]);

         // Process results
         const stats = {
            period,
            totalSearches: 0,
            uniqueUsers: 0,
            uniqueQueries: 0,
            avgDuration: 0,
            avgResults: 0,
            searchTypes: {},
            topQueries: topQueries || []
         };

         if (statsResults && statsResults.length > 0) {
            // รวมข้อมูลจากทุก search types
            statsResults.forEach(row => {
               stats.totalSearches += row.type_count;
               stats.searchTypes[row.search_type] = row.type_count;
            });

            // คำนวณค่าเฉลี่ย
            const totalRows = statsResults.length;
            stats.uniqueUsers = Math.max(...statsResults.map(r => r.unique_users || 0));
            stats.uniqueQueries = Math.max(...statsResults.map(r => r.unique_queries || 0));
            stats.avgDuration = statsResults.reduce((sum, r) => sum + (r.avg_duration || 0), 0) / totalRows;
            stats.avgResults = statsResults.reduce((sum, r) => sum + (r.avg_results || 0), 0) / totalRows;
         }

         return stats;
      } catch (error) {
         console.error('Get search statistics error:', error);
         return {
            period,
            totalSearches: 0,
            uniqueUsers: 0,
            uniqueQueries: 0,
            avgDuration: 0,
            avgResults: 0,
            searchTypes: {},
            topQueries: []
         };
      }
   }

   /**
    * 🔄 MAINTENANCE METHODS
    * สำหรับ optimize และ maintain search performance
    */

   /**
    * Cleanup เก่า search logs
    * @param {number} daysToKeep - จำนวนวันที่จะเก็บ
    * @returns {Promise<number>} จำนวน records ที่ลบ
    */
   async cleanupOldSearchLogs(daysToKeep = 90) {
      try {
         const sql = `
            DELETE FROM search_activity_log
            WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)
         `;

         const result = await this.executeQuery(sql, [daysToKeep]);
         return result.affectedRows || 0;
      } catch (error) {
         console.error('Cleanup old search logs error:', error);
         return 0;
      }
   }

   /**
    * สร้าง search indexes สำหรับ performance
    * @returns {Promise<boolean>} สำเร็จหรือไม่
    */
   async createSearchIndexes() {
      const indexes = [
         // Asset indexes
         'CREATE INDEX IF NOT EXISTS idx_asset_search ON asset_master (asset_no, description, serial_no, inventory_no)',
         'CREATE INDEX IF NOT EXISTS idx_asset_status ON asset_master (status)',
         'CREATE INDEX IF NOT EXISTS idx_asset_plant ON asset_master (plant_code)',
         'CREATE INDEX IF NOT EXISTS idx_asset_location ON asset_master (location_code)',

         // Plant indexes
         'CREATE INDEX IF NOT EXISTS idx_plant_search ON mst_plant (plant_code, description)',

         // Location indexes  
         'CREATE INDEX IF NOT EXISTS idx_location_search ON mst_location (location_code, description, plant_code)',

         // User indexes
         'CREATE INDEX IF NOT EXISTS idx_user_search ON mst_user (username, full_name)',

         // Search log indexes
         'CREATE INDEX IF NOT EXISTS idx_search_log_user ON search_activity_log (user_id, created_at)',
         'CREATE INDEX IF NOT EXISTS idx_search_log_query ON search_activity_log (search_query, created_at)',
         'CREATE INDEX IF NOT EXISTS idx_search_log_date ON search_activity_log (created_at)'
      ];

      try {
         for (const indexSQL of indexes) {
            await this.executeQuery(indexSQL);
         }
         console.log('Search indexes created successfully');
         return true;
      } catch (error) {
         console.error('Create search indexes error:', error);
         return false;
      }
   }

   /**
    * ตรวจสอบ search performance
    * @returns {Promise<Object>} performance metrics
    */
   async checkSearchPerformance() {
      try {
         const testQueries = [
            'SELECT COUNT(*) FROM asset_master WHERE asset_no LIKE "A%"',
            'SELECT COUNT(*) FROM asset_master WHERE description LIKE "%pump%"',
            'SELECT COUNT(*) FROM mst_plant WHERE plant_code LIKE "P%"',
            'SELECT COUNT(*) FROM mst_location WHERE location_code LIKE "L%"'
         ];

         const results = [];

         for (const sql of testQueries) {
            const startTime = Date.now();
            await this.executeQuery(sql);
            const duration = Date.now() - startTime;

            results.push({
               query: sql,
               duration_ms: duration,
               performance: duration < 100 ? 'Good' : duration < 500 ? 'Average' : 'Poor'
            });
         }

         return {
            timestamp: new Date().toISOString(),
            results,
            overall: results.every(r => r.duration_ms < 500) ? 'Good' : 'Needs Optimization'
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
}

module.exports = SearchModel;