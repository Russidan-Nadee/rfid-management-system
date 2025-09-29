// seedAssets.js
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/** =========================
 * 1) CONFIG / MAPPING
 * ========================= */
const INVALID_SERIALS = new Set(['0', 'INVALID', 'To Be Filled By O.E.M.']);
const BRAND_MAP = {
  'LENOVO': 'LENOVO',
  'LENOVO ': 'LENOVO',
  'Dell Inc.': 'DEL',
  'DELL': 'DEL',
  'DELL INC.': 'DEL',
  'HP': 'HP',
};

const DEPT_CODE_MAP = {
  'Human Resources': 'HR',
  'Quality Control GW': 'QC-GW',
  'Quality Control ESIE1': 'QC-ESIE1',
  'Quality Control BP': 'QC-BP',
  'Chemical Support': 'CHEM-SUP',
  'Gas BP': 'GAS-BP',
  'Gas GW': 'GAS-GW',
  'Maintenance ESIE1': null, // มากกว่า 10 chars
  'Kanigen': 'KANI',
  'Phosphate BP': 'PHOS-BP',
  'Phosphate ESIE1': null, // มากกว่า 10 chars
  'Delta ESIE1': 'DEL-ESIE1',
  'Information Technology BP': 'IT-BP',
  'Information Technology ESIE1': 'IT-ESIE1',
  'Prod.Engineering': 'PE',
  'Marketing H&S BP': null, // มากกว่า 10 chars
  'Marketing H&S ESIE1': null, // มากกว่า 10 chars
  'Marketing Chem ESIE1': null, // มากกว่า 10 chars
  'General Affair ESIE1': 'GA-ESIE1',
  'General Affair BP': 'GA-BP',
  'Quality Assurance ESIE1': 'QA-ESIE1',
  'Quality Assurance BP 12': 'QA-BP12',
  'Quality Assurance BP 8': 'QA-BP8',
  'Safety, Environment, Waste Water-ESIE1': null, // มากกว่า 10 chars
  'Isonite ESIE1': 'ISO-ESIE1',
  'Delivery Center H&S-ESIE1': null, // มากกว่า 10 chars
  'Analysis Center BP': 'AC-BP',
  'Technical Control BP': 'TC-BP',
  'Account': 'ACC',
  'Law & Planning': 'LAW',
  'Purchasing BP': 'PUR-BP',
  'Marketing Development': 'MKT-DEV',
  'Marketing Support': 'MKT-SUP',
  'Marketing Management': 'MKT-MGT',
  'Marketing Bill Collector': 'MKT-BC',
  'Automation': 'AUTO',
  'Safety & Environmental (C)': 'SE-C',
  'Safety&Environmental BP(F)': 'SE-BP-F',
  'Safety&Environmental GW (F)': 'SE-GW-F',
  'Marketing Chem BP': null, // มากกว่า 10 chars
  'Delivery Center Chem - BP': null, // มากกว่า 10 chars
  'Delivery Center H&S-BP': null, // มากกว่า 10 chars
  'Delivery Center H&S-GW': null, // มากกว่า 10 chars
  'Maintenance BP': 'MAINT-BP',
  'Maintenance GW': 'MAINT-GW',
  'Maintenance ESIE1': null, // มากกว่า 10 chars
  'Pallube ESIE1': 'PAL-ESIE1',
  'Gas ESIE1': 'GAS-ESIE1',
  'General Affair GW': 'GA-GW',
  'Purchasing ESIE1': 'PUR-ESIE1',
  'Analysis Center ESIE1': 'AC-ESIE1',
  'Analysis Center Special BP': 'AC-SP-BP',
  'Chem/Liquid': null,
  'Chem/Prepalene - X': null,
  'Management-Share All': 'MGT-SHARE'
};

const DEPT_TO_PLANT = {
  'QC-GW': 'TP-GW',
  'GAS-GW': 'TP-GW',

  'QA-BP12': 'TP-BP12',
  'QC-BP': 'TP-BP12',
  'IT-BP': 'TP-BP12',
  'MKT-HS-BP': 'TP-BP12',
  'PUR-BP': 'TP-BP12',
  'AC-BP': 'TP-BP12',
  'TC-BP': 'TP-BP12',
  'GA-BP': 'TP-BP12',

  'QA-BP8': 'TP-BP8',

  'QC-ESIE1': 'TP-ESIE1',
  'QA-ESIE1': 'TP-ESIE1',
  'MAINT-ESIE1': 'TP-ESIE1',
  'SEWW-ESIE1': 'TP-ESIE1',
  'ISO-ESIE1': 'TP-ESIE1',
  'MKT-HS-ESIE1': 'TP-ESIE1',
  'MKT-CHEM-ESIE1': 'TP-ESIE1',
  'GA-ESIE1': 'TP-ESIE1',
  'DC-HS-ESIE1': 'TP-ESIE1',
  'PHOS-ESIE1': 'TP-ESIE1',
};

/** =========================
 * 2) RAW ROWS (แนวนอน ประหยัด)
 *    วางข้อมูลจากรูปที่คุณส่ง (คอลัมน์: asset_no, inventory_no, brand_name, serial_no, department_name)
 *    เพิ่มต่อบรรทัดไปได้เรื่อยๆ
 * ========================= */
