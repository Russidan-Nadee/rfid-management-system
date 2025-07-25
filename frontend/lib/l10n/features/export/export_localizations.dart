// Path: frontend/lib/l10n/features/export/export_localizations.dart
import 'package:flutter/material.dart';
import 'export_localizations_en.dart';
import 'export_localizations_th.dart';
import 'export_localizations_ja.dart';

/// Abstract base class for Export localization
/// กำหนด Contract/Interface สำหรับ Export feature
abstract class ExportLocalizations {
  /// Get the appropriate localization instance based on current locale
  static ExportLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'th':
        return ExportLocalizationsTh();
      case 'ja':
        return ExportLocalizationsJa();
      case 'en':
      default:
        return ExportLocalizationsEn();
    }
  }

  // Page Title
  String get pageTitle;
  String get exportPageTitle;

  // Tab Labels
  String get createExportTab;
  String get historyTab;

  // Export Configuration
  String get exportConfiguration;
  String get exportConfigurationDescription;
  String get exportType;
  String get fileFormat;

  // Export Types
  String get assetsExport;
  String get assetsExportDescription;
  String get allStatusLabel;

  // File Formats
  String get excelFormat;
  String get excelFormatDescription;
  String get csvFormat;
  String get csvFormatDescription;

  // Export Data Notice
  String get exportData;
  String get exportDataDescription;

  // Buttons
  String get exportAllData;
  String get exportFile;
  String get download;
  String get retry;
  String get cancel;

  // Loading Messages
  String get creatingExportJob;
  String get processingExport;
  String get downloadingFile;
  String get loadingExportHistory;
  String get loading;
  String get searching;
  String get processing;

  // Success Messages
  String get exportJobCreated;
  String get exportCompleted;
  String get exportDownloadSuccess;
  String get fileShared;

  // Export History
  String get exportHistory;
  String get noExportHistory;
  String get createFirstExport;
  String get goToCreateExportTab;
  String get exportFilesExpire;

  // Export Item Details
  String get exportId;
  String get exportIdNumber;
  String get status;
  String get records;
  String get totalRecords;
  String get fileSize;
  String get createdAt;
  String get createdDate;

  // Formatting Labels (with colons)
  String get statusLabel;
  String get recordsLabel;
  String get createdLabel;
  String get formatLabel;
  String get selectedFormatLabel;
  String get configFormatLabel;

  // Status Labels
  String get statusCompleted;
  String get statusProcessing;
  String get statusFailed;
  String get statusCancelled;
  String get statusPending;

  // Error Messages
  String get errorLoadingHistory;
  String get errorCreatingExport;
  String get errorDownloadFailed;
  String get errorExportFailed;
  String get errorGeneric;
  String get errorInvalidFormat;
  String get platformNotSupported;

  // Detailed Error Messages (with prefixes)
  String get failedToCreateExport;
  String get failedToCheckStatus;
  String get failedToDownload;
  String get failedToLoadHistory;
  String get failedToCancelExport;
  String get failedToSaveSettings;

  // Format-specific Labels
  String get exportXLSX;
  String get exportCSV;
  String get exportXLSXFiltered;
  String get exportCSVFiltered;
  String get exportXLSXDateRange;
  String get exportCSVDateRange;

  // Sidebar Navigation (Large Screen)
  String get exportTools;
  String get createExportDescription;
  String get exportHistoryDescription;

  // Empty States
  String get noResultsFound;
  String get tryAgainLater;

  // Confirmation Messages
  String get confirmCancel;
  String get confirmDelete;

  // Time Related
  String get expiresIn;
  String get expired;
  String get daysLeft;
  String get hoursLeft;
  String get minutesLeft;

  // Debug & Development Messages
  String get formatSelected;
  String get exportPressed;
  String get exportingAllData;
  String get hasFiltersLabel;
  String get noDateRestrictions;

  // Additional Status and Progress
  String get exportInProgress;
  String get preparingDownload;
  String get initiatingExport;

  // Configuration Debug Info
  String get exportConfigurationDebug;
  String get plantsFilter;
  String get locationsFilter;
  String get statusFilter;

  // Additional Info
  String get totalSize;
  String get exportFormat;
  String get exportProgress;
  String get estimatedTime;
  String get remainingTime;
}
