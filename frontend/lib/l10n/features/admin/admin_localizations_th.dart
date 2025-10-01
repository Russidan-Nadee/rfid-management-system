// Path: frontend/lib/l10n/features/admin/admin_localizations_th.dart
import 'admin_localizations.dart';

/// Thai localization for Admin feature
class AdminLocalizationsTh extends AdminLocalizations {
  @override
  String get pageTitle => 'ผู้ดูแลระบบ - การจัดการสินทรัพย์';

  @override
  String get menuTitle => 'เมนูผู้ดูแลระบบ';
  
  // Search Section
  @override
  String get searchTitle => 'ค้นหาสินทรัพย์';

  @override
  String get searchHint => 'ค้นหาด้วยรหัสสินทรัพย์, คำอธิบาย, หมายเลขซีเรียล...';

  @override
  String get searchButton => 'ค้นหา';

  @override
  String get clearButton => 'ล้าง';

  @override
  String get statusFilter => 'สถานะ';

  @override
  String get statusAll => 'ทั้งหมด';

  @override
  String get statusAwaiting => 'รอดำเนินการ';

  @override
  String get statusChecked => 'ตรวจสอบแล้ว';

  @override
  String get statusInactive => 'ไม่ใช้งาน';
  
  // Asset List
  @override
  String get totalAssets => 'สินทรัพย์ทั้งหมด';

  @override
  String get assetNo => 'รหัสสินทรัพย์';

  @override
  String get description => 'คำอธิบาย';

  @override
  String get serialNo => 'หมายเลขซีเรียล';

  @override
  String get status => 'สถานะ';

  @override
  String get plant => 'โรงงาน';

  @override
  String get location => 'สถานที่';

  @override
  String get actions => 'การกระทำ';
  
  // Asset Status
  @override
  String get awaiting => 'รอดำเนินการ';

  @override
  String get checked => 'ตรวจสอบแล้ว';

  @override
  String get inactive => 'ไม่ใช้งาน';

  @override
  String get unknown => 'ไม่ทราบ';
  
  // Actions
  @override
  String get edit => 'แก้ไข';

  @override
  String get deactivate => 'ยกเลิกการใช้งาน';

  @override
  String get update => 'อัปเดต';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get retry => 'ลองใหม่';
  
  // Edit Dialog
  @override
  String get editAssetTitle => 'แก้ไขสินทรัพย์';

  @override
  String get descriptionLabel => 'คำอธิบาย';

  @override
  String get serialNoLabel => 'หมายเลขซีเรียล';

  @override
  String get inventoryNoLabel => 'หมายเลขสต็อก';

  @override
  String get quantityLabel => 'จำนวน';

  @override
  String get statusLabel => 'สถานะ';

  @override
  String get readOnlyInfoTitle => 'ข้อมูลที่อ่านอย่างเดียว:';

  @override
  String get epcCodeLabel => 'รหัส EPC';

  @override
  String get plantLabel => 'โรงงาน';

  @override
  String get locationLabel => 'สถานที่';

  @override
  String get unitLabel => 'หน่วย';
  
  // Delete/Deactivate Dialog
  @override
  String get deactivateAssetTitle => 'ยกเลิกการใช้งานสินทรัพย์';

  @override
  String get deactivateConfirmMessage => 'คุณแน่ใจหรือไม่ว่าต้องการยกเลิกการใช้งานสินทรัพย์นี้?';

  @override
  String get deactivateExplanation => 'การกระทำนี้จะเปลี่ยนสถานะสินทรัพย์เป็นไม่ใช้งาน ข้อมูลสินทรัพย์จะยังคงอยู่และสามารถเปิดใช้งานได้อีกครั้งในภายหลัง';
  
  // Messages
  @override
  String get assetUpdatedSuccess => 'อัปเดตสินทรัพย์เรียบร้อยแล้ว';

  @override
  String get assetDeactivatedSuccess => 'ยกเลิกการใช้งานสินทรัพย์เรียบร้อยแล้ว';

  @override
  String get noAssetsFound => 'ไม่พบสินทรัพย์';

  @override
  String get loading => 'กำลังโหลด...';

  @override
  String get dismiss => 'ปิด';
  
  // Error Messages
  @override
  String get errorGeneric => 'เกิดข้อผิดพลาดที่ไม่คาดคิด';

  @override
  String get errorLoadingAssets => 'ไม่สามารถโหลดข้อมูลสินทรัพย์ได้';

  @override
  String get errorUpdatingAsset => 'ไม่สามารถอัปเดตสินทรัพย์ได้';

  @override
  String get errorDeactivatingAsset => 'ไม่สามารถยกเลิกการใช้งานสินทรัพย์ได้';

  @override
  String get validationFailed => 'การตรวจสอบล้มเหลว';

  @override
  String get internalServerError => 'ข้อผิดพลาดภายในเซิร์ฟเวอร์';
  
