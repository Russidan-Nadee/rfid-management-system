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
}