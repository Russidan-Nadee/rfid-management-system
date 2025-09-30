// seedComputerInfo.js
const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const path = require('path');
const XLSX = require('xlsx');
const prisma = new PrismaClient();

/**
 * Parse date string or Excel serial number to Date object
 */
function parseDate(dateStr) {
  if (!dateStr) {
    return null;
  }

  // If it's a number (Excel serial date)
  if (typeof dateStr === 'number') {
    // Excel date: number of days since 1899-12-30 (Excel's epoch)
    // Excel incorrectly treats 1900 as a leap year, so subtract 1
    const excelEpoch = new Date(Date.UTC(1899, 11, 30));
    const date = new Date(excelEpoch.getTime() + dateStr * 24 * 60 * 60 * 1000);

    // Validate the date is reasonable (between 1900 and 2100)
    if (date.getFullYear() < 1900 || date.getFullYear() > 2100) {
      console.warn(`Invalid Excel date serial: ${dateStr} -> ${date.toISOString()}`);
      return null;
    }

    return date;
  }

  // Convert to string for text parsing
  const str = String(dateStr).trim();

  if (str === '' || str === 'Never') {
    return null;
  }

  try {
    // Format: "23-Sep-2025"
    const [day, month, year] = str.split('-');
    const monthMap = {
      'Jan': 0, 'Feb': 1, 'Mar': 2, 'Apr': 3, 'May': 4, 'Jun': 5,
      'Jul': 6, 'Aug': 7, 'Sep': 8, 'Oct': 9, 'Nov': 10, 'Dec': 11
    };

    if (monthMap[month] !== undefined) {
      const date = new Date(parseInt(year), monthMap[month], parseInt(day));
      return date;
    }

    // Try parsing as ISO date
    const parsed = new Date(str);
    return isNaN(parsed.getTime()) ? null : parsed;
  } catch (error) {
    console.error(`Error parsing date: ${dateStr}`, error);
    return null;
  }
}

/**
 * Clean and normalize string values
 */
function cleanString(str) {
  if (!str) return null;
  // Convert to string if it's a number
  const strValue = typeof str === 'string' ? str : String(str);
  const cleaned = strValue.trim();
  if (cleaned === '' || cleaned === '0' || cleaned === 'ไม่ทราบผู้ใช้งาน') {
    return null;
  }
  return cleaned;
}

/**
 * Convert "Yes"/"No" string to actual string or null
 */
function parseDomain(str) {
  const cleaned = cleanString(str);
  if (!cleaned) return null;
  if (cleaned.toLowerCase() === 'yes') return 'Yes';
  if (cleaned.toLowerCase() === 'no') return 'No';
  return cleaned;
}

/**
 * Parse price from string
 */
function parsePrice(str) {
  const cleaned = cleanString(str);
  if (!cleaned) return null;
  const num = parseFloat(cleaned.replace(/,/g, ''));
  return isNaN(num) ? null : num;
}

/**
 * Parse computer info data file (asset_computer_info.txt or .xlsx)
 * Format: asset_no, operating_system, domain, device_status, invest_plan, price_thb, username, employee_id, employee_name, employee_level
 */
