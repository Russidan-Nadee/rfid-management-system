// updateAssetDepartments.js
const { PrismaClient } = require('@prisma/client');
const XLSX = require('xlsx');
const path = require('path');
const prisma = new PrismaClient();

async function updateAssetDepartments() {
  try {
    console.log('Starting to update asset departments and plants...');

    // Read Excel file
    const excelPath = path.join(__dirname, '../../data/asset_no_with_department_for_make_seed.xlsx');
    const workbook = XLSX.readFile(excelPath);
    const worksheet = workbook.Sheets[workbook.SheetNames[0]];
    const data = XLSX.utils.sheet_to_json(worksheet);

    console.log(`Found ${data.length} rows in Excel file`);

    // Get all departments and plants
    const departments = await prisma.mst_department.findMany();
    const plants = await prisma.mst_plant.findMany();

    // Create lookup maps (case-insensitive)
    const deptByDescription = new Map();
    departments.forEach(dept => {
      const key = dept.description.trim().toLowerCase();
      deptByDescription.set(key, dept);
    });

    const plantByCode = new Map();
    plants.forEach(plant => {
      plantByCode.set(plant.plant_code, plant);
    });

    let successCount = 0;
    let skipCount = 0;
    let notFoundCount = 0;
    const notFoundDepts = new Set();

    for (const row of data) {
      try {
        const assetNo = row.asset_no;
        const deptRaw = row.dept_raw ? row.dept_raw.trim() : '';

        // Skip if no asset_no or empty dept_raw
        if (!assetNo || !deptRaw || deptRaw === ' ') {
          skipCount++;
          continue;
        }

        // Find department by description (case-insensitive)
        const deptKey = deptRaw.toLowerCase();
        const department = deptByDescription.get(deptKey);

        if (!department) {
          notFoundDepts.add(deptRaw);
          notFoundCount++;
          console.log(`⚠ Department not found for: ${assetNo} -> "${deptRaw}"`);
          continue;
        }

        // Get plant if department has plant_code
        let plantId = null;
        if (department.plant_code) {
          const plant = plantByCode.get(department.plant_code);
          if (plant) {
            plantId = plant.plant_id;
          }
        }

        // Update asset
        await prisma.asset.update({
          where: { asset_no: assetNo },
          data: {
            department_id: department.dept_id,
            plant_id: plantId,
          },
        });

        successCount++;
        if (successCount % 50 === 0) {
          console.log(`Processed ${successCount} assets...`);
        }
      } catch (error) {
        console.error(`Error updating asset ${row.asset_no}:`, error.message);
        skipCount++;
      }
    }

    console.log('\n=== Summary ===');
    console.log(`✓ Successfully updated: ${successCount} assets`);
    console.log(`⏭ Skipped (empty dept): ${skipCount} assets`);
    console.log(`⚠ Not found departments: ${notFoundCount} assets`);

    if (notFoundDepts.size > 0) {
      console.log('\n=== Departments not found in database ===');
      [...notFoundDepts].sort().forEach(dept => console.log(`  - "${dept}"`));
    }
  } catch (error) {
    console.error('Error updating asset departments:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

// Run if called directly
if (require.main === module) {
  updateAssetDepartments();
}

module.exports = updateAssetDepartments;
