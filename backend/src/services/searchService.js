// Path: backend/src/services/searchService.js

const SearchModel = require('../models/searchModel');
const SearchUtils = require('../utils/searchUtils');

/**
 * 🔍 SEARCH SERVICE
 * Business logic layer สำหรับ search functionality
 * - Coordinate ระหว่าง Model และ Controller
 * - Handle caching และ performance optimization
 * - Manage search analytics และ logging
 */
class SearchService {
   constructor() {
      this.searchModel = new SearchModel();
      this.cache = new Map(); // Simple in-memory cache (production ควรใช้ Redis)
      this.cacheTimeout = 5 * 60 * 1000; // 5 minutes cache
   }

   /**
    * ⚡ INSTANT SEARCH METHODS
    * สำหรับ real-time search - เน้นความเร็ว
    */

   /**
    * ค้นหาแบบ instant ทุก entities
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @param {Object} requestMeta - ข้อมูล request (สำหรับ logging)
    * @returns {Promise<Object>} ผลลัพธ์การค้นหา
    */
   async instantSearch(query, options = {}, requestMeta = {}) {
      const startTime = new Date();

      try {
         // Validate และ sanitize input
         const cleanQuery = SearchUtils.sanitizeSearchTerm(query);
         if (!cleanQuery || cleanQuery.length === 0) {
            throw new Error('Search query is required');
         }

         const {
            entities = ['assets'],
            limit = 5,
            includeDetails = false
         } = options;

         const requestedEntities = SearchUtils.parseEntities(entities.join ? entities.join(',') : entities);

         // ตรวจสอบ cache ก่อน
         const cacheKey = SearchUtils.generateCacheKey(cleanQuery, {
            entities: requestedEntities,
            limit,
            includeDetails,
            type: 'instant'
         });

         const cachedResult = this.getCachedResult(cacheKey);
         if (cachedResult) {
            // เพิ่ม performance metrics
            cachedResult.meta.cached = true;
            cachedResult.meta.performance = SearchUtils.calculatePerformanceMetrics(startTime, cachedResult.data);

            // Log search activity (async)
            this.logSearchAsync(cleanQuery, requestedEntities, cachedResult.data, requestMeta, 'instant');

            return cachedResult;
         }

         // ทำการค้นหาจริง
         const searchPromises = [];
         const searchOptions = { limit, includeDetails };

         if (requestedEntities.includes('assets')) {
            searchPromises.push(
               this.searchModel.instantSearchAssets(cleanQuery, searchOptions)
                  .then(results => ({ entity: 'assets', data: results }))
                  .catch(error => ({ entity: 'assets', data: [], error: error.message }))
            );
         }

         if (requestedEntities.includes('plants')) {
            searchPromises.push(
               this.searchModel.instantSearchPlants(cleanQuery, searchOptions)
                  .then(results => ({ entity: 'plants', data: results }))
                  .catch(error => ({ entity: 'plants', data: [], error: error.message }))
            );
         }

         if (requestedEntities.includes('locations')) {
            searchPromises.push(
               this.searchModel.instantSearchLocations(cleanQuery, searchOptions)
                  .then(results => ({ entity: 'locations', data: results }))
                  .catch(error => ({ entity: 'locations', data: [], error: error.message }))
            );
         }

         if (requestedEntities.includes('users')) {
            searchPromises.push(
               this.searchModel.instantSearchUsers(cleanQuery, searchOptions)
                  .then(results => ({ entity: 'users', data: results }))
                  .catch(error => ({ entity: 'users', data: [], error: error.message }))
            );
         }

         // รอผลลัพธ์จากทุก entities
         const entityResults = await Promise.all(searchPromises);

         // จัดรูปแบบผลลัพธ์
         const results = {};
         let totalResults = 0;
         const errors = [];

         entityResults.forEach(({ entity, data, error }) => {
            if (error) {
               errors.push({ entity, error });
               results[entity] = [];
            } else {
               results[entity] = SearchUtils.formatInstantSearchResults(
                  { [entity]: data },
                  { includeDetails, maxItems: limit }
               )[entity] || [];
               totalResults += results[entity].length;
            }
         });

         // สร้าง response object
         const response = {
            success: true,
            message: 'Instant search completed successfully',
            data: results,
            meta: {
               query: cleanQuery,
               entities: requestedEntities,
               totalResults,
               cached: false,
               performance: SearchUtils.calculatePerformanceMetrics(startTime, results),
               errors: errors.length > 0 ? errors : undefined
            },
            timestamp: new Date().toISOString()
         };

         // Cache ผลลัพธ์
         this.setCachedResult(cacheKey, response);

         // Log search activity (async)
         this.logSearchAsync(cleanQuery, requestedEntities, results, requestMeta, 'instant');

         return response;

      } catch (error) {
         console.error('Instant search error:', error);

         // Log error search (async)
         this.logSearchAsync(query, [], {}, requestMeta, 'instant', error.message);

         return SearchUtils.createErrorResponse(
            error.message || 'Instant search failed',
            500,
            {
               meta: {
                  query: SearchUtils.sanitizeSearchTerm(query),
                  performance: SearchUtils.calculatePerformanceMetrics(startTime, {})
               }
            }
         );
      }
   }

