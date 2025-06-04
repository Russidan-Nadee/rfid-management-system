// Path: backend/scripts/hashPasswords.js
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
require('dotenv').config();

// Database connection
const dbConfig = {
   host: process.env.DB_HOST,
   user: process.env.DB_USER,
   password: process.env.DB_PASSWORD,
   database: process.env.DB_NAME,
   port: process.env.DB_PORT
};

async function hashExistingPasswords() {
   let connection;

   try {
      console.log('🔗 Connecting to database...');
      connection = await mysql.createConnection(dbConfig);

      // Get all users with plain text passwords
      console.log('📋 Fetching users with plain text passwords...');
      const [users] = await connection.execute(
         'SELECT user_id, username, password FROM mst_user WHERE password = ?',
         ['password123']
      );

      console.log(`👥 Found ${users.length} users with password 'password123'`);

      if (users.length === 0) {
         console.log('✅ No users need password hashing');
         return;
      }

      // Hash password for each user
      const saltRounds = 12;
      const hashedPassword = await bcrypt.hash('password123', saltRounds);

      console.log('🔐 Hashing passwords...');
      console.log(`🔑 New hash: ${hashedPassword}`);

      // Update all users at once
      const [result] = await connection.execute(
         'UPDATE mst_user SET password = ? WHERE password = ?',
         [hashedPassword, 'password123']
      );

      console.log(`✅ Updated ${result.affectedRows} user passwords`);

      // Verify the update
      console.log('🔍 Verifying hash...');
      const isValid = await bcrypt.compare('password123', hashedPassword);
      console.log(`✅ Hash verification: ${isValid ? 'SUCCESS' : 'FAILED'}`);

      // Show updated users
      console.log('\n📊 Updated users:');
      users.forEach((user, index) => {
         console.log(`${index + 1}. ${user.user_id} (${user.username})`);
      });

      console.log('\n🎉 Password hashing completed successfully!');
      console.log('💡 Users can now login with password: password123');

   } catch (error) {
      console.error('❌ Error hashing passwords:', error.message);
      console.error('🔧 Please check your database connection and try again');
   } finally {
      if (connection) {
         await connection.end();
         console.log('🔗 Database connection closed');
      }
   }
}

// Run the script
if (require.main === module) {
   hashExistingPasswords().then(() => {
      console.log('📝 Script execution completed');
      process.exit(0);
   }).catch((error) => {
      console.error('💥 Script failed:', error);
      process.exit(1);
   });
}

module.exports = hashExistingPasswords;

// =======================
// Alternative: Manual SQL Method
// =======================

/*
If you prefer to run SQL directly:

1. Generate hash in Node.js console:
   
   const bcrypt = require('bcrypt');
   bcrypt.hash('password123', 12).then(hash => console.log(hash));

2. Copy the hash and run SQL:
   
   UPDATE mst_user 
   SET password = '$2b$12$[your_generated_hash_here]' 
   WHERE password = 'password123';

3. Verify with:
   
   SELECT user_id, username, password FROM mst_user LIMIT 5;
*/