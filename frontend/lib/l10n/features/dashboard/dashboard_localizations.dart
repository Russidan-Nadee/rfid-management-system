// Path: frontend/lib/l10n/features/dashboard/dashboard_localizations.dart
import 'package:flutter/material.dart';
import 'dashboard_localizations_en.dart';
import 'dashboard_localizations_th.dart';
import 'dashboard_localizations_ja.dart';

/// Abstract base class for Dashboard localization
/// กำหนด Contract/Interface สำหรับ Dashboard feature
abstract class DashboardLocalizations {
  /// Get the appropriate localization instance based on current locale
  static DashboardLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'th':
        return DashboardLocalizationsTh();
      case 'ja':
        return DashboardLocalizationsJa();
      case 'en':
      default:
        return DashboardLocalizationsEn();
    }
  }

  // Page Title
  String get pageTitle;
  String get dashboard;

  // Loading States
  String get loading;
  String get initializing;
  String get loadingDashboard;

  // Error States
  String get dashboardError;
  String get retry;
  String get loadDashboard;

  // Empty States
  String get noDashboardData;
  String get noDashboardDataDescription;
  String get noDataAvailable;
  String get noDataFound;
  String get noDataToDisplay;
  String get reload;
  String get noResultsFound;
  String get clearSearch;
  String get noConnection;
  String get checkInternetConnection;
  String get tryAgain;
  String get refreshDashboard;
  String get addAsset;
  String get noAssetsInSystem;

  // Summary Cards
  String get allAssets;
  String get newAssets;

  // Chart Titles
  String get auditProgress;
  String get assetDistribution;
  String get assetGrowthDepartment;
  String get assetGrowthLocation;

  // Filters
  String get allDepartments;
  String get allLocations;
  String get filtered;

  // Audit Progress
  String get auditProgressPrefix;
  String get auditProgressAllDepartments;
  String get overallProgress;
  String get checked;
  String get awaiting;
  String get total;
  String get completed;
  String get critical;
  String get totalDepts;
  String get departmentSummary;
  String get recommendations;
  String get complete;

  // Asset Distribution
  String get totalAssets;
  String get departments;
  String get filter;
  String get summary;
  String get assets;
  String get noDistributionData;
  String get noDistributionDataAvailable;

  // Growth Trends
  String get period;
  String get currentYear;
  String get latestYear;
  String get averageGrowth;
  String get periods;
  String get noTrendData;
  String get noTrendDataAvailable;
  String get noLocationTrendData;
  String get noLocationTrendDataAvailable;

  // Chart Data Labels
  String get year;

  // Time Info
  String get lastUpdated;
  String get fresh;
  String get stale;
  String get ok;
  String get timeAgo;

  // Refresh
  String get refresh;
  String get refreshing;
  String get refreshData;
  String get clearCache;
  String get autoRefresh;
  String get autoRefreshSettings;
  String get enableAutoRefresh;
  String get autoRefreshDescription;
  String get refreshInterval;
  String get autoRefreshWarning;
  String get cancel;
  String get apply;
  String get autoRefreshEnabled;
  String get autoRefreshDisabled;

  // Data Status
  String get noDepartmentData;
  String get noLocationData;
  String get noAuditData;
  String get noChartData;
  String get noChartDataAvailable;

  // Chart Types
  String get pieChart;
  String get barChart;
  String get lineChart;

  // Error Messages
  String get noDepartmentDataForThisDepartment;
  String get failedToLoadDashboard;
  String get dashboardDataNotAvailable;

  // Dynamic Functions
  String assetsCount(int count);
  String percentComplete(double percent);
  String moreRecommendations(int count);
  String chartTooltip(String year, int assets, String percentage);
  String lastUpdatedTooltip(String dateTime);
  String noResultsFor(String searchTerm);
  String autoRefreshEnabledWithInterval(String interval);
}
