// seedAssets.js
const { PrismaClient } = require('@prisma/client');
const XLSX = require('xlsx');
const path = require('path');
const prisma = new PrismaClient();

async function seedAssets() {
  try {
    console.log('Starting to seed assets from Excel file...');

    // Read Excel file
    const excelPath = path.join(__dirname, '../../data/all_asset_no_dept.xlsx');
    const workbook = XLSX.readFile(excelPath);
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    const data = XLSX.utils.sheet_to_json(worksheet);

    console.log(`Found ${data.length} rows in Excel file`);

    // Get reference data
    const categories = await prisma.mst_category.findMany();
    const brands = await prisma.mst_brand.findMany();
    const units = await prisma.mst_unit.findMany();
    const locations = await prisma.mst_location.findMany();
    const costCenters = await prisma.mst_cost_center.findMany();

    // Create lookup maps
    const categoryMap = new Map(categories.map(c => [c.category_code, c.category_code]));
    // Add mapping for Excel category names
    categoryMap.set('Laptop', 'LAP');
    categoryMap.set('PC', 'PC');
    // Brand mapping: Excel has brand names (e.g., "LENOVO"), need to map to codes (e.g., "LENOVO")
    const brandMap = new Map(brands.map(b => [b.brand_name.trim().toLowerCase(), b.brand_code]));
    const unitMap = new Map(units.map(u => [u.unit_code, u.unit_code]));
    const locationMap = new Map(locations.map(l => [l.location_code, l.location_code]));
    const costCenterMap = new Map(costCenters.map(cc => [cc.cost_center_code, cc.cost_center_code]));

    let successCount = 0;
    let skipCount = 0;

    for (let i = 0; i < data.length; i++) {
      const row = data[i];
      try {
        // Generate sequential EPC code (E280116060000200 + 8 digit number = 24 chars total)
        // If number exceeds 8 digits, take only the last 8 digits
        const epcNumber = ((i + 1) % 100000000).toString().padStart(8, '0');
        const epcCode = `E280116060000200${epcNumber}`;

        // Determine unit_code based on category
        const categoryCode = categoryMap.get(row.category_code) || null;
        let unitCode = 'SET'; // Default
        if (categoryCode === 'LAP') {
          unitCode = 'EA'; // Laptop is a single unit
        } else if (categoryCode === 'PC') {
          unitCode = 'SET'; // PC includes monitor, keyboard, mouse
        }

        // Determine created_at from asset_no (extract Buddhist year and convert to AD)
        let createdAt = new Date();
        if (row.asset_no) {
          const assetNo = row.asset_no.trim();
          let yearDigits = null;

          // Extract year from asset_no pattern
          if (assetNo.match(/^C\d/)) {
            // Pattern: C5xxxx or C6xxxx -> extract first 2 digits after C
            yearDigits = assetNo.substring(1, 3);
          } else if (assetNo.match(/^CL\d/)) {
            // Pattern: CLxxxx -> extract first 2 digits after CL
            yearDigits = assetNo.substring(2, 4);
          } else if (assetNo.match(/^NB\d/)) {
            // Pattern: NBxxxx -> extract first 2 digits after NB
            yearDigits = assetNo.substring(2, 4);
          }

          if (yearDigits) {
            // Convert to Buddhist year (25xx) and then to AD year
            const buddhistYear = 2500 + parseInt(yearDigits);
            const adYear = buddhistYear - 543;
            createdAt = new Date(`${adYear}-01-01`);
          }
        }

        // Map Excel columns to database fields (Excel has codes directly)
        const assetData = {
          asset_no: row.asset_no,
          epc_code: epcCode,
          description: row.description || row.asset_name || null,
          category_code: categoryCode,
          brand_code: brandMap.get(row.brand_code ? row.brand_code.trim().toLowerCase() : '') || null,
          serial_no: row.serial_no || null,
          inventory_no: row.inventory_no || null,
          unit_code: unitCode,
          location_code: locationMap.get(row.location_code) || null,
          cost_center_code: costCenterMap.get(row.cost_center_code) || null,
          // department and plant will be null since they're not in the Excel
          dept_code: null,
          plant_code: null,
          quantity: row.quantity ? parseFloat(row.quantity) : 1,
          status: Math.random() < 0.5 ? 'A' : 'C', // Random status: A or C
          created_at: createdAt,
        };

        // Create asset
        await prisma.asset_master.create({
          data: assetData,
        });

        successCount++;
        if (successCount % 100 === 0) {
          console.log(`Processed ${successCount} assets...`);
        }
      } catch (error) {
        console.error(`Error creating asset ${row.asset_no || 'unknown'}:`, error.message);
        skipCount++;
      }
    }

    console.log(`✓ Successfully seeded ${successCount} assets`);
    if (skipCount > 0) {
      console.log(`⚠ Skipped ${skipCount} assets due to errors`);
    }

    // Update departments and plants for assets
    console.log('\n🏢 Updating asset departments and plants...');
    await updateAssetDepartments();

  } catch (error) {
    console.error('Error seeding assets:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

async function updateAssetDepartments() {
  try {
    // Read Excel file with department mapping
    const excelPath = path.join(__dirname, '../../data/asset_no_with_department_for_make_seed.xlsx');
    const workbook = XLSX.readFile(excelPath);
    const worksheet = workbook.Sheets[workbook.SheetNames[0]];
    const data = XLSX.utils.sheet_to_json(worksheet);

    console.log(`Found ${data.length} rows in department mapping file`);

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
          continue;
        }

        // Get plant if department has plant_code
        let plantCode = null;
        if (department.plant_code) {
          const plant = plantByCode.get(department.plant_code);
          if (plant) {
            plantCode = plant.plant_code;
          }
        }

        // Update asset
        await prisma.asset_master.update({
          where: { asset_no: assetNo },
          data: {
            dept_code: department.dept_code,
            plant_code: plantCode,
          },
        });

        successCount++;
        if (successCount % 50 === 0) {
          console.log(`   Processed ${successCount} assets...`);
        }
      } catch (error) {
        skipCount++;
      }
    }

    console.log(`   ✓ Successfully updated: ${successCount} assets`);
    console.log(`   ⏭ Skipped (empty dept): ${skipCount} assets`);
    if (notFoundCount > 0) {
      console.log(`   ⚠ Not found departments: ${notFoundCount} assets`);
    }
  } catch (error) {
    console.error('Error updating asset departments:', error);
    throw error;
  }
}

// Run if called directly
if (require.main === module) {
  seedAssets();
}

module.exports = seedAssets;
