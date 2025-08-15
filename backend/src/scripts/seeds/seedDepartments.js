const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const departmentData = [
  { dept_code: 'ACC', description: 'Accounting', plant_code: 'TP-BP12' },
  { dept_code: 'FIN', description: 'Finance', plant_code: 'TP-BP12' },
  { dept_code: 'GA', description: 'General Affairs', plant_code: 'TP-BP12' },
  { dept_code: 'HR', description: 'Human Resources', plant_code: 'TP-BP12' },
  { dept_code: 'IT', description: 'Information Tech', plant_code: 'TP-BP12' },
  { dept_code: 'PUR', description: 'Purchasing and Planning', plant_code: 'TP-BP12' },
  { dept_code: 'QA', description: 'Quality Assurance', plant_code: 'TP-BP12' },
  { dept_code: 'QC', description: 'Quality Control', plant_code: 'TP-BP12' },
  { dept_code: 'SAFE', description: 'Safety', plant_code: 'TP-BP12' },
  { dept_code: 'SALES', description: 'Sales', plant_code: 'TP-BP12' },
  { dept_code: 'LEGAL', description: 'Legal', plant_code: 'TP-BP12' }
];

async function seedDepartments() {
  try {
    console.log('🏢 Seeding Departments...');
    
    await prisma.$connect();
    
    let created = 0;
    let skipped = 0;

    for (const department of departmentData) {
      try {
        const existing = await prisma.mst_department.findUnique({
          where: { dept_code: department.dept_code }
        });
        
        if (!existing) {
          await prisma.mst_department.create({ data: department });
          console.log(`✅ Created department: ${department.dept_code} - ${department.description}`);
          created++;
        } else {
          console.log(`⏭️  Skipping department: ${department.dept_code} (exists)`);
          skipped++;
        }
      } catch (error) {
        console.error(`❌ Failed to create department ${department.dept_code}:`, error.message);
      }
    }

    console.log(`\n📊 Departments Summary: ${created} created, ${skipped} skipped`);
    
  } catch (error) {
    console.error('💥 Department seeding failed:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  seedDepartments();
}

module.exports = { seedDepartments };