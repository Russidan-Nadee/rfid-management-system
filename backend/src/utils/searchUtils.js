// Path: backend/src/utils/searchUtils.js

/**
 * 🔧 SEARCH UTILITY FUNCTIONS
 * Helper functions สำหรับ Search System
 * - Query building and optimization
 * - Response formatting  
 * - Performance monitoring
 * - Caching utilities
 */

class SearchUtils {

   /**
    * 🏗️ QUERY BUILDING UTILITIES
    */

   /**
    * สร้าง WHERE clause สำหรับ full-text search
    * @param {string} searchTerm - คำค้นหา
    * @param {Array} fields - fields ที่จะค้นหา
    * @param {Object} options - ตัวเลือกเพิ่มเติม
    * @returns {Object} { whereClause, params }
    */
   static buildSearchWhereClause(searchTerm, fields, options = {}) {
      const {
         exactMatch = false,
         fuzzyMatch = false,
         boostFields = [],
         minScore = 0.1
      } = options;

      if (!searchTerm || !fields.length) {
         return { whereClause: '1=1', params: [] };
      }

      const conditions = [];
      const params = [];

      // Sanitize search term
      const cleanTerm = this.sanitizeSearchTerm(searchTerm);

      if (exactMatch) {
         // Exact match mode
         fields.forEach(field => {
            conditions.push(`${field} = ?`);
            params.push(cleanTerm);
         });
      } else {
         // LIKE pattern matching
         const likePattern = fuzzyMatch
            ? `%${cleanTerm.split('').join('%')}%`  // Fuzzy: A%B%C
            : `%${cleanTerm}%`;                      // Normal: %ABC%

         fields.forEach(field => {
            conditions.push(`${field} LIKE ?`);
            params.push(likePattern);
         });

         // เพิ่ม boost สำหรับ fields สำคัญ
         if (boostFields.length > 0) {
            const boostConditions = boostFields.map(field => {
               params.push(`${cleanTerm}%`); // Starts with pattern
               return `${field} LIKE ?`;
            });
            conditions.unshift(`(${boostConditions.join(' OR ')})`);
         }
      }

      const whereClause = conditions.length > 0 ? `(${conditions.join(' OR ')})` : '1=1';

      return { whereClause, params };
   }

   /**
    * สร้าง ORDER BY clause พร้อม relevance scoring
    * @param {string} sortType - ประเภทการเรียง
    * @param {string} searchTerm - คำค้นหา (สำหรับ relevance)
    * @param {Array} boostFields - fields ที่มีความสำคัญ
    * @returns {string} ORDER BY clause
    */
   static buildOrderByClause(sortType, searchTerm = '', boostFields = []) {
      switch (sortType) {
         case 'relevance':
            if (!searchTerm || !boostFields.length) {
               return 'ORDER BY created_at DESC';
            }

            // สร้าง relevance scoring
            const relevanceScore = boostFields.map(field =>
               `CASE 
                  WHEN ${field} LIKE '${this.sanitizeSearchTerm(searchTerm)}%' THEN 100
                  WHEN ${field} LIKE '%${this.sanitizeSearchTerm(searchTerm)}%' THEN 50
                  ELSE 0
               END`
            ).join(' + ');

            return `ORDER BY (${relevanceScore}) DESC, created_at DESC`;

         case 'created_date':
            return 'ORDER BY created_at DESC';

         case 'alphabetical':
            return 'ORDER BY description ASC, asset_no ASC';

         case 'recent':
            return 'ORDER BY updated_at DESC, created_at DESC';

         default:
            return 'ORDER BY created_at DESC';
      }
   }

