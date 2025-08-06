// Path: frontend/lib/l10n/features/search/search_localizations_en.dart
import 'search_localizations.dart';

/// English localization for Search feature
class SearchLocalizationsEn extends SearchLocalizations {
  // Page Title
  @override
  String get pageTitle => 'Search';

  // Search Input
  @override
  String get searchPlaceholder => 'Search...';
  @override
  String get searchHint => 'Type a query to see results';

  // Search States
  @override
  String get searchingFor => 'Searching for';
  @override
  String get startYourSearch => 'Start your search';
  @override
  String get typeQueryToSeeResults => 'Type a query to see results';

  // Results
  @override
  String get searchResults => 'Search Results';
  @override
  String get searchResultsFor => 'Search Results for';
  @override
  String get totalItems => 'items';
  @override
  String get noResultsFound => 'No results found for';
  @override
  String get noResultsFoundMessage =>
      'Try a different search term or check your spelling.';
  @override
  String get cached => 'Cached';

  // Loading States
  @override
  String get loading => 'Loading...';
  @override
  String get searchingMessage => 'Searching...';

  // Error States
  @override
  String get errorOccurred => 'Happened an error while searching for';
  @override
  String get searchFailed => 'Search failed';
  @override
  String get failedToSearch => 'Failed to search';
  @override
  String get retry => 'Retry';

  // Entity Types
  @override
  String get assets => 'Assets';
  @override
  String get plants => 'Plants';
  @override
  String get locations => 'Locations';
  @override
  String get departments => 'Departments';
  @override
  String get users => 'Users';

  // Asset Information
  @override
  String get assetNo => 'Asset No';
  @override
  String get assetNumber => 'Asset Number';
  @override
  String get description => 'Description';
  @override
  String get serialNumber => 'Serial Number';
  @override
  String get inventoryNumber => 'Inventory Number';
  @override
  String get quantity => 'Quantity';
  @override
  String get unit => 'Unit';
  @override
  String get status => 'Status';

  // Status Values
  @override
  String get active => 'Active';
  @override
  String get inactive => 'Inactive';
  @override
  String get created => 'Created';

  // Detail Dialog
  @override
  String get itemDetails => 'Item Details';
  @override
  String get completeInformation => 'Complete Information';
  @override
  String get close => 'Close';
  @override
  String get copied => 'copied';

  // Sections in Detail Dialog
  @override
  String get assetInformation => 'Asset Information';
  @override
  String get locationAndPlant => 'Location & Plant';
  @override
  String get department => 'Department';
  @override
  String get userInformation => 'User Information';
  @override
  String get timestamps => 'Timestamps';
  @override
  String get otherInformation => 'Other Information';

  // Common Fields
  @override
  String get noDescription => 'No description';
  @override
  String get noAssetNumber => 'No asset number';
  @override
  String get empty => '(empty)';

  // Time Related
  @override
  String get createdAt => 'Created At';
  @override
  String get updatedAt => 'Updated At';
  @override
  String get deactivatedAt => 'Deactivated At';

  // Plant & Location
  @override
  String get plantCode => 'Plant Code';
  @override
  String get plantDescription => 'Plant Description';
  @override
  String get locationCode => 'Location Code';
  @override
  String get locationDescription => 'Location Description';

  // Department
  @override
  String get deptCode => 'Dept Code';
  @override
  String get deptDescription => 'Dept Description';

  // User Fields
  @override
  String get createdBy => 'Created By';
  @override
  String get userRole => 'User Role';

  // Image Related
  @override
  String get images => 'Images';
  @override
  String get hasImages => 'Has images';
  @override
  String get noImagesAvailable => 'No images available';
  @override
  String get imagesWillAppearHere => 'Images will appear here';
  @override
  String get imageLoadError => 'Failed to load image';
  @override
  String get primary => 'Primary';
}
