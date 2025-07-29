// Path: frontend/lib/l10n/features/scan/scan_localizations.dart
import 'package:flutter/material.dart';
import 'scan_localizations_en.dart';
import 'scan_localizations_th.dart';
import 'scan_localizations_ja.dart';

/// Abstract base class for Scan localization
/// กำหนด Contract/Interface สำหรับ Scan feature
abstract class ScanLocalizations {
  /// Get the appropriate localization instance based on current locale
  static ScanLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'th':
        return ScanLocalizationsTh();
      case 'ja':
        return ScanLocalizationsJa();
      case 'en':
      default:
        return ScanLocalizationsEn();
    }
  }

  // Page Titles
  String get scanPageTitle;
  String get assetDetailPageTitle;
  String get createAssetPageTitle;

  // Scan Page - Ready State
  String get scannerReady;
  String get scanInstructions;
  String get startScanning;
  String get ensureScannerConnected;
  String get scanAgain;

  // Scan Page - Loading State
  String get scanningTags;
  String get pleaseWaitScanning;

  // Scan Page - Error State
  String get scanFailed;
  String get tryAgain;

  // Scan Page - Success State
  String scannedItemsCount(int count);

  // Asset Detail Page - Section Titles
  String get basicInformation;
  String get locationInformation;
  String get quantityInformation;
  String get scanActivity;
  String get creationInformation;

  // Asset Detail Page - Field Labels
  String get assetNumber;
  String get description;
  String get serialNumber;
  String get inventoryNumber;
  String get plant;
  String get location;
  String get department;
  String get quantity;
  String get unit;
  String get lastScan;
  String get scannedBy;
  String get createdBy;
  String get createdDate;
  String get epcCode;

  // Asset Status Labels
  String get statusActive;
  String get statusChecked;
  String get statusInactive;
  String get statusUnknown;
  String get statusAwaiting;

  // Asset Detail Page - Actions
  String get markAsChecked;
  String get markingAsChecked;

  // Asset Detail Page - Messages
  String get assetMarkedSuccess;
  String get neverScanned;
  String get unknownUser;

  // Create Asset Page - Header
  String get creatingUnknownAsset;

  // Create Asset Page - Loading States
  String get loadingFormData;
  String get creatingAsset;
  String get loadingFailed;
  String get pleaseWaitCreating;

  // Create Asset Page - Form Hints
  String get assetNumberHint;
  String get descriptionHint;
  String get optional;

  // Create Asset Page - Validation
  String get pleaseSelectPlant;
  String get pleaseSelectLocation;
  String get pleaseSelectUnit;

  // Create Asset Page - Sections
  String get optionalInformation;

  // Create Asset Page - Actions
  String get createAsset;

  // Create Asset Page - Messages
  String get assetCreatedSuccess;
  String get failedToGetCurrentUser;

  // Location Selection
  String get selectCurrentLocation;
  String get chooseLocationToVerify;

  // Scan List View - Filters
  String get filterByLocation;
  String get filterByStatus;
  String get searchLocations;
  String get allLocations;
  String get all;

  // Scan List View - Empty States
  String get noScannedItems;
  String get tapScanButtonToStart;
  String noItemsInLocation(String location);
  String noFilteredItems(String filter);
  String get tryDifferentLocationOrScan;
  String get tryDifferentFilterOrScan;

  // Scan List View - Search
  String noLocationsFound(String query);

  // Field Labels with Context
  String epcCodeField(String code);

  // Loading Messages
  String get loading;

  // Error Messages
  String get errorGeneric;
}