   /**
    * 💭 SUGGESTIONS METHODS
    * สำหรับ autocomplete functionality
    */

   /**
    * ดึง search suggestions
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @param {Object} requestMeta - ข้อมูล request
    * @returns {Promise<Object>} suggestions
    */
   async getSuggestions(query, options = {}, requestMeta = {}) {
      const startTime = new Date();

      try {
         const cleanQuery = SearchUtils.sanitizeSearchTerm(query);
         if (!cleanQuery || cleanQuery.length === 0) {
            return SearchUtils.createSuccessResponse(
               'No suggestions available',
               [],
               { query: cleanQuery, performance: SearchUtils.calculatePerformanceMetrics(startTime, []) }
            );
         }

         const {
            type = 'all',
            limit = 5,
            fuzzy = false
         } = options;

         // ตรวจสอบ cache
         const cacheKey = SearchUtils.generateCacheKey(cleanQuery, { type, limit, fuzzy, action: 'suggestions' });
         const cachedResult = this.getCachedResult(cacheKey);

         if (cachedResult) {
            cachedResult.meta.cached = true;
            cachedResult.meta.performance = SearchUtils.calculatePerformanceMetrics(startTime, cachedResult.data);
            return cachedResult;
         }

         let suggestions = [];

         if (type === 'all') {
            // ดึง suggestions จากทุก entities
            suggestions = await this.searchModel.getGlobalSuggestions(cleanQuery, { limit, fuzzy });
         } else {
            // ดึง suggestions จาก assets เท่านั้น (หรือ entity ที่ระบุ)
            suggestions = await this.searchModel.getAssetSuggestions(cleanQuery, { type, limit, fuzzy });
         }

         // จัดรูปแบบ response
         const response = SearchUtils.createSuccessResponse(
            'Suggestions retrieved successfully',
            suggestions,
            {
               query: cleanQuery,
               type,
               totalSuggestions: suggestions.length,
               cached: false,
               performance: SearchUtils.calculatePerformanceMetrics(startTime, suggestions)
            }
         );

         // Cache ผลลัพธ์
         this.setCachedResult(cacheKey, response);

         // Log suggestion activity (async)
         this.logSearchAsync(cleanQuery, ['suggestions'], { suggestions }, requestMeta, 'suggestions');

         return response;

      } catch (error) {
         console.error('Get suggestions error:', error);

         return SearchUtils.createErrorResponse(
            error.message || 'Failed to get suggestions',
            500,
            {
               meta: {
                  query: SearchUtils.sanitizeSearchTerm(query),
                  performance: SearchUtils.calculatePerformanceMetrics(startTime, [])
               }
            }
         );
      }
   }

   /**
    * 🌐 COMPREHENSIVE SEARCH METHODS
    * สำหรับ detailed search พร้อม pagination
    */

