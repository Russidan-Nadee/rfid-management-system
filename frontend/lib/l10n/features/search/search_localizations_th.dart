// Path: frontend/lib/l10n/features/search/search_localizations_th.dart
import 'search_localizations.dart';

/// Thai localization for Search feature
class SearchLocalizationsTh extends SearchLocalizations {
  // Page Title
  @override
  String get pageTitle => 'ค้นหา';

  // Search Input
  @override
  String get searchPlaceholder => 'ค้นหา...';
  @override
  String get searchHint => 'พิมพ์คำค้นหาเพื่อดูผลลัพธ์';

  // Search States
  @override
  String get searchingFor => 'กำลังค้นหา';
  @override
  String get startYourSearch => 'เริ่มการค้นหา';
  @override
  String get typeQueryToSeeResults => 'พิมพ์คำค้นหาเพื่อดูผลลัพธ์';

  // Results
  @override
  String get searchResults => 'ผลการค้นหา';
  @override
  String get searchResultsFor => 'ผลการค้นหาสำหรับ';
  @override
  String get totalItems => 'รายการ';
  @override
  String get noResultsFound => 'ไม่พบผลลัพธ์สำหรับ';
  @override
  String get noResultsFoundMessage => 'ลองใช้คำค้นหาอื่น หรือตรวจสอบการสะกดคำ';
  @override
  String get cached => 'แคช';

  // Loading States
  @override
  String get loading => 'กำลังโหลด...';
  @override
  String get searchingMessage => 'กำลังค้นหา...';

  // Error States
  @override
  String get errorOccurred => 'เกิดข้อผิดพลาดระหว่างการค้นหา';
  @override
  String get searchFailed => 'การค้นหาล้มเหลว';
  @override
  String get failedToSearch => 'ไม่สามารถค้นหาได้';
  @override
  String get retry => 'ลองใหม่';

  // Entity Types
  @override
  String get assets => 'สินทรัพย์';
  @override
  String get plants => 'โรงงาน';
  @override
  String get locations => 'สถานที่';
  @override
  String get departments => 'แผนก';
  @override
  String get users => 'ผู้ใช้งาน';

  // Asset Information
  @override
  String get assetNo => 'รหัสสินทรัพย์';
  @override
  String get assetNumber => 'หมายเลขสินทรัพย์';
  @override
  String get description => 'รายละเอียด';
  @override
  String get serialNumber => 'หมายเลขซีเรียล';
  @override
  String get inventoryNumber => 'หมายเลขสินค้าคงคลัง';
  @override
  String get quantity => 'จำนวน';
  @override
  String get unit => 'หน่วย';
  @override
  String get status => 'สถานะ';

  // Status Values
  @override
  String get active => 'ใช้งาน';
  @override
  String get inactive => 'ไม่ใช้งาน';
  @override
  String get created => 'สร้างแล้ว';

  // Detail Dialog
  @override
  String get itemDetails => 'รายละเอียดรายการ';
  @override
  String get completeInformation => 'ข้อมูลทั้งหมด';
  @override
  String get close => 'ปิด';
  @override
  String get copied => 'คัดลอกแล้ว';

  // Sections in Detail Dialog
  @override
  String get assetInformation => 'ข้อมูลสินทรัพย์';
  @override
  String get locationAndPlant => 'สถานที่และโรงงาน';
  @override
  String get department => 'แผนก';
  @override
  String get userInformation => 'ข้อมูลผู้ใช้งาน';
  @override
  String get timestamps => 'ข้อมูลเวลา';
  @override
  String get otherInformation => 'ข้อมูลอื่นๆ';

  // Common Fields
  @override
  String get noDescription => 'ไม่มีรายละเอียด';
  @override
  String get noAssetNumber => 'ไม่มีหมายเลขสินทรัพย์';
  @override
  String get empty => '(ว่าง)';

  // Time Related
  @override
  String get createdAt => 'สร้างเมื่อ';
  @override
  String get updatedAt => 'อัปเดตเมื่อ';
  @override
  String get deactivatedAt => 'ปิดใช้งานเมื่อ';

  // Plant & Location
  @override
  String get plantCode => 'รหัสโรงงาน';
  @override
  String get plantDescription => 'รายละเอียดโรงงาน';
  @override
  String get locationCode => 'รหัสสถานที่';
  @override
  String get locationDescription => 'รายละเอียดสถานที่';

  // Department
  @override
  String get deptCode => 'รหัสแผนก';
  @override
  String get deptDescription => 'รายละเอียดแผนก';

  // User Fields
  @override
  String get createdBy => 'สร้างโดย';
  @override
  String get userRole => 'บทบาทผู้ใช้งาน';
}
