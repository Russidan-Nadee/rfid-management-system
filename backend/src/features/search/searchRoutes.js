// Path: backend/src/features/search/searchRoutes.js
const express = require('express');
const router = express.Router();

// Import controller
const SearchController = require('./searchController');
const searchController = new SearchController();

// Import validators
const {
   instantSearchValidator,
   suggestionsValidator,
   globalSearchValidator,
   recentSearchValidator
} = require('./searchValidator');

// Import middleware
const { createRateLimit } = require('../scan/scanMiddleware');
const { authenticateToken, optionalAuth } = require('../auth/authMiddleware');

// สำหรับเพิ่มใน routes/route.js:
// router.use('/search', require('./searchRoutes'));

// Rate limiting - more strict for search APIs
const searchRateLimit = createRateLimit(1 * 60 * 1000, 60);    // 60 requests per minute
const instantRateLimit = createRateLimit(1 * 60 * 1000, 120);  // 120 requests per minute for instant

/**
 * 🔍 INSTANT SEARCH ROUTES
 * แบบ real-time ตอบเร็ว < 200ms
 */

// GET /api/v1/search/instant?q=ABC&entities=assets,plants
router.get('/instant',
   instantRateLimit,
   optionalAuth,  // ไม่บังคับ login แต่ถ้า login จะได้ผลดีกว่า
   instantSearchValidator,
   (req, res) => searchController.instantSearch(req, res)
);

// GET /api/v1/search/suggestions?q=AB&limit=5&type=asset_no
router.get('/suggestions',
   instantRateLimit,
   optionalAuth,
   suggestionsValidator,
   (req, res) => searchController.getSuggestions(req, res)
);

/**
 * 🌐 COMPREHENSIVE SEARCH ROUTES  
 * แบบค้นหาละเอียด มีข้อมูลครบ
 */

// GET /api/v1/search/global?q=pump&entities=assets,plants,locations
router.get('/global',
   searchRateLimit,
   optionalAuth,
   globalSearchValidator,
   (req, res) => searchController.globalSearch(req, res)
);

// GET /api/v1/search/advanced - ค้นหาแบบละเอียด พร้อม filters
router.get('/advanced',
   searchRateLimit,
   optionalAuth,
   globalSearchValidator, // ใช้ validator เดียวกัน
   (req, res) => searchController.advancedSearch(req, res)
);

/**
 * 📊 SEARCH ANALYTICS & HISTORY
 * สำหรับปรับปรุงประสิทธิภาพ
 */

// GET /api/v1/search/recent - ประวัติการค้นหา (ต้อง login)
router.get('/recent',
   searchRateLimit,
   authenticateToken,
   recentSearchValidator,
   (req, res) => searchController.getRecentSearches(req, res)
);

// GET /api/v1/search/popular - คำค้นหายอดนิยม
router.get('/popular',
   searchRateLimit,
   (req, res) => searchController.getPopularSearches(req, res)
);

// DELETE /api/v1/search/recent - ลบประวัติการค้นหา
router.delete('/recent',
   searchRateLimit,
   authenticateToken,
   (req, res) => searchController.clearRecentSearches(req, res)
);

/**
 * 🔧 ADMIN & DEBUGGING ROUTES
 * สำหรับ admin ดูสถิติและ debug
 */

// GET /api/v1/search/stats - สถิติการค้นหา (admin only)
router.get('/stats',
   searchRateLimit,
   authenticateToken,
   // requireRole(['admin']), // uncomment if you have role middleware
   (req, res) => searchController.getSearchStats(req, res)
);

// POST /api/v1/search/reindex - rebuild search index (admin only)  
router.post('/reindex',
   createRateLimit(60 * 60 * 1000, 1), // 1 time per hour
   authenticateToken,
   // requireRole(['admin']), // uncomment if you have role middleware
   (req, res) => searchController.rebuildSearchIndex(req, res)
);

/**
 * 📋 API DOCUMENTATION
 */
