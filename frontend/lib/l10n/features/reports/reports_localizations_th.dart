// Path: frontend/lib/l10n/features/reports/reports_localizations_th.dart
import 'reports_localizations.dart';

/// Thai localization for Reports feature
class ReportsLocalizationsTh extends ReportsLocalizations {
  @override
  String get allReportsTitle => 'รายงานทั้งหมด';

  @override
  String get allReportsAdminTitle => 'รายงานทั้งหมด (ผู้ดูแลระบบ)';

  @override
  String get myReportsTitle => 'รายงานของฉัน';
  
  // Loading States
  @override
  String get loadingAllReports => 'กำลังโหลดรายงานทั้งหมด...';

  @override
  String get loadingReports => 'กำลังโหลดรายงาน...';
  
  // Error States
  @override
  String get errorLoadingReports => 'เกิดข้อผิดพลาดในการโหลดรายงาน';

  @override
  String get errorLoadingReportsMessage => 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';

  @override
  String get tryAgain => 'ลองใหม่';
  
  // Empty States
  @override
  String get noReportsFound => 'ไม่พบรายงาน';

  @override
  String get noReportsFoundAdmin => 'ยังไม่มีรายงานในระบบ';

  @override
  String get noReportsFoundUser => 'คุณยังไม่ได้ส่งรายงานใดๆ';
  
  // Actions
  @override
  String get refresh => 'รีเฟรช';

  @override
  String get testApiConnection => 'ทดสอบการเชื่อมต่อ API';

  @override
  String get apiTestComplete => 'การทดสอบ API เสร็จสิ้น';

  @override
  String get apiTestCompleteAdmin => 'การทดสอบ API เสร็จสิ้น (โหมดผู้ดูแลระบบ) - ตรวจสอบคอนโซล';

  @override
  String get apiTestCompleteUser => 'การทดสอบ API เสร็จสิ้น (โหมดผู้ใช้) - ตรวจสอบคอนโซล';

  @override
  String get apiTestFailed => 'การทดสอบ API ล้มเหลว';

  @override
  String get checkConsole => 'ตรวจสอบคอนโซล';
  
  // General
  @override
  String get adminMode => 'โหมดผู้ดูแลระบบ';

  @override
  String get userMode => 'โหมดผู้ใช้';

  @override
  String get reports => 'รายงาน';

  @override
  String get report => 'รายงาน';

  @override
  String get allReports => 'รายงานทั้งหมด';

  @override
  String get myReports => 'รายงานของฉัน';
  
  // Report Card Content
  @override
  String get noSubject => 'ไม่มีหัวข้อ';

  @override
  String get noDescription => 'ไม่มีคำอธิบาย';

  @override
  String get reportId => 'รหัส';

  @override
  String get reported => 'วันที่รายงาน';

  @override
  String get updated => 'วันที่อัปเดต';

  @override
  String get reportedBy => 'รายงานโดย';

  @override
  String get acknowledged => 'รับทราบแล้ว';

  @override
  String get resolved => 'แก้ไขแล้ว';

  @override
  String get rejected => 'ปฏิเสธ';
  
  // Report Actions
  @override
  String get acknowledge => 'รับทราบ';

  @override
  String get reject => 'ปฏิเสธ';

  @override
  String get complete => 'เสร็จสิ้น';

  @override
  String get reportAcknowledgedSuccess => 'รายงานได้รับการรับทราบและย้ายไปที่กำลังดำเนินการ';

  @override
  String get failedToAcknowledgeReport => 'ไม่สามารถรับทราบรายงานได้';

  @override
  String get errorAcknowledgingReport => 'เกิดข้อผิดพลาดในการรับทราบรายงาน';
  
  // Problem Types
  @override
  String get assetDamage => 'สินทรัพย์เสียหาย';

  @override
  String get missingAsset => 'สินทรัพย์สูญหาย';

  @override
  String get locationIssue => 'ปัญหาตำแหน่ง';

  @override
  String get dataError => 'ข้อผิดพลาดข้อมูล';

  @override
  String get urgentIssue => 'เรื่องเร่งด่วน';

  @override
  String get other => 'อื่นๆ';
  
  // Status Types
  @override
  String get pending => 'รอดำเนินการ';

  @override
  String get acknowledgedStatus => 'รับทราบแล้ว';

  @override
  String get inProgress => 'กำลังดำเนินการ';

  @override
  String get resolvedStatus => 'แก้ไขแล้ว';

  @override
  String get cancelled => 'ยกเลิก';
  
  // Priority Types
  @override
  String get low => 'ต่ำ';

  @override
  String get normal => 'ปกติ';

  @override
  String get high => 'สูง';

  @override
  String get critical => 'วิกฤต';
  
  // General Labels
  @override
  String get notAvailable => 'ไม่มีข้อมูล';

  @override
  String get by => 'โดย';

  @override
  String get reportedLabel => 'รายงานเมื่อ';

  @override
  String get updatedLabel => 'อัปเดตเมื่อ';

  @override
  String get acknowledgedLabel => 'รับทราบเมื่อ';

  @override
  String get resolvedLabel => 'แก้ไขเมื่อ';
}