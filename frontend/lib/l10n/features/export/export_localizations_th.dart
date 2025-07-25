// Path: frontend/lib/l10n/features/export/export_localizations_th.dart
import 'export_localizations.dart';

/// Thai localization for Export feature
class ExportLocalizationsTh extends ExportLocalizations {
  // Page Title
  @override
  String get pageTitle => 'การจัดการส่งออก';

  @override
  String get exportPageTitle => 'ส่งออก';

  // Tab Labels
  @override
  String get createExportTab => 'สร้างการส่งออก';

  @override
  String get historyTab => 'ประวัติ';

  // Export Configuration
  @override
  String get exportConfiguration => 'การกำหนดค่าส่งออก';

  @override
  String get exportConfigurationDescription =>
      'กำหนดค่ารูปแบบและตัวกรองเพื่อสร้างรายงานที่ปรับแต่งได้';

  @override
  String get exportType => 'ประเภทการส่งออก';

  @override
  String get fileFormat => 'รูปแบบไฟล์';

  // Export Types
  @override
  String get assetsExport => 'ส่งออกสินทรัพย์';

  @override
  String get assetsExportDescription =>
      'ส่งออกข้อมูลสินทรัพย์ทั้งหมด รวมทั้งสถานที่ สถานะ และรายละเอียด';

  @override
  String get allStatusLabel => 'ทุกสถานะ (Active, Inactive, Created)';

  // File Formats
  @override
  String get excelFormat => 'Excel (.xlsx)';

  @override
  String get excelFormatDescription => 'สเปรดชีตพร้อมการจัดรูปแบบ';

  @override
  String get csvFormat => 'CSV (.csv)';

  @override
  String get csvFormatDescription => 'ข้อความธรรมดา คั่นด้วยเครื่องหมายจุลภาค';

  // Export Data Notice
  @override
  String get exportData => 'ส่งออกข้อมูล';

  @override
  String get exportDataDescription =>
      'จะส่งออกข้อมูลสินทรัพย์ทั้งหมดโดยไม่มีข้อจำกัดเรื่องวันที่ ประวัติทั้งหมดจะถูกรวมไว้';

  // Buttons
  @override
  String get exportAllData => 'ส่งออกข้อมูลทั้งหมด';

  @override
  String get exportFile => 'ส่งออกไฟล์';

  @override
  String get download => 'ดาวน์โหลด';

  @override
  String get retry => 'ลองใหม่';

  @override
  String get cancel => 'ยกเลิก';

  // Loading Messages
  @override
  String get creatingExportJob => 'กำลังสร้างงานส่งออก...';

  @override
  String get processingExport => 'กำลังประมวลผลการส่งออก...';

  @override
  String get downloadingFile => 'กำลังดาวน์โหลดไฟล์...';

  @override
  String get loadingExportHistory => 'กำลังโหลดประวัติการส่งออก...';

  @override
  String get loading => 'กำลังโหลด...';

  @override
  String get searching => 'กำลังค้นหา...';

  @override
  String get processing => 'กำลังประมวลผล...';

  // Success Messages
  @override
  String get exportJobCreated => 'สร้างงานส่งออกแล้ว! กำลังประมวลผล...';

  @override
  String get exportCompleted => 'การส่งออกเสร็จสมบูรณ์และพร้อมดาวน์โหลด!';

  @override
  String get exportDownloadSuccess => 'ดาวน์โหลดไฟล์สำเร็จ!';

  @override
  String get fileShared => 'แชร์ไฟล์แล้ว';

  // Export History
  @override
  String get exportHistory => 'ประวัติการส่งออก';

  @override
  String get noExportHistory => 'ไม่มีประวัติการส่งออก';

  @override
  String get createFirstExport => 'สร้างการส่งออกครั้งแรกเพื่อดูที่นี่';

  @override
  String get goToCreateExportTab => 'ไปที่แท็บสร้างการส่งออกเพื่อเริ่มต้น';

  @override
  String get exportFilesExpire => 'ไฟล์ส่งออกจะหมดอายุหลังจาก 7 วัน';

  // Export Item Details
  @override
  String get exportId => 'รหัสการส่งออก';

  @override
  String get exportIdNumber => 'การส่งออก #';

  @override
  String get status => 'สถานะ';

  @override
  String get records => 'บันทึก';

  @override
  String get totalRecords => 'บันทึก';

  @override
  String get fileSize => 'ขนาดไฟล์';

  @override
  String get createdAt => 'สร้างเมื่อ';

  @override
  String get createdDate => 'วันที่สร้าง';

  // Formatting Labels (with colons)
  @override
  String get statusLabel => 'สถานะ: ';

  @override
  String get recordsLabel => 'บันทึก: ';

  @override
  String get createdLabel => 'สร้างเมื่อ: ';

  @override
  String get formatLabel => 'รูปแบบ: ';

  @override
  String get selectedFormatLabel => 'รูปแบบที่เลือก: ';

  @override
  String get configFormatLabel => 'รูปแบบการกำหนดค่า: ';

  // Status Labels
  @override
  String get statusCompleted => 'เสร็จสมบูรณ์';

  @override
  String get statusProcessing => 'กำลังประมวลผล';

