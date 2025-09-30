const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkData() {
  try {
    await prisma.$connect();

    // Count tables
    const divisions = await prisma.mst_division.count();
    const costCenters = await prisma.mst_cost_center.count();
    const assets = await prisma.asset_master.count();
    const mappings = await prisma.dept_cost_center_mapping.count();

    console.log('📊 Database Summary:');
    console.log(`🏢 Divisions: ${divisions}`);
    console.log(`💰 Cost Centers: ${costCenters}`);
    console.log(`📦 Assets: ${assets}`);
    console.log(`🔗 Dept Mappings: ${mappings}`);

    // Count assets with cost centers
    const assetsWithCostCenter = await prisma.asset_master.count({
      where: { cost_center_code: { not: null } }
    });

    const assetsWithoutCostCenter = assets - assetsWithCostCenter;

    console.log('\n📈 Asset Cost Center Analysis:');
    console.log(`✅ Assets with Cost Center: ${assetsWithCostCenter} (${((assetsWithCostCenter/assets)*100).toFixed(1)}%)`);
    console.log(`❌ Assets without Cost Center: ${assetsWithoutCostCenter} (${((assetsWithoutCostCenter/assets)*100).toFixed(1)}%)`);

    // Sample data check
    const sampleAssets = await prisma.asset_master.findMany({
      where: { cost_center_code: { not: null } },
      include: { mst_cost_center: true },
      take: 5
    });

    console.log('\n🔍 Sample Assets with Cost Centers:');
    sampleAssets.forEach(asset => {
      console.log(`   ${asset.asset_no} → ${asset.cost_center_code} (${asset.mst_cost_center?.cost_center_name || 'N/A'})`);
    });

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

checkData();