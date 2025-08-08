-- Migration: Add Problem Notifications System
-- Created: 2025-01-08
-- Description: Creates tables and enums for problem notification system

-- Create enums for problem notifications
-- MySQL doesn't have proper enum support, so we'll use VARCHAR with CHECK constraints

-- Create problem_notification table
CREATE TABLE IF NOT EXISTS `problem_notification` (
  `notification_id` INT NOT NULL AUTO_INCREMENT,
  `asset_no` VARCHAR(20) NULL,
  `reported_by` VARCHAR(20) NOT NULL,
  `problem_type` ENUM('asset_damage', 'asset_missing', 'location_issue', 'data_error', 'urgent_issue', 'other') NOT NULL,
  `priority` ENUM('low', 'normal', 'high', 'urgent') NOT NULL DEFAULT 'normal',
  `subject` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `status` ENUM('pending', 'acknowledged', 'in_progress', 'resolved', 'cancelled') NOT NULL DEFAULT 'pending',
  `acknowledged_by` VARCHAR(20) NULL,
  `acknowledged_at` DATETIME(0) NULL,
  `resolved_by` VARCHAR(20) NULL,
  `resolved_at` DATETIME(0) NULL,
  `resolution_note` TEXT NULL,
  `created_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`notification_id`),
  
  -- Foreign Keys
  CONSTRAINT `fk_problem_notification_asset` 
    FOREIGN KEY (`asset_no`) REFERENCES `asset_master` (`asset_no`) 
    ON DELETE SET NULL ON UPDATE CASCADE,
    
  CONSTRAINT `fk_problem_notification_reporter` 
    FOREIGN KEY (`reported_by`) REFERENCES `mst_user` (`user_id`) 
    ON DELETE RESTRICT ON UPDATE CASCADE,
    
  CONSTRAINT `fk_problem_notification_acknowledger` 
    FOREIGN KEY (`acknowledged_by`) REFERENCES `mst_user` (`user_id`) 
    ON DELETE SET NULL ON UPDATE CASCADE,
    
  CONSTRAINT `fk_problem_notification_resolver` 
    FOREIGN KEY (`resolved_by`) REFERENCES `mst_user` (`user_id`) 
    ON DELETE SET NULL ON UPDATE CASCADE,
  
  -- Indexes for performance
  INDEX `idx_problem_notification_asset_no` (`asset_no`),
  INDEX `idx_problem_notification_reported_by` (`reported_by`),
  INDEX `idx_problem_notification_status` (`status`),
  INDEX `idx_problem_notification_priority` (`priority`),
  INDEX `idx_problem_notification_created_at` (`created_at`),
  INDEX `idx_problem_notification_type` (`problem_type`)
);

-- Insert some sample data for testing (optional)
-- INSERT INTO `problem_notification` (
--   `asset_no`, 
--   `reported_by`, 
--   `problem_type`, 
--   `priority`, 
--   `subject`, 
--   `description`
-- ) VALUES (
--   NULL,
--   'admin',
--   'data_error',
--   'normal',
--   'Test Notification',
--   'This is a test problem notification to verify the system is working correctly.'
-- );

-- Verify the table was created
DESCRIBE `problem_notification`;