function parseComputerInfoFile(filePath) {
  const computers = [];

  // Check if file is Excel
  if (filePath.endsWith('.xlsx') || filePath.endsWith('.xls')) {
    console.log('📊 Reading Excel file...');
    const workbook = XLSX.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    const data = XLSX.utils.sheet_to_json(worksheet);

    console.log(`📋 Found ${data.length} rows in Excel`);

    for (let i = 0; i < data.length; i++) {
      const row = data[i];

      const assetNoClean = cleanString(row.asset_no || row['asset_no'] || row['Asset No']);

      if (!assetNoClean) {
        console.warn(`Skipping row ${i + 2} without asset_no`);
        continue;
      }

      computers.push({
        asset_no: assetNoClean,
        operating_system: cleanString(row.operating_system || row['Operating System']),
        domain: parseDomain(row.domain || row['Domain']),
        device_status: cleanString(row.device_status || row['Device Status']),
        invest_plan: cleanString(row.invest_plan || row['Invest Plan']),
        price_thb: parsePrice(row.price_thb || row['Price (THB)']),
        username: cleanString(row.username || row['Username']),
        employee_id: cleanString(row.employee_id || row['Employee ID']),
        employee_name: cleanString(row.employee_name || row['Employee Name']),
        employee_level: cleanString(row.employee_level || row['Employee Level'])
      });
    }

    return computers;
  }

  // Text file parsing
  console.log('📄 Reading text file...');
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (!line.trim()) continue;

    const fields = line.split('\t');

    // Skip header line
    if (i === 0 && fields[0] === 'asset_no') {
      console.log('📋 Skipping header line');
      continue;
    }

    if (fields.length < 10) {
      console.warn(`Skipping invalid line ${i + 1} (not enough fields): ${line.substring(0, 50)}...`);
      continue;
    }

    const [
      assetNo,
      operatingSystem,
      domain,
      deviceStatus,
      investPlan,
      priceThb,
      username,
      employeeId,
      employeeName,
      employeeLevel
    ] = fields;

    const assetNoClean = cleanString(assetNo);

    if (!assetNoClean) {
      console.warn(`Skipping line ${i + 1} without asset_no`);
      continue;
    }

    computers.push({
      asset_no: assetNoClean,
      operating_system: cleanString(operatingSystem),
      domain: parseDomain(domain),
      device_status: cleanString(deviceStatus),
      invest_plan: cleanString(investPlan),
      price_thb: parsePrice(priceThb),
      username: cleanString(username),
      employee_id: cleanString(employeeId),
      employee_name: cleanString(employeeName),
      employee_level: cleanString(employeeLevel)
    });
  }

  return computers;
}

/**
 * Parse computer activity data file (asset_computer_activity.txt or .xlsx)
 * Format: asset_no, ip_address, power_on_date, user_logon
 */
function parseComputerActivityFile(filePath) {
  if (!fs.existsSync(filePath)) {
    console.log('⚠️  Activity file not found, skipping activity logs');
    return [];
  }

  const activities = [];

  // Check if file is Excel
  if (filePath.endsWith('.xlsx') || filePath.endsWith('.xls')) {
    console.log('📊 Reading activity Excel file...');
    const workbook = XLSX.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    const data = XLSX.utils.sheet_to_json(worksheet);

    console.log(`📋 Found ${data.length} activity rows in Excel`);

    for (const row of data) {
      const assetNoClean = cleanString(row.asset_no || row['Asset No']);
      if (!assetNoClean) continue;

      activities.push({
        asset_no: assetNoClean,
        ip_address: cleanString(row.ip_address || row['IP Address']),
        power_on_date: parseDate(row.power_on_date || row['Power On Date']),
        user_logon: cleanString(row.user_logon || row['User Logon'])
      });
    }

    return activities;
  }

  // Text file parsing
  console.log('📄 Reading activity text file...');
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (!line.trim()) continue;

    const fields = line.split('\t');

    // Skip header line
    if (i === 0 && fields[0] === 'asset_no') {
      console.log('📋 Skipping activity header line');
      continue;
    }

    if (fields.length < 4) {
      console.warn(`Skipping invalid activity line ${i + 1} (not enough fields)`);
      continue;
    }

    const [assetNo, ipAddress, powerOnDate, userLogon] = fields;

    const assetNoClean = cleanString(assetNo);
    if (!assetNoClean) continue;

    activities.push({
      asset_no: assetNoClean,
      ip_address: cleanString(ipAddress),
      power_on_date: parseDate(cleanString(powerOnDate)),
      user_logon: cleanString(userLogon)
    });
  }

  return activities;
}

/**
 * Seed computer info and activity logs
 */
