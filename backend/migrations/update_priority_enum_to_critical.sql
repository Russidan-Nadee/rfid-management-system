-- Migration: Update Priority ENUM to use 'critical' instead of 'urgent'
-- Created: 2025-01-11
-- Description: Updates the problem_notification priority ENUM to replace 'urgent' with 'critical'

-- First, update any existing records that have 'urgent' priority to 'critical'
UPDATE `problem_notification` 
SET `priority` = 'critical' 
WHERE `priority` = 'urgent';

-- Drop the existing ENUM constraint and recreate with 'critical'
ALTER TABLE `problem_notification` 
MODIFY COLUMN `priority` ENUM('low', 'normal', 'high', 'critical') NOT NULL DEFAULT 'normal';

-- Verify the change
DESCRIBE `problem_notification`;