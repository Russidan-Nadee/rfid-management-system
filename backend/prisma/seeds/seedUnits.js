const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const unitData = [
  { unit_code: 'EA', name: 'Each' },
  { unit_code: 'SET', name: 'Set' }
];

async function seedUnits() {
  try {
    console.log('📏 Seeding Units...');
    
    await prisma.$connect();
    
    let created = 0;
    let skipped = 0;

    for (const unit of unitData) {
      try {
        const existing = await prisma.mst_unit.findUnique({
          where: { unit_code: unit.unit_code }
        });
        
        if (!existing) {
          await prisma.mst_unit.create({ data: unit });
          console.log(`✅ Created unit: ${unit.unit_code} - ${unit.name}`);
          created++;
        } else {
          console.log(`⏭️  Skipping unit: ${unit.unit_code} (exists)`);
          skipped++;
        }
      } catch (error) {
        console.error(`❌ Failed to create unit ${unit.unit_code}:`, error.message);
      }
    }

    console.log(`\n📊 Units Summary: ${created} created, ${skipped} skipped`);
    
  } catch (error) {
    console.error('💥 Unit seeding failed:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  seedUnits();
}

module.exports = { seedUnits };