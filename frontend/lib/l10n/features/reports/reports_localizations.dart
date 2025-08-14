// Path: frontend/lib/l10n/features/reports/reports_localizations.dart
import 'package:flutter/material.dart';
import 'reports_localizations_en.dart';
import 'reports_localizations_th.dart';
import 'reports_localizations_ja.dart';

/// Abstract base class for Reports localization
/// กำหนด Contract/Interface สำหรับ Reports feature
abstract class ReportsLocalizations {
  /// Get the appropriate localization instance based on current locale
  static ReportsLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'th':
        return ReportsLocalizationsTh();
      case 'ja':
        return ReportsLocalizationsJa();
      case 'en':
      default:
        return ReportsLocalizationsEn();
    }
  }

  // Page Titles
  String get allReportsTitle;
  String get allReportsAdminTitle;
  String get myReportsTitle;
  
  // Loading States
  String get loadingAllReports;
  String get loadingReports;
  
  // Error States
  String get errorLoadingReports;
  String get errorLoadingReportsMessage;
  String get tryAgain;
  
  // Empty States
  String get noReportsFound;
  String get noReportsFoundAdmin;
  String get noReportsFoundUser;
  
  // Actions
  String get refresh;
  String get testApiConnection;
  String get apiTestComplete;
  String get apiTestCompleteAdmin;
  String get apiTestCompleteUser;
  String get apiTestFailed;
  String get checkConsole;
  
  // General
  String get adminMode;
  String get userMode;
  String get reports;
  String get report;
  String get allReports;
  String get myReports;
  
  // Report Card Content
  String get noSubject;
  String get noDescription;
  String get reportId;
  String get reported;
  String get updated;
  String get reportedBy;
  String get acknowledged;
  String get resolved;
  String get rejected;
  
  // Report Actions
  String get acknowledge;
  String get reject;
  String get complete;
  String get reportAcknowledgedSuccess;
  String get failedToAcknowledgeReport;
  String get errorAcknowledgingReport;
  
  // Problem Types
  String get assetDamage;
  String get missingAsset;
  String get locationIssue;
  String get dataError;
  String get urgentIssue;
  String get other;
  
  // Status Types
  String get pending;
  String get acknowledgedStatus;
  String get inProgress;
  String get resolvedStatus;
  String get cancelled;
  
  // Priority Types
  String get low;
  String get normal;
  String get high;
  String get critical;
  
  // General Labels
  String get notAvailable;
  String get by;
}