// Path: frontend/lib/l10n/features/export/export_localizations_en.dart
import 'export_localizations.dart';

/// English localization for Export feature
class ExportLocalizationsEn extends ExportLocalizations {
  // Page Title
  @override
  String get pageTitle => 'Export Management';

  @override
  String get exportPageTitle => 'Export';

  // Tab Labels
  @override
  String get createExportTab => 'Create Export';

  @override
  String get historyTab => 'History';

  // Export Configuration
  @override
  String get exportConfiguration => 'Export Configuration';

  @override
  String get exportConfigurationDescription =>
      'Configure your export format and filters to generate custom reports';

  @override
  String get exportType => 'Export Type';

  @override
  String get fileFormat => 'File Format';

  // Export Types
  @override
  String get assetsExport => 'Assets Export';

  @override
  String get assetsExportDescription =>
      'Export all asset information including locations, status, and descriptions';

  @override
  String get allStatusLabel => 'All Status (Awaiting, Checked, Inactive)';

  // File Formats
  @override
  String get excelFormat => 'Excel (.xlsx)';

  @override
  String get excelFormatDescription => 'Spreadsheet with formatting';

  @override
  String get csvFormat => 'CSV (.csv)';

  @override
  String get csvFormatDescription => 'Plain text, comma-separated';

  // Export Data Notice
  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataDescription =>
      'This will export all assets data without any date restrictions. All historical records will be included.';

  // Buttons
  @override
  String get exportAllData => 'Export All Data';

  @override
  String get exportFile => 'Export File';

  @override
  String get download => 'Download';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  // Loading Messages
  @override
  String get creatingExportJob => 'Creating export job...';

  @override
  String get processingExport => 'Processing export...';

  @override
  String get downloadingFile => 'Downloading file...';

  @override
  String get loadingExportHistory => 'Loading export history...';

  @override
  String get loading => 'Loading...';

  @override
  String get searching => 'Searching...';

  @override
  String get processing => 'Processing...';

  // Success Messages
  @override
  String get exportJobCreated => 'Export job created! Processing...';

  @override
  String get exportCompleted => 'Export completed and ready to download!';

  @override
  String get exportDownloadSuccess => 'File downloaded successfully!';

  @override
  String get fileShared => 'File shared';

  // Export History
  @override
  String get exportHistory => 'Export History';

  @override
  String get noExportHistory => 'No export history';

  @override
  String get createFirstExport => 'Create your first export to see it here';

  @override
  String get goToCreateExportTab => 'Go to Create Export tab to get started';

  @override
  String get exportFilesExpire => 'Export files expire after 7 days';

  // Export Item Details
  @override
  String get exportId => 'Export ID';

  @override
  String get exportIdNumber => 'Export #';

  @override
  String get status => 'Status';

  @override
  String get records => 'records';

  @override
  String get totalRecords => 'Records';

  @override
  String get fileSize => 'File Size';

  @override
  String get createdAt => 'Created';

  @override
  String get createdDate => 'Created Date';

  // Formatting Labels (with colons)
  @override
  String get statusLabel => 'Status: ';

  @override
  String get recordsLabel => 'Records: ';

  @override
  String get createdLabel => 'Created: ';

  @override
  String get formatLabel => 'Format: ';

  @override
  String get selectedFormatLabel => 'Selected format: ';

  @override
  String get configFormatLabel => 'Config format: ';

  // Status Labels
  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusPending => 'Pending';

  // Error Messages
  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String get errorCreatingExport => 'Failed to create export';

  @override
  String get errorDownloadFailed => 'Download failed';

  @override
  String get errorExportFailed => 'Export failed';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get errorInvalidFormat =>
      'Invalid export format. Please select xlsx or csv.';

  @override
  String get platformNotSupported =>
      'Export feature is only available on web browser or desktop. Please use the web version.';

  // Detailed Error Messages (with prefixes)
  @override
  String get failedToCreateExport => 'Failed to create export: ';

  @override
  String get failedToCheckStatus => 'Failed to check status: ';

  @override
  String get failedToDownload => 'Download failed: ';

  @override
  String get failedToLoadHistory => 'Failed to load history: ';

  @override
  String get failedToCancelExport => 'Failed to cancel export: ';

  @override
  String get failedToSaveSettings => 'Failed to save settings: ';

  // Format-specific Labels
  @override
  String get exportXLSX => 'Export XLSX';

  @override
  String get exportCSV => 'Export CSV';

  @override
  String get exportXLSXFiltered => 'Export XLSX (Filtered)';

  @override
  String get exportCSVFiltered => 'Export CSV (Filtered)';

  @override
  String get exportXLSXDateRange => 'Export XLSX (Date Range)';

  @override
  String get exportCSVDateRange => 'Export CSV (Date Range)';

  // Sidebar Navigation (Large Screen)
  @override
  String get exportTools => 'Export Tools';

  @override
  String get createExportDescription => 'Generate new export files';

  @override
  String get exportHistoryDescription => 'View and download exports';

  // Empty States
  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryAgainLater => 'Please try again later';

  // Confirmation Messages
  @override
  String get confirmCancel => 'Are you sure you want to cancel this export?';

  @override
  String get confirmDelete => 'Are you sure you want to delete this export?';

  // Time Related
  @override
  String get expiresIn => 'Expires in';

  @override
  String get expired => 'Expired';

  @override
  String get daysLeft => 'days left';

  @override
  String get hoursLeft => 'hours left';

  @override
  String get minutesLeft => 'minutes left';

  // Debug & Development Messages
  @override
  String get formatSelected => 'Format selected: ';

  @override
  String get exportPressed => 'Export pressed - exporting all data';

  @override
  String get exportingAllData => 'Exporting all data';

  @override
  String get hasFiltersLabel => 'Has Filters: ';

  @override
  String get noDateRestrictions =>
      'Note: Exporting ALL data (no date restrictions)';

  // Additional Status and Progress
  @override
  String get exportInProgress => 'Export in progress...';

  @override
  String get preparingDownload => 'Preparing download...';

  @override
  String get initiatingExport => 'Initiating export...';

  // Configuration Debug Info
  @override
  String get exportConfigurationDebug => 'Export Configuration:';

  @override
  String get plantsFilter => 'Plants: ';

  @override
  String get locationsFilter => 'Locations: ';

  @override
  String get statusFilter => 'Status: ';

  // Status Descriptions
  @override
  String get activeStatusDescription => 'Assets waiting for verification';

  @override
  String get createdStatusDescription => 'Assets that have been verified';

  @override
  String get inactiveStatusDescription => 'Inactive or retired assets';

  @override
  String get allStatusDescription => 'Export all assets regardless of status';

  // Additional Info
  @override
  String get totalSize => 'Total Size';

  @override
  String get exportFormat => 'Format';

  @override
  String get exportProgress => 'Progress';

  @override
  String get estimatedTime => 'Estimated Time';

  @override
  String get remainingTime => 'Remaining Time';
}