async function seedComputerInfo() {
  console.log('🖥️  Starting computer info seeding...');

  // Computer info file path
  const infoFilePath = path.join(__dirname, '../../data/asset_computer_info.xlsx');

  if (!fs.existsSync(infoFilePath)) {
    console.error(`❌ File not found: ${infoFilePath}`);
    console.log('Please make sure "backend/data/asset_computer_info.xlsx" exists');
    return;
  }

  console.log(`📂 Using file: ${path.basename(infoFilePath)}`);
  const computers = parseComputerInfoFile(infoFilePath);
  console.log(`📄 Parsed ${computers.length} computer info records`);

  // Activity file path
  const activityFilePath = path.join(__dirname, '../../data/asset_computer_activity.xlsx');
  const activities = parseComputerActivityFile(activityFilePath);
  console.log(`📊 Parsed ${activities.length} activity records`);

  // Create activity lookup map
  const activityMap = new Map();
  for (const activity of activities) {
    if (!activityMap.has(activity.asset_no)) {
      activityMap.set(activity.asset_no, []);
    }
    activityMap.get(activity.asset_no).push(activity);
  }

  let createdCount = 0;
  let updatedCount = 0;
  let skippedCount = 0;
  let activityLogCount = 0;

  console.log('\n⏳ Processing assets...\n');

  for (const computer of computers) {
    try {
      // Check if asset exists in asset_master
      const assetExists = await prisma.asset_master.findUnique({
        where: { asset_no: computer.asset_no }
      });

      if (!assetExists) {
        // console.warn(`⚠️  Asset ${computer.asset_no} not found in asset_master, skipping...`);
        skippedCount++;
        continue;
      }

      // Upsert computer info
      const existing = await prisma.asset_computer_info.findUnique({
        where: { asset_no: computer.asset_no }
      });

      await prisma.asset_computer_info.upsert({
        where: { asset_no: computer.asset_no },
        update: {
          operating_system: computer.operating_system,
          domain: computer.domain,
          device_status: computer.device_status,
          invest_plan: computer.invest_plan,
          price_thb: computer.price_thb,
          username: computer.username,
          employee_id: computer.employee_id,
          employee_name: computer.employee_name,
          employee_level: computer.employee_level,
          updated_at: new Date()
        },
        create: {
          asset_no: computer.asset_no,
          operating_system: computer.operating_system,
          domain: computer.domain,
          device_status: computer.device_status,
          invest_plan: computer.invest_plan,
          price_thb: computer.price_thb,
          username: computer.username,
          employee_id: computer.employee_id,
          employee_name: computer.employee_name,
          employee_level: computer.employee_level
        }
      });

      if (!existing) {
        createdCount++;
      } else {
        updatedCount++;
      }

      // Create activity logs for this asset
      const assetActivities = activityMap.get(computer.asset_no) || [];
      for (const activity of assetActivities) {
        // Skip if power_on_date is invalid
        const powerOnDate = activity.power_on_date;
        if (powerOnDate && isNaN(powerOnDate.getTime())) {
          continue; // Skip invalid dates
        }

        await prisma.asset_computer_activity.create({
          data: {
            asset_no: activity.asset_no,
            ip_address: activity.ip_address,
            power_on_date: powerOnDate,
            user_logon: activity.user_logon,
            logged_at: new Date()
          }
        });
        activityLogCount++;
      }

    } catch (error) {
      console.error(`❌ Error processing ${computer.asset_no}:`, error.message);
      skippedCount++;
    }
  }

  console.log('\n✅ Computer info seeding completed!');
  console.log(`   📊 Created: ${createdCount}`);
  console.log(`   🔄 Updated: ${updatedCount}`);
  console.log(`   ⏭️  Skipped: ${skippedCount}`);
  console.log(`   📝 Activity logs created: ${activityLogCount}`);
}

// Run if called directly
if (require.main === module) {
  seedComputerInfo()
    .catch((error) => {
      console.error('❌ Error seeding computer info:', error);
      process.exit(1);
    })
    .finally(async () => {
      await prisma.$disconnect();
    });
}

module.exports = { seedComputerInfo };