router.get('/docs', (req, res) => {
   const searchDocs = {
      success: true,
      message: 'Search API Documentation',
      version: '1.0.0',
      timestamp: new Date().toISOString(),
      endpoints: {
         instant_search: {
            'GET /search/instant': {
               description: 'Real-time search with fast response < 200ms',
               parameters: {
                  q: 'Search query (required, min 1 char)',
                  entities: 'Comma-separated: assets,plants,locations,users (default: assets)',
                  limit: 'Results per entity (default: 5, max: 10)',
                  include_details: 'Include full object details (default: false)'
               },
               example: '/search/instant?q=pump&entities=assets,plants&limit=3',
               response_time: '< 200ms'
            }
         },
         suggestions: {
            'GET /search/suggestions': {
               description: 'Autocomplete suggestions for search input',
               parameters: {
                  q: 'Search query (required, min 1 char)',
                  type: 'Suggestion type: all,asset_no,description,serial_no (default: all)',
                  limit: 'Number of suggestions (default: 5, max: 10)',
                  fuzzy: 'Enable fuzzy matching (default: false)'
               },
               example: '/search/suggestions?q=ab&type=asset_no&limit=5',
               response_time: '< 100ms'
            }
         },
         comprehensive: {
            'GET /search/global': {
               description: 'Comprehensive search across all entities with full details',
               parameters: {
                  q: 'Search query (required, min 2 chars)',
                  entities: 'Target entities (default: all)',
                  page: 'Page number (default: 1)',
                  limit: 'Results per page (default: 20, max: 100)',
                  sort: 'Sort order: relevance,created_date,alphabetical (default: relevance)'
               },
               example: '/search/global?q=pump&entities=assets&page=1&limit=20'
            },
            'GET /search/advanced': {
               description: 'Advanced search with filters and complex queries',
               parameters: {
                  q: 'Search query',
                  filters: 'JSON filters object',
                  date_range: 'Date range filter',
                  exact_match: 'Exact match mode (default: false)'
               }
            }
         },
         user_features: {
            'GET /search/recent': 'Get user recent searches (requires auth)',
            'GET /search/popular': 'Get popular search terms',
            'DELETE /search/recent': 'Clear user search history (requires auth)'
         },
         admin_features: {
            'GET /search/stats': 'Search analytics and statistics (admin only)',
            'POST /search/reindex': 'Rebuild search indexes (admin only)'
         }
      },
      search_entities: {
         assets: {
            searchable_fields: ['asset_no', 'description', 'serial_no', 'inventory_no'],
            boost_fields: ['asset_no', 'serial_no'], // ให้ความสำคัญมากกว่า
            filters: ['plant_code', 'location_code', 'unit_code', 'status'],
            sort_options: ['asset_no', 'created_at', 'description']
         },
         plants: {
            searchable_fields: ['plant_code', 'description'],
            boost_fields: ['plant_code'],
            filters: ['status'],
            sort_options: ['plant_code', 'description']
         },
         locations: {
            searchable_fields: ['location_code', 'description'],
            boost_fields: ['location_code'],
            filters: ['plant_code'],
            sort_options: ['location_code', 'plant_code']
         },
         users: {
            searchable_fields: ['username', 'full_name'],
            boost_fields: ['username'],
            filters: ['role'],
            sort_options: ['username', 'created_at']
         }
      },
      performance_notes: {
         instant_search: 'Optimized for speed, limited data returned',
         suggestions: 'Cached results, sub-100ms response time',
         global_search: 'Full-featured, may take 200-500ms for complex queries',
         caching: 'Popular searches cached for 5 minutes',
         rate_limiting: 'Instant: 120/min, Others: 60/min'
      },
      examples: {
         find_asset: {
            instant: '/search/instant?q=ABC123',
            suggestion: '/search/suggestions?q=ABC&type=asset_no',
            detailed: '/search/global?q=ABC123&entities=assets'
         },
         find_equipment: {
            instant: '/search/instant?q=pump&entities=assets,plants',
            global: '/search/global?q=pump motor&sort=relevance'
         },
         user_search: {
            recent: '/search/recent?limit=10',
            popular: '/search/popular?limit=5'
         }
      }
   };

   res.status(200).json(searchDocs);
});

module.exports = router;