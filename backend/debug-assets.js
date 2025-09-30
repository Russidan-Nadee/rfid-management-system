const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function debugAssets() {
  try {
    await prisma.$connect();

    // ดูข้อมูล assets 5 ตัวแรก
    const assets = await prisma.asset_master.findMany({
      take: 5,
      select: {
        asset_no: true,
        cost_center_code: true,
        created_at: true
      }
    });

    console.log('🔍 First 5 assets in database:');
    assets.forEach(asset => {
      console.log(`   ${asset.asset_no} | cost_center: ${asset.cost_center_code} | created: ${asset.created_at}`);
    });

    // ดูว่ามี cost centers ไหน
    const costCenters = await prisma.mst_cost_center.findMany({
      take: 5,
      select: {
        cost_center_code: true,
        cost_center_name: true
      }
    });

    console.log('\n💰 First 5 cost centers:');
    costCenters.forEach(cc => {
      console.log(`   ${cc.cost_center_code} - ${cc.cost_center_name}`);
    });

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

debugAssets();