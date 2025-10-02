const { seedPlants } = require('./seeds/seedPlants');
const { seedDepartments } = require('./seeds/seedDepartments');
const { seedUnits } = require('./seeds/seedUnits');
const { seedCategories } = require('./seeds/seedCategories');
const { seedBrands } = require('./seeds/seedBrands');
const { seedUsers } = require('./seeds/seedUsers');
const seedAssets = require('./seeds/seedAssets');
const { seedCostCentersComplete } = require('./seeds/seedCostCenters');
const { seedComputerInfo } = require('./seeds/seedComputerInfo');
const { seedProblemNotifications } = require('./seeds/seedProblemNotifications');

async function main() {
  console.log('🌱 Starting database seeding...');

  try {
    // Seed master data first (order is important due to foreign keys)
    await seedPlants();
    await seedCostCentersComplete(); // Seed divisions and cost centers
    await seedDepartments();
    await seedUnits();
    await seedCategories();
    await seedBrands();

    // Seed users
    await seedUsers();

    // Seed assets last (depends on all master data) - includes department/plant update
    await seedAssets();

    // Seed computer info
    await seedComputerInfo();

    // Seed problem notifications
    await seedProblemNotifications();

    console.log('✅ Database seeding completed successfully!');

  } catch (error) {
    console.error('❌ Database seeding failed:', error);
    throw error;
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });