// seedCostCenters.js - Complete cost center and division data
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/** =========================
 * 1) DIVISION DATA (Complete)
 * ========================= */
const DIVISIONS = [
  {
    division_code: 'ADMINISTRATIVE',
    division_name: 'Administrative Division',
    description: 'Administrative support functions including HR, IT, Finance, General Affairs'
  },
  {
    division_code: 'H&S_BUSINESS',
    division_name: 'Health & Safety Business Division',
    description: 'Health & Safety business operations, production, quality control, and engineering'
  },
  {
    division_code: 'BUSINESS',
    division_name: 'Business Division',
    description: 'Marketing, sales, chemical support, analysis, and commercial activities'
  },
  {
    division_code: 'CORPORATE_PLANNING',
    division_name: 'Corporate Planning Division',
    description: 'Corporate planning, legal affairs, and procurement functions'
  },
  {
    division_code: 'OTHER',
    division_name: 'Other Division',
    description: 'Quality assurance and special environmental functions'
  }
];

/** =========================
 * 2) COST CENTER DATA (Complete from raw data)
 * ========================= */
const COST_CENTERS = [
  // ADMINISTRATIVE DIVISION - 90xxxx
  {
    cost_center_code: '903100',
    cost_center_name: 'Administrative Services',
    division_code: 'ADMINISTRATIVE',
    plant_code: null,
    function_type: 'Administrative',
    description: 'Human Resources, Information Technology, Accounting, General Affairs'
  },
  {
    cost_center_code: '903300',
    cost_center_name: 'General Affair ESIE1',
    division_code: 'ADMINISTRATIVE',
    plant_code: 'TP-ESIE1',
    function_type: 'Administrative',
    description: 'General Affairs operations at ESIE1 plant'
  },

  // H&S BUSINESS DIVISION - Quality Control 20xxxx, 23xxxx
  {
    cost_center_code: '200200',
    cost_center_name: 'Quality Control BP/GW',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-BP12',
    function_type: 'Quality Control',
    description: 'Quality Control operations at BP and GW plants'
  },
  {
    cost_center_code: '230200',
    cost_center_name: 'Quality Control ESIE1',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Quality Control',
    description: 'Quality Control operations at ESIE1 plant'
  },

  // H&S BUSINESS DIVISION - Production 21xxxx, 23xxxx
  {
    cost_center_code: '214000',
    cost_center_name: 'Gas Production BP',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-BP12',
    function_type: 'Production',
    description: 'Gas production operations at BP plant'
  },
  {
    cost_center_code: '221000',
    cost_center_name: 'Gas Production GW',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-GW',
    function_type: 'Production',
    description: 'Gas production operations at GW plant'
  },
  {
    cost_center_code: '237000',
    cost_center_name: 'Gas Production ESIE1',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Production',
    description: 'Gas production operations at ESIE1 plant'
  },
  {
    cost_center_code: '211000',
    cost_center_name: 'Phosphate Production BP',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-BP12',
    function_type: 'Production',
    description: 'Phosphate production operations at BP plant'
  },
  {
    cost_center_code: '231000',
    cost_center_name: 'Phosphate Production ESIE1',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Production',
    description: 'Phosphate production operations at ESIE1 plant'
  },
  {
    cost_center_code: '213000',
    cost_center_name: 'Kanigen Production',
    division_code: 'H&S_BUSINESS',
    plant_code: null,
    function_type: 'Production',
    description: 'Kanigen production operations'
  },
  {
    cost_center_code: '235000',
    cost_center_name: 'Delta ESIE1 Operations',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Production',
    description: 'Delta operations at ESIE1 plant'
  },
  {
    cost_center_code: '234000',
    cost_center_name: 'Pallube ESIE1',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Production',
    description: 'Pallube operations at ESIE1 plant'
  },
  {
    cost_center_code: '236000',
    cost_center_name: 'Isonite ESIE1',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Production',
    description: 'Isonite operations at ESIE1 plant'
  },

  // H&S BUSINESS DIVISION - Support Operations 20xxxx, 23xxxx
  {
    cost_center_code: '200300',
    cost_center_name: 'Maintenance BP/GW',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-BP12',
    function_type: 'Maintenance',
    description: 'Maintenance operations at BP and GW plants'
  },
  {
    cost_center_code: '230300',
    cost_center_name: 'Maintenance ESIE1',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Maintenance',
    description: 'Maintenance operations at ESIE1 plant'
  },
  {
    cost_center_code: '200500',
    cost_center_name: 'Production Engineering',
    division_code: 'H&S_BUSINESS',
    plant_code: null,
    function_type: 'Engineering',
    description: 'Production engineering support'
  },
  {
    cost_center_code: '230100',
    cost_center_name: 'Safety & Environmental ESIE1',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Safety',
    description: 'Safety, Environment, Waste Water operations at ESIE1'
  },
  {
    cost_center_code: '200100',
    cost_center_name: 'Safety & Environmental BP/GW',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-BP12',
    function_type: 'Safety',
    description: 'Safety & Environmental operations at BP and GW plants'
  },
  {
    cost_center_code: '200410',
    cost_center_name: 'Management Shared Services',
    division_code: 'H&S_BUSINESS',
    plant_code: null,
    function_type: 'Management',
    description: 'Management shared services across H&S Business'
  },

  // H&S BUSINESS DIVISION - Delivery Centers 299xxx
  {
    cost_center_code: '299110',
    cost_center_name: 'Delivery Center H&S-BP',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-BP12',
    function_type: 'Delivery',
    description: 'H&S delivery center at BP plant'
  },
  {
    cost_center_code: '299120',
    cost_center_name: 'Delivery Center H&S-GW',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-GW',
    function_type: 'Delivery',
    description: 'H&S delivery center at GW plant'
  },
  {
    cost_center_code: '299130',
    cost_center_name: 'Delivery Center H&S-ESIE1',
    division_code: 'H&S_BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Delivery',
    description: 'H&S delivery center at ESIE1 plant'
  },

  // BUSINESS DIVISION - Marketing 901xxx, 299xxx
  {
    cost_center_code: '901100',
    cost_center_name: 'Automation',
    division_code: 'BUSINESS',
    plant_code: null,
    function_type: 'Technology',
    description: 'Automation and technology support'
  },
  {
    cost_center_code: '901200',
    cost_center_name: 'Marketing Management',
    division_code: 'BUSINESS',
    plant_code: null,
    function_type: 'Marketing',
    description: 'Marketing management and administration'
  },
  {
    cost_center_code: '901300',
    cost_center_name: 'Marketing Support',
    division_code: 'BUSINESS',
    plant_code: null,
    function_type: 'Marketing',
    description: 'Marketing support services'
  },
  {
    cost_center_code: '901400',
    cost_center_name: 'Marketing Bill Collector',
    division_code: 'BUSINESS',
    plant_code: null,
    function_type: 'Marketing',
    description: 'Marketing billing and collection services'
  },
  {
    cost_center_code: '901500',
    cost_center_name: 'Marketing Development',
    division_code: 'BUSINESS',
    plant_code: null,
    function_type: 'Marketing',
    description: 'Marketing development and business growth'
  },
  {
    cost_center_code: '299210',
    cost_center_name: 'Marketing H&S BP',
    division_code: 'BUSINESS',
    plant_code: 'TP-BP12',
    function_type: 'Marketing',
    description: 'H&S marketing operations at BP plant'
  },
  {
    cost_center_code: '299220',
    cost_center_name: 'Marketing H&S ESIE1',
    division_code: 'BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Marketing',
    description: 'H&S marketing operations at ESIE1 plant'
  },

  // BUSINESS DIVISION - Chemical & Analysis 1xxxxx, 902xxx, 199xxx
  {
    cost_center_code: '110100',
    cost_center_name: 'Chemical Support',
    division_code: 'BUSINESS',
    plant_code: null,
    function_type: 'Chemical',
    description: 'Chemical support and related business operations'
  },
  {
    cost_center_code: '110110',
    cost_center_name: 'Chemical Liquid',
    division_code: 'BUSINESS',
    plant_code: null,
    function_type: 'Chemical',
    description: 'Chemical liquid operations'
  },
  {
    cost_center_code: '110120',
    cost_center_name: 'Chemical Prepalene-X',
    division_code: 'BUSINESS',
    plant_code: null,
    function_type: 'Chemical',
    description: 'Chemical Prepalene-X operations'
  },
  {
    cost_center_code: '902100',
    cost_center_name: 'Analysis & Technical Control BP',
    division_code: 'BUSINESS',
    plant_code: 'TP-BP12',
    function_type: 'Analysis',
    description: 'Analysis center and technical control at BP plant'
  },
  {
    cost_center_code: '902200',
    cost_center_name: 'Analysis Center ESIE1',
    division_code: 'BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Analysis',
    description: 'Analysis center operations at ESIE1 plant'
  },
  {
    cost_center_code: '199100',
    cost_center_name: 'Delivery Center Chemical BP',
    division_code: 'BUSINESS',
    plant_code: 'TP-BP12',
    function_type: 'Delivery',
    description: 'Chemical delivery center at BP plant'
  },
  {
    cost_center_code: '199210',
    cost_center_name: 'Marketing Chemical BP',
    division_code: 'BUSINESS',
    plant_code: 'TP-BP12',
    function_type: 'Marketing',
    description: 'Chemical marketing operations at BP plant'
  },
  {
    cost_center_code: '199220',
    cost_center_name: 'Marketing Chemical ESIE1',
    division_code: 'BUSINESS',
    plant_code: 'TP-ESIE1',
    function_type: 'Marketing',
    description: 'Chemical marketing operations at ESIE1 plant'
  },

  // CORPORATE PLANNING DIVISION - 904xxx
  {
    cost_center_code: '904100',
    cost_center_name: 'Law & Planning',
    division_code: 'CORPORATE_PLANNING',
    plant_code: null,
    function_type: 'Legal',
    description: 'Legal affairs and corporate planning'
  },
  {
    cost_center_code: '904200',
    cost_center_name: 'Purchasing',
    division_code: 'CORPORATE_PLANNING',
    plant_code: null,
    function_type: 'Procurement',
    description: 'Purchasing and procurement services'
  },

  // OTHER DIVISION - 905xxx
  {
    cost_center_code: '905100',
    cost_center_name: 'Quality Assurance',
    division_code: 'OTHER',
    plant_code: null,
    function_type: 'Quality Assurance',
    description: 'Quality assurance operations'
  },
  {
    cost_center_code: '905200',
    cost_center_name: 'Safety & Environmental (Central)',
    division_code: 'OTHER',
    plant_code: null,
    function_type: 'Safety',
    description: 'Central safety and environmental coordination'
  }
];

/** =========================
 * 3) COMPLETE DEPARTMENT NAME TO COST CENTER MAPPING
 * ========================= */
const DEPT_NAME_TO_COST_CENTER = {
  // ADMINISTRATIVE - 903100, 903300
  'Human Resources': '903100',
  'Information Technology BP': '903100',
  'Information Technology ESIE1': '903100',
  'Account': '903100',
  'General Affair BP': '903100',
  'General Affair ESIE1': '903300',

  // H&S BUSINESS - Quality Control 200200, 230200
  'Quality Control GW': '200200',
  'Quality Control BP': '200200',
  'Quality Control ESIE1': '230200',

  // H&S BUSINESS - Production 21xxxx, 23xxxx
  'Gas BP': '214000',
  'Gas GW': '221000',
  'Gas ESIE1': '237000',
  'Phosphate BP': '211000',
  'Phosphate ESIE1': '231000',
  'Kanigen': '213000',
  'Delta ESIE1': '235000',
  'Pallube ESIE1': '234000',
  'Isonite ESIE1': '236000',

  // H&S BUSINESS - Support 200xxx, 230xxx
  'Maintenance BP': '200300',
  'Maintenance GW': '200300',
  'Maintenance ESIE1': '230300',
  'Prod.Engineering': '200500',
  'Safety, Environment, Waste Water-ESIE1': '230100',
  'Safety&Environmental BP(F)': '200100',
  'Safety&Environmental GW (F)': '200100',
  'Management-Share All': '200410',
  'General Affair GW': '221000',

  // H&S BUSINESS - Delivery Centers 299xxx
  'Delivery Center H&S-BP': '299110',
  'Delivery Center H&S-GW': '299120',
  'Delivery Center H&S-ESIE1': '299130',

  // BUSINESS - Marketing 901xxx, 299xxx
  'Automation': '901100',
  'Marketing Management': '901200',
  'Marketing Support': '901300',
  'Marketing Bill Collector': '901400',
  'Marketing Development': '901500',
  'Marketing H&S BP': '299210',
  'Marketing H&S ESIE1': '299220',

  // BUSINESS - Chemical & Analysis 1xxxxx, 902xxx, 199xxx
  'Chemical Support': '110100',
  'Chem/Liquid': '110110',
  'Chem/Prepalene - X': '110120',
  'Analysis Center BP': '902100',
  'Analysis Center ESIE1': '902200',
  'Analysis Center Special BP': '902100',
  'Technical Control BP': '902100',
  'Delivery Center Chem - BP': '199100',
  'Marketing Chem BP': '199210',
  'Marketing Chem ESIE1': '199220',

  // CORPORATE PLANNING - 904xxx
  'Law & Planning': '904100',
  'Purchasing BP': '904200',
  'Purchasing ESIE1': '904200',

  // OTHER - 905xxx
  'Quality Assurance ESIE1': '905100',
  'Quality Assurance BP 12': '905100',
  'Quality Assurance BP 8': '905100',
  'Safety & Environmental (C)': '905200'
};

