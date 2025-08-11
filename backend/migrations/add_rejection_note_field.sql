-- Migration: Add rejection_note field to problem_notification table
-- Date: 2025-08-11
-- Purpose: Add a field to store rejection reason when reports are cancelled

USE asset_management;

-- Check if the column already exists before adding it
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'asset_management'
    AND TABLE_NAME = 'problem_notification'
    AND COLUMN_NAME = 'rejection_note'
);

-- Add rejection_note column if it doesn't exist
SET @sql = IF(@column_exists = 0,
    'ALTER TABLE problem_notification ADD COLUMN rejection_note TEXT NULL COMMENT "Reason for rejection when status is cancelled"',
    'SELECT "Column rejection_note already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Verify the column was added
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'asset_management'
AND TABLE_NAME = 'problem_notification'
AND COLUMN_NAME = 'rejection_note';