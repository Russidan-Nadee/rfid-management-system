const mysql = require('mysql2/promise');

async function addRejectionNoteColumn() {
  let connection;
  
  try {
    // Create connection (adjust credentials as needed)
    connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '', // Add your MySQL root password here
      database: 'asset_management'
    });

    console.log('Connected to database...');

    // Check if column exists
    const [columns] = await connection.execute(`
      SELECT COLUMN_NAME 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = 'asset_management' 
      AND TABLE_NAME = 'problem_notification' 
      AND COLUMN_NAME = 'rejection_note'
    `);

    if (columns.length > 0) {
      console.log('✅ Column rejection_note already exists');
    } else {
      // Add the column
      await connection.execute(`
        ALTER TABLE problem_notification 
        ADD COLUMN rejection_note TEXT NULL 
        COMMENT 'Reason for rejection when status is cancelled'
      `);
      console.log('✅ Successfully added rejection_note column');
    }

    // Verify the column was added
    const [result] = await connection.execute(`
      SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_COMMENT
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = 'asset_management'
      AND TABLE_NAME = 'problem_notification'
      AND COLUMN_NAME = 'rejection_note'
    `);

    if (result.length > 0) {
      console.log('Column details:', result[0]);
      console.log('✅ Database migration completed successfully!');
      console.log('');
      console.log('Next steps:');
      console.log('1. Stop your backend server (Ctrl+C)');
      console.log('2. Run: npx prisma generate');
      console.log('3. Restart your backend server');
    } else {
      console.log('❌ Column was not added properly');
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.log('');
    console.log('Manual SQL to run:');
    console.log('USE asset_management;');
    console.log('ALTER TABLE problem_notification ADD COLUMN rejection_note TEXT NULL COMMENT "Reason for rejection when status is cancelled";');
  } finally {
    if (connection) {
      await connection.end();
      console.log('Database connection closed.');
    }
  }
}

addRejectionNoteColumn();