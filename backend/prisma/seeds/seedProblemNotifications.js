const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Problem notification seed data (30 records with various types, priorities, and statuses)
const problemNotificationData = [
  // PENDING status (5 records)
  {
    asset_no: 'C57385',
    reported_by: 'USR_000003',
    problem_type: 'asset_damage',
    priority: 'high',
    subject: 'Monitor screen cracked',
    description: 'The monitor screen has a crack in the upper left corner. Needs immediate replacement.',
    status: 'pending'
  },
  {
    asset_no: 'C58422',
    reported_by: 'USR_000004',
    problem_type: 'location_issue',
    priority: 'normal',
    subject: 'Asset not in designated location',
    description: 'Found this asset in wrong department. Should be in QC but found in warehouse.',
    status: 'pending'
  },
  {
    asset_no: 'C58423',
    reported_by: 'USR_000005',
    problem_type: 'data_error',
    priority: 'low',
    subject: 'Incorrect asset description',
    description: 'Multiple assets have outdated descriptions in the system.',
    status: 'pending'
  },
  {
    asset_no: 'C58430',
    reported_by: 'USR_000006',
    problem_type: 'asset_missing',
    priority: 'critical',
    subject: 'Critical equipment missing',
    description: 'Production equipment cannot be found. Last seen in maintenance area.',
    status: 'pending'
  },
  {
    asset_no: 'C59457',
    reported_by: 'USR_000007',
    problem_type: 'urgent_issue',
    priority: 'critical',
    subject: 'Server overheating',
    description: 'Server temperature reaching critical levels. Immediate attention required.',
    status: 'pending'
  },

  // ACKNOWLEDGED status (5 records)
  {
    asset_no: 'C60490',
    reported_by: 'USR_000003',
    problem_type: 'asset_damage',
    priority: 'normal',
    subject: 'Keyboard not working properly',
    description: 'Several keys on the keyboard are not responsive.',
    status: 'acknowledged',
    acknowledged_by: 'USR_000001',
    acknowledged_at: new Date('2025-01-15T09:30:00')
  },
  {
    asset_no: 'C60511',
    reported_by: 'USR_000004',
    problem_type: 'location_issue',
    priority: 'low',
    subject: 'Asset location mismatch',
    description: 'Asset registered to Building A but physically in Building B.',
    status: 'acknowledged',
    acknowledged_by: 'USR_000002',
    acknowledged_at: new Date('2025-01-16T10:15:00')
  },
  {
    asset_no: 'C60517',
    reported_by: 'USR_000005',
    problem_type: 'other',
    priority: 'normal',
    subject: 'RFID tag not scanning',
    description: 'RFID tag appears to be damaged or deactivated.',
    status: 'acknowledged',
    acknowledged_by: 'USR_000001',
    acknowledged_at: new Date('2025-01-17T14:20:00')
  },
  {
    asset_no: 'C60512',
    reported_by: 'USR_000008',
    problem_type: 'data_error',
    priority: 'high',
    subject: 'Duplicate asset records',
    description: 'Found duplicate entries for several assets in the database.',
    status: 'acknowledged',
    acknowledged_by: 'USR_000003',
    acknowledged_at: new Date('2025-01-18T11:00:00')
  },
  {
    asset_no: 'C61531',
    reported_by: 'USR_000006',
    problem_type: 'asset_damage',
    priority: 'high',
    subject: 'Printer paper jam and mechanical issue',
    description: 'Printer has persistent paper jam issue. Mechanical parts may need replacement.',
    status: 'acknowledged',
    acknowledged_by: 'USR_000002',
    acknowledged_at: new Date('2025-01-19T08:45:00')
  },

  // IN_PROGRESS status (8 records)
  {
    asset_no: 'C61534',
    reported_by: 'USR_000003',
    problem_type: 'asset_damage',
    priority: 'critical',
    subject: 'Power supply failure',
    description: 'Computer power supply unit failed. System won\'t turn on.',
    status: 'in_progress',
    acknowledged_by: 'USR_000001',
    acknowledged_at: new Date('2025-01-10T09:00:00')
  },
  {
    asset_no: 'C61555',
    reported_by: 'USR_000004',
    problem_type: 'asset_missing',
    priority: 'high',
    subject: 'Laptop missing from office',
    description: 'Assigned laptop cannot be located. Last seen on Jan 5.',
    status: 'in_progress',
    acknowledged_by: 'USR_000002',
    acknowledged_at: new Date('2025-01-11T10:30:00')
  },
  {
    asset_no: 'C61584',
    reported_by: 'USR_000005',
    problem_type: 'location_issue',
    priority: 'normal',
    subject: 'Equipment in wrong department',
    description: 'Testing equipment found in production area instead of QC lab.',
    status: 'in_progress',
    acknowledged_by: 'USR_000001',
    acknowledged_at: new Date('2025-01-12T13:15:00')
  },
  {
    asset_no: 'C61530',
    reported_by: 'USR_000009',
    problem_type: 'data_error',
    priority: 'normal',
    subject: 'Incorrect purchase date',
    description: 'Several assets have incorrect acquisition dates in the system.',
    status: 'in_progress',
    acknowledged_by: 'USR_000003',
    acknowledged_at: new Date('2025-01-13T15:20:00')
  },
  {
    asset_no: 'C61573',
    reported_by: 'USR_000006',
    problem_type: 'urgent_issue',
    priority: 'critical',
    subject: 'Network equipment failure',
    description: 'Core switch experiencing intermittent failures. Affecting entire network.',
    status: 'in_progress',
    acknowledged_by: 'USR_000002',
    acknowledged_at: new Date('2025-01-14T08:00:00')
  },
  {
    asset_no: 'NB60142',
    reported_by: 'USR_000007',
    problem_type: 'asset_damage',
    priority: 'low',
    subject: 'Screen brightness issue',
    description: 'Laptop screen brightness adjustment not working properly.',
    status: 'in_progress',
    acknowledged_by: 'USR_000001',
    acknowledged_at: new Date('2025-01-15T11:30:00')
  },
  {
    asset_no: 'NB60153',
    reported_by: 'USR_000008',
    problem_type: 'other',
    priority: 'high',
    subject: 'Asset warranty expiring soon',
    description: 'Multiple critical assets have warranties expiring within 30 days.',
    status: 'in_progress',
    acknowledged_by: 'USR_000003',
    acknowledged_at: new Date('2025-01-16T09:45:00')
  },
  {
    asset_no: 'C60522',
    reported_by: 'USR_000010',
    problem_type: 'location_issue',
    priority: 'low',
    subject: 'Incorrect room assignment',
    description: 'Asset shows Room 301 but actually located in Room 305.',
    status: 'in_progress',
    acknowledged_by: 'USR_000002',
    acknowledged_at: new Date('2025-01-17T10:00:00')
  },

  // RESOLVED status (7 records)
  {
    asset_no: 'C60486',
    reported_by: 'USR_000003',
    problem_type: 'asset_damage',
    priority: 'normal',
    subject: 'Mouse not functioning',
    description: 'Wireless mouse stopped working. Battery replacement needed.',
    status: 'resolved',
    acknowledged_by: 'USR_000001',
    acknowledged_at: new Date('2025-01-05T09:00:00'),
    resolved_by: 'USR_000001',
    resolved_at: new Date('2025-01-05T14:30:00'),
    resolution_note: 'Replaced batteries and verified mouse is working properly.'
  },
  {
    asset_no: 'NB60156',
    reported_by: 'USR_000004',
    problem_type: 'asset_missing',
    priority: 'high',
    subject: 'Tablet missing from storage',
    description: 'Tablet was not found in designated storage location.',
    status: 'resolved',
    acknowledged_by: 'USR_000002',
    acknowledged_at: new Date('2025-01-06T10:00:00'),
    resolved_by: 'USR_000002',
    resolved_at: new Date('2025-01-07T16:00:00'),
    resolution_note: 'Found tablet in conference room. User forgot to return it to storage. Asset returned and logged.'
  },
  {
    asset_no: 'C61541',
    reported_by: 'USR_000005',
    problem_type: 'location_issue',
    priority: 'low',
    subject: 'Asset not in registered location',
    description: 'Equipment found in different floor than registered.',
    status: 'resolved',
    acknowledged_by: 'USR_000001',
    acknowledged_at: new Date('2025-01-07T11:00:00'),
    resolved_by: 'USR_000001',
    resolved_at: new Date('2025-01-08T09:30:00'),
    resolution_note: 'Updated location in system to match actual location. Verified with department manager.'
  },
  {
    asset_no: 'C61533',
    reported_by: 'USR_000009',
    problem_type: 'data_error',
    priority: 'normal',
    subject: 'Missing asset specifications',
    description: 'Technical specifications missing for several computer assets.',
    status: 'resolved',
    acknowledged_by: 'USR_000003',
    acknowledged_at: new Date('2025-01-08T13:00:00'),
    resolved_by: 'USR_000003',
    resolved_at: new Date('2025-01-09T17:00:00'),
    resolution_note: 'Retrieved specifications from purchase orders and updated all affected records.'
  },
  {
    asset_no: 'C61546',
    reported_by: 'USR_000006',
    problem_type: 'urgent_issue',
    priority: 'critical',
    subject: 'Production line equipment down',
    description: 'Critical production equipment not operational. Production stopped.',
    status: 'resolved',
    acknowledged_by: 'USR_000002',
    acknowledged_at: new Date('2025-01-09T08:00:00'),
    resolved_by: 'USR_000002',
    resolved_at: new Date('2025-01-09T12:30:00'),
    resolution_note: 'Replaced faulty component. Equipment tested and back in production. Scheduled preventive maintenance.'
  },
  {
    asset_no: 'C61554',
    reported_by: 'USR_000007',
    problem_type: 'other',
    priority: 'low',
    subject: 'Asset label peeling off',
    description: 'Physical asset label is peeling off and becoming unreadable.',
    status: 'resolved',
    acknowledged_by: 'USR_000001',
    acknowledged_at: new Date('2025-01-10T14:00:00'),
    resolved_by: 'USR_000001',
    resolved_at: new Date('2025-01-11T10:00:00'),
    resolution_note: 'Printed and applied new asset label. Verified barcode scans correctly.'
  },
  {
    asset_no: 'C61579',
    reported_by: 'USR_000008',
    problem_type: 'asset_damage',
    priority: 'high',
    subject: 'Hard drive failure warning',
    description: 'System showing SMART errors indicating imminent hard drive failure.',
    status: 'resolved',
    acknowledged_by: 'USR_000003',
    acknowledged_at: new Date('2025-01-11T09:00:00'),
    resolved_by: 'USR_000003',
    resolved_at: new Date('2025-01-12T15:00:00'),
    resolution_note: 'Backed up all data and replaced hard drive. Restored system and verified all data intact.'
  },

  // CANCELLED status (5 records)
  {
    asset_no: 'C60494',
    reported_by: 'USR_000003',
    problem_type: 'asset_missing',
    priority: 'normal',
    subject: 'Asset not found during audit',
    description: 'Could not locate asset during physical audit.',
    status: 'cancelled',
    acknowledged_by: 'USR_000001',
    acknowledged_at: new Date('2025-01-03T10:00:00'),
    rejection_note: 'Asset was found in another building. False alarm - asset was temporarily relocated for maintenance.'
  },
  {
    asset_no: 'C60497',
    reported_by: 'USR_000004',
    problem_type: 'data_error',
    priority: 'low',
    subject: 'Wrong category assignment',
    description: 'Asset appears to be in wrong category.',
    status: 'cancelled',
    acknowledged_by: 'USR_000002',
    acknowledged_at: new Date('2025-01-04T11:30:00'),
    rejection_note: 'Verified with procurement. Category assignment is correct per manufacturer specifications.'
  },
  {
    asset_no: 'C60498',
    reported_by: 'USR_000005',
    problem_type: 'location_issue',
    priority: 'normal',
    subject: 'Asset location discrepancy',
    description: 'Location in system does not match physical location.',
    status: 'cancelled',
    acknowledged_by: 'USR_000001',
    acknowledged_at: new Date('2025-01-05T09:30:00'),
    rejection_note: 'Asset was correctly relocated with proper documentation. Reporter was using outdated location data.'
  },
  {
    asset_no: 'C60520',
    reported_by: 'USR_000010',
    problem_type: 'other',
    priority: 'low',
    subject: 'Duplicate issue report',
    description: 'Noticed some issues with asset management system.',
    status: 'cancelled',
    acknowledged_by: 'USR_000003',
    acknowledged_at: new Date('2025-01-06T14:00:00'),
    rejection_note: 'Duplicate of existing issue #15. Closing this report.'
  },
  {
    asset_no: 'C61532',
    reported_by: 'USR_000006',
    problem_type: 'asset_damage',
    priority: 'low',
    subject: 'Cosmetic damage on casing',
    description: 'Minor scratch on equipment casing.',
    status: 'cancelled',
    acknowledged_by: 'USR_000002',
    acknowledged_at: new Date('2025-01-07T15:30:00'),
    rejection_note: 'Cosmetic damage does not affect functionality. No action required per asset management policy.'
  }
];

