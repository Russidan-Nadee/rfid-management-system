// Path: frontend/lib/l10n/features/admin/admin_localizations.dart
import 'package:flutter/material.dart';
import 'admin_localizations_en.dart';
import 'admin_localizations_th.dart';
import 'admin_localizations_ja.dart';

/// Abstract base class for Admin localization
/// กำหนด Contract/Interface สำหรับ Admin feature
abstract class AdminLocalizations {
  /// Get the appropriate localization instance based on current locale
  static AdminLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'th':
        return AdminLocalizationsTh();
      case 'ja':
        return AdminLocalizationsJa();
      case 'en':
      default:
        return AdminLocalizationsEn();
    }
  }

  // Page Title and Navigation
  String get pageTitle;
  String get menuTitle;
  
  // Search Section
  String get searchTitle;
  String get searchHint;
  String get searchButton;
  String get clearButton;
  String get statusFilter;
  String get statusAll;
  String get statusAwaiting;
  String get statusChecked;
  String get statusInactive;
  
  // Asset List
  String get totalAssets;
  String get assetNo;
  String get description;
  String get serialNo;
  String get status;
  String get plant;
  String get location;
  String get actions;
  
  // Asset Status
  String get awaiting;
  String get checked;
  String get inactive;
  String get unknown;
  
  // Actions
  String get edit;
  String get deactivate;
  String get update;
  String get cancel;
  String get retry;
  
  // Edit Dialog
  String get editAssetTitle;
  String get descriptionLabel;
  String get serialNoLabel;
  String get inventoryNoLabel;
  String get quantityLabel;
  String get statusLabel;
  String get readOnlyInfoTitle;
  String get epcCodeLabel;
  String get plantLabel;
  String get locationLabel;
  String get unitLabel;
  
  // Delete/Deactivate Dialog
  String get deactivateAssetTitle;
  String get deactivateConfirmMessage;
  String get deactivateExplanation;
  
  // Messages
  String get assetUpdatedSuccess;
  String get assetDeactivatedSuccess;
  String get noAssetsFound;
  String get loading;
  String get dismiss;
  
  // Error Messages
  String get errorGeneric;
  String get errorLoadingAssets;
  String get errorUpdatingAsset;
  String get errorDeactivatingAsset;
  String get validationFailed;
  String get internalServerError;
  
  // Reports Section
  String get allReports;
  String get loadingAllReports;
  String get errorLoadingReports;
  String get noReportsFound;
  String get noReportsFoundMessage;
  
  // Report Actions Dialog
  String get acknowledgeReportTitle;
  String get completeReportTitle;
  String get rejectReportTitle;
  String get updateReportTitle;
  String get acknowledgeDescription;
  String get completeDescription;
  String get rejectDescription;
  String get updateDescription;
  String get resolutionNoteRequired;
  String get rejectionReasonRequired;
  String get acknowledgmentNoteOptional;
  String get resolutionNotePlaceholder;
  String get rejectionReasonPlaceholder;
  String get acknowledgmentNotePlaceholder;
  String get acknowledgeButton;
  String get markCompleteButton;
  String get rejectReportButton;
  String get updateButton;
  String get reportAcknowledgedMessage;
  String get reportCompletedMessage;
  String get reportRejectedMessage;
  String get reportUpdatedMessage;
  String get noSubject;
  String get noDescription;
  String get asset;
  String get reportNumber;
  String get pleaseProvideResolution;
  String get pleaseProvideRejection;
  
  // Role Management
  String get roleManagement;
  String get totalUsers;
  String get filterByRole;
  String get allRoles;
  String get filterByStatus;
  String get allStatus;
  String get roleLabel;
  String get statusFilterLabel;
  String get noUsersFound;
  String get activateUser;
  String get deactivateUser;
  String get activeStatus;
  String get inactiveStatus;
  String get neverLoggedIn;
  String get searchAndFilters;
  String get searchByNameEmployeeId;
  String get searchUsers;
  String get primaryImage;
}