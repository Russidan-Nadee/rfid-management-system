// Path: backend/src/scripts/seedDefaultUsers.js
const { PrismaClient } = require('@prisma/client');
const { hashPassword } = require('../core/auth/passwordUtils');

const prisma = new PrismaClient();

const defaultUsers = [
   {
      user_id: 'ADMIN001',
      username: 'admin',
      full_name: 'System Administrator',
      password: 'password123',
      role: 'admin'
   },
   {
      user_id: 'MGR001',
      username: 'manager',
      full_name: 'Asset Manager',
      password: 'password123',
      role: 'manager'
   },
   {
      user_id: 'USER001',
      username: 'user',
      full_name: 'Standard User',
      password: 'password123',
      role: 'user'
   },
   {
      user_id: 'VIEW001',
      username: 'viewer',
      full_name: 'View Only User',
      password: 'password123',
      role: 'viewer'
   }
];

async function seedDefaultUsers() {
   try {
      console.log('🌱 Seeding default users...');

      // Check database connection
      await prisma.$connect();
      console.log('✅ Database connected');

      // Check if users already exist
      const existingCount = await prisma.mst_user.count();

      if (existingCount > 0) {
         console.log(`⚠️  Database already has ${existingCount} users.`);
         console.log('🤔 Do you want to proceed anyway? (This will skip existing users)');

         // Simple confirmation without readline for seeder
         const args = process.argv.slice(2);
         if (!args.includes('--force')) {
            console.log('💡 Use --force flag to proceed: npm run seed-default-users -- --force');
            process.exit(0);
         }
      }

      let created = 0;
      let skipped = 0;

      for (const userData of defaultUsers) {
         try {
            // Check if user already exists
            const existing = await prisma.mst_user.findFirst({
               where: {
                  OR: [
                     { user_id: userData.user_id },
                     { username: userData.username }
                  ]
               }
            });

            if (existing) {
               console.log(`⏭️  Skipping ${userData.username} (already exists)`);
               skipped++;
               continue;
            }

            // Hash password
            const hashedPassword = await hashPassword(userData.password);

            // Create user
            await prisma.mst_user.create({
               data: {
                  user_id: userData.user_id,
                  username: userData.username,
                  full_name: userData.full_name,
                  password: hashedPassword,
                  role: userData.role,
                  created_at: new Date(),
                  updated_at: new Date()
               }
            });

            console.log(`✅ Created user: ${userData.username} (${userData.role})`);
            created++;

         } catch (error) {
            console.error(`❌ Failed to create ${userData.username}:`, error.message);
         }
      }

      console.log('\n📊 Summary:');
      console.log(`   Created: ${created} users`);
      console.log(`   Skipped: ${skipped} users`);

      if (created > 0) {
         console.log('\n🔑 Default Login Credentials:');
         console.log('===============================');
         defaultUsers.forEach(user => {
            console.log(`${user.role.toUpperCase()}:`);
            console.log(`   Username: ${user.username}`);
            console.log(`   Password: ${user.password}\n`);
         });

         console.log('⚠️  IMPORTANT: Change these passwords after first login!');
      }

   } catch (error) {
      console.error('💥 Seeding failed:', error.message);
      process.exit(1);
   } finally {
      await prisma.$disconnect();
   }
}

seedDefaultUsers();