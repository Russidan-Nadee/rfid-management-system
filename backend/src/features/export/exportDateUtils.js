/**
 * Date utilities for export feature
 * Provides predefined date range options and helper functions
 */

class ExportDateUtils {
  /**
   * Get predefined period filter options for export
   * @returns {Array} Array of period options with labels and date ranges
   */
  static getPeriodOptions() {
    const today = new Date();
    const todayStr = today.toISOString().split('T')[0]; // YYYY-MM-DD format

    return [
      {
        label: "Today",
        value: "today",
        start_date: todayStr,
        end_date: todayStr
      },
      {
        label: "Last 7 days",
        value: "last_7_days",
        start_date: this._getDateDaysAgo(today, 6).toISOString().split('T')[0],
        end_date: todayStr
      },
      {
        label: "Last 30 days",
        value: "last_30_days", 
        start_date: this._getDateDaysAgo(today, 29).toISOString().split('T')[0],
        end_date: todayStr
      },
      {
        label: "Last 90 days",
        value: "last_90_days",
        start_date: this._getDateDaysAgo(today, 89).toISOString().split('T')[0],
        end_date: todayStr
      },
      {
        label: "Last 180 days",
        value: "last_180_days",
        start_date: this._getDateDaysAgo(today, 179).toISOString().split('T')[0],
        end_date: todayStr
      },
      {
        label: "Last 365 days",
        value: "last_365_days",
        start_date: this._getDateDaysAgo(today, 364).toISOString().split('T')[0],
        end_date: todayStr
      },
      {
        label: "Custom date range",
        value: "custom",
        start_date: null,
        end_date: null
      }
    ];
  }

  /**
   * Get date range for a specific period value
   * @param {string} periodValue - The period value (e.g., 'last_30_days')
   * @param {string} customStartDate - Custom start date for 'custom' period
   * @param {string} customEndDate - Custom end date for 'custom' period
   * @returns {Object} Object with start_date and end_date
   */
  static getDateRangeForPeriod(periodValue, customStartDate = null, customEndDate = null) {
    const periods = this.getPeriodOptions();
    const period = periods.find(p => p.value === periodValue);

    if (!period) {
      throw new Error(`Invalid period value: ${periodValue}`);
    }

    // Handle custom period
    if (periodValue === 'custom') {
      if (!customStartDate || !customEndDate) {
        throw new Error('Custom period requires both start_date and end_date');
      }
      
      // Validate date format
      if (!this._isValidDateFormat(customStartDate) || !this._isValidDateFormat(customEndDate)) {
        throw new Error('Invalid date format. Use YYYY-MM-DD format');
      }

      // Validate date range
      if (new Date(customStartDate) > new Date(customEndDate)) {
        throw new Error('Start date must be before or equal to end date');
      }

      return {
        start_date: customStartDate,
        end_date: customEndDate
      };
    }

    return {
      start_date: period.start_date,
      end_date: period.end_date
    };
  }

  /**
   * Apply date range filtering to asset data query
   * @param {Object} filters - Existing filters object
   * @param {string} dateField - Field to filter on ('created_at', 'last_update', etc.)
   * @param {string} startDate - Start date in YYYY-MM-DD format
   * @param {string} endDate - End date in YYYY-MM-DD format
   * @returns {Object} Updated filters object
   */
  static applyDateRangeFilter(filters, dateField, startDate, endDate) {
    if (!startDate || !endDate) {
      return filters;
    }

    // Create date range for the specified field
    const startDateTime = new Date(startDate + 'T00:00:00.000Z');
    const endDateTime = new Date(endDate + 'T23:59:59.999Z');

    filters[dateField] = {
      gte: startDateTime,
      lte: endDateTime
    };

    return filters;
  }

  /**
   * Validate export date configuration
   * @param {Object} config - Export configuration
   * @returns {Object} Validated and normalized config
   */
  static validateAndNormalizeDateConfig(config) {
    const { date_range } = config;
    
    if (!date_range) {
      // No date filtering requested
      return config;
    }

    const { period, field = 'created_at', custom_start_date, custom_end_date } = date_range;

    if (!period) {
      throw new Error('Date range period is required');
    }

    // Validate field and map frontend field names to database field names
    const fieldMapping = {
      'created_at': 'created_at',
      'updated_at': 'last_update', // Map frontend 'updated_at' to database 'last_update'
      'last_update': 'last_update',
      'deactivated_at': 'deactivated_at',
      'last_scan_date': 'last_scan_date'
    };
    
    const dbField = fieldMapping[field];
    if (!dbField) {
      throw new Error(`Invalid date field. Allowed fields: ${Object.keys(fieldMapping).join(', ')}`);
    }

    // Get date range for the period
    const dateRange = this.getDateRangeForPeriod(period, custom_start_date, custom_end_date);

    return {
      ...config,
      date_range: {
        ...date_range,
        ...dateRange,
        field: dbField // Use the mapped database field name
      }
    };
  }

  /**
   * Get a date that is X days ago from the given date
   * @param {Date} fromDate - The reference date
   * @param {number} daysAgo - Number of days to subtract
   * @returns {Date} The calculated date
   * @private
   */
  static _getDateDaysAgo(fromDate, daysAgo) {
    const date = new Date(fromDate);
    date.setDate(date.getDate() - daysAgo);
    return date;
  }

  /**
   * Validate if a string is in YYYY-MM-DD format
   * @param {string} dateString - The date string to validate
   * @returns {boolean} True if valid format
   * @private
   */
  static _isValidDateFormat(dateString) {
    const regex = /^\d{4}-\d{2}-\d{2}$/;
    if (!regex.test(dateString)) {
      return false;
    }

    // Check if it's a valid date
    const date = new Date(dateString);
    return date instanceof Date && !isNaN(date) && dateString === date.toISOString().split('T')[0];
  }

  /**
   * Format date range for display
   * @param {string} startDate - Start date in YYYY-MM-DD format
   * @param {string} endDate - End date in YYYY-MM-DD format
   * @returns {string} Formatted date range string
   */
  static formatDateRangeDisplay(startDate, endDate) {
    if (!startDate || !endDate) {
      return 'All time';
    }

    if (startDate === endDate) {
      return new Date(startDate).toLocaleDateString();
    }

    return `${new Date(startDate).toLocaleDateString()} - ${new Date(endDate).toLocaleDateString()}`;
  }
}

module.exports = ExportDateUtils;