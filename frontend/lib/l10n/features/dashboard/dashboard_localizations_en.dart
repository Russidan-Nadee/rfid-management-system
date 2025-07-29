// Path: frontend/lib/l10n/features/dashboard/dashboard_localizations_en.dart
import 'dashboard_localizations.dart';

/// English localization for Dashboard feature
class DashboardLocalizationsEn extends DashboardLocalizations {
  @override
  String get pageTitle => 'Dashboard';

  @override
  String get dashboard => 'Dashboard';

  // Loading States
  @override
  String get loading => 'Loading...';

  @override
  String get initializing => 'Initializing dashboard...';

  @override
  String get loadingDashboard => 'Loading dashboard...';

  // Error States
  @override
  String get dashboardError => 'Dashboard Error';

  @override
  String get retry => 'Retry';

  @override
  String get loadDashboard => 'Load Dashboard';

  // Empty States
  @override
  String get noDashboardData => 'No Dashboard Data';

  @override
  String get noDashboardDataDescription =>
      'Dashboard data is not available at the moment';

  @override
  String get noDataAvailable => 'No Data Available';

  @override
  String get noDataFound => 'No Data Found';

  @override
  String get noDataToDisplay => 'There is no data to display at the moment.';

  @override
  String get reload => 'Reload';

  @override
  String get noResultsFound => 'No Results Found';

  @override
  String get clearSearch => 'Clear Search';

  @override
  String get noConnection => 'No Connection';

  @override
  String get checkInternetConnection =>
      'Please check your internet connection and try again.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get refreshDashboard => 'Refresh Dashboard';

  @override
  String get addAsset => 'Add Asset';

  @override
  String get noAssetsInSystem =>
      'No assets available in the system.\nStart by adding your first asset.';

  // Summary Cards
  @override
  String get allAssets => 'All Assets';

  @override
  String get newAssets => 'New Assets';

  // Chart Titles
  @override
  String get auditProgress => 'Audit Progress';

  @override
  String get assetDistribution => 'Asset Distribution';

  @override
  String get assetGrowthDepartment => 'Asset Growth Department';

  @override
  String get assetGrowthLocation => 'Asset Growth Location';

  // Filters
  @override
  String get allDepartments => 'All Departments';

  @override
  String get allLocations => 'All Locations';

  @override
  String get filtered => 'Filtered';

  // Audit Progress
  @override
  String get auditProgressPrefix => 'Audit Progress - ';

  @override
  String get auditProgressAllDepartments => 'Audit Progress - All Departments';

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String get checked => 'Checked';

  @override
  String get awaiting => 'Awaiting';

  @override
  String get total => 'Total';

  @override
  String get completed => 'Completed';

  @override
  String get critical => 'Critical';

  @override
  String get totalDepts => 'Total Depts';

  @override
  String get departmentSummary => 'Department Summary';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get complete => 'Complete';

  // Asset Distribution
  @override
  String get totalAssets => 'Total Assets';

  @override
  String get departments => 'Departments';

  @override
  String get filter => 'Filter';

  @override
  String get summary => 'Summary';

  @override
  String get assets => 'Assets';

  @override
  String get noDistributionData => 'No Distribution Data';

  @override
  String get noDistributionDataAvailable => 'No distribution data available';

  // Growth Trends
  @override
  String get period => 'Period';

  @override
  String get currentYear => 'Current Year';

  @override
  String get latestYear => 'Latest Year';

  @override
  String get averageGrowth => 'Average Growth';

  @override
  String get periods => 'Periods';

  @override
  String get noTrendData => 'No Trend Data';

  @override
  String get noTrendDataAvailable => 'No trend data available';

  @override
  String get noLocationTrendData => 'No Location Trend Data';

  @override
  String get noLocationTrendDataAvailable => 'No location trend data available';

  // Chart Data Labels
  @override
  String get year => 'Year';

  // Time Info
  @override
  String get lastUpdated => 'Last updated';

  @override
  String get fresh => 'Fresh';

  @override
  String get stale => 'Stale';

  @override
  String get ok => 'OK';

  @override
  String get timeAgo => 'ago';

  // Refresh
  @override
  String get refresh => 'Refresh';

  @override
  String get refreshing => 'Refreshing...';

  @override
  String get refreshData => 'Refresh Data';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get autoRefresh => 'Auto Refresh';

  @override
  String get autoRefreshSettings => 'Auto Refresh Settings';

  @override
  String get enableAutoRefresh => 'Enable Auto Refresh';

  @override
  String get autoRefreshDescription => 'Automatically refresh dashboard data';

  @override
  String get refreshInterval => 'Refresh Interval:';

  @override
  String get autoRefreshWarning =>
      'Auto refresh will consume more battery and data.';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get autoRefreshEnabled => 'Auto refresh enabled';

  @override
  String get autoRefreshDisabled => 'Auto refresh disabled';

  // Data Status
  @override
  String get noDepartmentData => 'No Department Data';

  @override
  String get noLocationData => 'No Location Data';

  @override
  String get noAuditData => 'No Audit Data';

  @override
  String get noChartData => 'No Chart Data';

  @override
  String get noChartDataAvailable => 'No chart data available';

  // Error Messages
  @override
  String get noDepartmentDataForThisDepartment =>
      'No data available for this department.';

  @override
  String get failedToLoadDashboard => 'Failed to load dashboard';

  @override
  String get dashboardDataNotAvailable =>
      'Dashboard data is not available at the moment';

  // Dynamic Functions
  @override
  String assetsCount(int count) => '$count assets';

  @override
  String percentComplete(double percent) =>
      '${percent.toStringAsFixed(0)}% complete';

  @override
  String moreRecommendations(int count) => '+ $count more recommendations';

  @override
  String chartTooltip(String year, int assets, String percentage) =>
      'Year $year\n$assets assets\n$percentage';

  @override
  String lastUpdatedTooltip(String dateTime) => 'Last updated: $dateTime';

  @override
  String noResultsFor(String searchTerm) =>
      'No results found for "$searchTerm".\nTry different keywords.';

  @override
  String autoRefreshEnabledWithInterval(String interval) =>
      'Auto refresh enabled ($interval)';
}