const rawRows = [
  // ==== บล็อคแรก ====
  ['C57385', '4300000499-0', 'LENOVO', 'PB0372BD', 'Human Resources'],
  ['C58422', '4300000583-0', 'LENOVO', 'PC03QGR2', 'Quality Control GW'],
  ['C58423', '4300000584-0', 'LENOVO', 'PC03QGQR', 'Quality Control GW'],
  ['C58392', '4300000511-0', 'LENOVO', '0', ''],
  ['C58430', '4300000567-0', 'LENOVO', 'PC03W0GH', 'Chemical Support'],
  ['C58437', '4300000574-0', 'LENOVO', 'PC03W0G0', 'Chemical Support'],
  ['C59457', '4300000633-0', 'LENOVO', '', ''],
  ['C59470', '4300000620-0', 'LENOVO', '', ''],
  ['C59454', '4300000606-0', 'LENOVO', '', ''],
  ['C60490', '4300000677-0', 'LENOVO', 'PC0M7P56', 'Gas BP'],
  ['C60491', '4300000678-0', 'LENOVO', 'PC0M7P53', ''],
  ['C60494', '4300000681-0', 'LENOVO', 'PC0M7P5D', ''],
  ['C60512', '4300000699-0', 'LENOVO', 'PC0M7P50', ''],
  ['C60511', '4300000698-0', 'LENOVO', 'PC0M7P5E', ''],
  ['C60517', '4300000704-0', 'LENOVO', 'PC0M7P4Z', 'Phosphate ESIE1'],
  ['C60520', '4300000707-0', 'LENOVO', 'PC0M7P5F', 'Delta ESIE1'],
  ['C60497', '4300000684-0', 'LENOVO', 'PC0M7P4T', ''],
  ['C60498', '4300000685-0', 'LENOVO', 'PC0M7P54', ''],
  ['NB60142', '4300000658-0', 'LENOVO', 'LR093J3A', 'Quality Control GW'],
  ['C60522', '', 'Dell Inc.', '64H0F02', 'Quality Control ESIE1'],
  ['NB60153', '4300000720-0', 'LENOVO', 'LR0A5HJK', 'Quality Control GW'],
  ['NB60155', '4300000722-0', 'LENOVO', 'LR0A5HKC', 'Quality Control GW'],
  ['C60486', '4300000673-0', 'LENOVO', 'PC0M7P5S', 'Quality Control ESIE1'],
  ['NB60156', '', 'LENOVO', '', ''],
  ['C61531', '', 'LENOVO', 'PC0SQMZE', ''],
  ['C61534', '', 'LENOVO', 'PC0SQMZ8', ''],
  ['C61530', '4300000739-0', 'LENOVO', '', ''],
  ['C61532', '', 'LENOVO', 'PC0SQMZF', ''],
  ['C61533', '', 'LENOVO', 'PC0SQMZG', ''],
  ['C61536', '', 'LENOVO', 'PC0SQMZB', ''],
  ['NB61178', '4300000760-0', 'LENOVO', 'LR0ADY2P', ''],
  ['C61541', '4300000771-0', 'LENOVO', 'PC0Y3SGM', 'Information Technology BP'],
  ['C61584', '4300000786-0', 'LENOVO', 'PC0Y3SGD', 'Gas GW'],
  ['C61555', '4300000788-0', 'LENOVO', 'PC0Y3SH3', 'Chemical Support'],
  ['C61546', '4300000776-0', 'LENOVO', 'PC0Y3SGH', ''],
  ['C61571', '4300000808-0', 'LENOVO', '', ''],
  ['C61554', '4300000784-0', 'LENOVO', 'PC0Y3SGQ', ''],
  ['C61573', '4300000810-0', 'LENOVO', 'PC0Y3SG8', 'Maintenance ESIE1'],
  ['C61579', '4300000816-0', 'LENOVO', '', ''],
  ['C61581', '4300000818-0', 'LENOVO', 'PC0Y3SG7', ''],
  ['C61551', '4300000781-0', 'LENOVO', 'PC0Y3SG1', 'Quality Control BP'],
  ['C61553', '4300000783-0', 'LENOVO', 'PC0Y3SGL', ''],
  ['C61580', '4300000817-0', 'LENOVO', 'PC0Y3SHH', 'Quality Control ESIE1'],
  ['C61549', '4300000779-0', 'LENOVO', 'PC0Y3SHK', 'Phosphate BP'],
  ['C61552', '4300000782-0', 'LENOVO', 'PC0Y3SGY', 'Kanigen'],
  ['C61566', '4300000801-0', 'LENOVO', '', ''],
  ['C61577', '4300000814-0', 'LENOVO', 'PC0Y3SGR', ''],
  ['C61575', '4300000812-0', 'LENOVO', '', ''],
  ['C61544', '4300000774-0', 'LENOVO', 'PC0Y3SGC', ''],
  ['C61545', '4300000775-0', 'LENOVO', 'PC0Y3SGS', ''],
  ['C61543', '4300000773-0', 'LENOVO', 'PC0Y3SGP', ''],
  ['C61570', '4300000807-0', 'LENOVO', 'PC0Y3SH6', ''],
  ['C61569', '4300000806-0', 'LENOVO', 'PC0Y3SG3', 'Information Technology ESIE1'],
  ['C61594', '4300000824-0', 'LENOVO', 'PC0Y3SGK', ''],
  ['NB61183', '4300000765-0', 'LENOVO', 'R90RXUX6', ''],
  ['C61592', '4300000822-0', 'LENOVO', 'PC0Y3SGB', 'Prod.Engineering'],
  ['C61589', '4300000805-0', 'LENOVO', 'PC0Y3SH2', ''],
  ['C61588', '4300000804-0', 'LENOVO', 'PC0Y3SH4', 'Quality Control GW'],
  ['C61558', '4300000791-0', 'LENOVO', 'PC0Y3SH7', 'Chemical Support'],
  ['C61561', '4300000796-0', 'LENOVO', 'PC0Y3SG6', 'Quality Control GW'],
  ['C61562', '4300000797-0', 'LENOVO', 'PC0Y3SG9', 'Quality Control GW'],
  ['C61563', '4300000798-0', 'LENOVO', 'PC0Y3SH8', ''],
  ['C61567', '4300000802-0', 'LENOVO', 'PC0Y3SHB', ''],
  ['C61564', '4300000799-0', 'LENOVO', 'PC0Y3SHJ', ''],
  ['C61568', '4300000803-0', 'LENOVO', '', ''],
  ['C61585', '4300000787-0', 'LENOVO', 'PC0Y3SHG', 'Quality Control BP'],
  ['C61574', '4300000811-0', 'LENOVO', 'PC0Y3SH9', ''],
  ['C61527', '4300000736-0', 'LENOVO', 'PC0SQMZD', 'Marketing H&S BP'],
  ['C61557', '4300000790-0', 'LENOVO', 'PC0Y3SHE', ''],
  ['C61587', '4300000795-0', 'LENOVO', 'PC0Y3SGE', 'Chemical Support'],
  ['C61550', '4300000780-0', 'LENOVO', 'PC0Y3SHD', ''],
  ['C61578', '', 'LENOVO', '', ''],
  ['NB62184', '', 'LENOVO', '', ''],
  ['NB62187', '4300000832-0', 'LENOVO', '', ''],
  ['NB62188', '4300000833-0', 'LENOVO', 'MP1HP3S7', 'Chemical Support'],
  ['NB62191', '4300000837-0', 'LENOVO', 'PF1PN41P', 'Information Technology BP'],
  ['NB62190', '4300000836-0', 'LENOVO', '', ''],
  ['C62599', '4300000841-0', 'LENOVO', '', ''],
  ['C62598', '4300000840-0', 'LENOVO', 'PC15LZDH', ''],
  ['C62597', '4300000839-0', 'LENOVO', 'PC15LZDG', ''],
  ['C62600', '4300000845-0', 'LENOVO', 'PC16H8X5', 'General Affair ESIE1'],
  ['C62601', '4300000846-0', 'LENOVO', 'PC16H8X6', 'Quality Assurance ESIE1'],
  ['C62602', '4300000847-0', 'LENOVO', 'PC16H8X7', 'Quality Assurance ESIE1'],
  ['NB62193', '4300000869-0', 'LENOVO', '', ''],
  ['C62605', '4300000862-0', 'LENOVO', 'PC19M4ZJ', 'Delivery Center H&S-ESIE1'],
  ['NB62195', '4300000850-0', 'LENOVO', 'R90VWAY6', ''],
  ['C62613', '4300000865-0', 'LENOVO', 'PC19M4ZD', ''],
  ['C62614', '4300000859-0', 'LENOVO', 'PC19M4ZG', 'Marketing H&S ESIE1'],
  ['C62608', '4300000858-0', 'LENOVO', 'PC19M4ZN', 'Quality Control ESIE1'],
  ['C62610', '4300000853-0', 'LENOVO', 'PC19M4ZL', 'Safety, Environment, Waste Water-ESIE1'],
  ['C62609', '4300000854-0', 'LENOVO', 'PC19M4ZT', 'Isonite ESIE1'],
  ['C62617', '4300000866-0', 'LENOVO', 'PC19M4ZK', 'Marketing Chem ESIE1'],
  ['C62618', '4300000856-0', 'LENOVO', 'PC19M4ZE', 'Safety, Environment, Waste Water-ESIE1'],
  ['C62620', '4300000863-0', 'LENOVO', '', ''],
  ['NB62198', '4300000868-0', 'LENOVO', 'R90V96MQ', ''],
  ['C62622', '4300000874-0', 'LENOVO', '', ''],
  ['NB62194', '', 'LENOVO', '', ''],
  ['NB62225', '', 'LENOVO', '', ''],
  ['NB63201', '4300000897-0', 'LENOVO', 'MP1Q12LN', 'Analysis Center BP'],
  ['NB63214', '4300000910-0', 'LENOVO', 'MP1Q0YFZ', 'Prod.Engineering'],
  ['NB63223', '4300000919-0', 'LENOVO', 'MP1Q0YRG', 'Safety, Environment, Waste Water-ESIE1'],
  ['NB63225', '4300000921-0', 'LENOVO', 'MP1Q12E9', ''],
  ['NB63207', '4300000903-0', 'LENOVO', 'MP1Q0N8P', ''],
  ['NB63226', '4300000922-0', 'LENOVO', 'MP1Q115B', 'Technical Control BP'],
  ['NB63204', '4300000900-0', 'LENOVO', 'MP1Q0W4T', ''],
  ['NB63228', '4300000924-0', 'LENOVO', 'MP1Q1101', 'Delivery Center H&S-ESIE1'],
  ['NB63202', '4300000898-0', 'LENOVO', 'MP1Q0NSF', ''],
  ['NB63206', '4300000902-0', 'LENOVO', 'MP1Q0YT1', 'Quality Assurance BP 12'],
  ['NB63209', '4300000905-0', 'LENOVO', '', 'Pallube ESIE1'],
  ['NB63212', '4300000908-0', 'LENOVO', 'MP1Q12FQ', ''],
  ['NB63234', '4300000930-0', 'LENOVO', 'MP1Q0RVY', 'Safety & Environmental (C)'],
  ['NB63235', '4300000934-0', 'LENOVO', 'MP1Q0RZ8', 'Phosphate ESIE1'],
  ['NB63239', '4300000938-0', 'LENOVO', 'MP1Q0RZ8', 'Marketing Support'],
  ['NB63249', '4300000925-0', 'LENOVO', 'PF1CLBR2', 'Marketing Chem ESIE1'],
  ['NB63236', '4300000938-0', 'LENOVO', 'MP1Q0RZ8', 'Marketing Support'],
  ['NB63240', '4300000939-0', 'LENOVO', 'MP1Q0L45', 'Chem/Liquid'],
  ['NB63243', '4300000942-0', 'LENOVO', '', ''],
  ['NB63244', '4300000943-0', 'LENOVO', 'MP1Q0YEA', ''],
  ['NB63246', '4300000945-0', 'LENOVO', 'MP1Q12D8', 'Purchasing BP'],
  ['NB63245', '4300000944-0', 'LENOVO', 'MP1Q0YMM', 'General Affair GW'],
  ['NB63250', '4300000926-0', 'LENOVO', 'PF1CLBPJ', 'Marketing Chem ESIE1'],
  ['NB63255', '4300000956-0', 'LENOVO', 'R90XHC1L', 'Information Technology BP'],
  ['NB63256', '4300000957-0', 'LENOVO', 'PF1TL0Y1', 'Marketing Management'],
  ['NB63252', '4300000953-0', 'LENOVO', 'PF1WLP33', 'Marketing H&S ESIE1'],
  ['NB63251', '4300000952-0', 'LENOVO', 'PF1WLP48', 'Marketing Chem ESIE1'],
  ['NB63253', '4300000954-0', 'LENOVO', '0', 'Management-Share All'],
  ['NB63257', '4300000958-0', 'LENOVO', 'PF1TL0XF', 'Marketing H&S BP'],
  ['NB63258', '4300000959-0', 'LENOVO', 'R90XRWKB', 'Management-Share All'],
  ['NB63259', '4300000961-0', 'LENOVO', 'PF28LXS5', 'Information Technology BP'],
  ['C63624', '', 'LENOVO', '', ''],
  ['NB63261', '4300000963-0', 'LENOVO', 'PF28LXSS', 'Information Technology BP'],
  ['NB63265', '4300000967-0', 'LENOVO', '', 'Information Technology BP'],
  ['NB63266', '4300000968-0', 'LENOVO', 'PF2H2PXH', 'Marketing Support'],
  ['NB63264', '4300000966-0', 'LENOVO', 'PF2H2K3W', 'Law & Planning'],
  ['NB63262', '4300000964-0', 'LENOVO', 'PF28LVLB', 'Automation'],
  ['NB63263', '4300000965-0', 'LENOVO', 'PF28LXRJ', 'Human Resources'],
  ['NB63267', '4300000970-0', 'LENOVO', 'PF1SM0DY', 'Purchasing BP'],
  ['NB63268', '4300000971-0', 'LENOVO', '', ''],
  ['NB63271', '4300000974-0', 'LENOVO', 'PF23SHGL', 'Marketing H&S BP'],
  ['NB63272', '4300000975-0', 'LENOVO', '', 'Marketing H&S BP'],
  ['NB63270', '4300000973-0', 'LENOVO', 'PF1VM531', 'Management-Share All'],
  ['NB63222', '4300000918-0', 'LENOVO', 'MP1Q114K', 'Chem/Prepalene - X'],
  ['NB63269', '4300000972-0', 'LENOVO', 'R90ZS9GQ', ''],
  ['NB63230', '4300000929-0', 'LENOVO', 'INVALID', 'Phosphate ESIE1'],
  ['C63623', '', 'LENOVO', 'To Be Filled By O.E.M.', 'Quality Control ESIE1'],
  ['NB63218', '4300000914-0', 'LENOVO', '', ''],
  ['NB63219', '', 'LENOVO', '', ''],
  ['NB63221', '', 'LENOVO', '', ''],
  ['NB63210', '4300000906-0', 'LENOVO', 'MP1Q111L', 'General Affair BP'],
  ['NB63216', '', 'LENOVO', 'MP1Q12Q7', ''],
  ['NB63248', '', 'LENOVO', 'MP1Q0DHN', ''],
  ['NB64275', '4300000997-0', 'Dell Inc.', 'C21YD63', 'Account'],
  ['NB64287', '4300001002-0', 'Dell Inc.', '9MYXD63', 'Quality Assurance BP 12'],
  ['NB64277', '4300001000-0', 'Dell Inc.', '121YD63', 'Quality Assurance BP 12'],
  ['NB64273', '4300000996-0', 'Dell Inc.', '8NYXD63', 'Quality Assurance BP 8'],
  ['NB64274', '4300000999-0', 'Dell Inc.', '411YD63', 'Quality Assurance BP 12'],
  ['NB64283', '4300000982-0', 'Dell Inc.', '801YD63', 'Delivery Center Chem - BP'],
  ['NB64280', '4300000981-0', 'Dell Inc.', '8LYXD63', 'Chemical Support'],
  ['NB64282', '4300000988-0', 'LENOVO', '', ''],
  ['NB64284', '4300000983-0', 'Dell Inc.', '1PYXD63', 'Chemical Support'],
  ['NB64286', '4300000985-0', 'Dell Inc.', '921YD63', 'Chemical Support'],
  ['NB64285', '4300000984-0', 'Dell Inc.', 'BNYXD63', 'Chemical Support'],
  ['NB64293', '4300000992-0', 'Dell Inc.', 'B21YD63', 'Safety, Environment, Waste Water-ESIE1'],
  ['NB64291', '4300000991-0', 'Dell Inc.', 'B11YD63', ''],
  ['NB64294', '4300000994-0', 'Dell Inc.', '321YD63', 'Marketing Chem ESIE1'],
  ['NB64288', '4300000989-0', 'Dell Inc.', '4PYXD63', 'Information Technology ESIE1'],
  ['NB64307', '4300001015-0', 'LENOVO', 'PF2KC9JE', 'Information Technology BP'],
  ['NB64300', '4300001008-0', 'LENOVO', 'PF2L0EXH', 'Chemical Support'],
  ['NB64301', '4300001009-0', 'LENOVO', 'PF2L0GNZ', 'Human Resources'],
  ['NB64305', '4300001013-0', 'LENOVO', 'PF2L0EZT', 'General Affair BP'],
  ['NB64304', '4300001012-0', 'LENOVO', 'PF2L0EYY', 'Marketing Development'],
  ['NB64302', '4300001010-0', 'LENOVO', 'PF2L0GL1', 'Purchasing BP'],
  ['NB64299', '4300001004-0', 'LENOVO', 'PF2L0GLG', ''],
  ['NB64298', '4300001007-0', 'LENOVO', 'PF2L0GMN', 'Maintenance ESIE1'],
  ['NB64296', '4300001005-0', 'LENOVO', '', ''],
  ['NB64297', '4300001006-0', 'LENOVO', 'PF2L0GNK', 'Isonite ESIE1'],
  ['NB64309', '4300001018-0', 'LENOVO', 'PF2JPE1E', 'Quality Control BP'],
  ['NB64312', '4300001021-0', 'LENOVO', 'PF2JPTJF', 'Marketing Chem BP'],
  ['NB64311', '4300001020-0', 'LENOVO', 'PF2JPLSE', 'Information Technology BP'],
  ['NB64316', '4300001025-0', 'LENOVO', 'PF2JPLSY', 'Marketing Chem BP'],
  ['NB64315', '4300001024-0', 'LENOVO', 'PF2JP9H0', 'Marketing Chem BP'],
  ['NB64318', '4300001027-0', 'LENOVO', 'PF2JPP21', 'Marketing Chem BP'],
  ['NB64331', '4300001040-0', 'LENOVO', 'PF2JQKD4', 'Management-Share All'],
  ['NB64322', '4300001031-0', 'LENOVO', '', ''],
  ['NB64327', '4300001036-0', 'LENOVO', 'PF2JQML8', 'Maintenance BP'],
  ['NB64326', '4300001035-0', 'LENOVO', 'PF2JPZ1L', 'Management-Share All'],
  ['NB64320', '4300001029-0', 'LENOVO', 'PF2JPG68', 'Marketing Chem BP'],
  ['NB64321', '4300001030-0', 'LENOVO', 'PF2JQPTL', 'Marketing Chem BP'],
  ['NB64329', '4300001038-0', 'LENOVO', 'PF2JPLR8', 'Delivery Center H&S-BP'],
  ['NB64328', '4300001037-0', 'LENOVO', '0', 'Phosphate BP'],
  ['NB64323', '4300001032-0', 'LENOVO', 'PF2JPDXC', 'Marketing Chem ESIE1'],
  ['NB64324', '4300001033-0', 'LENOVO', 'PF2JQMKT', 'Marketing Chem ESIE1'],
  ['NB64325', '4300001034-0', 'LENOVO', 'PF2JQH1Q', 'Marketing Chem ESIE1'],
  ['NB64310', '4300001019-0', 'LENOVO', 'PF2JQVC0', 'General Affair ESIE1'],
  ['NB64333', '4300001044-0', 'LENOVO', 'PF2H4AY3', 'Technical Control BP'],
  ['NB64332', '4300001043-0', 'LENOVO', 'PF2H4HWY', 'Analysis Center ESIE1'],
  ['NB64334', '4300001045-0', 'LENOVO', 'PF2H3JQH', 'Analysis Center Special BP'],
  ['NB64335', '4300001046-0', 'LENOVO', 'PF2GZY8S', 'Analysis Center Special BP'],
  ['NB64336', '4300001047-0', 'LENOVO', 'PF2GZYC4', 'Marketing Development'],
  ['NB64337', '4300001048-0', 'LENOVO', 'PF2H4E9W', 'Marketing Development'],
  ['NB64240', '', 'LENOVO', 'PF2SVHN8', 'Marketing Chem ESIE1'],
  ['NB64276', '4300000999-0', 'Dell Inc.', '411YD63', 'Quality Assurance BP 12'],
  ['NB64278', '4300001001-0', 'Dell Inc.', 'J21YD63', 'Chemical Support'],
  ['NB64289', '4300001003-0', 'Dell Inc.', '611YD63', 'Safety, Environment, Waste Water-ESIE1'],
  ['NB64292', '4300000992-0', 'Dell Inc.', 'B21YD63', 'Safety, Environment, Waste Water-ESIE1'],
  ['NB64303', '4300001011-0', 'LENOVO', 'PF2L0EYE', 'General Affair BP'],
  ['NB64313', '4300001022-0', 'LENOVO', 'PF2JPG7F', 'Account'],
  ['NB64319', '4300001028-0', 'LENOVO', 'PF2JQ7ZH', 'Marketing Chem BP'],
  ['NB64330', '4300001039-0', 'LENOVO', 'PF2JQMKX', 'Management-Share All'],
  ['NB64339', '4300001050-0', 'LENOVO', 'PF2SW2F0', 'Marketing Chem ESIE1'],
  ['NB64338', '4300001049-0', 'LENOVO', 'PF2SVNDP', 'Marketing Chem ESIE1'],
  ['NB64343', '4300001054-0', 'LENOVO', 'PF2KC9JM', 'Information Technology BP'],
  ['NB64342', '4300001055-0', 'LENOVO', 'PF2SVGSN', 'Marketing H&S ESIE1'],
  ['NB64370', '4300001082-0', 'LENOVO', 'PF2Z3LLC', 'Maintenance ESIE1'],
  ['NB64372', '4300001084-0', 'LENOVO', 'PF2Z4DV6', 'Prod.Engineering'],
  ['NB64375', '4300001087-0', 'LENOVO', 'PF2XDTC0', 'Phosphate BP'],
  ['NB64371', '4300001083-0', 'LENOVO', 'PF2XDTHM', 'Pallube ESIE1'],
  ['NB64373', '4300001085-0', 'LENOVO', 'PF2Z4WE1', 'Quality Control BP'],
  ['NB64374', '4300001086-0', 'LENOVO', 'PF2XDQXC', 'Quality Control BP'],
  ['NB64344', '4300001056-0', 'LENOVO', 'PF2YB79R', ''],
  ['NB64351', '4300001063-0', 'LENOVO', 'PF2ZY3T3', 'Analysis Center BP'],
  ['NB64349', '4300001061-0', 'LENOVO', 'PF2YA1NF', 'Technical Control BP'],
  ['NB64350', '4300001062-0', 'LENOVO', 'PF2XCQWT', 'Analysis Center Special BP'],
  ['NB64379', '4300001091-0', 'LENOVO', 'PF2YAW6N', 'Prod.Engineering'],
  ['NB64378', '4300001090-0', 'LENOVO', 'PF2Z4DLH', 'Safety&Environmental BP(F)'],
  ['NB64377', '4300001089-0', 'LENOVO', '', ''],
  ['NB64376', '4300001088-0', 'LENOVO', 'PF2Z4XM3', 'Gas BP'],
  ['NB64352', '4300001064-0', 'LENOVO', 'PF2Z47R9', 'Marketing H&S BP'],
  ['NB64353', '4300001065-0', 'LENOVO', 'PF2Z4BGB', 'Marketing H&S BP'],
  ['NB64354', '4300001066-0', 'LENOVO', 'PF2Z3ND4', 'Maintenance GW'],
  ['NB64355', '4300001067-0', 'LENOVO', 'PF2XDMZZ', 'Quality Control GW'],
  ['NB64356', '4300001068-0', 'LENOVO', 'PF2YA1KG', 'Gas GW'],
  ['NB64357', '4300001069-0', 'LENOVO', 'PF2YA36K', 'Safety, Environment, Waste Water-ESIE1'],
  ['NB64358', '4300001070-0', 'LENOVO', 'PF2Z5SL7', 'Safety, Environment, Waste Water-ESIE1'],
  ['NB64362', '4300001074-0', 'LENOVO', 'PF2YASC0', 'Safety, Environment, Waste Water-ESIE1'],
  ['NB64363', '4300001075-0', 'LENOVO', 'PF2YRX2T', 'Quality Control ESIE1'],
  ['NB64361', '4300001073-0', 'LENOVO', 'PF2Z4DMH', 'Isonite ESIE1'],
  ['NB64360', '4300001072-0', 'LENOVO', 'PF2XE0MP', 'Isonite ESIE1'],
  ['NB64359', '4300001071-0', 'LENOVO', 'PF2YS1HR', 'Prod.Engineering'],
  ['NB64364', '4300001076-0', 'LENOVO', 'PF2Z5GDJ', 'Prod.Engineering'],
  ['NB64345', '4300001057-0', 'LENOVO', '', ''],
  ['NB64347', '4300001059-0', 'LENOVO', 'PF2XDLYF', 'Quality Assurance ESIE1'],
  ['NB64348', '4300001060-0', 'LENOVO', 'PF2XE1TP', 'Quality Assurance ESIE1'],
  ['NB64346', '4300001058-0', 'LENOVO', 'PF2Z4AB0', 'Information Technology ESIE1'],
  ['NB64365', '4300001077-0', 'LENOVO', 'PF2Z621F', 'Phosphate ESIE1'],
  ['NB64367', '4300001079-0', 'LENOVO', 'PF2XBP6P', 'Phosphate ESIE1'],
  ['NB64366', '4300001078-0', 'LENOVO', 'PF2Z3LJD', 'Delta ESIE1'],
  ['NB64368', '4300001080-0', 'LENOVO', 'PF2Z4H53', ''],
  ['NB64369', '4300001081-0', 'LENOVO', 'PF2YA6EX', 'Pallube ESIE1'],
  ['NB64385', '4300001097-0', 'LENOVO', 'PF34S6BB', 'Analysis Center ESIE1'],
  ['NB64381', '4300001093-0', 'LENOVO', 'PF2S4B6J', 'Marketing Chem ESIE1'],
  ['NB64384', '4300001096-0', 'LENOVO', 'PF2S3E97', 'Marketing Chem ESIE1'],
  ['NB64382', '4300001094-0', 'LENOVO', 'PF2S5L4L', 'Marketing Chem ESIE1'],
  ['NB64386', '', 'LENOVO', 'PF33RY2N', 'Safety & Environmental (C)'],
  ['NB64388', '', 'LENOVO', '', ''],
  ['NB64389', '', 'LENOVO', 'PF31CL9A', 'Prod.Engineering'],
  ['NB64390', '4300001098-0', 'LENOVO', 'PF36DHJ6', 'Quality Control BP'],
  ['NB64383', '4300001095-0', 'LENOVO', 'PF2S40YR', 'Marketing Chem ESIE1'],
  ['NB64387', '', 'LENOVO', '', ''],
  ['NB65394', '4300001111-0', 'LENOVO', 'PF3BDGNM', 'Marketing Chem BP'],
  ['NB65395', '4300001112-0', 'LENOVO', 'PF3BBKS1', 'Marketing Chem BP'],
  ['NB65392', '4300001109-0', 'LENOVO', 'PF3BEKER', 'Marketing Chem BP'],
  ['NB65400', '4300001117-0', 'LENOVO', 'PF3AE88T', ''],
  ['NB65397', '4300001114-0', 'LENOVO', 'PF3AE3Q8', ''],
  ['NB65396', '4300001113-0', 'LENOVO', 'PF3AXYEW', 'Marketing Chem BP'],
  ['NB65393', '4300001110-0', 'LENOVO', 'PF3BEHGM', 'Marketing Chem BP'],
  ['NB65398', '4300001115-0', 'LENOVO', 'PF3AE1FQ', 'Analysis Center ESIE1'],
  ['NB65401', '4300001118-0', 'LENOVO', 'PF3ARB02', 'Marketing Chem ESIE1'],
  ['NB65402', '4300001119-0', 'LENOVO', 'PF3AEM56', 'Marketing Chem ESIE1'],
  ['NB65403', '4300001120-0', 'LENOVO', 'PF3ARD9R', 'Marketing Chem ESIE1'],
  ['NB65404', '4300001121-0', 'LENOVO', 'PF3ARAYA', 'Marketing Chem ESIE1'],
  ['NB65391', '4300001108-0', 'LENOVO', 'PF3BDJHF', 'Automation'],
  ['NB65405', '4300001124-0', 'LENOVO', '', 'Marketing Chem ESIE1'],
  ['NB65406', '4300001125-0', 'LENOVO', 'PF3LE955', 'Quality Assurance ESIE1'],
  ['NB65408', '4300001129-0', 'LENOVO', '', 'Account'],
  ['NB65409', '4300001130-0', 'LENOVO', 'PF3FBEVJ', 'Information Technology BP'],
  ['NB65410', '4300001131-0', 'LENOVO', 'PF3E4E08', 'Information Technology BP'],
  ['NB65407', '4300001128-0', 'LENOVO', 'PF3EB25R', 'Law & Planning'],
  ['NB65417', '4300001138-0', 'LENOVO', 'PF3DXG85', 'Quality Control GW'],
  ['NB65418', '4300001139-0', 'LENOVO', 'PF3EATGY', ''],
  ['NB65411', '4300001132-0', 'LENOVO', 'PF3E4E1Y', 'Human Resources'],
  ['NB65412', '4300001133-0', 'LENOVO', 'PF33R17Y', 'Marketing Bill Collector'],
  ['NB65413', '4300001134-0', 'LENOVO', '', 'Chemical Support'],
  ['NB65415', '4300001136-0', 'LENOVO', 'PF3EATG4', 'Marketing Support'],
  ['NB65416', '4300001137-0', 'LENOVO', 'PF3FQF1H', 'Marketing Chem BP'],
  ['NB65420', '4300001142-0', 'LENOVO', 'PF3EATXT', 'Human Resources'],
  ['NB65419', '4300001140-0', 'LENOVO', 'PF3DVHA4', 'Marketing Development'],
  ['NB65414', '4300001135-0', 'LENOVO', 'PF31TT13', 'Quality Control ESIE1'],
  ['NB65430', '4300001156-0', 'LENOVO', 'PF33QXAV', 'Purchasing BP'],
  ['NB65424', '4300001150-0', 'LENOVO', 'PF33SV2J', 'Account'],
  ['NB65431', '4300001157-0', 'LENOVO', 'PF33STES', 'Delivery Center Chem - BP'],
  ['NB65422', '4300001148-0', 'LENOVO', 'PF3FQ8WD', 'Gas ESIE1'],
  ['NB65423', '4300001149-0', 'LENOVO', 'PF3EAR98', 'Gas ESIE1'],
  ['NB65432', '4300001158-0', 'LENOVO', 'PF33QXB5', 'Chemical Support'],
  ['NB65433', '4300001159-0', 'LENOVO', 'PF33QZFW', 'Chemical Support'],
  ['NB65434', '4300001160-0', 'LENOVO', 'PF31TT00', 'Chemical Support'],
  ['NB65435', '4300001161-0', 'LENOVO', 'PF33STET', 'Prod.Engineering'],
  ['NB65436', '4300001162-0', 'LENOVO', 'PF33QX8C', 'Phosphate BP'],
  ['NB65427', '4300001153-0', 'LENOVO', 'PF3AG1RB', 'Law & Planning'],
  ['NB65428', '4300001154-0', 'LENOVO', 'PF3LJC52', 'Maintenance BP'],
  ['NB65426', '4300001152-0', 'LENOVO', 'PF3FQD3A', 'Marketing Development'],
  ['C65630', '4300001165-0', 'LENOVO', 'PC2DX6E0', 'Marketing Support'],
  ['C65631', '4300001166-0', 'LENOVO', 'PF3DVF1S', 'Quality Control GW'],
  ['NB65425', '4300001151-0', 'LENOVO', 'PF3EB04J', 'Chemical Support'],
  ['NB65429', '4300001155-0', 'LENOVO', 'PF33QXAE', 'Purchasing BP'],
  ['NB65421', '4300001145-0', 'LENOVO', '', 'Information Technology BP'],
  ['NB65399', '4300001116-0', 'LENOVO', 'PF3AD1QL', 'Information Technology ESIE1'],
  ['NB66458', '4300001208-0', 'LENOVO', 'PF4ANAF2', 'Purchasing ESIE1'],
  ['NB66459', '4300001209-0', 'LENOVO', 'PF4ANAEN', 'Purchasing BP'],
  ['NB66500', '4300001256-0', 'LENOVO', 'PF47C573', 'Safety, Environment, Waste Water-ESIE1'],
  ['NB66471', '4300001225-0', 'LENOVO', 'PF478MYG', 'Human Resources'],
  ['NB66474', '4300001228-0', 'LENOVO', 'PF478MZX', 'Human Resources'],
  ['NB66465', '4300001214-0', 'LENOVO', 'PF478MZD', 'Technical Control BP'],
  ['NB66466', '4300001215-0', 'LENOVO', 'PF478N0E', 'Analysis Center Special BP'],
  ['NB66476', '4300001237-0', 'LENOVO', 'PF478N02', 'Gas BP'],
  ['NB66461', '4300001218-0', 'LENOVO', 'PF47AVCF', ''],
  ['NB66468', '4300001222-0', 'LENOVO', 'PF478MXN', 'General Affair BP'],
  ['NB66477', '4300001243-0', 'LENOVO', 'PF47AVD0', 'Marketing Management'],
  ['NB66484', '4300001230-0', 'LENOVO', 'PF478MZ2', 'Quality Assurance BP 12'],
  ['NB66505', '4300001240-0', 'LENOVO', 'PF478KPW', 'Delivery Center H&S-BP'],
  ['NB66483', '4300001236-0', 'LENOVO', 'PF47AVEX', 'Marketing Chem BP'],
  ['NB66481', '4300001284-0', 'LENOVO', 'PF478KM9', 'Marketing Chem BP'],
  ['NB66509', '4300001233-0', 'LENOVO', 'PF478KQZ', 'Gas GW'],
  ['NB66485', '4300001216-0', 'LENOVO', 'PF479SZT', 'Analysis Center Special BP'],
  ['NB66482', '4300001235-0', 'LENOVO', 'PF479T00', 'Phosphate BP'],
  ['NB66469', '4300001223-0', 'LENOVO', 'PF478N0X', 'General Affair BP'],
  ['NB66467', '4300001263-0', 'LENOVO', 'PF478MY7', 'Account'],
  ['NB66511', '4300001260-0', 'LENOVO', 'PF478HG1', 'Law & Planning'],
  ['NB66462', '4300001219-0', 'LENOVO', 'PF47AVER', 'Account'],
  ['NB66473', '4300001227-0', 'LENOVO', 'PF478KPJ', 'Account'],
  ['NB66472', '4300001226-0', 'LENOVO', 'PF478MZ7', 'Human Resources'],
  ['NB66470', '4300001224-0', 'LENOVO', 'PF478HGJ', 'General Affair BP'],
  ['NB66460', '4300001217-0', 'LENOVO', 'PF47AVFG', 'Human Resources'],
  ['NB66475', '4300001229-0', 'LENOVO', 'PF47WD21', 'Human Resources'],
  ['NB66486', '4300001210-0', 'LENOVO', 'PF478KR7', 'Chemical Support'],
  ['NB66508', '4300001232-0', 'LENOVO', 'PF47AVCA', 'Prod.Engineering'],
  ['NB66512', '4300001264-0', 'LENOVO', 'PF4G0WBJ', 'General Affair BP'],
  ['NB66490', '4300001248-0', 'LENOVO', 'PF47AVAP', 'General Affair ESIE1'],
  ['NB66487', '4300001231-0', 'LENOVO', 'PF47L9MA', 'Quality Assurance BP 8'],
  ['NB66506', '4300001241-0', 'LENOVO', 'PF478KNV', 'General Affair GW'],
  ['NB66507', '4300001242-0', 'LENOVO', 'PF478N0J', 'Delivery Center H&S-GW'],
  ['NB66504', '4300001239-0', 'LENOVO', 'PF478MZR', 'Gas GW'],
  ['NB66503', '4300001238-0', 'LENOVO', 'PF478MYA', 'Prod.Engineering'],
  ['NB66501', '4300001246-0', 'LENOVO', 'PF478KPS', 'Safety, Environment, Waste Water-ESIE1'],
  ['NB66492', '4300001250-0', 'LENOVO', 'PF478MY1', 'General Affair ESIE1'],
  ['NB66478', '4300001258-0', 'LENOVO', 'PF478MWN', 'Phosphate BP'],
  ['NB66479', '4300001259-0', 'LENOVO', 'PF47AVBY', 'Quality Assurance BP 12'],
  ['NB66480', '4300001234-0', 'LENOVO', 'PF478KQR', 'Maintenance BP'],
  ['NB66488', '4300001211-0', 'LENOVO', 'PF47WD27', 'Chemical Support'],
  ['C66643', '4300001265-0', 'LENOVO', 'GM07YZWH', 'Marketing Bill Collector'],
  ['NB66497', '4300001244-0', 'LENOVO', 'PF478KMP', 'Marketing H&S ESIE1'],
  ['NB66498', '4300001245-0', 'LENOVO', 'PF47C56R', 'Marketing H&S ESIE1'],
  ['C66641', '4300001266-0', 'LENOVO', 'GM07YZW8', 'Gas BP'],
  ['C66642', '4300001267-0', 'LENOVO', 'GM07YZWF', ''],
  ['C66644', '4300001268-0', 'LENOVO', 'GM07YZW1', 'Delivery Center Chem - BP'],
  ['C66645', '4300001269-0', 'LENOVO', 'GM07YZW6', ''],
  ['C66659', '4300001283-0', 'LENOVO', 'GM07YZW3', 'Delivery Center H&S-GW'],
  ['NB66502', '4300001254-0', 'LENOVO', 'PF47C56L', 'Maintenance ESIE1'],
  ['NB66489', '4300001257-0', 'LENOVO', 'PF478MWT', 'Gas ESIE1'],
  ['NB66463', '4300001220-0', 'LENOVO', 'PF47AVF3', 'Account'],
  ['NB66495', '4300001253-0', 'LENOVO', 'PF478KQA', 'General Affair ESIE1'],
  ['NB66494', '4300001252-0', 'LENOVO', 'PF47C576', 'General Affair ESIE1'],
  ['NB66499', '4300001255-0', 'LENOVO', 'PF478KNA', 'Safety, Environment, Waste Water-ESIE1'],
  ['NB66491', '4300001249-0', 'LENOVO', 'PF478KMW', 'General Affair ESIE1'],
  ['NB66496', '4300001213-0', 'LENOVO', 'PF478MXV', 'Marketing Chem ESIE1'],
  ['NB66493', '4300001251-0', 'LENOVO', 'PF47AVCM', 'General Affair ESIE1'],
  ['NB66510', '4300001247-0', 'LENOVO', 'PF478MZK', 'Prod.Engineering'],
  ['NB66514', '4300001285-0', 'LENOVO', 'PF4B0FAF', 'Quality Control ESIE1'],
  ['NB66464', '4300001221-0', 'LENOVO', 'PF478MYV', 'Account'],
  ['C66650', '4300001274-0', 'LENOVO', 'GM07YZW2', 'Delivery Center H&S-ESIE1'],
  ['C66651', '4300001275-0', 'LENOVO', '', ''],
  ['C66652', '4300001276-0', 'LENOVO', 'GM07YZWA', 'Delivery Center H&S-ESIE1'],
  ['C66649', '4300001273-0', 'LENOVO', 'GM07YZWD', 'Delivery Center H&S-ESIE1'],
  ['C66653', '4300001277-0', 'LENOVO', 'GM07YZW5', 'Delivery Center H&S-ESIE1'],
  ['NB66515', '4300001286-0', 'LENOVO', 'PF4B0DCT', 'Marketing H&S BP'],
  ['C66656', '4300001280-0', 'LENOVO', 'GM07YZWC', ''],
  ['C66654', '4300001278-0', 'LENOVO', 'GM07YZW7', 'Pallube ESIE1'],
  ['C66657', '4300001281-0', 'LENOVO', 'GM07YZWB', 'Quality Control ESIE1'],
  ['C66658', '4300001282-0', 'LENOVO', 'GM07YZW9', ''],
  ['C66647', '4300001271-0', 'LENOVO', 'GM07YZWE', 'Delivery Center H&S-ESIE1'],
  ['C66648', '4300001272-0', 'LENOVO', 'GM07YZWG', 'Delivery Center H&S-ESIE1'],
  ['C66646', '4300001270-0', 'LENOVO', 'GM07YZW4', 'Maintenance ESIE1'],
  ['C66655', '4300001279-0', 'LENOVO', 'GM07YZWK', 'Quality Control ESIE1'],
  ['NB66513', '4300001262-0', 'LENOVO', 'PF4B0F7G', 'Marketing H&S BP'],
  ['NB66521', '4300001294-0', 'LENOVO', 'PF4JT3WQ', 'Purchasing BP'],
  ['NB66517', '4300001290-0', 'LENOVO', 'PF4JTK5B', 'Law & Planning'],
  ['NB66519', '4300001292-0', 'LENOVO', 'PF4JTPP0', 'Purchasing BP'],
  ['NB66522', '4300001295-0', 'LENOVO', 'PF4JTMFW', 'Purchasing BP'],
  ['NB66516', '4300001289-0', 'LENOVO', 'PF4JSZBN', 'Law & Planning'],
  ['NB66518', '4300001291-0', 'LENOVO', 'PF4JT1L6', 'Law & Planning'],
  ['NB66520', '4300001293-0', 'LENOVO', 'PF4JT1JJ', 'Purchasing BP'],
  ['C66661', '', 'LENOVO', 'YJ01K9DV', 'Marketing Bill Collector'],
  ['C66660', '', 'LENOVO', '', 'Marketing Bill Collector'],
  ['NB67524', '4300001303-0', 'HP', '5CD338HZX5', 'Information Technology ESIE1'],
  ['NB67523', '4300001304-0', 'HP', '5CD338HZX9', 'Information Technology BP'],
  ['NB67540', '4300001328-0', 'LENOVO', 'PF4S1BSW', 'Marketing H&S BP'],
  ['NB67534', '4300001322-0', 'LENOVO', 'PF4S2LGA', 'Management-Share All'],
  ['NB67526', '4300001314-0', 'LENOVO', 'PF4S1BWR', 'Account'],
  ['NB67525', '4300001313-0', 'LENOVO', 'PF4S17B1', 'Safety & Environmental (C)'],
  ['NB67527', '4300001315-0', 'LENOVO', 'PF4S19JG', 'Safety&Environmental BP(F)'],
  ['NB67538', '4300001326-0', 'LENOVO', 'PF4S1BW5', 'Safety&Environmental GW (F)'],
  ['NB67539', '4300001327-0', 'LENOVO', 'PF4S2LK1', 'Marketing Chem BP'],
  ['NB67531', '4300001319-0', 'LENOVO', 'PF4S19KS', 'Marketing H&S ESIE1'],
  ['NB67532', '4300001320-0', 'LENOVO', 'PF4S1BV9', 'Marketing H&S ESIE1'],
  ['NB67541', '4300001329-0', 'LENOVO', 'PF4S2NS9', ''],
  ['NB67533', '4300001321-0', 'LENOVO', 'PF4S2LGA', 'Marketing H&S ESIE1'],
  ['NB67530', '4300001318-0', 'LENOVO', 'PF4YLA0M', 'Information Technology ESIE1'],
  ['NB67528', '4300001316-0', 'LENOVO', '', ''],
  ['NB67535', '4300001323-0', 'LENOVO', 'PF4S2NQG', 'Marketing Development'],
  ['NB67537', '4300001325-0', 'LENOVO', 'PF4S17C6', 'Marketing H&S BP'],
  ['NB67542', '4300001331-0', 'LENOVO', 'PW0ATZZN', 'Human Resources'],
  ['NB67529', '4300001317-0', 'LENOVO', 'PF4S2LJH', 'Chemical Support'],
  ['NB67544', '4300001341-0', 'LENOVO', 'PW0BNJFK', 'Law & Planning'],
  ['NB67543', '4300001334-0', 'LENOVO', 'PW0BNJFK', 'Information Technology BP'],
  ['C67660', '4300001306-0', 'LENOVO', 'YJ01LH54', ''],
  ['C67664', '4300001310-0', 'LENOVO', 'YJ01LH7M', 'Maintenance ESIE1'],
  ['C67665', '4300001311-0', 'LENOVO', 'YJ01LH4P', 'Maintenance ESIE1'],
  ['C67662', '4300001308-0', 'LENOVO', 'YJ01LH4Y', 'Information Technology ESIE1'],
  ['C67661', '4300001307-0', 'LENOVO', 'YJ01LH6J', ''],
  ['C67671', '4300001340-0', 'LENOVO', 'YJ01LH2Z', 'Quality Control ESIE1'],
  ['C67666', '4300001312-0', 'LENOVO', 'YJ01K9FD', 'Information Technology ESIE1'],
  ['C67670', '4300001339-0', 'LENOVO', 'YJ01LH5P', ''],
  ['NB67536', '4300001324-0', 'LENOVO', 'PF4S1BTX', 'Marketing H&S BP'],
  ['C67669', '4300001338-0', 'LENOVO', 'YJ01LH3J', 'Marketing H&S BP'],
  ['C67667', '4300001332-0', 'LENOVO', 'GM0EBA8S', 'Maintenance ESIE1'],
  ['NB67546', '', 'LENOVO', '0', 'Marketing Management'],
  ['C67681', '', 'LENOVO', 'GM0L3LXX', ''],
  ['NB67547', '', 'LENOVO', '0', 'Purchasing BP'],
  ['NB67548', '', 'LENOVO', '0', 'Marketing Management'],
  ['NB67545', '', 'LENOVO', '0', 'Information Technology BP'],
  ['NB67549', '', 'HP', '5CG4273PPZ', 'Management-Share All'],
  ['CL68683', '', 'LENOVO', '0', ''],
  ['C65628', '4300001163-0', 'LENOVO', '', 'Marketing Support'],
  ['C65629', '4300001164-0', 'LENOVO', 'PC2DX6E6', 'Marketing Support'],
  ['C65632', '4306DV', '', '', ''],
  ['C65633', '4300001174-0', 'LENOVO', 'PC2D3WTY', ''],
  ['C65634', '4300001175-0', 'LENOVO', 'PC2D3WTZ', ''],
  ['C65635', '4300001187-0', 'LENOVO', 'PC29DJWK', ''],
  ['C65636', '', '', '', 'Gas BP'],
  ['C65637', '4300001189-0', 'LENOVO', 'PC29DJWH', 'Quality Control BP'],
  ['C65638', '4300001190-0', 'LENOVO', 'PC2D3WW3', ''],
  ['C65639', '4300001191-0', 'LENOVO', 'PC2D3WTK', ''],
  ['C65640', '4300001192-0', 'LENOVO', 'PC2D3WW0', 'Delivery Center H&S-ESIE1'],
  ['NB65437', '4300001168-0', 'LENOVO', 'PF31TT1T', 'Chemical Support'],
  ['NB65438', '', 'LENOVO', 'PF33STFL', 'Analysis Center ESIE1'],
  ['NB65439', '4300001170-0', 'LENOVO', 'PF33QZD7', 'Analysis Center Special ESIE1'],
  ['NB65440', '4300001171-0', 'LENOVO', 'PF33SV1K', ''],
  ['NB65441', '4300001172-0', 'LENOVO', 'PF33QZF1', 'Isonite ESIE1'],
  ['NB65442', '4300001176-0', 'LENOVO', 'PF3N2MDL', 'Marketing Management'],
  ['NB65443', '4300001177-0', 'LENOVO', 'PF3N2PL4', 'Delivery Center H&S-BP'],
  ['NB65444', '4300001178-0', 'LENOVO', 'PF3N2RX5', 'Delivery Center H&S-BP'],
  ['NB65445', '4300001179-0', 'LENOVO', 'PF3N2RWB', 'Delivery Center H&S-BP'],
  ['NB65446', '4300001180-0', 'LENOVO', 'PF3N2RZ3', 'Delivery Center H&S-GW'],
  ['NB65447', '4300001181-0', 'LENOVO', 'PF3N2PNC', 'Gas BP'],
  ['NB65448', '4300001182-0', 'LENOVO', 'PF3N2RXN', 'Quality Assurance BP 12'],
  ['NB65449', '4300001183-0', 'LENOVO', 'PF3N2PM8', 'Kanigen'],
  ['NB65450', '4300001184-0', 'LENOVO', '', ''],
  ['NB65451', '4300001185-0', 'LENOVO', 'PF3N2DT8', 'Human Resources'],
  ['NB65452', '4300001186-0', 'LENOVO', 'PF3N2K69', 'Chemical Support'],
  ['NB65453', '4300001193-0', 'LENOVO', '', ''],
  ['NB65454', '4300001194-0', 'LENOVO', 'PF40W00L', 'Quality Assurance BP 12'],
  ['NB65455', '', 'LENOVO', 'PF40VL35', 'Information Technology BP'],
  ['NB65456', '4300001188-0', 'LENOVO', 'PC29DJWN', ''],
  ['NB65457', '', 'LENOVO', 'PF3N2PLP', 'Marketing H&S BP'],
];

