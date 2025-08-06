// Path: frontend/lib/l10n/features/scan/scan_localizations_th.dart
import 'scan_localizations.dart';

/// Thai localization for Scan feature
class ScanLocalizationsTh extends ScanLocalizations {
  // Page Titles
  @override
  String get scanPageTitle => 'สแกน RFID';

  @override
  String get assetDetailPageTitle => 'รายละเอียดสินทรัพย์';

  @override
  String get createAssetPageTitle => 'สร้างสินทรัพย์ใหม่';

  // Scan Page - Ready State
  @override
  String get scannerReady => 'เครื่องสแกน RFID พร้อมใช้งาน';

  @override
  String get scanInstructions => 'กดปุ่มด้านล่างเพื่อเริ่มสแกนแท็ก RFID';

  @override
  String get startScanning => 'เริ่มสแกน';

  @override
  String get ensureScannerConnected =>
      'ตรวจสอบให้แน่ใจว่าเครื่องสแกน RFID เชื่อมต่อแล้ว';

  @override
  String get scanAgain => 'สแกนอีกครั้ง';

  // Scan Page - Loading State
  @override
  String get scanningTags => 'กำลังสแกนแท็ก RFID...';

  @override
  String get pleaseWaitScanning => 'กรุณารอสักครู่ในขณะที่เราสแกนหาสินทรัพย์';

  // Scan Page - Error State
  @override
  String get scanFailed => 'การสแกนล้มเหลว';

  @override
  String get tryAgain => 'ลองใหม่';

  // Scan Page - Success State
  @override
  String scannedItemsCount(int count) => 'สแกนได้ $count รายการ';

  // Asset Detail Page - Section Titles
  @override
  String get basicInformation => 'ข้อมูลพื้นฐาน';

  @override
  String get locationInformation => 'ข้อมูลสถานที่';

  @override
  String get quantityInformation => 'ข้อมูลจำนวน';

  @override
  String get scanActivity => 'กิจกรรมการสแกน';

  @override
  String get creationInformation => 'ข้อมูลการสร้าง';

  // Asset Detail Page - Field Labels
  @override
  String get assetNumber => 'หมายเลขสินทรัพย์';

  @override
  String get description => 'คำอธิบาย';

  @override
  String get serialNumber => 'หมายเลขเครื่อง';

  @override
  String get inventoryNumber => 'หมายเลขสินค้าคงคลัง';

  @override
  String get plant => 'โรงงาน';

  @override
  String get location => 'สถานที่';

  @override
  String get department => 'แผนก';

  @override
  String get quantity => 'จำนวน';

  @override
  String get unit => 'หน่วย';

  @override
  String get lastScan => 'สแกนล่าสุด';

  @override
  String get scannedBy => 'สแกนโดย';

  @override
  String get createdBy => 'สร้างโดย';

  @override
  String get createdDate => 'วันที่สร้าง';

  @override
  String get epcCode => 'รหัส EPC';

  // Asset Status Labels
  @override
  String get statusActive => 'ใช้งาน';

  @override
  String get statusChecked => 'ตรวจสอบแล้ว';

  @override
  String get statusInactive => 'ไม่ใช้งาน';

  @override
  String get statusUnknown => 'ไม่รู้จัก';

  @override
  String get statusAwaiting => 'รอการตรวจสอบ';

  // Asset Detail Page - Actions
  @override
  String get markAsChecked => 'ทำเครื่องหมายว่าตรวจสอบแล้ว';

  @override
  String get markingAsChecked => 'กำลังทำเครื่องหมายว่าตรวจสอบแล้ว...';

  // Asset Detail Page - Messages
  @override
  String get assetMarkedSuccess =>
      'ทำเครื่องหมายสินทรัพย์ว่าตรวจสอบแล้วเรียบร้อย';

  @override
  String get neverScanned => 'ไม่เคยสแกน';

  @override
  String get unknownUser => 'ผู้ใช้ไม่ทราบ';

  // Create Asset Page - Header
  @override
  String get creatingUnknownAsset => 'กำลังสร้างสินทรัพย์ที่ไม่ทราบ';