async function seedProblemNotifications() {
  try {
    console.log('🔔 Seeding Problem Notifications...');

    await prisma.$connect();

    let created = 0;
    let skipped = 0;

    for (const notification of problemNotificationData) {
      try {
        await prisma.problem_notification.create({ data: notification });
        console.log(`✅ Created notification: ${notification.subject} (${notification.status})`);
        created++;
      } catch (error) {
        console.error(`❌ Failed to create notification: ${notification.subject}`, error.message);
        skipped++;
      }
    }

    console.log(`\n📊 Problem Notifications Summary: ${created} created, ${skipped} skipped`);
    console.log(`\n📈 Status breakdown:`);
    console.log(`   Pending: ${problemNotificationData.filter(n => n.status === 'pending').length}`);
    console.log(`   Acknowledged: ${problemNotificationData.filter(n => n.status === 'acknowledged').length}`);
    console.log(`   In Progress: ${problemNotificationData.filter(n => n.status === 'in_progress').length}`);
    console.log(`   Resolved: ${problemNotificationData.filter(n => n.status === 'resolved').length}`);
    console.log(`   Cancelled: ${problemNotificationData.filter(n => n.status === 'cancelled').length}`);

  } catch (error) {
    console.error('💥 Problem Notifications seeding failed:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  seedProblemNotifications();
}

module.exports = { seedProblemNotifications };
