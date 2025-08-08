const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkTableStructure() {
  let connection;
  
  try {
    // Parse DATABASE_URL
    const dbUrl = process.env.DATABASE_URL;
    const urlMatch = dbUrl.match(/mysql:\/\/([^:]+):([^@]+)@([^:]+):(\d+)\/(.+)/);
    const [, user, password, host, port, database] = urlMatch;
    
    connection = await mysql.createConnection({
      host,
      port: parseInt(port),
      user,
      password,
      database
    });
    
    console.log('Checking asset_master table structure...');
    const [assetColumns] = await connection.execute('DESCRIBE asset_master');
    console.log('asset_master structure:');
    console.table(assetColumns);
    
    console.log('\nChecking mst_user table structure...');
    const [userColumns] = await connection.execute('DESCRIBE mst_user');
    console.log('mst_user structure:');
    console.table(userColumns);
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

checkTableStructure();