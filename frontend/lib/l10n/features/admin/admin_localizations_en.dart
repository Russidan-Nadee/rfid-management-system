// Path: frontend/lib/l10n/features/admin/admin_localizations_en.dart
import 'admin_localizations.dart';

/// English localization for Admin feature
class AdminLocalizationsEn extends AdminLocalizations {
  @override
  String get pageTitle => 'Admin - Asset Management';

  @override
  String get menuTitle => 'Admin Menu';
  
  // Search Section
  @override
  String get searchTitle => 'Search Assets';

  @override
  String get searchHint => 'Search by Asset No, Description, Serial No...';

  @override
  String get searchButton => 'Search';

  @override
  String get clearButton => 'Clear';

  @override
  String get statusFilter => 'Status';

  @override
  String get statusAll => 'All';

  @override
  String get statusAwaiting => 'Awaiting';

  @override
  String get statusChecked => 'Checked';

  @override
  String get statusInactive => 'Inactive';
  
  // Asset List
  @override
  String get totalAssets => 'Total Assets';

  @override
  String get assetNo => 'Asset No';

  @override
  String get description => 'Description';

  @override
  String get serialNo => 'Serial No';

  @override
  String get status => 'Status';

  @override
  String get plant => 'Plant';

  @override
  String get location => 'Location';

  @override
  String get actions => 'Actions';
  
  // Asset Status
  @override
  String get awaiting => 'Awaiting';

  @override
  String get checked => 'Checked';

  @override
  String get inactive => 'Inactive';

  @override
  String get unknown => 'Unknown';
  
  // Actions
  @override
  String get edit => 'Edit';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get update => 'Update';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';
  
  // Edit Dialog
  @override
  String get editAssetTitle => 'Edit Asset';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get serialNoLabel => 'Serial No';

  @override
  String get inventoryNoLabel => 'Inventory No';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get statusLabel => 'Status';

  @override
  String get readOnlyInfoTitle => 'Read-only Information:';

  @override
  String get epcCodeLabel => 'EPC Code';

  @override
  String get plantLabel => 'Plant';

  @override
  String get locationLabel => 'Location';

  @override
  String get unitLabel => 'Unit';
  
  // Delete/Deactivate Dialog
  @override
  String get deactivateAssetTitle => 'Deactivate Asset';

  @override
  String get deactivateConfirmMessage => 'Are you sure you want to deactivate this asset?';

  @override
  String get deactivateExplanation => 'This will set the asset status to Inactive. The asset data will be preserved and can be reactivated later.';
  
  // Messages
  @override
  String get assetUpdatedSuccess => 'Asset updated successfully';

  @override
  String get assetDeactivatedSuccess => 'Asset deactivated successfully';

  @override
  String get noAssetsFound => 'No assets found';

  @override
  String get loading => 'Loading...';

  @override
  String get dismiss => 'Dismiss';
  
  // Error Messages
  @override
  String get errorGeneric => 'An unexpected error occurred';

  @override
  String get errorLoadingAssets => 'Failed to load assets';

  @override
  String get errorUpdatingAsset => 'Failed to update asset';

  @override
  String get errorDeactivatingAsset => 'Failed to deactivate asset';

  @override
  String get validationFailed => 'Validation failed';

  @override
  String get internalServerError => 'Internal server error';
  
  // Reports Section
  @override
  String get allReports => 'All Issues';

  @override
  String get loadingAllReports => 'Loading all issues...';

  @override
  String get errorLoadingReports => 'Error Loading Issues';

  @override
  String get noReportsFound => 'No Issues Found';

  @override
  String get noReportsFoundMessage => 'There are no issues in the system yet.';
  
  // Report Actions Dialog
  @override
  String get acknowledgeReportTitle => 'Acknowledge Issue';

  @override
  String get completeReportTitle => 'Complete Issue';

  @override
  String get rejectReportTitle => 'Reject Issue';

  @override
  String get updateReportTitle => 'Update Issue';

  @override
  String get acknowledgeDescription => 'Acknowledge this issue and move it to in-progress status.';

  @override
  String get completeDescription => 'Mark this issue as resolved. Please provide resolution details.';

  @override
  String get rejectDescription => 'Reject this issue and mark it as cancelled. Please provide a reason.';

  @override
  String get updateDescription => 'Update this issue.';

  @override
  String get resolutionNoteRequired => 'Resolution Note *';

  @override
  String get rejectionReasonRequired => 'Rejection Reason *';

  @override
  String get acknowledgmentNoteOptional => 'Acknowledgment Note (Optional)';

  @override
  String get resolutionNotePlaceholder => 'Describe how the issue was resolved...';

  @override
  String get rejectionReasonPlaceholder => 'Explain why this issue is being rejected...';

  @override
  String get acknowledgmentNotePlaceholder => 'Add any notes about this acknowledgment...';

  @override
  String get acknowledgeButton => 'Acknowledge';

  @override
  String get markCompleteButton => 'Mark Complete';

  @override
  String get rejectReportButton => 'Reject Issue';

  @override
  String get updateButton => 'Update';

  @override
  String get reportAcknowledgedMessage => 'Issue acknowledged and moved to in-progress';

  @override
  String get reportCompletedMessage => 'Issue marked as resolved';

  @override
  String get reportRejectedMessage => 'Issue rejected and cancelled';

  @override
  String get reportUpdatedMessage => 'Issue updated';

  @override
  String get noSubject => 'No Subject';

  @override
  String get noDescription => 'No Description';

  @override
  String get asset => 'Asset';

  @override
  String get reportNumber => 'Issue #';

  @override
  String get pleaseProvideResolution => 'Please provide resolution details';

  @override
  String get pleaseProvideRejection => 'Please provide rejection reason';
  
  // Role Management
  @override
  String get roleManagement => 'Role Management';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get filterByRole => 'Filter by Role';

  @override
  String get allRoles => 'All Roles';

  @override
  String get filterByStatus => 'Filter by Status';

  @override
  String get allStatus => 'All';

  @override
  String get roleLabel => 'Role';

  @override
  String get statusFilterLabel => 'Status';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get activateUser => 'Activate';

  @override
  String get deactivateUser => 'Deactivate';

  @override
  String get activeStatus => 'ACTIVE';

  @override
  String get inactiveStatus => 'INACTIVE';

  @override
  String get neverLoggedIn => 'Never';

  @override
  String get searchAndFilters => 'Search & Filters';

  @override
  String get searchByNameEmployeeId => 'Search by name, employee ID, or email...';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get primaryImage => 'PRIMARY';
}