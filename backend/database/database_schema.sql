-- =====================================================
-- RFID Asset Management System - Updated Database Schema
-- =====================================================
-- Version: 2.0 (Based on Actual Production Database)
-- Updated: 2024-12-24
-- Database: rfidassetdetdb
-- =====================================================

USE rfidassetdetdb;

-- =====================================================
-- 1. MASTER TABLES
-- =====================================================

-- 1.1 Plant Master Table
CREATE TABLE `mst_plant` (
  `plant_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Plant code - unique identifier',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Plant description',
  PRIMARY KEY (`plant_code`),
  KEY `idx_mst_plant_description` (`description`)
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Master table for plant information';

-- 1.2 Unit Master Table
CREATE TABLE `mst_unit` (
  `unit_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unit code - unique identifier',
  `name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Unit name',
  PRIMARY KEY (`unit_code`),
  KEY `idx_mst_unit_name` (`name`)
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Master table for unit of measurement';

-- 1.3 User Master Table
CREATE TABLE `mst_user` (
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'User ID - unique identifier',
  `username` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Username for login',
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Full name of user',
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1234' COMMENT 'Hashed password',
  `role` enum('admin','manager','user','viewer') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user' COMMENT 'User role',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record update timestamp',
  `last_login` datetime DEFAULT NULL COMMENT 'Last login timestamp',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `uk_mst_user_username` (`username`),
  KEY `idx_mst_user_username` (`username`),
  KEY `idx_mst_user_role` (`role`),
  KEY `idx_mst_user_full_name` (`full_name`)
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Master table for user information';

-- 1.4 Department Master Table
CREATE TABLE `mst_department` (
  `dept_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Department code - unique identifier',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Department description',
  `plant_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Plant code reference',
  PRIMARY KEY (`dept_code`),
  KEY `idx_mst_department_plant_code` (`plant_code`),
  CONSTRAINT `fk_mst_department_plant_code` 
    FOREIGN KEY (`plant_code`) 
    REFERENCES `mst_plant` (`plant_code`) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Master table for department information';

-- 1.5 Location Master Table
CREATE TABLE `mst_location` (
  `location_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Location code - unique identifier',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Location description',
  `plant_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Plant code reference',
  PRIMARY KEY (`location_code`),
  KEY `plant_code` (`plant_code`),
  KEY `idx_mst_location_plant_code` (`plant_code`),
  CONSTRAINT `mst_location_ibfk_1` 
    FOREIGN KEY (`plant_code`) 
    REFERENCES `mst_plant` (`plant_code`) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Master table for location information';

-- =====================================================
-- 2. ASSET TABLES
-- =====================================================

-- 2.1 Asset Master Table
CREATE TABLE `asset_master` (
  `asset_no` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Asset number - unique identifier',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Asset description',
  `plant_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Plant code reference',
  `location_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Location code reference',
  `dept_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Department code reference',
  `serial_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Serial number - unique',
  `inventory_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Inventory number - unique',
  `quantity` decimal(10,2) DEFAULT NULL COMMENT 'Asset quantity',
  `unit_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Unit of measurement',
  `status` enum('A','C','I') COLLATE utf8mb4_unicode_ci DEFAULT 'C' COMMENT 'A = Active, C = Created, I = Inactive',
  `created_by` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who created this asset',
  `created_at` datetime DEFAULT NULL COMMENT 'Creation timestamp',
  `deactivated_at` datetime DEFAULT NULL COMMENT 'Deactivation timestamp',
  PRIMARY KEY (`asset_no`),
  
  UNIQUE KEY `serial_no` (`serial_no`),
  UNIQUE KEY `inventory_no` (`inventory_no`),
  
  KEY `fk_asset_master_unit_code` (`unit_code`),
  KEY `idx_asset_master_plant_code` (`plant_code`),
  KEY `idx_asset_master_location_code` (`location_code`),
  KEY `idx_asset_master_dept_code` (`dept_code`),
  KEY `idx_asset_master_status` (`status`),
  KEY `idx_asset_master_created_by` (`created_by`),
  KEY `idx_asset_master_created_at` (`created_at`),
  
  CONSTRAINT `asset_master_ibfk_1` 
    FOREIGN KEY (`plant_code`) 
    REFERENCES `mst_plant` (`plant_code`) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE,
    
  CONSTRAINT `asset_master_ibfk_2` 
    FOREIGN KEY (`location_code`) 
    REFERENCES `mst_location` (`location_code`) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE,
    
  CONSTRAINT `asset_master_ibfk_3` 
    FOREIGN KEY (`unit_code`) 
    REFERENCES `mst_unit` (`unit_code`) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE,
    
  CONSTRAINT `fk_asset_master_created_by` 
    FOREIGN KEY (`created_by`) 
    REFERENCES `mst_user` (`user_id`) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE,
    
  CONSTRAINT `fk_asset_master_dept_code` 
    FOREIGN KEY (`dept_code`) 
    REFERENCES `mst_department` (`dept_code`) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Asset master table';

-- 2.2 Asset Scan Log Table
CREATE TABLE `asset_scan_log` (
  `scan_id` int NOT NULL AUTO_INCREMENT COMMENT 'Scan ID - auto increment',
  `asset_no` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Asset number reference',
  `scanned_by` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who scanned the asset',
  `location_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Location where asset was scanned',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IP address of scanning device',
  `user_agent` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User agent of scanning device',
  `scanned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Scan timestamp',
  PRIMARY KEY (`scan_id`),
  
  KEY `fk_scan_user` (`scanned_by`),
  KEY `fk_scan_asset` (`asset_no`),
  KEY `fk_scan_location` (`location_code`),
  KEY `idx_asset_scan_log_scanned_at` (`scanned_at`),
  
  CONSTRAINT `fk_scan_asset` 
    FOREIGN KEY (`asset_no`) 
    REFERENCES `asset_master` (`asset_no`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION,
    
  CONSTRAINT `fk_scan_location` 
    FOREIGN KEY (`location_code`) 
    REFERENCES `mst_location` (`location_code`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION,
    
  CONSTRAINT `fk_scan_user` 
    FOREIGN KEY (`scanned_by`) 
    REFERENCES `mst_user` (`user_id`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION
) ENGINE=InnoDB 
AUTO_INCREMENT=2757 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Asset scan log table';

-- 2.3 Asset Status History Table
CREATE TABLE `asset_status_history` (
  `history_id` int NOT NULL AUTO_INCREMENT COMMENT 'History ID - auto increment',
  `asset_no` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Asset number reference',
  `old_status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Previous status',
  `new_status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'New status',
  `changed_at` datetime DEFAULT NULL COMMENT 'Status change timestamp',
  `changed_by` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who changed the status',
  `remarks` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Change remarks',
  PRIMARY KEY (`history_id`),
  
  KEY `asset_no` (`asset_no`),
  KEY `changed_by` (`changed_by`),
  KEY `idx_asset_status_history_changed_at` (`changed_at`),
  
  CONSTRAINT `asset_status_history_ibfk_1` 
    FOREIGN KEY (`asset_no`) 
    REFERENCES `asset_master` (`asset_no`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION,
    
  CONSTRAINT `asset_status_history_ibfk_2` 
    FOREIGN KEY (`changed_by`) 
    REFERENCES `mst_user` (`user_id`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION
) ENGINE=InnoDB 
AUTO_INCREMENT=152 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Asset status change history table';

-- =====================================================
-- 3. SYSTEM TABLES
-- =====================================================

-- 3.1 Export History Table
CREATE TABLE `export_history` (
  `export_id` int NOT NULL AUTO_INCREMENT COMMENT 'Export ID - auto increment',
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'User who requested the export',
  `export_type` enum('assets','scan_logs','status_history') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Type of export',
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'P' COMMENT 'Export status: P=Pending, C=Completed, F=Failed',
  `export_config` json NOT NULL COMMENT 'Export configuration in JSON format',
  `file_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Path to exported file',
  `file_size` bigint DEFAULT NULL COMMENT 'Size of exported file in bytes',
  `total_records` int DEFAULT NULL COMMENT 'Total number of records exported',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Export request timestamp',
  `expires_at` datetime DEFAULT NULL COMMENT 'Export file expiration timestamp',
  `error_message` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Error message if export failed',
  PRIMARY KEY (`export_id`),
  
  KEY `idx_user_status` (`user_id`,`status`,`created_at`),
  KEY `idx_cleanup` (`expires_at`,`status`),
  KEY `idx_created_at` (`created_at`),
  
  CONSTRAINT `fk_export_user` 
    FOREIGN KEY (`user_id`) 
    REFERENCES `mst_user` (`user_id`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION
) ENGINE=InnoDB 
AUTO_INCREMENT=86 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Export history and status tracking table';

-- 3.2 User Login Log Table
CREATE TABLE `user_login_log` (
  `log_id` int NOT NULL AUTO_INCREMENT COMMENT 'Log ID - auto increment',
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User ID reference',
  `username` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Username used for login attempt',
  `event_type` enum('login','logout','failed_login','password_change') COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Type of login event',
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Event timestamp',
  `ip_address` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IP address of the client',
  `user_agent` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User agent string',
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Session identifier',
  `success` tinyint(1) DEFAULT '1' COMMENT 'Success flag (1=success, 0=failure)',
  PRIMARY KEY (`log_id`),
  
  KEY `fk_user_login_log_user` (`user_id`),
  KEY `idx_user_login_log_timestamp` (`timestamp`),
  KEY `idx_user_login_log_event_type` (`event_type`),
  
  CONSTRAINT `fk_user_login_log_user` 
    FOREIGN KEY (`user_id`) 
    REFERENCES `mst_user` (`user_id`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION
) ENGINE=InnoDB 
AUTO_INCREMENT=71 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='User login activity log table';

-- =====================================================
-- 4. PERFORMANCE INDEXES (Based on Current Structure)
-- =====================================================

-- Asset search optimization (already exist in current schema)
-- Key: idx_asset_master_plant_code
-- Key: idx_asset_master_location_code  
-- Key: idx_asset_master_status
-- Key: idx_asset_master_created_by
-- Key: idx_asset_master_created_at

-- User management indexes (already exist)
-- Key: idx_mst_user_username
-- Key: idx_mst_user_role
-- Key: idx_mst_user_full_name

-- Export system indexes (already optimized)
-- Key: idx_user_status (user_id, status, created_at)
-- Key: idx_cleanup (expires_at, status)
-- Key: idx_created_at

-- Scan log performance (already indexed)
-- Key: fk_scan_user, fk_scan_asset, fk_scan_location

-- =====================================================
-- 5. CURRENT DATABASE ANALYSIS
-- =====================================================

/*
EXISTING TABLES ANALYSIS (10 Tables Total):

✅ MASTER TABLES (5):
1. mst_plant         - Plant information
2. mst_unit          - Unit of measurement  
3. mst_user          - User accounts with roles
4. mst_department    - Department information
5. mst_location      - Location information

✅ ASSET TABLES (3):
6. asset_master      - Main asset records
7. asset_scan_log    - RFID scan history (2757+ records)
8. asset_status_history - Asset status changes (152+ records)

✅ SYSTEM TABLES (2):
9. export_history    - Export job tracking (86+ records)
10. user_login_log   - User activity logs (71+ records)

CURRENT STATUS: ✅ PRODUCTION READY
- All foreign key relationships properly defined
- Comprehensive indexing strategy implemented
- Full Unicode support (utf8mb4_unicode_ci)
- Audit trail complete with scan logs and status history
- Export system with JSON configuration support
- User activity tracking and authentication logs
- Department-based asset organization
*/