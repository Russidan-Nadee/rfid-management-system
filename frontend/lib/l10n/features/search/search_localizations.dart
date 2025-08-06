// Path: frontend/lib/l10n/features/search/search_localizations.dart
import 'package:flutter/material.dart';
import 'search_localizations_en.dart';
import 'search_localizations_th.dart';
import 'search_localizations_ja.dart';

/// Abstract base class for Search localization
/// กำหนด Contract/Interface สำหรับ Search feature
abstract class SearchLocalizations {
  /// Get the appropriate localization instance based on current locale
  static SearchLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'th':
        return SearchLocalizationsTh();
      case 'ja':
        return SearchLocalizationsJa();
      case 'en':
      default:
        return SearchLocalizationsEn();
    }
  }

  // Page Title
  String get pageTitle;

  // Search Input
  String get searchPlaceholder;
  String get searchHint;

  // Search States
  String get searchingFor;
  String get startYourSearch;
  String get typeQueryToSeeResults;

  // Results
  String get searchResults;
  String get searchResultsFor;
  String get totalItems;
  String get noResultsFound;
  String get noResultsFoundMessage;
  String get cached;

  // Loading States
  String get loading;
  String get searchingMessage;

  // Error States
  String get errorOccurred;
  String get searchFailed;
  String get failedToSearch;
  String get retry;

  // Entity Types
  String get assets;
  String get plants;
  String get locations;
  String get departments;
  String get users;

  // Asset Information
  String get assetNo;
  String get assetNumber;
  String get description;
  String get serialNumber;
  String get inventoryNumber;
  String get quantity;
  String get unit;
  String get status;

  // Status Values
  String get active;
  String get inactive;
  String get created;

  // Detail Dialog
  String get itemDetails;
  String get completeInformation;
  String get close;
  String get copied;

  // Sections in Detail Dialog
  String get assetInformation;
  String get locationAndPlant;
  String get department;
  String get userInformation;
  String get timestamps;
  String get otherInformation;

  // Common Fields
  String get noDescription;
  String get noAssetNumber;
  String get empty;

  // Time Related
  String get createdAt;
  String get updatedAt;
  String get deactivatedAt;

  // Plant & Location
  String get plantCode;
  String get plantDescription;
  String get locationCode;
  String get locationDescription;

  // Department
  String get deptCode;
  String get deptDescription;

  // User Fields
  String get createdBy;
  String get userRole;

  // Image Related
  String get images;
  String get hasImages;
  String get noImagesAvailable;
  String get imagesWillAppearHere;
  String get imageLoadError;
  String get primary;
}
