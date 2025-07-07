// Path: backend/src/features/search/searchController.js

const SearchService = require('./searchService');
const SearchUtils = require('./searchUtils');
/**
 * 🔍 SEARCH CONTROLLER
 * Handle HTTP requests สำหรับ search functionality
 * - เป็น entry point สำหรับ API calls
 * - จัดการ request/response formatting
 * - Handle errors และ validation
 * - Extract request metadata สำหรับ logging
 */
class SearchController {
   constructor() {
      this.searchService = new SearchService();
   }

   /**
    * ⚡ INSTANT SEARCH ENDPOINTS
    * Fast response APIs สำหรับ real-time search
    */

   /**
    * GET /api/v1/search/instant
    * Real-time search ทุก entities
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    */
   async instantSearch(req, res) {
      const startTime = new Date();

      try {
         const { q: query, entities, limit, include_details } = req.query;

         // Extract request metadata
         const requestMeta = this.extractRequestMeta(req, startTime);

         // Parse entities
         const entityList = entities ? entities.split(',').map(e => e.trim()) : ['assets'];

         // Parse options
         const options = {
            entities: entityList,
            limit: limit ? parseInt(limit) : 5,
            includeDetails: include_details === 'true'
         };

         // Call service
         const result = await this.searchService.instantSearch(query, options, requestMeta);

         // Add response timing
         if (result.meta) {
            result.meta.responseTime = Date.now() - startTime.getTime();
         }

         // Return appropriate status code
         const statusCode = result.success ? 200 : 500;
         res.status(statusCode).json(result);

      } catch (error) {
         console.error('Instant search controller error:', error);

         const errorResponse = SearchUtils.createErrorResponse(
            'Instant search request failed',
            500,
            {
               meta: {
                  responseTime: Date.now() - startTime.getTime(),
                  requestId: req.id || 'unknown'
               }
            }
         );

         res.status(500).json(errorResponse);
      }
   }

   /**
    * GET /api/v1/search/suggestions
    * Autocomplete suggestions
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    */
   async getSuggestions(req, res) {
      const startTime = new Date();

      try {
         const { q: query, type, limit, fuzzy } = req.query;

         const requestMeta = this.extractRequestMeta(req, startTime);

         const options = {
            type: type || 'all',
            limit: limit ? parseInt(limit) : 5,
            fuzzy: fuzzy === 'true'
         };

         const result = await this.searchService.getSuggestions(query, options, requestMeta);

         if (result.meta) {
            result.meta.responseTime = Date.now() - startTime.getTime();
         }

         const statusCode = result.success ? 200 : 500;
         res.status(statusCode).json(result);

      } catch (error) {
         console.error('Get suggestions controller error:', error);

         const errorResponse = SearchUtils.createErrorResponse(
            'Get suggestions request failed',
            500,
            {
               meta: {
                  responseTime: Date.now() - startTime.getTime()
               }
            }
         );

         res.status(500).json(errorResponse);
      }
   }

   /**
    * 🌐 COMPREHENSIVE SEARCH ENDPOINTS
    * Detailed search APIs พร้อม full features
    */

   /**
    * GET /api/v1/search/global
    * Comprehensive search ทุก entities
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    */
   async globalSearch(req, res) {
      const startTime = new Date();

      try {
         const {
            q: query,
            entities,
            page,
            limit,
            sort,
            filters,
            exact_match
         } = req.query;

         const requestMeta = this.extractRequestMeta(req, startTime);

         // Parse entities
         const entityList = entities ? entities.split(',').map(e => e.trim()) : ['assets'];

         // Parse filters (JSON string)
         let parsedFilters = {};
         if (filters) {
            try {
               parsedFilters = JSON.parse(filters);
            } catch (parseError) {
               return res.status(400).json(
                  SearchUtils.createErrorResponse('Invalid filters JSON format', 400)
               );
            }
         }

         const options = {
            entities: entityList,
            page: page ? parseInt(page) : 1,
            limit: limit ? parseInt(limit) : 20,
            sort: sort || 'relevance',
            filters: parsedFilters,
            exactMatch: exact_match === 'true'
         };

         const result = await this.searchService.globalSearch(query, options, requestMeta);

         if (result.meta) {
            result.meta.responseTime = Date.now() - startTime.getTime();
         }

         const statusCode = result.success ? 200 : 500;
         res.status(statusCode).json(result);

      } catch (error) {
         console.error('Global search controller error:', error);

         const errorResponse = SearchUtils.createErrorResponse(
            'Global search request failed',
            500,
            {
               meta: {
                  responseTime: Date.now() - startTime.getTime()
               }
            }
         );

         res.status(500).json(errorResponse);
      }
   }

