const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const plantData = [
  { plant_code: 'TP-BP12', description: 'Thai Parkerizing Bangpoo Soi 12' },
  { plant_code: 'TP-BP8', description: 'Thai Parkerizing Bangpoo Soi 8' },
  { plant_code: 'TP-GW', description: 'Thai Parkerizing Gateway' }
];

async function seedPlants() {
  try {
    console.log('🏭 Seeding Plants...');
    
    await prisma.$connect();
    
    let created = 0;
    let skipped = 0;

    for (const plant of plantData) {
      try {
        const existing = await prisma.mst_plant.findUnique({
          where: { plant_code: plant.plant_code }
        });
        
        if (!existing) {
          await prisma.mst_plant.create({ data: plant });
          console.log(`✅ Created plant: ${plant.plant_code} - ${plant.description}`);
          created++;
        } else {
          console.log(`⏭️  Skipping plant: ${plant.plant_code} (exists)`);
          skipped++;
        }
      } catch (error) {
        console.error(`❌ Failed to create plant ${plant.plant_code}:`, error.message);
      }
    }

    console.log(`\n📊 Plants Summary: ${created} created, ${skipped} skipped`);
    
  } catch (error) {
    console.error('💥 Plant seeding failed:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  seedPlants();
}

module.exports = { seedPlants };