   /**
    * ค้นหาแบบ global ทุก entities
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @param {Object} requestMeta - ข้อมูล request
    * @returns {Promise<Object>} ผลลัพธ์การค้นหา
    */
   async globalSearch(query, options = {}, requestMeta = {}) {
      const startTime = new Date();

      try {
         const cleanQuery = SearchUtils.sanitizeSearchTerm(query);
         if (!cleanQuery || cleanQuery.length < 2) {
            throw new Error('Search query must be at least 2 characters');
         }

         const {
            entities = ['assets'],
            page = 1,
            limit = 20,
            sort = 'relevance',
            filters = {},
            exactMatch = false
         } = options;

         const requestedEntities = SearchUtils.parseEntities(entities.join ? entities.join(',') : entities);

         // ตรวจสอบ cache (สำหรับ global search cache timeout สั้นกว่า)
         const cacheKey = SearchUtils.generateCacheKey(cleanQuery, {
            entities: requestedEntities,
            page,
            limit,
            sort,
            filters,
            exactMatch,
            type: 'global'
         });

         const cachedResult = this.getCachedResult(cacheKey, 2 * 60 * 1000); // 2 minutes cache
         if (cachedResult) {
            cachedResult.meta.cached = true;
            cachedResult.meta.performance = SearchUtils.calculatePerformanceMetrics(startTime, cachedResult.data);

            this.logSearchAsync(cleanQuery, requestedEntities, cachedResult.data, requestMeta, 'global');
            return cachedResult;
         }

         const searchPromises = [];
         const searchOptions = { page, limit, sort, filters, exactMatch };

         // ค้นหาใน assets (รองรับ pagination เต็มรูปแบบ)
         if (requestedEntities.includes('assets')) {
            searchPromises.push(
               this.searchModel.comprehensiveSearchAssets(cleanQuery, searchOptions)
                  .then(results => ({ entity: 'assets', ...results }))
                  .catch(error => ({
                     entity: 'assets',
                     data: [],
                     pagination: { page, limit, total: 0, totalPages: 0 },
                     error: error.message
                  }))
            );
         }

         // สำหรับ entities อื่นๆ ใช้ instant search (simplified)
         if (requestedEntities.includes('plants')) {
            searchPromises.push(
               this.searchModel.instantSearchPlants(cleanQuery, { limit: Math.min(limit, 50) })
                  .then(results => ({
                     entity: 'plants',
                     data: results,
                     pagination: { page: 1, limit: results.length, total: results.length, totalPages: 1 }
                  }))
                  .catch(error => ({
                     entity: 'plants',
                     data: [],
                     pagination: { page: 1, limit: 0, total: 0, totalPages: 0 },
                     error: error.message
                  }))
            );
         }

         if (requestedEntities.includes('locations')) {
            searchPromises.push(
               this.searchModel.instantSearchLocations(cleanQuery, { limit: Math.min(limit, 50) })
                  .then(results => ({
                     entity: 'locations',
                     data: results,
                     pagination: { page: 1, limit: results.length, total: results.length, totalPages: 1 }
                  }))
                  .catch(error => ({
                     entity: 'locations',
                     data: [],
                     pagination: { page: 1, limit: 0, total: 0, totalPages: 0 },
                     error: error.message
                  }))
            );
         }

         if (requestedEntities.includes('users')) {
            searchPromises.push(
               this.searchModel.instantSearchUsers(cleanQuery, { limit: Math.min(limit, 50) })
                  .then(results => ({
                     entity: 'users',
                     data: results,
                     pagination: { page: 1, limit: results.length, total: results.length, totalPages: 1 }
                  }))
                  .catch(error => ({
                     entity: 'users',
                     data: [],
                     pagination: { page: 1, limit: 0, total: 0, totalPages: 0 },
                     error: error.message
                  }))
            );
         }

         // รอผลลัพธ์จากทุก entities
         const entityResults = await Promise.all(searchPromises);

         // จัดรูปแบบผลลัพธ์
         const results = {};
         const pagination = {};
         let totalResults = 0;
         const errors = [];

         entityResults.forEach(({ entity, data, pagination: entityPagination, error }) => {
            if (error) {
               errors.push({ entity, error });
            }

            results[entity] = data || [];
            pagination[entity] = entityPagination || { page, limit: 0, total: 0, totalPages: 0 };
            totalResults += (data || []).length;
         });

         // สร้าง response
         const response = SearchUtils.createSuccessResponse(
            'Global search completed successfully',
            results,
            {
               query: cleanQuery,
               entities: requestedEntities,
               pagination,
               totalResults,
               searchOptions: { sort, exactMatch, filters },
               cached: false,
               performance: SearchUtils.calculatePerformanceMetrics(startTime, results),
               errors: errors.length > 0 ? errors : undefined
            }
         );

         // Cache ผลลัพธ์
         this.setCachedResult(cacheKey, response);

         // Log search activity (async)
         this.logSearchAsync(cleanQuery, requestedEntities, results, requestMeta, 'global');

         return response;

      } catch (error) {
         console.error('Global search error:', error);

         this.logSearchAsync(query, [], {}, requestMeta, 'global', error.message);

         return SearchUtils.createErrorResponse(
            error.message || 'Global search failed',
            500,
            {
               meta: {
                  query: SearchUtils.sanitizeSearchTerm(query),
                  performance: SearchUtils.calculatePerformanceMetrics(startTime, {})
               }
            }
         );
      }
   }

