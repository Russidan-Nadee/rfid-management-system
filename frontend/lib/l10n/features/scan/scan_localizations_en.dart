// Path: frontend/lib/l10n/features/scan/scan_localizations_en.dart
import 'scan_localizations.dart';

/// English localization for Scan feature
class ScanLocalizationsEn extends ScanLocalizations {
  // Page Titles
  @override
  String get scanPageTitle => 'RFID Scan';

  @override
  String get assetDetailPageTitle => 'Asset Detail';

  @override
  String get createAssetPageTitle => 'Create New Asset';

  // Scan Page - Ready State
  @override
  String get scannerReady => 'RFID Scanner Ready';

  @override
  String get scanInstructions =>
      'Press the button below to start scanning RFID tags';

  @override
  String get startScanning => 'Start Scanning';

  @override
  String get ensureScannerConnected => 'Make sure RFID scanner is connected';

  @override
  String get scanAgain => 'Scan Again';

  // Scan Page - Loading State
  @override
  String get scanningTags => 'Scanning RFID Tags...';

  @override
  String get pleaseWaitScanning => 'Please wait while we scan for assets';

  // Scan Page - Error State
  @override
  String get scanFailed => 'Scan Failed';

  @override
  String get tryAgain => 'Try Again';

  // Scan Page - Success State
  @override
  String scannedItemsCount(int count) => 'Scanned $count items';

  // Asset Detail Page - Section Titles
  @override
  String get basicInformation => 'Basic Information';

  @override
  String get locationInformation => 'Location Information';

  @override
  String get quantityInformation => 'Quantity Information';

  @override
  String get scanActivity => 'Scan Activity';

  @override
  String get creationInformation => 'Creation Information';

  // Asset Detail Page - Field Labels
  @override
  String get assetNumber => 'Asset Number';

  @override
  String get description => 'Description';

  @override
  String get serialNumber => 'Serial Number';

  @override
  String get inventoryNumber => 'Inventory Number';

  @override
  String get plant => 'Plant';

  @override
  String get location => 'Location';

  @override
  String get department => 'Department';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get lastScan => 'Last Scan';

  @override
  String get scannedBy => 'Scanned By';

  @override
  String get createdBy => 'Created By';

  @override
  String get createdDate => 'Created Date';

  @override
  String get epcCode => 'EPC Code';

  // Asset Status Labels
  @override
  String get statusActive => 'Active';

  @override
  String get statusChecked => 'Checked';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get statusAwaiting => 'Awaiting';

  // Asset Detail Page - Actions
  @override
  String get markAsChecked => 'Mark as Checked';

  @override
  String get markingAsChecked => 'Marking as Checked...';

  // Asset Detail Page - Messages
  @override
  String get assetMarkedSuccess => 'Asset marked as checked successfully';

  @override
  String get neverScanned => 'Never scanned';

  @override
  String get unknownUser => 'Unknown User';

  // Create Asset Page - Header
  @override
  String get creatingUnknownAsset => 'Creating Unknown Asset';

  // Create Asset Page - Loading States
  @override
  String get loadingFormData => 'Loading form data...';

  @override
  String get creatingAsset => 'Creating asset...';

  @override
  String get loadingFailed => 'Loading Failed';

  @override
  String get pleaseWaitCreating => 'Please wait while we create your asset';

  // Create Asset Page - Form Hints
  @override
  String get assetNumberHint => 'Enter asset number (e.g., A001234)';

  @override
  String get descriptionHint => 'Enter asset description';

  @override
  String get optional => 'Optional';

  // Create Asset Page - Validation
  @override
  String get pleaseSelectPlant => 'Please select a plant';

  @override
  String get pleaseSelectLocation => 'Please select a location';

  @override
  String get pleaseSelectUnit => 'Please select a unit';

  // Create Asset Page - Sections
  @override
  String get optionalInformation => 'Optional Information';

  // Create Asset Page - Actions
  @override
  String get createAsset => 'Create Asset';

  // Create Asset Page - Messages
  @override
  String get assetCreatedSuccess => 'Asset created successfully';

  @override
  String get failedToGetCurrentUser => 'Failed to get current user';

  // Location Selection
  @override
  String get selectCurrentLocation => 'Select Current Location';

  @override
  String get chooseLocationToVerify =>
      'Choose your current location to verify scanned assets';

  // Scan List View - Filters
  @override
  String get filterByLocation => 'Filter by Location';

  @override
  String get filterByStatus => 'Filter by Status';

  @override
  String get searchLocations => 'Search locations...';

  @override
  String get allLocations => 'All Locations';

  @override
  String get all => 'All';

  // Scan List View - Empty States
  @override
  String get noScannedItems => 'No scanned items';

  @override
  String get tapScanButtonToStart =>
      'Tap the scan button to start scanning RFID tags';

  @override
  String noItemsInLocation(String location) => 'No items in $location';

  @override
  String noFilteredItems(String filter) => 'No $filter items';

  @override
  String get tryDifferentLocationOrScan =>
      'Try selecting a different location or scan again';

  @override
  String get tryDifferentFilterOrScan =>
      'Try selecting a different filter or scan again';

  // Scan List View - Search
  @override
  String noLocationsFound(String query) =>
      'No locations found matching "$query"';

  // Field Labels with Context
  @override
  String epcCodeField(String code) => 'EPC Code: $code';

  // Loading Messages
  @override
  String get loading => 'Loading...';

  // Error Messages
  @override
  String get errorGeneric => 'An unexpected error occurred';
}