   /**
    * สร้าง filters WHERE clause
    * @param {Object} filters - object ของ filters
    * @returns {Object} { whereClause, params }
    */
   static buildFiltersWhereClause(filters) {
      if (!filters || typeof filters !== 'object') {
         return { whereClause: '1=1', params: [] };
      }

      const conditions = [];
      const params = [];

      // Plant codes filter
      if (filters.plant_codes && Array.isArray(filters.plant_codes) && filters.plant_codes.length > 0) {
         const placeholders = filters.plant_codes.map(() => '?').join(',');
         conditions.push(`plant_code IN (${placeholders})`);
         params.push(...filters.plant_codes);
      }

      // Location codes filter
      if (filters.location_codes && Array.isArray(filters.location_codes) && filters.location_codes.length > 0) {
         const placeholders = filters.location_codes.map(() => '?').join(',');
         conditions.push(`location_code IN (${placeholders})`);
         params.push(...filters.location_codes);
      }

      // Status filter
      if (filters.status && Array.isArray(filters.status) && filters.status.length > 0) {
         const placeholders = filters.status.map(() => '?').join(',');
         conditions.push(`status IN (${placeholders})`);
         params.push(...filters.status);
      }

      // Date range filter
      if (filters.date_range) {
         if (filters.date_range.from) {
            conditions.push('created_at >= ?');
            params.push(filters.date_range.from);
         }
         if (filters.date_range.to) {
            conditions.push('created_at <= ?');
            params.push(filters.date_range.to);
         }
      }

      const whereClause = conditions.length > 0 ? conditions.join(' AND ') : '1=1';
      return { whereClause, params };
   }

   /**
    * 🧹 TEXT PROCESSING UTILITIES
    */