/** =========================
 * 2.5) LOCATION MAPPING
 * ========================= */
const LOCATIONS_BY_PLANT = {
  'TP-BP12': ['RM221', 'RM222', 'RM223', 'RM224', 'RM225', 'CONF-BP12', 'SRV-BP12', 'ADM-BP12', 'OFC-BP12'],
  'TP-BP8': ['CONF-BP8', 'SRV-BP8', 'OFC-BP8'],
  'TP-GW': ['CONF-GW', 'SRV-GW', 'OFC-GW'],
  'TP-ESIE1': ['CONF-ESIE1', 'SRV-ESIE1', 'ADM-ESIE1', 'OFC-ESIE1']
};

/** =========================
 * 3) HELPERS
 * ========================= */
const START_EPC_HEX = 'E28011606000020000000001';
function incHex(hex, inc) {
  // บวกเลขฐาน16 (ยาว 24 ไบต์) แล้วคืนเป็นสตริงความยาวเดิม
  const n = BigInt('0x' + hex) + BigInt(inc);
  let s = n.toString(16).toUpperCase();
  if (s.length < hex.length) s = s.padStart(hex.length, '0');
  return s;
}

function toCategory(assetNo) {
  if (!assetNo) return 'PC';
  return assetNo.startsWith('NB') ? 'LAP' : 'PC';
}

