// Path: frontend/lib/l10n/features/reports/reports_localizations_en.dart
import 'reports_localizations.dart';

/// English localization for Reports feature
class ReportsLocalizationsEn extends ReportsLocalizations {
  @override
  String get allReportsTitle => 'All Issues';

  @override
  String get allReportsAdminTitle => 'All Issues (Admin)';

  @override
  String get myReportsTitle => 'My Issues';
  
  // Loading States
  @override
  String get loadingAllReports => 'Loading all issues...';

  @override
  String get loadingReports => 'Loading issues...';
  
  // Error States
  @override
  String get errorLoadingReports => 'Error Loading Issues';

  @override
  String get errorLoadingReportsMessage => 'An unknown error occurred';

  @override
  String get tryAgain => 'Try Again';
  
  // Empty States
  @override
  String get noReportsFound => 'No Issues Found';

  @override
  String get noReportsFoundAdmin => 'There are no issues in the system yet.';

  @override
  String get noReportsFoundUser => 'You haven\'t submitted any issues yet.';
  
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
  String get reports => 'Issues';

  @override
  String get report => 'Issue';

  @override
  String get allReports => 'All Issues';

  @override
  String get myReports => 'My Issues';
  
  // Report Card Content
  @override
  String get noSubject => 'No Subject';

  @override
  String get noDescription => 'No Description';

  @override
  String get reportId => 'Issue ID';

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
  String get reportAcknowledgedSuccess => 'Issue acknowledged and moved to in-progress';

  @override
  String get failedToAcknowledgeReport => 'Failed to acknowledge issue';

  @override
  String get errorAcknowledgingReport => 'Error acknowledging issue';
  
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

  @override
  String get reportedLabel => 'Reported';

  @override
  String get updatedLabel => 'Updated';

  @override
  String get acknowledgedLabel => 'Acknowledged';

  @override
  String get resolvedLabel => 'Resolved';
}