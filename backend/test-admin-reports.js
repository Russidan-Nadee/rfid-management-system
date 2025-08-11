const NotificationService = require('./src/features/notification/notificationService');
const NotificationModel = require('./src/features/notification/notificationModel');

async function testAdminReports() {
  console.log('🧪 Testing Admin Reports Functionality...\n');

  try {
    // Test 1: Check if we can fetch all notifications with admin role
    console.log('📋 Test 1: Testing admin role access...');
    const adminFilters = {
      page: 1,
      limit: 100,
      sortBy: 'created_at',
      sortOrder: 'desc'
    };

    try {
      const adminResult = await NotificationService.getNotifications(adminFilters, 'admin');
      console.log('✅ Admin role access: SUCCESS');
      console.log(`📊 Found ${adminResult.notifications?.length || 0} notifications for admin`);
      console.log(`📈 Total count: ${adminResult.pagination?.total || 0}\n`);

      // Show sample of notifications
      if (adminResult.notifications && adminResult.notifications.length > 0) {
        console.log('📝 Sample notifications:');
        adminResult.notifications.slice(0, 3).forEach((notification, index) => {
          console.log(`   ${index + 1}. ID: ${notification.notification_id}, Subject: "${notification.subject}", Reporter: ${notification.reporter?.full_name || 'Unknown'}`);
        });
        console.log('');
      }
    } catch (error) {
      console.log('❌ Admin role access: FAILED');
      console.log(`   Error: ${error.message}\n`);
    }

    // Test 2: Check if regular user is blocked
    console.log('📋 Test 2: Testing non-admin role access (should be blocked)...');
    try {
      await NotificationService.getNotifications(adminFilters, 'viewer');
      console.log('❌ Non-admin access: SHOULD BE BLOCKED BUT WASN\'T\n');
    } catch (error) {
      console.log('✅ Non-admin access: PROPERLY BLOCKED');
      console.log(`   Error: ${error.message}\n`);
    }

    // Test 3: Check direct database access
    console.log('📋 Test 3: Testing direct database access...');
    try {
      const directResult = await NotificationModel.getAllNotifications(adminFilters);
      console.log('✅ Direct database access: SUCCESS');
      console.log(`📊 Found ${directResult.notifications?.length || 0} notifications directly from DB`);
      console.log(`📈 Total count: ${directResult.pagination?.total || 0}\n`);
    } catch (error) {
      console.log('❌ Direct database access: FAILED');
      console.log(`   Error: ${error.message}\n`);
    }

    // Test 4: Check if there are reports in the database at all
    console.log('📋 Test 4: Testing if any reports exist in database...');
    try {
      const allReports = await NotificationModel.getAllNotifications({ page: 1, limit: 1000 });
      console.log(`📊 Total reports in database: ${allReports.notifications?.length || 0}`);
      
      if (allReports.notifications && allReports.notifications.length > 0) {
        console.log('✅ Reports found in database');
        
        // Show breakdown by user
        const reportsByUser = {};
        allReports.notifications.forEach(report => {
          const reporter = report.reporter?.full_name || report.reported_by || 'Unknown';
          reportsByUser[reporter] = (reportsByUser[reporter] || 0) + 1;
        });
        
        console.log('👥 Reports by user:');
        Object.entries(reportsByUser).forEach(([user, count]) => {
          console.log(`   ${user}: ${count} reports`);
        });
        
        // Show breakdown by status
        const reportsByStatus = {};
        allReports.notifications.forEach(report => {
          reportsByStatus[report.status] = (reportsByStatus[report.status] || 0) + 1;
        });
        
        console.log('\n📈 Reports by status:');
        Object.entries(reportsByStatus).forEach(([status, count]) => {
          console.log(`   ${status}: ${count} reports`);
        });
      } else {
        console.log('❌ No reports found in database - this might be why admin sees nothing!');
      }
    } catch (error) {
      console.log('❌ Database check failed');
      console.log(`   Error: ${error.message}`);
    }

  } catch (error) {
    console.log('💥 Test suite failed:', error.message);
  }
  
  console.log('\n🧪 Test completed!');
  process.exit(0);
}

// Run the test
testAdminReports();