  @override
  String get statusFailed => 'ล้มเหลว';

  @override
  String get statusCancelled => 'ยกเลิกแล้ว';

  @override
  String get statusPending => 'รอดำเนินการ';

  // Error Messages
  @override
  String get errorLoadingHistory => 'เกิดข้อผิดพลาดในการโหลดประวัติ';

  @override
  String get errorCreatingExport => 'ไม่สามารถสร้างการส่งออกได้';

  @override
  String get errorDownloadFailed => 'การดาวน์โหลดล้มเหลว';

  @override
  String get errorExportFailed => 'การส่งออกล้มเหลว';

  @override
  String get errorGeneric => 'เกิดข้อผิดพลาด';

  @override
  String get errorInvalidFormat =>
      'รูปแบบการส่งออกไม่ถูกต้อง กรุณาเลือก xlsx หรือ csv';

  @override
  String get platformNotSupported =>
      'ฟีเจอร์ส่งออกใช้ได้เฉพาะในเว็บเบราว์เซอร์หรือเดสก์ท็อปเท่านั้น กรุณาใช้เวอร์ชันเว็บ';

  // Detailed Error Messages (with prefixes)
  @override
  String get failedToCreateExport => 'ไม่สามารถสร้างการส่งออกได้: ';

  @override
  String get failedToCheckStatus => 'ไม่สามารถตรวจสอบสถานะได้: ';

  @override
  String get failedToDownload => 'การดาวน์โหลดล้มเหลว: ';

  @override
  String get failedToLoadHistory => 'ไม่สามารถโหลดประวัติได้: ';

  @override
  String get failedToCancelExport => 'ไม่สามารถยกเลิกการส่งออกได้: ';

  @override
  String get failedToSaveSettings => 'ไม่สามารถบันทึกการตั้งค่าได้: ';

  // Format-specific Labels
  @override
  String get exportXLSX => 'ส่งออก XLSX';

  @override
  String get exportCSV => 'ส่งออก CSV';

  @override
  String get exportXLSXFiltered => 'ส่งออก XLSX (กรองแล้ว)';

  @override
  String get exportCSVFiltered => 'ส่งออก CSV (กรองแล้ว)';

  @override
  String get exportXLSXDateRange => 'ส่งออก XLSX (ช่วงวันที่)';

  @override
  String get exportCSVDateRange => 'ส่งออก CSV (ช่วงวันที่)';

  // Sidebar Navigation (Large Screen)
  @override
  String get exportTools => 'เครื่องมือส่งออก';

  @override
  String get createExportDescription => 'สร้างไฟล์ส่งออกใหม่';

  @override
  String get exportHistoryDescription => 'ดูและดาวน์โหลดการส่งออก';

  // Empty States
  @override
  String get noResultsFound => 'ไม่พบผลลัพธ์';

  @override
  String get tryAgainLater => 'กรุณาลองใหม่อีกครั้งในภายหลัง';

  // Confirmation Messages
  @override
  String get confirmCancel => 'คุณแน่ใจหรือไม่ว่าต้องการยกเลิกการส่งออกนี้?';

  @override
  String get confirmDelete => 'คุณแน่ใจหรือไม่ว่าต้องการลบการส่งออกนี้?';

  // Time Related
  @override
  String get expiresIn => 'หมดอายุใน';

  @override
  String get expired => 'หมดอายุแล้ว';

  @override
  String get daysLeft => 'วันที่เหลือ';

  @override
  String get hoursLeft => 'ชั่วโมงที่เหลือ';

  @override
  String get minutesLeft => 'นาทีที่เหลือ';

  // Debug & Development Messages
  @override
  String get formatSelected => 'รูปแบบที่เลือก: ';

  @override
  String get exportPressed => 'กดส่งออก - ส่งออกข้อมูลทั้งหมด';

  @override
  String get exportingAllData => 'ส่งออกข้อมูลทั้งหมด';

  @override
  String get hasFiltersLabel => 'มีตัวกรอง: ';

  @override
  String get noDateRestrictions =>
      'หมายเหตุ: ส่งออกข้อมูลทั้งหมด (ไม่มีข้อจำกัดเรื่องวันที่)';

  // Additional Status and Progress
  @override
  String get exportInProgress => 'การส่งออกกำลังดำเนินการ...';

  @override
  String get preparingDownload => 'กำลังเตรียมการดาวน์โหลด...';

  @override
  String get initiatingExport => 'กำลังเริ่มการส่งออก...';

  // Configuration Debug Info
  @override
  String get exportConfigurationDebug => 'การกำหนดค่าส่งออก:';

  @override
  String get plantsFilter => 'โรงงาน: ';

  @override
  String get locationsFilter => 'สถานที่: ';

  @override
  String get statusFilter => 'สถานะ: ';

  // Additional Info
  @override
  String get totalSize => 'ขนาดรวม';

  @override
  String get exportFormat => 'รูปแบบ';

  @override
  String get exportProgress => 'ความคืบหน้า';

  @override
  String get estimatedTime => 'เวลาที่คาดการณ์';

  @override
  String get remainingTime => 'เวลาที่เหลือ';
}
