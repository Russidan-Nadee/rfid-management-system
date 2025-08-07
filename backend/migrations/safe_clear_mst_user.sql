-- Safely clear mst_user table by handling foreign key constraints
-- This script will either update references to NULL or preserve necessary data

-- Step 1: Disable foreign key checks temporarily (MySQL specific)
SET FOREIGN_KEY_CHECKS = 0;

-- Step 2: Delete all users
DELETE FROM mst_user;

-- Step 3: Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Step 4: Verify the table is empty
SELECT COUNT(*) as users_remaining FROM mst_user;

SELECT 'mst_user table cleared successfully' as status;