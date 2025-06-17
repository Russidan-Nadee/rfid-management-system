-- =====================================================
-- RFID Asset Management System - Database Schema
-- =====================================================
-- Updated schema with Department table
-- =====================================================

USE rfidassetdb;

-- 1. Plant Master Table
CREATE TABLE `mst_plant` (
  `plant_code` VARCHAR(10) NOT NULL COMMENT 'Plant code - unique identifier',
  `description` VARCHAR(255) DEFAULT NULL COMMENT 'Plant description',
  PRIMARY KEY (`plant_code`),
  INDEX `idx_mst_plant_description` (`description`)
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Master table for plant information';

-- 2. Unit Master Table
CREATE TABLE `mst_unit` (
  `unit_code` VARCHAR(10) NOT NULL COMMENT 'Unit code - unique identifier',
  `name` VARCHAR(50) DEFAULT NULL COMMENT 'Unit name',
  PRIMARY KEY (`unit_code`),
  INDEX `idx_mst_unit_name` (`name`)
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Master table for unit of measurement';

-- 3. User Master Table
CREATE TABLE `mst_user` (
  `user_id` VARCHAR(20) NOT NULL COMMENT 'User ID - unique identifier',
  `username` VARCHAR(100) DEFAULT NULL COMMENT 'Username for login',
  `full_name` VARCHAR(255) DEFAULT NULL COMMENT 'Full name of user',
  `password` VARCHAR(255) NOT NULL DEFAULT '1234' COMMENT 'Hashed password',
  `role` ENUM('admin','manager','user','viewer') NOT NULL DEFAULT 'user' COMMENT 'User role',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record update timestamp',
  `last_login` DATETIME DEFAULT NULL COMMENT 'Last login timestamp',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_mst_user_username` (`username`),
  INDEX `idx_mst_user_full_name` (`full_name`),
  INDEX `idx_mst_user_role` (`role`)
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Master table for user information';

-- 4. Department Master Table
CREATE TABLE `mst_department` (
  `dept_code` VARCHAR(10) NOT NULL COMMENT 'Department code - unique identifier',
  `description` VARCHAR(255) DEFAULT NULL COMMENT 'Department description',
  `plant_code` VARCHAR(10) DEFAULT NULL COMMENT 'Plant code reference',
  PRIMARY KEY (`dept_code`),
  INDEX `idx_mst_department_plant_code` (`plant_code`),
  CONSTRAINT `fk_mst_department_plant_code` 
    FOREIGN KEY (`plant_code`) 
    REFERENCES `mst_plant` (`plant_code`) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Master table for department information';

-- 5. Location Master Table
CREATE TABLE `mst_location` (
  `location_code` VARCHAR(10) NOT NULL COMMENT 'Location code - unique identifier',
  `description` VARCHAR(255) DEFAULT NULL COMMENT 'Location description',
  `plant_code` VARCHAR(10) DEFAULT NULL COMMENT 'Plant code reference',
  PRIMARY KEY (`location_code`),
  INDEX `idx_mst_location_plant_code` (`plant_code`),
  CONSTRAINT `fk_mst_location_plant_code` 
    FOREIGN KEY (`plant_code`) 
    REFERENCES `mst_plant` (`plant_code`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Master table for location information';

-- 6. Asset Master Table
CREATE TABLE `asset_master` (
  `asset_no` VARCHAR(20) NOT NULL COMMENT 'Asset number - unique identifier',
  `description` VARCHAR(255) DEFAULT NULL COMMENT 'Asset description',
  `plant_code` VARCHAR(10) DEFAULT NULL COMMENT 'Plant code reference',
  `location_code` VARCHAR(10) DEFAULT NULL COMMENT 'Location code reference',
  `dept_code` VARCHAR(10) DEFAULT NULL COMMENT 'Department code reference',
  `serial_no` VARCHAR(50) DEFAULT NULL COMMENT 'Serial number - unique',
  `inventory_no` VARCHAR(50) DEFAULT NULL COMMENT 'Inventory number - unique',
  `quantity` DECIMAL(10,2) DEFAULT NULL COMMENT 'Asset quantity',
  `unit_code` VARCHAR(10) DEFAULT NULL COMMENT 'Unit of measurement',
  `status` CHAR(1) DEFAULT NULL COMMENT 'Asset status',
  `created_by` VARCHAR(20) DEFAULT NULL COMMENT 'User who created this asset',
  `created_at` DATETIME DEFAULT NULL COMMENT 'Creation timestamp',
  `deactivated_at` DATETIME DEFAULT NULL COMMENT 'Deactivation timestamp',
  PRIMARY KEY (`asset_no`),
  
  UNIQUE KEY `uk_asset_master_serial_no` (`serial_no`),
  UNIQUE KEY `uk_asset_master_inventory_no` (`inventory_no`),
  
  INDEX `idx_asset_master_plant_code` (`plant_code`),
  INDEX `idx_asset_master_location_code` (`location_code`),
  INDEX `idx_asset_master_dept_code` (`dept_code`),
  INDEX `idx_asset_master_unit_code` (`unit_code`),
  INDEX `idx_asset_master_status` (`status`),
  INDEX `idx_asset_master_created_by` (`created_by`),
  INDEX `idx_asset_master_created_at` (`created_at`),
  
  CONSTRAINT `fk_asset_master_plant_code` 
    FOREIGN KEY (`plant_code`) 
    REFERENCES `mst_plant` (`plant_code`) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE,
    
  CONSTRAINT `fk_asset_master_location_code` 
    FOREIGN KEY (`location_code`) 
    REFERENCES `mst_location` (`location_code`) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE,
    
  CONSTRAINT `fk_asset_master_dept_code` 
    FOREIGN KEY (`dept_code`) 
    REFERENCES `mst_department` (`dept_code`) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE,
    
  CONSTRAINT `fk_asset_master_unit_code` 
    FOREIGN KEY (`unit_code`) 
    REFERENCES `mst_unit` (`unit_code`) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE,
    
  CONSTRAINT `fk_asset_master_created_by` 
    FOREIGN KEY (`created_by`) 
    REFERENCES `mst_user` (`user_id`) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Asset master table';

-- 7. Asset Scan Log Table
CREATE TABLE `asset_scan_log` (
  `scan_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Scan ID - auto increment',
  `asset_no` VARCHAR(20) DEFAULT NULL COMMENT 'Asset number reference',
  `scanned_by` VARCHAR(20) DEFAULT NULL COMMENT 'User who scanned the asset',
  `location_code` VARCHAR(10) DEFAULT NULL COMMENT 'Location where asset was scanned',
  `ip_address` VARCHAR(45) DEFAULT NULL COMMENT 'IP address of scanning device',
  `user_agent` TEXT DEFAULT NULL COMMENT 'User agent of scanning device',
  `scanned_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Scan timestamp',
  PRIMARY KEY (`scan_id`),
  
  INDEX `idx_asset_scan_log_asset_no` (`asset_no`),
  INDEX `idx_asset_scan_log_scanned_by` (`scanned_by`),
  INDEX `idx_asset_scan_log_location_code` (`location_code`),
  
  CONSTRAINT `fk_asset_scan_log_asset_no` 
    FOREIGN KEY (`asset_no`) 
    REFERENCES `asset_master` (`asset_no`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION,
    
  CONSTRAINT `fk_asset_scan_log_scanned_by` 
    FOREIGN KEY (`scanned_by`) 
    REFERENCES `mst_user` (`user_id`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION,
    
  CONSTRAINT `fk_asset_scan_log_location_code` 
    FOREIGN KEY (`location_code`) 
    REFERENCES `mst_location` (`location_code`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Asset scan log table';

-- 8. Asset Status History Table
CREATE TABLE `asset_status_history` (
  `history_id` INT NOT NULL AUTO_INCREMENT COMMENT 'History ID - auto increment',
  `asset_no` VARCHAR(20) DEFAULT NULL COMMENT 'Asset number reference',
  `old_status` VARCHAR(50) DEFAULT NULL COMMENT 'Previous status',
  `new_status` VARCHAR(50) DEFAULT NULL COMMENT 'New status',
  `changed_at` DATETIME DEFAULT NULL COMMENT 'Status change timestamp',
  `changed_by` VARCHAR(20) DEFAULT NULL COMMENT 'User who changed the status',
  `remarks` TEXT DEFAULT NULL COMMENT 'Change remarks',
  PRIMARY KEY (`history_id`),
  
  INDEX `idx_asset_status_history_asset_no` (`asset_no`),
  INDEX `idx_asset_status_history_changed_by` (`changed_by`),
  
  CONSTRAINT `fk_asset_status_history_asset_no` 
    FOREIGN KEY (`asset_no`) 
    REFERENCES `asset_master` (`asset_no`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION,
    
  CONSTRAINT `fk_asset_status_history_changed_by` 
    FOREIGN KEY (`changed_by`) 
    REFERENCES `mst_user` (`user_id`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Asset status change history table';

-- 9. Export History Table
CREATE TABLE `export_history` (
  `export_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Export ID - auto increment',
  `user_id` VARCHAR(20) NOT NULL COMMENT 'User who requested the export',
  `export_type` ENUM('assets','scan_logs','status_history') NOT NULL COMMENT 'Type of export',
  `status` CHAR(1) NOT NULL DEFAULT 'P' COMMENT 'Export status: P=Pending, C=Completed, F=Failed',
  `export_config` JSON NOT NULL COMMENT 'Export configuration in JSON format',
  `file_path` VARCHAR(500) DEFAULT NULL COMMENT 'Path to exported file',
  `file_size` BIGINT DEFAULT NULL COMMENT 'Size of exported file in bytes',
  `total_records` INT DEFAULT NULL COMMENT 'Total number of records exported',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Export request timestamp',
  `expires_at` DATETIME DEFAULT NULL COMMENT 'Export file expiration timestamp',
  `error_message` TEXT DEFAULT NULL COMMENT 'Error message if export failed',
  PRIMARY KEY (`export_id`),
  
  INDEX `idx_export_history_user_id` (`user_id`),
  INDEX `idx_export_history_created_at` (`created_at`),
  INDEX `idx_export_history_expires_at` (`expires_at`),
  
  CONSTRAINT `fk_export_history_user_id` 
    FOREIGN KEY (`user_id`) 
    REFERENCES `mst_user` (`user_id`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='Export history and status tracking table';

-- 10. User Login Log Table
CREATE TABLE `user_login_log` (
  `log_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Log ID - auto increment',
  `user_id` VARCHAR(20) DEFAULT NULL COMMENT 'User ID reference',
  `username` VARCHAR(100) DEFAULT NULL COMMENT 'Username used for login attempt',
  `event_type` ENUM('login','logout','failed_login','password_change') DEFAULT NULL COMMENT 'Type of login event',
  `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Event timestamp',
  `ip_address` VARCHAR(50) DEFAULT NULL COMMENT 'IP address of the client',
  `user_agent` TEXT DEFAULT NULL COMMENT 'User agent string',
  `session_id` VARCHAR(255) DEFAULT NULL COMMENT 'Session identifier',
  `success` TINYINT(1) DEFAULT 1 COMMENT 'Success flag (1=success, 0=failure)',
  PRIMARY KEY (`log_id`),
  
  INDEX `idx_user_login_log_user_id` (`user_id`),
  
  CONSTRAINT `fk_user_login_log_user_id` 
    FOREIGN KEY (`user_id`) 
    REFERENCES `mst_user` (`user_id`) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION
) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci 
COMMENT='User login activity log table';