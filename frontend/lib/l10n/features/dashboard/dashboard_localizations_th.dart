// Path: frontend/lib/l10n/features/dashboard/dashboard_localizations_th.dart
import 'dashboard_localizations.dart';

/// Thai localization for Dashboard feature
class DashboardLocalizationsTh extends DashboardLocalizations {
  @override
  String get pageTitle => 'แดชบอร์ด';

  @override
  String get dashboard => 'แดชบอร์ด';

  // Loading States
  @override
  String get loading => 'กำลังโหลด...';

  @override
  String get initializing => 'กำลังเตรียมแดชบอร์ด...';

  @override
  String get loadingDashboard => 'กำลังโหลดแดชบอร์ด...';

  // Error States
  @override
  String get dashboardError => 'ข้อผิดพลาดแดชบอร์ด';

  @override
  String get retry => 'ลองใหม่';

  @override
  String get loadDashboard => 'โหลดแดชบอร์ด';

  // Empty States
  @override
  String get noDashboardData => 'ไม่มีข้อมูลแดชบอร์ด';

  @override
  String get noDashboardDataDescription =>
      'ข้อมูลแดชบอร์ดไม่พร้อมใช้งานในขณะนี้';

  @override
  String get noDataAvailable => 'ไม่มีข้อมูล';

  @override
  String get noDataFound => 'ไม่พบข้อมูล';

  @override
  String get noDataToDisplay => 'ไม่มีข้อมูลที่จะแสดงในขณะนี้';

  @override
  String get reload => 'โหลดใหม่';

  @override
  String get noResultsFound => 'ไม่พบผลลัพธ์';

  @override
  String get clearSearch => 'ล้างการค้นหา';

  @override
  String get noConnection => 'ไม่มีการเชื่อมต่อ';

  @override
  String get checkInternetConnection =>
      'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตและลองใหม่';

  @override
  String get tryAgain => 'ลองใหม่';

  @override
  String get refreshDashboard => 'รีเฟรชแดชบอร์ด';

  @override
  String get addAsset => 'เพิ่มสินทรัพย์';

  @override
  String get noAssetsInSystem =>
      'ไม่มีสินทรัพย์ในระบบ เริ่มต้นด้วยการเพิ่มสินทรัพย์แรกของคุณ';

  // Summary Cards
  @override
  String get allAssets => 'สินทรัพย์ทั้งหมด';

  @override
  String get newAssets => 'สินทรัพย์ใหม่';

  // Chart Titles
  @override
  String get auditProgress => 'ความคืบหน้าการตรวจสอบ';

  @override
  String get assetDistribution => 'การกระจายสินทรัพย์';

  @override
  String get assetGrowthDepartment => 'การเติบโตสินทรัพย์แยกตามแผนก';

  @override
  String get assetGrowthLocation => 'การเติบโตสินทรัพย์แยกตามสถานที่';

  // Filters
  @override
  String get allDepartments => 'ทุกแผนก';

  @override
  String get allLocations => 'ทุกสถานที่';

  @override
  String get filtered => 'กรองแล้ว';

  // Audit Progress
  @override
  String get auditProgressPrefix => 'ความคืบหน้าการตรวจสอบ - ';

  @override
  String get auditProgressAllDepartments => 'ความคืบหน้าการตรวจสอบ - ทุกแผนก';

  @override
  String get overallProgress => 'ความคืบหน้าโดยรวม';

  @override
  String get checked => 'ตรวจแล้ว';

  @override
  String get awaiting => 'รอตรวจ';

  @override
  String get total => 'ทั้งหมด';

  @override
  String get completed => 'เสร็จแล้ว';

  @override
  String get critical => 'วิกฤต';

  @override
  String get totalDepts => 'แผนกทั้งหมด';

  @override
  String get departmentSummary => 'สรุปแผนก';

  @override
  String get recommendations => 'คำแนะนำ';

  @override
  String get complete => 'เสร็จสิ้น';

  // Asset Distribution
  @override
  String get totalAssets => 'สินทรัพย์ทั้งหมด';

  @override
  String get departments => 'แผนก';

  @override
  String get filter => 'กรอง';

  @override
  String get summary => 'สรุป';

  @override
  String get assets => 'สินทรัพย์';

  @override
  String get noDistributionData => 'ไม่มีข้อมูลการกระจาย';