   /**
    * GET /api/v1/search/advanced
    * Advanced search พร้อม analytics
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    */
   async advancedSearch(req, res) {
      const startTime = new Date();

      try {
         const {
            q: query,
            entities,
            page,
            limit,
            sort,
            filters,
            exact_match,
            include_analytics,
            include_related,
            highlight_matches
         } = req.query;

         const requestMeta = this.extractRequestMeta(req, startTime);

         const entityList = entities ? entities.split(',').map(e => e.trim()) : ['assets'];

         let parsedFilters = {};
         if (filters) {
            try {
               parsedFilters = JSON.parse(filters);
            } catch (parseError) {
               return res.status(400).json(
                  SearchUtils.createErrorResponse('Invalid filters JSON format', 400)
               );
            }
         }

         const options = {
            entities: entityList,
            page: page ? parseInt(page) : 1,
            limit: limit ? parseInt(limit) : 20,
            sort: sort || 'relevance',
            filters: parsedFilters,
            exactMatch: exact_match === 'true',
            includeAnalytics: include_analytics !== 'false', // default true
            includeRelated: include_related !== 'false',     // default true
            highlightMatches: highlight_matches !== 'false'  // default true
         };

         const result = await this.searchService.advancedSearch(query, options, requestMeta);

         if (result.meta) {
            result.meta.responseTime = Date.now() - startTime.getTime();
         }

         const statusCode = result.success ? 200 : 500;
         res.status(statusCode).json(result);

      } catch (error) {
         console.error('Advanced search controller error:', error);

         const errorResponse = SearchUtils.createErrorResponse(
            'Advanced search request failed',
            500,
            {
               meta: {
                  responseTime: Date.now() - startTime.getTime()
               }
            }
         );

         res.status(500).json(errorResponse);
      }
   }

   /**
    * 📜 USER SEARCH MANAGEMENT ENDPOINTS
    * APIs สำหรับจัดการ search history และ preferences
    */

   /**
    * GET /api/v1/search/recent
    * ดึง recent searches ของ user
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    */
   async getRecentSearches(req, res) {
      try {
         const { userId } = req.user; // จาก authentication middleware
         const { limit, days } = req.query;

         const options = {
            limit: limit ? parseInt(limit) : 10,
            days: days ? parseInt(days) : 30
         };

         const result = await this.searchService.getUserRecentSearches(userId, options);

         const statusCode = result.success ? 200 : 500;
         res.status(statusCode).json(result);

      } catch (error) {
         console.error('Get recent searches controller error:', error);

         const errorResponse = SearchUtils.createErrorResponse(
            'Failed to get recent searches',
            500
         );

         res.status(500).json(errorResponse);
      }
   }

   /**
    * DELETE /api/v1/search/recent
    * ลบ search history ของ user
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    */
   async clearRecentSearches(req, res) {
      try {
         const { userId } = req.user;

         const result = await this.searchService.clearUserSearchHistory(userId);

         const statusCode = result.success ? 200 : 500;
         res.status(statusCode).json(result);

      } catch (error) {
         console.error('Clear recent searches controller error:', error);

         const errorResponse = SearchUtils.createErrorResponse(
            'Failed to clear search history',
            500
         );

         res.status(500).json(errorResponse);
      }
   }

