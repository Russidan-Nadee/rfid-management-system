const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const userData = [
  // Managers (2)
  {
    user_id: 'USR_000001',
    full_name: 'Manager One',
    employee_id: '000001',
    department: 'Operations',
    position: 'Operations Manager',
    company_role: 'Manager',
    email: 'manager1@company.com',
    role: 'manager',
    is_active: true
  },
  {
    user_id: 'USR_000002',
    full_name: 'Manager Two',
    employee_id: '000002',
    department: 'Quality Control',
    position: 'QC Manager',
    company_role: 'Manager',
    email: 'manager2@company.com',
    role: 'manager',
    is_active: true
  },

  // Staff (4)
  {
    user_id: 'USR_000003',
    full_name: 'Staff One',
    employee_id: '000003',
    department: 'IT Department',
    position: 'IT Staff',
    company_role: 'IT Support',
    email: 'staff1@company.com',
    role: 'staff',
    is_active: true
  },
  {
    user_id: 'USR_000004',
    full_name: 'Staff Two',
    employee_id: '000004',
    department: 'Asset Management',
    position: 'Asset Staff',
    company_role: 'Asset Coordinator',
    email: 'staff2@company.com',
    role: 'staff',
    is_active: true
  },
  {
    user_id: 'USR_000005',
    full_name: 'Staff Three',
    employee_id: '000005',
    department: 'Warehouse',
    position: 'Warehouse Staff',
    company_role: 'Inventory Staff',
    email: 'staff3@company.com',
    role: 'staff',
    is_active: true
  },
  {
    user_id: 'USR_000006',
    full_name: 'Staff Four',
    employee_id: '000006',
    department: 'Maintenance',
    position: 'Maintenance Staff',
    company_role: 'Technician',
    email: 'staff4@company.com',
    role: 'staff',
    is_active: true
  },

  // Viewers (4)
  {
    user_id: 'USR_000007',
    full_name: 'Viewer One',
    employee_id: '000007',
    department: 'Accounting',
    position: 'Accountant',
    company_role: 'Finance',
    email: 'viewer1@company.com',
    role: 'viewer',
    is_active: true
  },
  {
    user_id: 'USR_000008',
    full_name: 'Viewer Two',
    employee_id: '000008',
    department: 'Human Resources',
    position: 'HR Officer',
    company_role: 'HR',
    email: 'viewer2@company.com',
    role: 'viewer',
    is_active: true
  },
  {
    user_id: 'USR_000009',
    full_name: 'Viewer Three',
    employee_id: '000009',
    department: 'Procurement',
    position: 'Buyer',
    company_role: 'Purchasing',
    email: 'viewer3@company.com',
    role: 'viewer',
    is_active: true
  },
  {
    user_id: 'USR_000010',
    full_name: 'Viewer Four',
    employee_id: '000010',
    department: 'Audit',
    position: 'Auditor',
    company_role: 'Internal Audit',
    email: 'viewer4@company.com',
    role: 'viewer',
    is_active: true
  },

  // Admin (1)
  {
    user_id: 'USR_999999',
    full_name: 'Admin User',
    employee_id: '999999',
    department: 'IT Department',
    position: 'System Administrator',
    company_role: 'Admin',
    email: 'admin@company.com',
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