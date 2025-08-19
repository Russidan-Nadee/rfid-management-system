// Path: backend/scripts/setupSessionTables.js
const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const path = require('path');

const prisma = new PrismaClient();

async function setupSessionTables() {
  try {
    console.log('🔧 Setting up session management tables...');

    // Read and execute the migration SQL
    const migrationPath = path.join(__dirname, '../migrations/add_user_sessions_table.sql');
    const migrationSQL = fs.readFileSync(migrationPath, 'utf8');

    // Split by delimiter and execute each statement
    const statements = migrationSQL.split('DELIMITER');
    
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i].trim();
      
      if (statement && !statement.startsWith('//') && !statement.startsWith('--')) {
        try {
          // Clean up the statement
          const cleanStatement = statement
            .replace(/^\/\/.*$/gm, '') // Remove single-line comments
            .replace(/\/\*[\s\S]*?\*\//g, '') // Remove multi-line comments
            .replace(/^\s*\n/gm, '') // Remove empty lines
            .trim();

          if (cleanStatement) {
            console.log(`📝 Executing statement ${i + 1}...`);
            await prisma.$executeRawUnsafe(cleanStatement);
          }
        } catch (error) {
          console.warn(`⚠️ Warning executing statement ${i + 1}:`, error.message);
          // Continue with other statements
        }
      }
    }

    console.log('✅ Session tables setup completed successfully!');

    // Test the setup
    await testSessionSetup();

  } catch (error) {
    console.error('❌ Error setting up session tables:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

async function testSessionSetup() {
  try {
    console.log('\n🧪 Testing session setup...');

    // Test table creation
    const tableExists = await prisma.$queryRaw`
      SELECT COUNT(*) as count 
      FROM information_schema.tables 
      WHERE table_schema = DATABASE() 
      AND table_name = 'user_sessions'
    `;

    if (tableExists[0].count > 0) {
      console.log('✅ user_sessions table created successfully');
    } else {
      throw new Error('user_sessions table not found');
    }

    // Test session creation (if there are users)
    const userCount = await prisma.mst_user.count();
    
    if (userCount > 0) {
      console.log(`📊 Found ${userCount} users in the system`);
      
      // Create a test session
      const testUser = await prisma.mst_user.findFirst({
        where: { is_active: true }
      });

      if (testUser) {
        const testSession = await prisma.user_sessions.create({
          data: {
            session_id: 'test-session-' + Date.now(),
            user_id: testUser.user_id,
            expires_at: new Date(Date.now() + 15 * 60 * 1000), // 15 minutes
            ip_address: '127.0.0.1',
            user_agent: 'Setup Test',
            device_type: 'test'
          }
        });

        console.log('✅ Test session created successfully:', testSession.session_id);

        // Clean up test session
        await prisma.user_sessions.delete({
          where: { session_id: testSession.session_id }
        });

        console.log('✅ Test session cleaned up successfully');
      }
    } else {
      console.log('ℹ️ No users found, skipping session creation test');
    }

    console.log('✅ All tests passed!');

  } catch (error) {
    console.error('❌ Test failed:', error);
    throw error;
  }
}

// Run the setup if this file is executed directly
if (require.main === module) {
  setupSessionTables()
    .then(() => {
      console.log('\n🎉 Session management setup completed successfully!');
      console.log('\n📋 Next steps:');
      console.log('1. Restart your application server');
      console.log('2. Update your frontend to use cookie-based authentication');
      console.log('3. Test login/logout with session cookies');
      console.log('4. Monitor session analytics in admin panel');
      process.exit(0);
    })
    .catch((error) => {
      console.error('\n💥 Setup failed:', error.message);
      process.exit(1);
    });
}

module.exports = { setupSessionTables, testSessionSetup };