   /**
    * GET /api/v1/search/popular
    * ดึง popular search terms
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    */
   async getPopularSearches(req, res) {
      try {
         const { limit, days } = req.query;

         const options = {
            limit: limit ? parseInt(limit) : 10,
            days: days ? parseInt(days) : 7
         };

         const result = await this.searchService.getPopularSearches(options);

         const statusCode = result.success ? 200 : 500;
         res.status(statusCode).json(result);

      } catch (error) {
         console.error('Get popular searches controller error:', error);

         const errorResponse = SearchUtils.createErrorResponse(
            'Failed to get popular searches',
            500
         );

         res.status(500).json(errorResponse);
      }
   }

   /**
    * 📊 ADMIN & ANALYTICS ENDPOINTS
    * APIs สำหรับ admin และ search analytics
    */

   /**
    * GET /api/v1/search/stats
    * ดึง search statistics (admin only)
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    */
   async getSearchStats(req, res) {
      try {
         // ตรวจสอบ admin permission (ถ้ามี role middleware)
         if (req.user && req.user.role !== 'admin') {
            return res.status(403).json(
               SearchUtils.createErrorResponse('Admin access required', 403)
            );
         }

         const { period, entity } = req.query;

         const options = {
            period: period || 'week',
            entity: entity || 'all'
         };

         const result = await this.searchService.getSearchStatistics(options);

         const statusCode = result.success ? 200 : 500;
         res.status(statusCode).json(result);

      } catch (error) {
         console.error('Get search stats controller error:', error);

         const errorResponse = SearchUtils.createErrorResponse(
            'Failed to get search statistics',
            500
         );

         res.status(500).json(errorResponse);
      }
   }

   /**
    * POST /api/v1/search/reindex
    * Rebuild search indexes (admin only)
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    */
   async rebuildSearchIndex(req, res) {
      try {
         // ตรวจสอบ admin permission
         if (req.user && req.user.role !== 'admin') {
            return res.status(403).json(
               SearchUtils.createErrorResponse('Admin access required', 403)
            );
         }

         const { entity, force } = req.query;

         // Log admin action
         console.log(`Admin ${req.user?.username || 'unknown'} initiated search index rebuild`);

         const result = await this.searchService.rebuildSearchIndex();

         const statusCode = result.success ? 200 : 500;
         res.status(statusCode).json(result);

      } catch (error) {
         console.error('Rebuild search index controller error:', error);

         const errorResponse = SearchUtils.createErrorResponse(
            'Failed to rebuild search index',
            500
         );

         res.status(500).json(errorResponse);
      }
   }

   /**
    * GET /api/v1/search/health
    * Search system health check
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    */
   async healthCheck(req, res) {
      try {
         const result = await this.searchService.healthCheck();

         // Set status code based on health
         let statusCode = 200;
         if (result.data && result.data.status === 'unhealthy') {
            statusCode = 503; // Service Unavailable
         } else if (result.data && result.data.status === 'degraded') {
            statusCode = 200; // OK but with warnings
         }

         res.status(statusCode).json(result);

      } catch (error) {
         console.error('Search health check controller error:', error);

         const errorResponse = SearchUtils.createErrorResponse(
            'Health check failed',
            503,
            {
               status: 'unhealthy',
               timestamp: new Date().toISOString()
            }
         );

         res.status(503).json(errorResponse);
      }
   }

   /**
    * POST /api/v1/search/cleanup
    * Cleanup old search logs (admin only)
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    */
   async cleanupSearchLogs(req, res) {
      try {
         if (req.user && req.user.role !== 'admin') {
            return res.status(403).json(
               SearchUtils.createErrorResponse('Admin access required', 403)
            );
         }

         const { days_to_keep } = req.body;
         const daysToKeep = days_to_keep ? parseInt(days_to_keep) : 90;

         console.log(`Admin ${req.user?.username || 'unknown'} initiated search logs cleanup (${daysToKeep} days)`);

         const result = await this.searchService.cleanupSearchLogs(daysToKeep);

         const statusCode = result.success ? 200 : 500;
         res.status(statusCode).json(result);

      } catch (error) {
         console.error('Cleanup search logs controller error:', error);

         const errorResponse = SearchUtils.createErrorResponse(
            'Failed to cleanup search logs',
            500
         );

         res.status(500).json(errorResponse);
      }
   }

   /**
    * 🔧 PRIVATE HELPER METHODS
    */