  // Reports Section
  @override
  String get allReports => 'ปัญหาทั้งหมด';

  @override
  String get loadingAllReports => 'กำลังโหลดปัญหาทั้งหมด...';

  @override
  String get errorLoadingReports => 'เกิดข้อผิดพลาดในการโหลดปัญหา';

  @override
  String get noReportsFound => 'ไม่พบปัญหา';

  @override
  String get noReportsFoundMessage => 'ยังไม่มีปัญหาในระบบ';
  
  // Report Actions Dialog
  @override
  String get acknowledgeReportTitle => 'รับทราบปัญหา';

  @override
  String get completeReportTitle => 'ปิดปัญหา';

  @override
  String get rejectReportTitle => 'ปฏิเสธปัญหา';

  @override
  String get updateReportTitle => 'อัปเดตปัญหา';

  @override
  String get acknowledgeDescription => 'รับทราบปัญหานี้และเปลี่ยนสถานะเป็นกำลังดำเนินการ';

  @override
  String get completeDescription => 'ทำเครื่องหมายปัญหานี้เป็นแก้ไขแล้ว กรุณาระบุรายละเอียดการแก้ไข';

  @override
  String get rejectDescription => 'ปฏิเสธปัญหานี้และทำเครื่องหมายเป็นยกเลิก กรุณาระบุเหตุผล';

  @override
  String get updateDescription => 'อัปเดตปัญหานี้';

  @override
  String get resolutionNoteRequired => 'หมายเหตุการแก้ไข *';

  @override
  String get rejectionReasonRequired => 'เหตุผลการปฏิเสธ *';

  @override
  String get acknowledgmentNoteOptional => 'หมายเหตุการรับทราบ (ไม่จำเป็น)';

  @override
  String get resolutionNotePlaceholder => 'อธิบายวิธีการแก้ไขปัญหา...';

  @override
  String get rejectionReasonPlaceholder => 'อธิบายเหตุผลที่ปฏิเสธปัญหานี้...';

  @override
  String get acknowledgmentNotePlaceholder => 'เพิ่มหมายเหตุเกี่ยวกับการรับทราบนี้...';

  @override
  String get acknowledgeButton => 'รับทราบ';

  @override
  String get markCompleteButton => 'ทำเครื่องหมายเสร็จสิ้น';

  @override
  String get rejectReportButton => 'ปฏิเสธปัญหา';

  @override
  String get updateButton => 'อัปเดต';

  @override
  String get reportAcknowledgedMessage => 'รับทราบปัญหาแล้วและเปลี่ยนเป็นกำลังดำเนินการ';

  @override
  String get reportCompletedMessage => 'ทำเครื่องหมายปัญหาเป็นแก้ไขแล้ว';

  @override
  String get reportRejectedMessage => 'ปฏิเสธปัญหาและยกเลิกแล้ว';

  @override
  String get reportUpdatedMessage => 'อัปเดตปัญหาแล้ว';

  @override
  String get noSubject => 'ไม่มีหัวข้อ';

  @override
  String get noDescription => 'ไม่มีคำอธิบาย';

  @override
  String get asset => 'สินทรัพย์';

  @override
  String get reportNumber => 'ปัญหาหมายเลข';

  @override
  String get pleaseProvideResolution => 'กรุณาระบุรายละเอียดการแก้ไข';

  @override
  String get pleaseProvideRejection => 'กรุณาระบุเหตุผลการปฏิเสธ';
  
  // Role Management
  @override
  String get roleManagement => 'จัดการบทบาทผู้ใช้';

  @override
  String get totalUsers => 'ผู้ใช้ทั้งหมด';

  @override
  String get filterByRole => 'กรองตามบทบาท';

  @override
  String get allRoles => 'บทบาททั้งหมด';

  @override
  String get filterByStatus => 'กรองตามสถานะ';

  @override
  String get allStatus => 'ทั้งหมด';

  @override
  String get roleLabel => 'บทบาท';

  @override
  String get statusFilterLabel => 'สถานะ';

  @override
  String get noUsersFound => 'ไม่พบผู้ใช้';

  @override
  String get activateUser => 'เปิดใช้งาน';

  @override
  String get deactivateUser => 'ปิดใช้งาน';

  @override
  String get activeStatus => 'ใช้งาน';

  @override
  String get inactiveStatus => 'ไม่ใช้งาน';

  @override
  String get neverLoggedIn => 'ไม่เคย';

  @override
  String get searchAndFilters => 'ค้นหาและกรอง';

  @override
  String get searchByNameEmployeeId => 'ค้นหาด้วยชื่อ รหัสพนักงาน หรืออีเมล...';

  @override
  String get searchUsers => 'ค้นหาผู้ใช้...';

  @override
  String get primaryImage => 'หลัก';
}