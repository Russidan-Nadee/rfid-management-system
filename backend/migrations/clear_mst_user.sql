-- Clear existing data from mst_user table
-- This removes all old user data so we can start fresh with LDAP authentication

-- Delete all existing users
DELETE FROM mst_user;

-- Reset auto-increment if there was one (not applicable for this table since user_id is manually set)
-- ALTER TABLE mst_user AUTO_INCREMENT = 1;

-- Optional: Show the table is now empty
SELECT COUNT(*) as remaining_users FROM mst_user;