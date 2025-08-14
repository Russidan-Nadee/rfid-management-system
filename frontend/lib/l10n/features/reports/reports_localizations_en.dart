// Path: frontend/lib/l10n/features/reports/reports_localizations_en.dart
import 'reports_localizations.dart';

/// English localization for Reports feature
class ReportsLocalizationsEn extends ReportsLocalizations {
  @override
  String get allReportsTitle => 'All Reports';

  @override
  String get allReportsAdminTitle => 'All Reports (Admin)';

  @override
  String get myReportsTitle => 'My Reports';
  
  // Loading States
  @override
  String get loadingAllReports => 'Loading all reports...';

  @override
  String get loadingReports => 'Loading reports...';
  
  // Error States
  @override
  String get errorLoadingReports => 'Error Loading Reports';

  @override
  String get errorLoadingReportsMessage => 'An unknown error occurred';

  @override
  String get tryAgain => 'Try Again';
  
  // Empty States
  @override
  String get noReportsFound => 'No Reports Found';

  @override
  String get noReportsFoundAdmin => 'There are no reports in the system yet.';

  @override
  String get noReportsFoundUser => 'You haven\'t submitted any reports yet.';
  
  // Actions
  @override
  String get refresh => 'Refresh';

  @override
  String get testApiConnection => 'Test API Connection';

  @override
  String get apiTestComplete => 'API Test Complete';

  @override
  String get apiTestCompleteAdmin => 'API Test Complete (Admin Mode) - Check console';

  @override
  String get apiTestCompleteUser => 'API Test Complete (User Mode) - Check console';

  @override
  String get apiTestFailed => 'API Test Failed';

  @override
  String get checkConsole => 'Check console';
  
  // General
  @override
  String get adminMode => 'Admin Mode';

  @override
  String get userMode => 'User Mode';

  @override
  String get reports => 'Reports';

  @override
  String get report => 'Report';

  @override
  String get allReports => 'All Reports';

  @override
  String get myReports => 'My Reports';
  
  // Report Card Content
  @override
  String get noSubject => 'No Subject';

  @override
  String get noDescription => 'No Description';

  @override
  String get reportId => 'ID';

  @override
  String get reported => 'Reported';

  @override
  String get updated => 'Updated';

  @override
  String get reportedBy => 'Reported by';

  @override
  String get acknowledged => 'Acknowledged';

  @override
  String get resolved => 'Resolved';

  @override
  String get rejected => 'Rejected';
  
  // Report Actions
  @override
  String get acknowledge => 'Acknowledge';

  @override
  String get reject => 'Reject';

  @override
  String get complete => 'Complete';

  @override
  String get reportAcknowledgedSuccess => 'Report acknowledged and moved to in-progress';

  @override
  String get failedToAcknowledgeReport => 'Failed to acknowledge report';

  @override
  String get errorAcknowledgingReport => 'Error acknowledging report';
  
  // Problem Types
  @override
  String get assetDamage => 'Asset Damage';

  @override
  String get missingAsset => 'Missing Asset';

  @override
  String get locationIssue => 'Location Issue';

  @override
  String get dataError => 'Data Error';

  @override
  String get urgentIssue => 'Urgent Issue';

  @override
  String get other => 'Other';
  
  // Status Types
  @override
  String get pending => 'Pending';

  @override
  String get acknowledgedStatus => 'Acknowledged';

  @override
  String get inProgress => 'In Progress';

  @override
  String get resolvedStatus => 'Resolved';

  @override
  String get cancelled => 'Cancelled';
  
  // Priority Types
  @override
  String get low => 'Low';

  @override
  String get normal => 'Normal';

  @override
  String get high => 'High';

  @override
  String get critical => 'Critical';
  
  // General Labels
  @override
  String get notAvailable => 'N/A';

  @override
  String get by => 'by';
}