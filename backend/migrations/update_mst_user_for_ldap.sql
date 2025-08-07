-- Manual migration for mst_user table to support LDAP authentication
-- This script updates only the mst_user table structure

-- Step 1: Add new columns for Employee Information System data
ALTER TABLE mst_user 
ADD COLUMN employee_id VARCHAR(20) NULL UNIQUE,
ADD COLUMN department VARCHAR(100) NULL,
ADD COLUMN position VARCHAR(100) NULL,
ADD COLUMN company_role VARCHAR(50) NULL,
ADD COLUMN email VARCHAR(255) NULL,
ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

-- Step 2: Update the role enum to include new system roles
-- Note: MySQL doesn't support ALTER ENUM directly, so we need to modify the column
ALTER TABLE mst_user MODIFY COLUMN role ENUM('admin', 'manager', 'staff', 'viewer') DEFAULT 'viewer';

-- Step 3: Remove password column (since authentication is via LDAP)
ALTER TABLE mst_user DROP COLUMN password;

-- Step 4: Drop username unique constraint and make it nullable (we might want to remove it later)
ALTER TABLE mst_user DROP INDEX uk_mst_user_username;
ALTER TABLE mst_user MODIFY COLUMN username VARCHAR(100) NULL;

-- Step 5: Add new indexes for better performance
CREATE INDEX idx_mst_user_employee_id ON mst_user(employee_id);
CREATE INDEX idx_mst_user_active ON mst_user(is_active);

-- Step 6: Remove old username index and add it back without unique constraint
DROP INDEX idx_mst_user_username ON mst_user;
CREATE INDEX idx_mst_user_username ON mst_user(username);

-- Display the updated table structure
DESCRIBE mst_user;