/** =========================
 * 4) DEPARTMENT CODE TO COST CENTER MAPPING
 * ========================= */
const DEPT_CODE_TO_COST_CENTER = [
  // ADMINISTRATIVE
  { dept_code: 'HR', default_cost_center: '903100' },
  { dept_code: 'IT-BP', default_cost_center: '903100' },
  { dept_code: 'IT-ESIE1', default_cost_center: '903100' },
  { dept_code: 'ACC', default_cost_center: '903100' },
  { dept_code: 'GA-BP', default_cost_center: '903100' },
  { dept_code: 'GA-ESIE1', default_cost_center: '903300' },

  // H&S BUSINESS - Quality Control
  { dept_code: 'QC-GW', default_cost_center: '200200' },
  { dept_code: 'QC-BP', default_cost_center: '200200' },
  { dept_code: 'QC-ESIE1', default_cost_center: '230200' },

  // H&S BUSINESS - Production
  { dept_code: 'GAS-BP', default_cost_center: '214000' },
  { dept_code: 'GAS-GW', default_cost_center: '221000' },
  { dept_code: 'GAS-ESIE1', default_cost_center: '237000' },
  { dept_code: 'PHOS-BP', default_cost_center: '211000' },
  { dept_code: 'PHOS-ESIE1', default_cost_center: '231000' },
  { dept_code: 'KANI', default_cost_center: '213000' },
  { dept_code: 'DEL-ESIE1', default_cost_center: '235000' },
  { dept_code: 'PAL-ESIE1', default_cost_center: '234000' },
  { dept_code: 'ISO-ESIE1', default_cost_center: '236000' },

  // H&S BUSINESS - Support
  { dept_code: 'MAINT-BP', default_cost_center: '200300' },
  { dept_code: 'MAINT-GW', default_cost_center: '200300' },
  { dept_code: 'MAINT-ESIE1', default_cost_center: '230300' },
  { dept_code: 'PE', default_cost_center: '200500' },
  { dept_code: 'SE-BP-F', default_cost_center: '200100' },
  { dept_code: 'SE-GW-F', default_cost_center: '200100' },
  { dept_code: 'MGT-SHARE', default_cost_center: '200410' },
  { dept_code: 'GA-GW', default_cost_center: '221000' },

  // BUSINESS - Marketing
  { dept_code: 'AUTO', default_cost_center: '901100' },
  { dept_code: 'MKT-MGT', default_cost_center: '901200' },
  { dept_code: 'MKT-SUP', default_cost_center: '901300' },
  { dept_code: 'MKT-BC', default_cost_center: '901400' },
  { dept_code: 'MKT-DEV', default_cost_center: '901500' },

  // BUSINESS - Chemical & Analysis
  { dept_code: 'CHEM-SUP', default_cost_center: '110100' },
  { dept_code: 'AC-BP', default_cost_center: '902100' },
  { dept_code: 'AC-ESIE1', default_cost_center: '902200' },
  { dept_code: 'AC-SP-BP', default_cost_center: '902100' },
  { dept_code: 'TC-BP', default_cost_center: '902100' },

  // CORPORATE PLANNING
  { dept_code: 'LAW', default_cost_center: '904100' },
  { dept_code: 'PUR-BP', default_cost_center: '904200' },
  { dept_code: 'PUR-ESIE1', default_cost_center: '904200' },

  // OTHER
  { dept_code: 'QA-ESIE1', default_cost_center: '905100' },
  { dept_code: 'QA-BP12', default_cost_center: '905100' },
  { dept_code: 'QA-BP8', default_cost_center: '905100' },
  { dept_code: 'SE-C', default_cost_center: '905200' }
];