   /**
    * ค้นหาแบบ advanced พร้อม complex filters
    * @param {string} query - คำค้นหา
    * @param {Object} options - ตัวเลือก
    * @param {Object} requestMeta - ข้อมูล request
    * @returns {Promise<Object>} ผลลัพธ์การค้นหา
    */
   async advancedSearch(query, options = {}, requestMeta = {}) {
      // Advanced search เป็นการขยายจาก globalSearch
      const advancedOptions = {
         ...options,
         // เพิ่ม advanced features
         includeAnalytics: true,
         includeRelated: options.includeRelated !== false, // default true
         highlightMatches: options.highlightMatches !== false // default true
      };

      const result = await this.globalSearch(query, advancedOptions, requestMeta);

      // เพิ่ม advanced features ถ้า search สำเร็จ
      if (result.success && advancedOptions.includeAnalytics) {
         // เพิ่ม analytics data
         result.meta.analytics = await this.getSearchAnalytics(query);
      }

      if (result.success && advancedOptions.includeRelated) {
         // เพิ่ม related suggestions
         result.meta.relatedQueries = await this.getRelatedQueries(query);
      }

      return result;
   }

   /**
    * 📊 USER SEARCH MANAGEMENT
    * สำหรับจัดการ search history และ preferences
    */

   /**
    * ดึง user recent searches
    * @param {string} userId - User ID
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Object>} recent searches
    */
   async getUserRecentSearches(userId, options = {}) {
      try {
         if (!userId) {
            throw new Error('User ID is required');
         }

         const recentSearches = await this.searchModel.getUserRecentSearches(userId, options);

         return SearchUtils.createSuccessResponse(
            'Recent searches retrieved successfully',
            recentSearches,
            {
               userId,
               totalSearches: recentSearches.length,
               options
            }
         );

      } catch (error) {
         console.error('Get user recent searches error:', error);
         return SearchUtils.createErrorResponse(error.message || 'Failed to get recent searches', 500);
      }
   }

   /**
    * ลบ user search history
    * @param {string} userId - User ID
    * @returns {Promise<Object>} result
    */
   async clearUserSearchHistory(userId) {
      try {
         if (!userId) {
            throw new Error('User ID is required');
         }

         const success = await this.searchModel.clearUserSearchHistory(userId);

         if (success) {
            return SearchUtils.createSuccessResponse('Search history cleared successfully');
         } else {
            throw new Error('Failed to clear search history');
         }

      } catch (error) {
         console.error('Clear user search history error:', error);
         return SearchUtils.createErrorResponse(error.message || 'Failed to clear search history', 500);
      }
   }

   /**
    * ดึง popular searches
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Object>} popular searches
    */
   async getPopularSearches(options = {}) {
      try {
         const popularSearches = await this.searchModel.getPopularSearches(options);

         return SearchUtils.createSuccessResponse(
            'Popular searches retrieved successfully',
            popularSearches,
            {
               totalQueries: popularSearches.length,
               options
            }
         );

      } catch (error) {
         console.error('Get popular searches error:', error);
         return SearchUtils.createErrorResponse(error.message || 'Failed to get popular searches', 500);
      }
   }

