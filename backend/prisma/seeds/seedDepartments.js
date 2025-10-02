const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const departmentData = [
  { dept_code: 'AC-BP', description: 'Analysis Center BP', plant_code: 'TP-BP12' },
  { dept_code: 'AC-ESIE1', description: 'Analysis Center ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'AC-SP-BP', description: 'Analysis Center Special BP', plant_code: 'TP-BP12' },
  { dept_code: 'AC-SP-ESIE1', description: 'Analysis Center Special ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'ACC', description: 'Account', plant_code: null },
  { dept_code: 'AUTO', description: 'Automation', plant_code: null },
  { dept_code: 'CHEM-LIQ', description: 'Chem/Liquid', plant_code: null },
  { dept_code: 'CHEM-PREP-X', description: 'Chem/Prepalene - X', plant_code: null },
  { dept_code: 'CHEM-SUP', description: 'Chemical Support', plant_code: null },
  { dept_code: 'DC-CHEM-BP', description: 'Delivery Center Chem - BP', plant_code: 'TP-BP12' },
  { dept_code: 'DC-HS-BP', description: 'Delivery Center H&S-BP', plant_code: 'TP-BP12' },
  { dept_code: 'DC-HS-ESIE1', description: 'Delivery Center H&S-ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'DC-HS-GW', description: 'Delivery Center H&S-GW', plant_code: 'TP-GW' },
  { dept_code: 'DEL-ESIE1', description: 'Delta ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'GA-BP', description: 'General Affair BP', plant_code: 'TP-BP12' },
  { dept_code: 'GA-ESIE1', description: 'General Affair ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'GA-GW', description: 'General Affair GW', plant_code: 'TP-GW' },
  { dept_code: 'GAS-BP', description: 'Gas BP', plant_code: 'TP-BP12' },
  { dept_code: 'GAS-ESIE1', description: 'Gas ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'GAS-GW', description: 'Gas GW', plant_code: 'TP-GW' },
  { dept_code: 'HR', description: 'Human Resources', plant_code: null },
  { dept_code: 'ISO-ESIE1', description: 'Isonite ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'IT-BP', description: 'Information Technology BP', plant_code: 'TP-BP12' },
  { dept_code: 'IT-ESIE1', description: 'Information Technology ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'KANI', description: 'Kanigen', plant_code: null },
  { dept_code: 'LAW', description: 'Law & Planning', plant_code: null },
  { dept_code: 'MAINT-BP', description: 'Maintenance BP', plant_code: 'TP-BP12' },
  { dept_code: 'MAINT-ESIE1', description: 'Maintenance ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'MAINT-GW', description: 'Maintenance GW', plant_code: 'TP-GW' },
  { dept_code: 'MGT-SHARE', description: 'Management-Share All', plant_code: null },
  { dept_code: 'MKT-BC', description: 'Marketing Bill Collector', plant_code: null },
  { dept_code: 'MKT-CHEM-BP', description: 'Marketing Chem BP', plant_code: 'TP-BP12' },
  { dept_code: 'MKT-CHEM-ESIE1', description: 'Marketing Chem ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'MKT-DEV', description: 'Marketing Development', plant_code: null },
  { dept_code: 'MKT-HS-BP', description: 'Marketing H&S BP', plant_code: 'TP-BP12' },
  { dept_code: 'MKT-HS-ESIE1', description: 'Marketing H&S ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'MKT-MGT', description: 'Marketing Management', plant_code: null },
  { dept_code: 'MKT-SUP', description: 'Marketing Support', plant_code: null },
  { dept_code: 'PAL-ESIE1', description: 'Pallube ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'PE', description: 'Prod.Engineering', plant_code: null },
  { dept_code: 'PHOS-BP', description: 'Phosphate BP', plant_code: 'TP-BP12' },
  { dept_code: 'PHOS-ESIE1', description: 'Phosphate ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'PUR-BP', description: 'Purchasing BP', plant_code: 'TP-BP12' },
  { dept_code: 'PUR-ESIE1', description: 'Purchasing ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'QA-BP12', description: 'Quality Assurance BP 12', plant_code: 'TP-BP12' },
  { dept_code: 'QA-BP8', description: 'Quality Assurance BP 8', plant_code: 'TP-BP12' },
  { dept_code: 'QA-ESIE1', description: 'Quality Assurance ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'QC-BP', description: 'Quality Control BP', plant_code: 'TP-BP12' },
  { dept_code: 'QC-ESIE1', description: 'Quality Control ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'QC-GW', description: 'Quality Control GW', plant_code: 'TP-GW' },
  { dept_code: 'SE-BP-F', description: 'Safety&Environmental BP(F)', plant_code: 'TP-BP12' },
  { dept_code: 'SE-C', description: 'Safety & Environmental (C)', plant_code: null },
  { dept_code: 'SE-GW-F', description: 'Safety&Environmental GW (F)', plant_code: 'TP-GW' },
  { dept_code: 'SEWW-ESIE1', description: 'Safety, Environment, Waste Water-ESIE1', plant_code: 'TP-ESIE1' },
  { dept_code: 'TC-BP', description: 'Technical Control BP', plant_code: 'TP-BP12' }
];

async function seedDepartments() {
  try {
    console.log('🏢 Seeding Departments...');
    
    await prisma.$connect();
    
    let created = 0;
    let skipped = 0;

    for (const department of departmentData) {
      try {
        const existing = await prisma.mst_department.findUnique({
          where: { dept_code: department.dept_code }
        });
        
        if (!existing) {
          await prisma.mst_department.create({ data: department });
          console.log(`✅ Created department: ${department.dept_code} - ${department.description}`);
          created++;
        } else {
          console.log(`⏭️  Skipping department: ${department.dept_code} (exists)`);
          skipped++;
        }
      } catch (error) {
        console.error(`❌ Failed to create department ${department.dept_code}:`, error.message);
      }
    }

    console.log(`\n📊 Departments Summary: ${created} created, ${skipped} skipped`);
    
  } catch (error) {
    console.error('💥 Department seeding failed:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  seedDepartments();
}

module.exports = { seedDepartments };