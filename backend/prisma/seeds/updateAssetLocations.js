const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const LOCATIONS_BY_PLANT = {
  'TP-BP12': ['RM221', 'RM222', 'RM223', 'RM224', 'RM225', 'CONF-BP12', 'SRV-BP12', 'ADM-BP12', 'OFC-BP12'],
  'TP-BP8': ['CONF-BP8', 'SRV-BP8', 'OFC-BP8'],
  'TP-GW': ['CONF-GW', 'SRV-GW', 'OFC-GW'],
  'TP-ESIE1': ['CONF-ESIE1', 'SRV-ESIE1', 'ADM-ESIE1', 'OFC-ESIE1']
};

function randomLocation(plantCode) {
  if (!plantCode || !LOCATIONS_BY_PLANT[plantCode]) {
    return null; // ไม่มี plant หรือ plant ไม่มี location
  }
  const locations = LOCATIONS_BY_PLANT[plantCode];
  return locations[Math.floor(Math.random() * locations.length)];
}

async function updateAssetLocations() {
  try {
    console.log('📍 Updating Asset Locations...');

    await prisma.$connect();

    // ดึง assets ทั้งหมดที่มี plant_code
    const assets = await prisma.asset_master.findMany({
      where: {
        plant_code: {
          not: null
        }
      },
      select: {
        asset_no: true,
        plant_code: true,
        location_code: true
      }
    });

    console.log(`Found ${assets.length} assets with plant_code`);

    let updated = 0;
    let skipped = 0;

    for (const asset of assets) {
      try {
        const newLocationCode = randomLocation(asset.plant_code);

        if (newLocationCode) {
          await prisma.asset_master.update({
            where: { asset_no: asset.asset_no },
            data: { location_code: newLocationCode }
          });

          console.log(`✅ Updated ${asset.asset_no}: ${asset.plant_code} -> ${newLocationCode}`);
          updated++;
        } else {
          console.log(`⏭️  Skipped ${asset.asset_no}: No locations for plant ${asset.plant_code}`);
          skipped++;
        }
      } catch (error) {
        console.error(`❌ Failed to update asset ${asset.asset_no}:`, error.message);
        skipped++;
      }
    }

    console.log(`\n📊 Update Summary: ${updated} updated, ${skipped} skipped`);

  } catch (error) {
    console.error('💥 Location update failed:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  updateAssetLocations();
}

module.exports = { updateAssetLocations };