   /**
    * 📈 SEARCH ANALYTICS & ADMIN
    * สำหรับ admin และ analytics
    */

   /**
    * ดึง search statistics
    * @param {Object} options - ตัวเลือก
    * @returns {Promise<Object>} statistics
    */
   async getSearchStatistics(options = {}) {
      try {
         const stats = await this.searchModel.getSearchStatistics(options);

         return SearchUtils.createSuccessResponse(
            'Search statistics retrieved successfully',
            stats,
            {
               generatedAt: new Date().toISOString(),
               options
            }
         );

      } catch (error) {
         console.error('Get search statistics error:', error);
         return SearchUtils.createErrorResponse(error.message || 'Failed to get search statistics', 500);
      }
   }

   /**
    * Rebuild search indexes
    * @returns {Promise<Object>} result
    */
   async rebuildSearchIndex() {
      try {
         console.log('Starting search index rebuild...');

         // สร้าง indexes
         const indexSuccess = await this.searchModel.createSearchIndexes();

         if (!indexSuccess) {
            throw new Error('Failed to create search indexes');
         }

         // ตรวจสอบ performance หลัง rebuild
         const performanceCheck = await this.searchModel.checkSearchPerformance();

         // ล้าง cache
         this.clearCache();

         console.log('Search index rebuild completed');

         return SearchUtils.createSuccessResponse(
            'Search index rebuilt successfully',
            {
               indexesCreated: true,
               cacheCleared: true,
               performance: performanceCheck
            }
         );

      } catch (error) {
         console.error('Rebuild search index error:', error);
         return SearchUtils.createErrorResponse(error.message || 'Failed to rebuild search index', 500);
      }
   }

   /**
    * 🎯 PRIVATE HELPER METHODS
    */

   /**
    * Log search activity แบบ async
    * @param {string} query - คำค้นหา
    * @param {Array} entities - entities ที่ค้นหา
    * @param {Object} results - ผลลัพธ์
    * @param {Object} requestMeta - ข้อมูล request
    * @param {string} searchType - ประเภทการค้นหา
    * @param {string} error - error message (ถ้ามี)
    * @private
    */
   logSearchAsync(query, entities, results, requestMeta, searchType, error = null) {
      // ทำแบบ async เพื่อไม่ขัดขวางการ response
      setImmediate(async () => {
         try {
            let resultsCount = 0;
            if (results && typeof results === 'object') {
               Object.values(results).forEach(entityResults => {
                  if (Array.isArray(entityResults)) {
                     resultsCount += entityResults.length;
                  }
               });
            }

            const logData = {
               userId: requestMeta.userId || null,
               query: SearchUtils.sanitizeSearchTerm(query),
               searchType,
               entities,
               resultsCount,
               duration: requestMeta.duration || 0,
               ipAddress: requestMeta.ipAddress || 'unknown',
               userAgent: requestMeta.userAgent || 'unknown',
               success: !error,
               error
            };

            // Log ไปยัง search model
            await this.searchModel.logSearchActivity(logData);

            // Log ไปยัง console สำหรับ monitoring
            SearchUtils.logSearchActivity(logData);

         } catch (logError) {
            console.error('Failed to log search activity:', logError);
         }
      });
   }

   /**
    * ดึงข้อมูลจาก cache
    * @param {string} key - cache key
    * @param {number} timeout - cache timeout (ms)
    * @returns {Object|null} cached data
    * @private
    */
   getCachedResult(key, timeout = this.cacheTimeout) {
      const cached = this.cache.get(key);
      if (!cached) return null;

      const now = Date.now();
      if (now - cached.timestamp > timeout) {
         this.cache.delete(key);
         return null;
      }

      return cached.data;
   }

   /**
    * เก็บข้อมูลลง cache
    * @param {string} key - cache key
    * @param {Object} data - data ที่จะ cache
    * @private
    */
   setCachedResult(key, data) {
      // จำกัดขนาด cache ไม่เกิน 1000 entries
      if (this.cache.size >= 1000) {
         // ลบ entry เก่าที่สุด
         const firstKey = this.cache.keys().next().value;
         this.cache.delete(firstKey);
      }

      this.cache.set(key, {
         data,
         timestamp: Date.now()
      });
   }