   /**
    * Extract request metadata สำหรับ logging และ analytics
    * @param {Object} req - Express request
    * @param {Date} startTime - request start time
    * @returns {Object} request metadata
    * @private
    */
   extractRequestMeta(req, startTime) {
      return {
         userId: req.user?.userId || null,
         username: req.user?.username || 'anonymous',
         ipAddress: req.ip || req.connection?.remoteAddress || 'unknown',
         userAgent: req.get('User-Agent') || 'unknown',
         requestId: req.id || `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
         startTime,
         method: req.method,
         path: req.originalUrl,
         query: req.query,
         body: req.body
      };
   }

   /**
    * Handle common controller errors
    * @param {Error} error - error object
    * @param {Object} res - Express response
    * @param {string} operation - operation name
    * @param {Date} startTime - request start time
    * @private
    */
   handleControllerError(error, res, operation, startTime) {
      console.error(`${operation} controller error:`, error);

      let statusCode = 500;
      let message = `${operation} request failed`;

      // Handle specific error types
      if (error.message.includes('required')) {
         statusCode = 400;
         message = error.message;
      } else if (error.message.includes('not found')) {
         statusCode = 404;
         message = error.message;
      } else if (error.message.includes('unauthorized') || error.message.includes('access denied')) {
         statusCode = 403;
         message = 'Access denied';
      }

      const errorResponse = SearchUtils.createErrorResponse(
         message,
         statusCode,
         {
            meta: {
               operation,
               responseTime: startTime ? Date.now() - startTime.getTime() : 0,
               timestamp: new Date().toISOString()
            }
         }
      );

      res.status(statusCode).json(errorResponse);
   }

   /**
    * Validate search query
    * @param {string} query - search query
    * @param {Object} res - Express response
    * @param {number} minLength - minimum query length
    * @returns {boolean} is valid
    * @private
    */
   validateSearchQuery(query, res, minLength = 1) {
      if (!query || typeof query !== 'string') {
         res.status(400).json(
            SearchUtils.createErrorResponse('Search query is required', 400)
         );
         return false;
      }

      const cleanQuery = SearchUtils.sanitizeSearchTerm(query);
      if (cleanQuery.length < minLength) {
         res.status(400).json(
            SearchUtils.createErrorResponse(`Search query must be at least ${minLength} characters`, 400)
         );
         return false;
      }

      return true;
   }

   /**
    * Set cache headers สำหรับ search responses
    * @param {Object} res - Express response
    * @param {number} maxAge - cache max age in seconds
    * @private
    */
   setCacheHeaders(res, maxAge = 300) {
      res.set({
         'Cache-Control': `public, max-age=${maxAge}`,
         'Vary': 'Accept-Encoding, User-Agent'
      });
   }

   /**
    * Set CORS headers สำหรับ search APIs
    * @param {Object} res - Express response
    * @private
    */
   setCorsHeaders(res) {
      res.set({
         'Access-Control-Allow-Origin': '*',
         'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
         'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With'
      });
   }

   /**
    * Rate limiting check (ถ้าต้องการ custom rate limiting)
    * @param {Object} req - Express request
    * @param {Object} res - Express response
    * @param {string} operation - operation type
    * @returns {boolean} is allowed
    * @private
    */
   checkRateLimit(req, res, operation = 'search') {
      const userId = req.user?.userId || req.ip;
      const rateLimitResult = SearchUtils.checkRateLimit(userId, operation);

      if (!rateLimitResult.allowed) {
         res.status(429).json(
            SearchUtils.createErrorResponse(
               'Rate limit exceeded',
               429,
               {
                  retryAfter: Math.ceil((rateLimitResult.resetTime - new Date()) / 1000),
                  limit: rateLimitResult.limit,
                  remaining: rateLimitResult.remaining
               }
            )
         );
         return false;
      }

      // Set rate limit headers
      res.set({
         'X-RateLimit-Limit': rateLimitResult.limit,
         'X-RateLimit-Remaining': rateLimitResult.remaining,
         'X-RateLimit-Reset': rateLimitResult.resetTime.toISOString()
      });

      return true;
   }
}

module.exports = SearchController;