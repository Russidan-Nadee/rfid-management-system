const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const brandData = [
  { brand_code: 'DEL', brand_name: 'Dell', description: 'Manufacturer of laptops, desktops, and accessories.', is_active: true },
  { brand_code: 'HP', brand_name: 'HP', description: 'Technology company offering hardware and software services.', is_active: true },
  { brand_code: 'LEN', brand_name: 'Lenovo', description: 'Global leader in PCs and smart devices.', is_active: true },
  { brand_code: 'LOG', brand_name: 'Logitech', description: 'Peripherals and accessories for computers and gaming.', is_active: true },
  { brand_code: 'MSI', brand_name: 'MSI', description: 'High-performance gaming hardware and laptops.', is_active: true },
  { brand_code: 'APL', brand_name: 'Apple', description: 'Technology company known for innovative consumer electronics.', is_active: true },
  { brand_code: 'ASUS', brand_name: 'ASUS', description: 'Multinational computer hardware and electronics company.', is_active: true },
  { brand_code: 'ACER', brand_name: 'Acer', description: 'Computer hardware and electronics manufacturer.', is_active: true }
];

async function seedBrands() {
  try {
    console.log('🏷️  Seeding Brands...');

    await prisma.$connect();

    let created = 0;
    let skipped = 0;

    for (const brand of brandData) {
      try {
        const existing = await prisma.mst_brand.findUnique({
          where: { brand_code: brand.brand_code }
        });

        if (!existing) {
          await prisma.mst_brand.create({ data: brand });
          console.log(`✅ Created brand: ${brand.brand_code} - ${brand.brand_name}`);
          created++;
        } else {
          console.log(`⏭️  Skipping brand: ${brand.brand_code} (exists)`);
          skipped++;
        }
      } catch (error) {
        console.error(`❌ Failed to create brand ${brand.brand_code}:`, error.message);
      }
    }

    console.log(`\n📊 Brands Summary: ${created} created, ${skipped} skipped`);

  } catch (error) {
    console.error('💥 Brand seeding failed:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  seedBrands();
}

module.exports = { seedBrands };