function normBrand(name) {
  if (!name) return null;
  return BRAND_MAP[name.trim()] || name.trim();
}

function toDeptCode(name) {
  if (!name) return null;
  return DEPT_CODE_MAP[name.trim()] || null;
}

function toPlantCode(deptCode) {
  if (!deptCode) return null;
  return DEPT_TO_PLANT[deptCode] || null;
}

function cleanSerial(s) {
  if (!s) return null;
  const v = String(s).trim();
  return INVALID_SERIALS.has(v) ? null : v;
}

function randomLocation(plantCode) {
  if (!plantCode || !LOCATIONS_BY_PLANT[plantCode]) {
    return null; // ไม่มี plant หรือ plant ไม่มี location
  }
  const locations = LOCATIONS_BY_PLANT[plantCode];
  return locations[Math.floor(Math.random() * locations.length)];
}

function extractYearFromAssetNo(assetNo) {
  if (!assetNo) return new Date('2025-01-01'); // default

  // Extract year from asset_no pattern: NB62184 or C62600
  const match = assetNo.match(/^(NB|C|CL)(\d{2})/);
  if (match) {
    const yearSuffix = parseInt(match[2]); // 62, 63, etc.
    const fullYear = 2500 + yearSuffix; // 2562, 2563, etc. (Buddhist Era)
    const gregorianYear = fullYear - 543; // Convert to Gregorian (2019, 2020, etc.)
    return new Date(`${gregorianYear}-01-01`);
  }

  return new Date('2025-01-01'); // fallback
}

