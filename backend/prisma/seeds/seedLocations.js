const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const locationData = [
  // Meeting Rooms (BP12)
  { location_code: 'RM221', description: 'Meeting Room 221', plant_code: 'TP-BP12' },
  { location_code: 'RM222', description: 'Meeting Room 222', plant_code: 'TP-BP12' },
  { location_code: 'RM223', description: 'Meeting Room 223', plant_code: 'TP-BP12' },
  { location_code: 'RM224', description: 'Meeting Room 224', plant_code: 'TP-BP12' },
  { location_code: 'RM225', description: 'Meeting Room 225', plant_code: 'TP-BP12' },
  { location_code: 'CONF-BP12', description: 'Conference Room BP12', plant_code: 'TP-BP12' },
  { location_code: 'CONF-BP8', description: 'Conference Room BP8', plant_code: 'TP-BP8' },
  { location_code: 'CONF-GW', description: 'Conference Room GW', plant_code: 'TP-GW' },
  { location_code: 'CONF-ESIE1', description: 'Conference Room ESIE1', plant_code: 'TP-ESIE1' },

  // Special Rooms
  { location_code: 'SRV-BP12', description: 'Server Room BP12', plant_code: 'TP-BP12' },
  { location_code: 'SRV-BP8', description: 'Server Room BP8', plant_code: 'TP-BP8' },
  { location_code: 'SRV-GW', description: 'Server Room GW', plant_code: 'TP-GW' },
  { location_code: 'SRV-ESIE1', description: 'Server Room ESIE1', plant_code: 'TP-ESIE1' },
  { location_code: 'ADM-BP12', description: 'Admin Room BP12', plant_code: 'TP-BP12' },
  { location_code: 'ADM-ESIE1', description: 'Admin Room ESIE1', plant_code: 'TP-ESIE1' },
  { location_code: 'OFC-BP12', description: 'Office Room BP12', plant_code: 'TP-BP12' },
  { location_code: 'OFC-BP8', description: 'Office Room BP8', plant_code: 'TP-BP8' },
  { location_code: 'OFC-GW', description: 'Office Room GW', plant_code: 'TP-GW' },
  { location_code: 'OFC-ESIE1', description: 'Office Room ESIE1', plant_code: 'TP-ESIE1' }
];

async function seedLocations() {
  try {
    console.log('📍 Seeding Locations...');

    await prisma.$connect();

    let created = 0;
    let skipped = 0;

    for (const location of locationData) {
      try {
        const existing = await prisma.mst_location.findUnique({
          where: { location_code: location.location_code }
        });

        if (!existing) {
          await prisma.mst_location.create({ data: location });
          console.log(`✅ Created location: ${location.location_code} - ${location.description}`);
          created++;
        } else {
          console.log(`⏭️  Skipping location: ${location.location_code} (exists)`);
          skipped++;
        }
      } catch (error) {
        console.error(`❌ Failed to create location ${location.location_code}:`, error.message);
      }
    }

    console.log(`\n📊 Locations Summary: ${created} created, ${skipped} skipped`);

  } catch (error) {
    console.error('💥 Location seeding failed:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  seedLocations();
}

module.exports = { seedLocations };