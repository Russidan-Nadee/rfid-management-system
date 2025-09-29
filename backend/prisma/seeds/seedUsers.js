const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const userData = [
  {
    user_id: 'USR_999999',
    full_name: 'System User',
    employee_id: '999999',
    department: 'System',
    position: 'System',
    company_role: 'System',
    email: 'system@company.com',
    role: 'admin',
    is_active: true
  }
];

async function seedUsers() {
  try {
    console.log('👤 Seeding Users...');

    await prisma.$connect();

    let created = 0;
    let skipped = 0;

    for (const user of userData) {
      try {
        const existing = await prisma.mst_user.findUnique({
          where: { user_id: user.user_id }
        });

        if (!existing) {
          await prisma.mst_user.create({ data: user });
          console.log(`✅ Created user: ${user.user_id} - ${user.full_name}`);
          created++;
        } else {
          console.log(`⏭️  Skipping user: ${user.user_id} (exists)`);
          skipped++;
        }
      } catch (error) {
        console.error(`❌ Failed to create user ${user.user_id}:`, error.message);
      }
    }

    console.log(`\n📊 Users Summary: ${created} created, ${skipped} skipped`);

  } catch (error) {
    console.error('💥 User seeding failed:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  seedUsers();
}

module.exports = { seedUsers };