   /**
    * ล้าง cache ทั้งหมด
    * @private
    */
   clearCache() {
      this.cache.clear();
   }

   /**
    * ดึง search analytics สำหรับ query
    * @param {string} query - คำค้นหา
    * @returns {Promise<Object>} analytics data
    * @private
    */
   async getSearchAnalytics(query) {
      try {
         // ดึงข้อมูล analytics พื้นฐาน
         const analytics = {
            searchCount: 0,
            avgResults: 0,
            avgDuration: 0,
            popularityRank: 0
         };

         // ในการ implement จริงจะดึงจาก database
         // ตัวอย่างนี้ return mock data
         return analytics;

      } catch (error) {
         console.error('Get search analytics error:', error);
         return {};
      }
   }

   /**
    * ดึง related queries
    * @param {string} query - คำค้นหา
    * @returns {Promise<Array>} related queries
    * @private
    */
   async getRelatedQueries(query) {
      try {
         // ดึง popular searches ที่คล้ายกัน
         const popularSearches = await this.searchModel.getPopularSearches({ limit: 20 });

         const cleanQuery = SearchUtils.sanitizeSearchTerm(query).toLowerCase();

         // หา queries ที่มีคำร่วมกัน
         const relatedQueries = popularSearches
            .filter(search => {
               const searchTerm = search.query.toLowerCase();
               return searchTerm !== cleanQuery &&
                  (searchTerm.includes(cleanQuery) || cleanQuery.includes(searchTerm));
            })
            .slice(0, 5)
            .map(search => search.query);

         return relatedQueries;

      } catch (error) {
         console.error('Get related queries error:', error);
         return [];
      }
   }

   /**
    * 🧹 MAINTENANCE METHODS
    */

   /**
    * ทำความสะอาด search logs เก่า
    * @param {number} daysToKeep - จำนวนวันที่จะเก็บ
    * @returns {Promise<Object>} cleanup result
    */
   async cleanupSearchLogs(daysToKeep = 90) {
      try {
         const deletedCount = await this.searchModel.cleanupOldSearchLogs(daysToKeep);

         return SearchUtils.createSuccessResponse(
            'Search logs cleanup completed',
            {
               deletedRecords: deletedCount,
               daysKept: daysToKeep
            }
         );

      } catch (error) {
         console.error('Cleanup search logs error:', error);
         return SearchUtils.createErrorResponse(error.message || 'Failed to cleanup search logs', 500);
      }
   }

   /**
    * ตรวจสอบ search system health
    * @returns {Promise<Object>} health check result
    */
   async healthCheck() {
      try {
         const performanceCheck = await this.searchModel.checkSearchPerformance();
         const cacheSize = this.cache.size;
         const timestamp = new Date().toISOString();

         const health = {
            status: 'healthy',
            timestamp,
            performance: performanceCheck,
            cache: {
               size: cacheSize,
               maxSize: 1000,
               hitRate: this.calculateCacheHitRate()
            },
            version: '1.0.0'
         };

         // ประเมิน overall health
         if (performanceCheck.overall === 'Error') {
            health.status = 'unhealthy';
         } else if (performanceCheck.overall === 'Needs Optimization') {
            health.status = 'degraded';
         }

         return SearchUtils.createSuccessResponse(
            'Search system health check completed',
            health
         );

      } catch (error) {
         console.error('Search health check error:', error);
         return SearchUtils.createErrorResponse(
            error.message || 'Health check failed',
            500,
            {
               status: 'unhealthy',
               timestamp: new Date().toISOString(),
               error: error.message
            }
         );
      }
   }

   /**
    * คำนวณ cache hit rate
    * @returns {number} hit rate percentage
    * @private
    */
   calculateCacheHitRate() {
      // ในการ implement จริงควรมี counter สำหรับ hits/misses
      // ตัวอย่างนี้ return mock value
      return 85.5;
   }
}

module.exports = SearchService;