  @override
  String get noDistributionDataAvailable => 'ไม่มีข้อมูลการกระจายสินทรัพย์';

  // Growth Trends
  @override
  String get period => 'ช่วงเวลา';

  @override
  String get currentYear => 'ปีปัจจุบัน';

  @override
  String get latestYear => 'ปีล่าสุด';

  @override
  String get averageGrowth => 'การเติบโตเฉลี่ย';

  @override
  String get periods => 'ช่วงเวลา';

  @override
  String get noTrendData => 'ไม่มีข้อมูลแนวโน้ม';

  @override
  String get noTrendDataAvailable => 'ไม่มีข้อมูลแนวโน้มการเติบโต';

  @override
  String get noLocationTrendData => 'ไม่มีข้อมูลแนวโน้มสถานที่';

  @override
  String get noLocationTrendDataAvailable =>
      'ไม่มีข้อมูลแนวโน้มการเติบโตของสถานที่';

  // Chart Data Labels
  @override
  String get year => 'ปี';

  // Time Info
  @override
  String get lastUpdated => 'อัปเดตล่าสุด';

  @override
  String get fresh => 'ล่าสุด';

  @override
  String get stale => 'ล้าสมัย';

  @override
  String get ok => 'ปกติ';

  @override
  String get timeAgo => 'ที่แล้ว';

  // Refresh
  @override
  String get refresh => 'รีเฟรช';

  @override
  String get refreshing => 'กำลังรีเฟรช...';

  @override
  String get refreshData => 'รีเฟรชข้อมูล';

  @override
  String get clearCache => 'ล้างแคช';

  @override
  String get autoRefresh => 'รีเฟรชอัตโนมัติ';

  @override
  String get autoRefreshSettings => 'การตั้งค่ารีเฟรชอัตโนมัติ';

  @override
  String get enableAutoRefresh => 'เปิดใช้รีเฟรชอัตโนมัติ';

  @override
  String get autoRefreshDescription => 'รีเฟรชข้อมูลแดชบอร์ดโดยอัตโนมัติ';

  @override
  String get refreshInterval => 'ช่วงเวลารีเฟรช:';

  @override
  String get autoRefreshWarning =>
      'การรีเฟรชอัตโนมัติจะใช้แบตเตอรี่และข้อมูลมากขึ้น';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get apply => 'ใช้งาน';

  @override
  String get autoRefreshEnabled => 'เปิดใช้รีเฟรชอัตโนมัติแล้ว';

  @override
  String get autoRefreshDisabled => 'ปิดใช้รีเฟรชอัตโนมัติแล้ว';

  // Data Status
  @override
  String get noDepartmentData => 'ไม่มีข้อมูลแผนก';

  @override
  String get noLocationData => 'ไม่มีข้อมูลสถานที่';

  @override
  String get noAuditData => 'ไม่มีข้อมูลการตรวจสอบ';

  @override
  String get noChartData => 'ไม่มีข้อมูลกราฟ';

  @override
  String get noChartDataAvailable => 'ไม่มีข้อมูลกราฟ';

  // Error Messages
  @override
  String get noDepartmentDataForThisDepartment => 'ไม่มีข้อมูลสำหรับแผนกนี้';

  @override
  String get failedToLoadDashboard => 'ไม่สามารถโหลดแดชบอร์ดได้';

  @override
  String get dashboardDataNotAvailable =>
      'ข้อมูลแดชบอร์ดไม่พร้อมใช้งานในขณะนี้';

  // Dynamic Functions
  @override
  String assetsCount(int count) => '$count สินทรัพย์';

  @override
  String percentComplete(double percent) =>
      'เสร็จแล้ว ${percent.toStringAsFixed(0)}%';

  @override
  String moreRecommendations(int count) => '+ อีก $count คำแนะนำ';

  @override
  String chartTooltip(String year, int assets, String percentage) =>
      'ปี $year\n$assets สินทรัพย์\n$percentage';

  @override
  String lastUpdatedTooltip(String dateTime) => 'อัปเดตล่าสุด: $dateTime';

  @override
  String noResultsFor(String searchTerm) =>
      'ไม่พบผลลัพธ์สำหรับ "$searchTerm" ลองใช้คำค้นหาอื่น';

  @override
  String autoRefreshEnabledWithInterval(String interval) =>
      'เปิดใช้รีเฟรชอัตโนมัติ ($interval)';
}