   /**
    * ทำความสะอาด search term
    * @param {string} term - คำค้นหา
    * @returns {string} term ที่สะอาดแล้ว
    */
   static sanitizeSearchTerm(term) {
      if (!term || typeof term !== 'string') return '';

      return term
         .trim()
         .replace(/['"\\;--]/g, '')           // ลบ SQL injection chars
         .replace(/[<>{}()[\]]/g, '')         // ลบ special chars
         .replace(/\s+/g, ' ')                // แปลง multiple spaces
         .substring(0, 200);                  // จำกัดความยาว
   }

   /**
    * แยกคำค้นหาเป็น terms
    * @param {string} query - คำค้นหา
    * @returns {Array} array ของ search terms
    */
   static parseSearchTerms(query) {
      if (!query) return [];

      return this.sanitizeSearchTerm(query)
         .split(/\s+/)
         .filter(term => term.length > 0)
         .slice(0, 10); // จำกัดไม่เกิน 10 terms
   }

   /**
    * สร้าง search suggestions
    * @param {string} query - คำค้นหา
    * @param {Array} data - ข้อมูลสำหรับสร้าง suggestions
    * @param {Object} options - ตัวเลือก
    * @returns {Array} suggestions
    */
   static generateSuggestions(query, data, options = {}) {
      const { limit = 5, type = 'all', fuzzy = false } = options;

      if (!query || !data.length) return [];

      const cleanQuery = this.sanitizeSearchTerm(query).toLowerCase();
      const suggestions = new Set(); // ใช้ Set เพื่อไม่ให้ซ้ำ

      data.forEach(item => {
         // ตรวจสอบทุก field ที่เป็นไปได้
         const searchableFields = this.getSearchableFields(item, type);

         searchableFields.forEach(({ field, value, fieldType }) => {
            if (!value) return;

            const lowerValue = value.toLowerCase();
            let score = 0;

            // Exact match = highest score
            if (lowerValue === cleanQuery) {
               score = 100;
            }
            // Starts with = high score  
            else if (lowerValue.startsWith(cleanQuery)) {
               score = 80;
            }
            // Contains = medium score
            else if (lowerValue.includes(cleanQuery)) {
               score = 50;
            }
            // Fuzzy match = low score
            else if (fuzzy && this.fuzzyMatch(cleanQuery, lowerValue)) {
               score = 20;
            }

            if (score > 0) {
               suggestions.add({
                  value: value,
                  type: fieldType,
                  field: field,
                  score: score,
                  label: this.formatSuggestionLabel(value, fieldType, item)
               });
            }
         });
      });

      // เรียงตาม score และตัด limit
      return Array.from(suggestions)
         .sort((a, b) => b.score - a.score)
         .slice(0, limit);
   }

   /**
    * ดึง searchable fields จาก item
    * @param {Object} item - data item
    * @param {string} type - ประเภทที่ต้องการ
    * @returns {Array} searchable fields
    */
   static getSearchableFields(item, type) {
      const allFields = [
         { field: 'asset_no', value: item.asset_no, fieldType: 'asset_no' },
         { field: 'description', value: item.description, fieldType: 'description' },
         { field: 'serial_no', value: item.serial_no, fieldType: 'serial_no' },
         { field: 'inventory_no', value: item.inventory_no, fieldType: 'inventory_no' },
         { field: 'plant_code', value: item.plant_code, fieldType: 'plant_code' },
         { field: 'location_code', value: item.location_code, fieldType: 'location_code' },
         { field: 'username', value: item.username, fieldType: 'username' },
         { field: 'full_name', value: item.full_name, fieldType: 'full_name' }
      ];

      if (type === 'all') {
         return allFields.filter(f => f.value);
      }

      return allFields.filter(f => f.fieldType === type && f.value);
   }

   /**
    * Format suggestion label สำหรับแสดงผล
    * @param {string} value - ค่าที่จะแสดง
    * @param {string} type - ประเภท
    * @param {Object} item - item เต็ม
    * @returns {string} formatted label
    */
   static formatSuggestionLabel(value, type, item) {
      const typeLabels = {
         'asset_no': 'Asset',
         'description': 'Description',
         'serial_no': 'Serial',
         'inventory_no': 'Inventory',
         'plant_code': 'Plant',
         'location_code': 'Location',
         'username': 'User',
         'full_name': 'User Name'
      };

      const typeLabel = typeLabels[type] || type;

      // เพิ่มข้อมูลเสริม
      let additionalInfo = '';
      if (type === 'asset_no' && item.description) {
         additionalInfo = ` - ${item.description.substring(0, 30)}`;
      } else if (type === 'description' && item.asset_no) {
         additionalInfo = ` (${item.asset_no})`;
      } else if (type === 'plant_code' && item.plant_description) {
         additionalInfo = ` - ${item.plant_description}`;
      }

      return `${value}${additionalInfo}`;
   }

   /**
    * Fuzzy matching algorithm
    * @param {string} pattern - pattern ที่ค้นหา
    * @param {string} text - text ที่จะเทียบ
    * @returns {boolean} match หรือไม่
    */
   static fuzzyMatch(pattern, text) {
      if (!pattern || !text) return false;

      let patternIdx = 0;
      let textIdx = 0;

      while (patternIdx < pattern.length && textIdx < text.length) {
         if (pattern[patternIdx] === text[textIdx]) {
            patternIdx++;
         }
         textIdx++;
      }

      return patternIdx === pattern.length;
   }

   /**
    * 📊 RESPONSE FORMATTING UTILITIES
    */

   /**
    * Format search results สำหรับ instant search
    * @param {Object} results - ผลลัพธ์จาก database
    * @param {Object} options - ตัวเลือก
    * @returns {Object} formatted results
    */
   static formatInstantSearchResults(results, options = {}) {
      const { includeDetails = false, maxItems = 5 } = options;

      const formatted = {};

      Object.keys(results).forEach(entity => {
         if (!results[entity] || !Array.isArray(results[entity])) return;

         formatted[entity] = results[entity].slice(0, maxItems).map(item => {
            if (includeDetails) {
               return this.formatDetailedItem(item, entity);
            } else {
               return this.formatBasicItem(item, entity);
            }
         });
      });

      return formatted;
   }

   /**
    * Format basic item สำหรับ instant search
    * @param {Object} item - data item
    * @param {string} entity - entity type
    * @returns {Object} basic formatted item
    */
   static formatBasicItem(item, entity) {
      const baseFormat = {
         id: this.getItemId(item, entity),
         title: this.getItemTitle(item, entity),
         subtitle: this.getItemSubtitle(item, entity),
         type: entity
      };

      // เพิ่มข้อมูลสำคัญตาม entity
      switch (entity) {
         case 'assets':
            return {
               ...baseFormat,
               asset_no: item.asset_no,
               status: item.status,
               plant_code: item.plant_code,
               location_code: item.location_code
            };

         case 'plants':
            return {
               ...baseFormat,
               plant_code: item.plant_code
            };

         case 'locations':
            return {
               ...baseFormat,
               location_code: item.location_code,
               plant_code: item.plant_code
            };

         case 'users':
            return {
               ...baseFormat,
               username: item.username,
               role: item.role
            };

         default:
            return baseFormat;
      }
   }

   /**
    * Format detailed item สำหรับ comprehensive search
    * @param {Object} item - data item
    * @param {string} entity - entity type  
    * @returns {Object} detailed formatted item
    */
   static formatDetailedItem(item, entity) {
      const basic = this.formatBasicItem(item, entity);

      // เพิ่มรายละเอียดเต็ม
      return {
         ...basic,
         ...item, // ข้อมูลทั้งหมด
         formatted_created_at: this.formatDateTime(item.created_at),
         formatted_updated_at: this.formatDateTime(item.updated_at)
      };
   }

   /**
    * ดึง unique ID ของ item
    * @param {Object} item - data item
    * @param {string} entity - entity type
    * @returns {string} unique ID
    */
   static getItemId(item, entity) {
      const idFields = {
         'assets': 'asset_no',
         'plants': 'plant_code',
         'locations': 'location_code',
         'users': 'user_id'
      };

      return item[idFields[entity]] || item.id || '';
   }

   /**
    * ดึง title ของ item
    * @param {Object} item - data item
    * @param {string} entity - entity type
    * @returns {string} title
    */
   static getItemTitle(item, entity) {
      switch (entity) {
         case 'assets':
            return item.asset_no || 'Unknown Asset';
         case 'plants':
            return item.plant_code || 'Unknown Plant';
         case 'locations':
            return item.location_code || 'Unknown Location';
         case 'users':
            return item.full_name || item.username || 'Unknown User';
         default:
            return 'Unknown Item';
      }
   }

   /**
    * ดึง subtitle ของ item
    * @param {Object} item - data item
    * @param {string} entity - entity type
    * @returns {string} subtitle
    */
   static getItemSubtitle(item, entity) {
      switch (entity) {
         case 'assets':
            return item.description || `${item.plant_code} - ${item.location_code}`;
         case 'plants':
            return item.description || 'Plant';
         case 'locations':
            return item.description || `Plant: ${item.plant_code}`;
         case 'users':
            return `${item.role || 'User'} - ${item.username || ''}`;
         default:
            return '';
      }
   }

   /**
    * 🎯 PERFORMANCE UTILITIES
    */

   /**
    * สร้าง cache key สำหรับ search results
    * @param {string} query - search query
    * @param {Object} options - search options
    * @returns {string} cache key
    */
   static generateCacheKey(query, options = {}) {
      const keyParts = [
         'search',
         this.sanitizeSearchTerm(query),
         options.entities || 'all',
         options.limit || 'default',
         options.sort || 'relevance',
         JSON.stringify(options.filters || {})
      ];

      return keyParts.join(':').replace(/[^a-zA-Z0-9:_-]/g, '');
   }

   /**
    * คำนวณ search performance metrics
    * @param {Date} startTime - เวลาเริ่มต้น
    * @param {Object} results - ผลลัพธ์
    * @returns {Object} performance metrics
    */
   static calculatePerformanceMetrics(startTime, results) {
      const endTime = new Date();
      const duration = endTime - startTime;

      let totalResults = 0;
      if (results && typeof results === 'object') {
         Object.values(results).forEach(entityResults => {
            if (Array.isArray(entityResults)) {
               totalResults += entityResults.length;
            }
         });
      }

      return {
         duration_ms: duration,
         total_results: totalResults,
         performance_grade: this.getPerformanceGrade(duration),
         timestamp: endTime.toISOString()
      };
   }

   /**
    * ประเมิน performance grade
    * @param {number} duration - เวลาที่ใช้ (ms)
    * @returns {string} grade (A, B, C, D, F)
    */
   static getPerformanceGrade(duration) {
      if (duration < 100) return 'A';
      if (duration < 200) return 'B';
      if (duration < 500) return 'C';
      if (duration < 1000) return 'D';
      return 'F';
   }

   /**
    * 🕒 DATE & TIME UTILITIES
    */

   /**
    * Format datetime สำหรับแสดงผล
    * @param {Date|string} date - วันที่
    * @returns {string} formatted datetime
    */
   static formatDateTime(date) {
      if (!date) return '';

      const d = new Date(date);
      if (isNaN(d.getTime())) return '';

      return d.toLocaleString('th-TH', {
         year: 'numeric',
         month: '2-digit',
         day: '2-digit',
         hour: '2-digit',
         minute: '2-digit',
         second: '2-digit'
      });
   }

   /**
    * 🔐 SECURITY UTILITIES
    */

   /**
    * ตรวจสอบ rate limiting
    * @param {string} userId - user ID
    * @param {string} action - การกระทำ
    * @returns {Object} rate limit status
    */
   static checkRateLimit(userId, action) {
      // Implementation ขึ้นอยู่กับ rate limiting strategy
      // สามารถใช้ Redis หรือ in-memory cache

      return {
         allowed: true,
         remaining: 100,
         resetTime: new Date(Date.now() + 60000)
      };
   }

   /**
    * Log search activity สำหรับ analytics
    * @param {Object} searchData - ข้อมูลการค้นหา
    */
   static logSearchActivity(searchData) {
      const logEntry = {
         timestamp: new Date().toISOString(),
         query: this.sanitizeSearchTerm(searchData.query),
         user_id: searchData.userId || 'anonymous',
         entities: searchData.entities || 'unknown',
         results_count: searchData.resultsCount || 0,
         duration_ms: searchData.duration || 0,
         ip_address: searchData.ipAddress || 'unknown',
         user_agent: searchData.userAgent || 'unknown'
      };

      // Log to console (production ควรส่งไป logging service)
      console.log(`[SEARCH_ACTIVITY] ${JSON.stringify(logEntry)}`);
   }

   /**
    * 🧪 UTILITY HELPERS
    */

   /**
    * ตรวจสอบว่า entity valid หรือไม่
    * @param {string} entity - entity name
    * @returns {boolean} valid หรือไม่
    */
   static isValidEntity(entity) {
      const validEntities = ['assets', 'plants', 'locations', 'users'];
      return validEntities.includes(entity);
   }

   /**
    * แปลง entity list เป็น array
    * @param {string} entitiesStr - entities string (comma-separated)
    * @returns {Array} array ของ valid entities
    */
   static parseEntities(entitiesStr) {
      if (!entitiesStr) return ['assets']; // default

      return entitiesStr
         .split(',')
         .map(e => e.trim())
         .filter(e => this.isValidEntity(e));
   }

   /**
    * สร้าง error response
    * @param {string} message - error message
    * @param {number} statusCode - HTTP status code
    * @param {Object} details - รายละเอียดเพิ่มเติม
    * @returns {Object} error response
    */
   static createErrorResponse(message, statusCode = 500, details = {}) {
      return {
         success: false,
         message,
         timestamp: new Date().toISOString(),
         statusCode,
         ...details
      };
   }

   /**
    * สร้าง success response
    * @param {string} message - success message
    * @param {*} data - response data
    * @param {Object} meta - metadata
    * @returns {Object} success response
    */
   static createSuccessResponse(message, data = null, meta = {}) {
      const response = {
         success: true,
         message,
         timestamp: new Date().toISOString()
      };

      if (data !== null) {
         response.data = data;
      }

      if (Object.keys(meta).length > 0) {
         response.meta = meta;
      }

      return response;
   }
}

module.exports = SearchUtils;