/** =========================
 * 4) MAIN SEED
 * ========================= */
async function seedAssets() {
  console.log('💻 Seeding asset_master...');
  await prisma.$connect();

  let created = 0, skipped = 0;

  for (let i = 0; i < rawRows.length; i++) {
    const [asset_no, inventory_no, brand_name, serial_no, dept_name] = rawRows[i];

    const brand_code = normBrand(brand_name);
    const dept_code = toDeptCode(dept_name);
    const plant_code = toPlantCode(dept_code);
    const category_code = toCategory(asset_no);
    const unit_code = 'EA';
    const quantity = 1;
    const status = 'A';
    const description = null;
    const deactivated_at = null;
    const created_by = 'USR_999999';
    const created_at = extractYearFromAssetNo(asset_no);
    const last_update = created_at;

    const epc_code = incHex(START_EPC_HEX, i); // +1 ต่อแถว

    const finalSerial = cleanSerial(serial_no);

    const data = {
      asset_no,
      epc_code,
      description,
      plant_code,
      location_code: null,
      dept_code,
      serial_no: finalSerial,
      inventory_no: inventory_no || null,
      quantity,
      unit_code,
      category_code,
      brand_code,
      status,
      deactivated_at,
      created_by,
      created_at,
      last_update,
    };

    const exists = await prisma.asset_master.findUnique({ where: { asset_no } });
    if (exists) {
      console.log(`⏭️  Skip ${asset_no} (exists)`);
      skipped++;
      continue;
    }

    try {
      await prisma.asset_master.create({ data });
      console.log(`✅ Created ${asset_no}`);
      created++;
    } catch (error) {
      console.error(`❌ Failed to create ${asset_no}:`, error.message);
      skipped++;
    }
  }

  console.log(`\n📊 Summary: ${created} created, ${skipped} skipped`);
  await prisma.$disconnect();
}

if (require.main === module) {
  seedAssets()
    .catch((e) => { console.error(e); process.exit(1); });
}

module.exports = { seedAssets };
