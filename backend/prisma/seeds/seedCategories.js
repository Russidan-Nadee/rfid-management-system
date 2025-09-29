const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const categoryData = [
  { category_code: 'LAP', category_name: 'Laptop', description: 'Portable personal computers.', is_active: true },
  { category_code: 'PC', category_name: 'PC', description: 'Desktop personal computers.', is_active: true }
];

async function seedCategories() {
  try {
    console.log('📂 Seeding Categories...');

    await prisma.$connect();

    let created = 0;
    let skipped = 0;

    for (const category of categoryData) {
      try {
        const existing = await prisma.mst_category.findUnique({
          where: { category_code: category.category_code }
        });

        if (!existing) {
          await prisma.mst_category.create({ data: category });
          console.log(`✅ Created category: ${category.category_code} - ${category.category_name}`);
          created++;
        } else {
          console.log(`⏭️  Skipping category: ${category.category_code} (exists)`);
          skipped++;
        }
      } catch (error) {
        console.error(`❌ Failed to create category ${category.category_code}:`, error.message);
      }
    }

    console.log(`\n📊 Categories Summary: ${created} created, ${skipped} skipped`);

  } catch (error) {
    console.error('💥 Category seeding failed:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  seedCategories();
}

module.exports = { seedCategories };