  // Create Asset Page - Loading States
  @override
  String get loadingFormData => 'กำลังโหลดข้อมูลแบบฟอร์ม...';

  @override
  String get creatingAsset => 'กำลังสร้างสินทรัพย์...';

  @override
  String get loadingFailed => 'การโหลดล้มเหลว';

  @override
  String get pleaseWaitCreating =>
      'กรุณารอสักครู่ในขณะที่เราสร้างสินทรัพย์ของคุณ';

  // Create Asset Page - Form Hints
  @override
  String get assetNumberHint => 'ใส่หมายเลขสินทรัพย์ (เช่น A001234)';

  @override
  String get descriptionHint => 'ใส่คำอธิบายสินทรัพย์';

  @override
  String get optional => 'ไม่บังคับ';

  // Create Asset Page - Validation
  @override
  String get pleaseSelectPlant => 'กรุณาเลือกโรงงาน';

  @override
  String get pleaseSelectLocation => 'กรุณาเลือกสถานที่';

  @override
  String get pleaseSelectUnit => 'กรุณาเลือกหน่วย';

  // Create Asset Page - Sections
  @override
  String get optionalInformation => 'ข้อมูลเสริม';

  // Create Asset Page - Actions
  @override
  String get createAsset => 'สร้างสินทรัพย์';

  // Create Asset Page - Messages
  @override
  String get assetCreatedSuccess => 'สร้างสินทรัพย์เรียบร้อยแล้ว';

  @override
  String get failedToGetCurrentUser => 'ไม่สามารถดึงข้อมูลผู้ใช้ปัจจุบันได้';

  // Location Selection
  @override
  String get selectCurrentLocation => 'เลือกสถานที่ปัจจุบัน';

  @override
  String get chooseLocationToVerify =>
      'เลือกสถานที่ปัจจุบันของคุณเพื่อตรวจสอบสินทรัพย์ที่สแกน';

  // Scan List View - Filters
  @override
  String get filterByLocation => 'กรองตามสถานที่';

  @override
  String get filterByStatus => 'กรองตามสถานะ';

  @override
  String get searchLocations => 'ค้นหาสถานที่...';

  @override
  String get allLocations => 'สถานที่ทั้งหมด';

  @override
  String get all => 'ทั้งหมด';

  // Scan List View - Empty States
  @override
  String get noScannedItems => 'ไม่มีรายการที่สแกน';

  @override
  String get tapScanButtonToStart => 'แตะปุ่มสแกนเพื่อเริ่มสแกนแท็ก RFID';

  @override
  String noItemsInLocation(String location) => 'ไม่มีรายการใน $location';

  @override
  String noFilteredItems(String filter) => 'ไม่มีรายการ $filter';

  @override
  String get tryDifferentLocationOrScan => 'ลองเลือกสถานที่อื่นหรือสแกนใหม่';

  @override
  String get tryDifferentFilterOrScan => 'ลองเลือกตัวกรองอื่นหรือสแกนใหม่';

  // Scan List View - Search
  @override
  String noLocationsFound(String query) => 'ไม่พบสถานที่ที่ตรงกับ "$query"';

  // Field Labels with Context
  @override
  String epcCodeField(String code) => 'รหัส EPC: $code';

  // Loading Messages
  @override
  String get loading => 'กำลังโหลด...';

  // Error Messages
  @override
  String get errorGeneric => 'เกิดข้อผิดพลาดที่ไม่คาดคิด';

  // Image Gallery Section
  @override
  String get images => 'รูปภาพ';

  @override
  String get primary => 'หลัก';

  @override
  String get noImagesAvailable => 'ไม่มีรูปภาพ';

  @override
  String get imagesWillAppearHere => 'รูปภาพจะปรากฏที่นี่เมื่ออัพโหลด';

  @override
  String get imageLoadError => 'ไม่สามารถโหลดรูปภาพได้';

  // Category and Brand Selection
  @override
  get categoryBrandInformation => 'ข้อมูลหมวดหมู่และแบรนด์';

  @override
  String get category => 'หมวดหมู่';

  @override
  String get brand => 'แบรนด์';
}
