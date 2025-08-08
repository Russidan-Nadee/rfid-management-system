const mysql = require('mysql2/promise');
require('dotenv').config();

async function createNotificationTable() {
  let connection;
  
  try {
    // Parse DATABASE_URL
    const dbUrl = process.env.DATABASE_URL;
    const urlMatch = dbUrl.match(/mysql:\/\/([^:]+):([^@]+)@([^:]+):(\d+)\/(.+)/);
    const [, user, password, host, port, database] = urlMatch;
    
    console.log('Connecting to MySQL database...');
    connection = await mysql.createConnection({
      host,
      port: parseInt(port),
      user,
      password,
      database
    });
    
    console.log('Connected to database');
    
    // Check if table already exists
    const [existing] = await connection.execute(`
      SELECT COUNT(*) as count 
      FROM information_schema.tables 
      WHERE table_schema = ? AND table_name = 'problem_notification'
    `, [database]);
    
    if (existing[0].count > 0) {
      console.log('⚠️ problem_notification table already exists - dropping first');
      await connection.execute('DROP TABLE problem_notification');
    }
    
    console.log('Creating problem_notification table (without foreign keys)...');
    
    // Create the table without foreign keys
    await connection.execute(`
      CREATE TABLE \`problem_notification\` (
        \`notification_id\` INT NOT NULL AUTO_INCREMENT,
        \`asset_no\` VARCHAR(20) NULL,
        \`reported_by\` VARCHAR(20) NOT NULL,
        \`problem_type\` ENUM('asset_damage', 'asset_missing', 'location_issue', 'data_error', 'urgent_issue', 'other') NOT NULL,
        \`priority\` ENUM('low', 'normal', 'high', 'urgent') NOT NULL DEFAULT 'normal',
        \`subject\` VARCHAR(255) NOT NULL,
        \`description\` TEXT NOT NULL,
        \`status\` ENUM('pending', 'acknowledged', 'in_progress', 'resolved', 'cancelled') NOT NULL DEFAULT 'pending',
        \`acknowledged_by\` VARCHAR(20) NULL,
        \`acknowledged_at\` DATETIME NULL,
        \`resolved_by\` VARCHAR(20) NULL,
        \`resolved_at\` DATETIME NULL,
        \`resolution_note\` TEXT NULL,
        \`created_at\` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        \`updated_at\` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        
        PRIMARY KEY (\`notification_id\`),
        
        INDEX \`idx_problem_notification_asset_no\` (\`asset_no\`),
        INDEX \`idx_problem_notification_reported_by\` (\`reported_by\`),
        INDEX \`idx_problem_notification_status\` (\`status\`),
        INDEX \`idx_problem_notification_priority\` (\`priority\`),
        INDEX \`idx_problem_notification_created_at\` (\`created_at\`),
        INDEX \`idx_problem_notification_type\` (\`problem_type\`)
      )
    `);
    
    console.log('✅ problem_notification table created successfully (without foreign keys)');
    
    // Verify table structure
    const [columns] = await connection.execute('DESCRIBE problem_notification');
    console.log('Table structure:');
    console.table(columns);
    
    // Insert a test record
    console.log('Inserting test record...');
    const [result] = await connection.execute(`
      INSERT INTO \`problem_notification\` (
        \`reported_by\`, 
        \`problem_type\`, 
        \`priority\`, 
        \`subject\`, 
        \`description\`
      ) VALUES (
        'admin',
        'data_error',
        'normal',
        'Test Notification System',
        'This is a test problem notification to verify the system is working correctly.'
      )
    `);
    
    console.log(`✅ Test record inserted with ID: ${result.insertId}`);
    
    // Show the test record
    const [testRecord] = await connection.execute('SELECT * FROM problem_notification WHERE notification_id = ?', [result.insertId]);
    console.log('Test record:');
    console.table(testRecord);
    
  } catch (error) {
    console.error('❌ Error creating notification table:', error);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
      console.log('Database connection closed');
    }
  }
}

createNotificationTable();