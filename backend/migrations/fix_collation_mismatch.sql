-- Fix collation mismatch issue
-- Convert all relevant tables to use utf8mb4_unicode_ci collation consistently

-- Set database collation
ALTER DATABASE `rfid_asset_management` COLLATE utf8mb4_unicode_ci;

-- Fix asset_master table collations
ALTER TABLE `asset_master` 
  MODIFY COLUMN `asset_no` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  MODIFY COLUMN `plant_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `location_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `dept_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `category_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `brand_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `unit_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `epc_code` VARCHAR(50) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `description` VARCHAR(255) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `created_by` VARCHAR(20) COLLATE utf8mb4_unicode_ci;

-- Fix problem_notification table collations
ALTER TABLE `problem_notification` 
  MODIFY COLUMN `asset_no` VARCHAR(20) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `reported_by` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  MODIFY COLUMN `acknowledged_by` VARCHAR(20) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `resolved_by` VARCHAR(20) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `subject` VARCHAR(255) COLLATE utf8mb4_unicode_ci NOT NULL;

-- Fix master data tables collations
ALTER TABLE `mst_plant` 
  MODIFY COLUMN `plant_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  MODIFY COLUMN `description` VARCHAR(255) COLLATE utf8mb4_unicode_ci;

ALTER TABLE `mst_location` 
  MODIFY COLUMN `location_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  MODIFY COLUMN `plant_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `description` VARCHAR(255) COLLATE utf8mb4_unicode_ci;

ALTER TABLE `mst_department` 
  MODIFY COLUMN `dept_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  MODIFY COLUMN `plant_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  MODIFY COLUMN `description` VARCHAR(255) COLLATE utf8mb4_unicode_ci;

ALTER TABLE `mst_user` 
  MODIFY COLUMN `user_id` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  MODIFY COLUMN `full_name` VARCHAR(255) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `employee_id` VARCHAR(20) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `department` VARCHAR(100) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `position` VARCHAR(100) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `company_role` VARCHAR(50) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `email` VARCHAR(255) COLLATE utf8mb4_unicode_ci;

-- Fix other master tables
ALTER TABLE `mst_category` 
  MODIFY COLUMN `category_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  MODIFY COLUMN `name` VARCHAR(50) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `description` VARCHAR(255) COLLATE utf8mb4_unicode_ci;

ALTER TABLE `mst_brand` 
  MODIFY COLUMN `brand_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  MODIFY COLUMN `name` VARCHAR(50) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `description` VARCHAR(255) COLLATE utf8mb4_unicode_ci;

ALTER TABLE `mst_unit` 
  MODIFY COLUMN `unit_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  MODIFY COLUMN `name` VARCHAR(50) COLLATE utf8mb4_unicode_ci;

-- Fix status tables if they exist
ALTER TABLE `asset_status_history` 
  MODIFY COLUMN `asset_no` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  MODIFY COLUMN `changed_by` VARCHAR(20) COLLATE utf8mb4_unicode_ci;

ALTER TABLE `asset_scan_log` 
  MODIFY COLUMN `asset_no` VARCHAR(20) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `location_code` VARCHAR(10) COLLATE utf8mb4_unicode_ci,
  MODIFY COLUMN `scanned_by` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL;

-- Set table collation for all affected tables
ALTER TABLE `asset_master` COLLATE utf8mb4_unicode_ci;
ALTER TABLE `problem_notification` COLLATE utf8mb4_unicode_ci;
ALTER TABLE `mst_plant` COLLATE utf8mb4_unicode_ci;
ALTER TABLE `mst_location` COLLATE utf8mb4_unicode_ci;
ALTER TABLE `mst_department` COLLATE utf8mb4_unicode_ci;
ALTER TABLE `mst_user` COLLATE utf8mb4_unicode_ci;
ALTER TABLE `mst_category` COLLATE utf8mb4_unicode_ci;
ALTER TABLE `mst_brand` COLLATE utf8mb4_unicode_ci;
ALTER TABLE `mst_unit` COLLATE utf8mb4_unicode_ci;
ALTER TABLE `asset_status_history` COLLATE utf8mb4_unicode_ci;
ALTER TABLE `asset_scan_log` COLLATE utf8mb4_unicode_ci;

-- Verify collation fix
SELECT TABLE_NAME, TABLE_COLLATION 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'rfid_asset_management' 
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;