/** =========================
 * 5) MAIN SEED FUNCTIONS
 * ========================= */
async function seedDivisions() {
  console.log('🏢 Seeding divisions...');

  for (const division of DIVISIONS) {
    try {
      await prisma.mst_division.upsert({
        where: { division_code: division.division_code },
        update: division,
        create: division
      });
      console.log(`✅ Division: ${division.division_code} - ${division.division_name}`);
    } catch (error) {
      console.error(`❌ Failed to seed division ${division.division_code}:`, error.message);
    }
  }
}

async function seedCostCenters() {
  console.log('💰 Seeding cost centers...');

  for (const costCenter of COST_CENTERS) {
    try {
      await prisma.mst_cost_center.upsert({
        where: { cost_center_code: costCenter.cost_center_code },
        update: costCenter,
        create: costCenter
      });
      console.log(`✅ Cost Center: ${costCenter.cost_center_code} - ${costCenter.cost_center_name}`);
    } catch (error) {
      console.error(`❌ Failed to seed cost center ${costCenter.cost_center_code}:`, error.message);
    }
  }
}

async function seedDeptCostCenterMapping() {
  console.log('🔗 Seeding department to cost center mapping...');

  for (const mapping of DEPT_CODE_TO_COST_CENTER) {
    try {
      // ตรวจสอบว่า department มีอยู่จริงไหม
      const deptExists = await prisma.mst_department.findUnique({
        where: { dept_code: mapping.dept_code }
      });

      if (!deptExists) {
        console.log(`⏭️  Skip mapping ${mapping.dept_code} (department not found)`);
        continue;
      }

      await prisma.dept_cost_center_mapping.upsert({
        where: { dept_code: mapping.dept_code },
        update: mapping,
        create: mapping
      });
      console.log(`✅ Mapping: ${mapping.dept_code} → ${mapping.default_cost_center}`);
    } catch (error) {
      console.error(`❌ Failed to seed mapping ${mapping.dept_code}:`, error.message);
    }
  }
}

async function seedCostCentersComplete() {
  console.log('🚀 Starting complete cost center and division seeding...');
  await prisma.$connect();

  try {
    await seedDivisions();
    await seedCostCenters();
    await seedDeptCostCenterMapping();

    console.log('\n📊 Complete cost center and division seeding finished successfully!');
    console.log('📋 Summary:');
    console.log(`   🏢 Divisions: ${DIVISIONS.length}`);
    console.log(`   💰 Cost Centers: ${COST_CENTERS.length}`);
    console.log(`   🔗 Department Mappings: ${DEPT_CODE_TO_COST_CENTER.length}`);
  } catch (error) {
    console.error('❌ Error during seeding:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  seedCostCentersComplete()
    .catch((e) => {
      console.error(e);
      process.exit(1);
    });
}

module.exports = {
  seedCostCentersComplete,
  DEPT_NAME_TO_COST_CENTER,
  DIVISIONS,
  COST_CENTERS
};