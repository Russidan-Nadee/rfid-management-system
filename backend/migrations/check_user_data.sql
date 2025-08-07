-- Check current user data and dependencies
SELECT 'Current users:' as info;
SELECT user_id, full_name, role FROM mst_user;

SELECT 'Assets referencing users:' as info;  
SELECT DISTINCT created_by FROM asset_master WHERE created_by IS NOT NULL;

SELECT 'Scan logs referencing users:' as info;
SELECT DISTINCT scanned_by FROM asset_scan_log WHERE scanned_by IS NOT NULL;