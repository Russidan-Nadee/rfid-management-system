// Path: frontend/lib/l10n/features/scan/scan_localizations_ja.dart
import 'scan_localizations.dart';

/// Japanese localization for Scan feature
class ScanLocalizationsJa extends ScanLocalizations {
  // Page Titles
  @override
  String get scanPageTitle => 'RFIDスキャン';

  @override
  String get assetDetailPageTitle => 'アセット詳細';

  @override
  String get createAssetPageTitle => '新しいアセットを作成';

  // Scan Page - Ready State
  @override
  String get scannerReady => 'RFIDスキャナー準備完了';

  @override
  String get scanInstructions => '下のボタンを押してRFIDタグのスキャンを開始してください';

  @override
  String get startScanning => 'スキャン開始';

  @override
  String get ensureScannerConnected => 'RFIDスキャナーが接続されていることを確認してください';

  @override
  String get scanAgain => '再スキャン';

  // Scan Page - Loading State
  @override
  String get scanningTags => 'RFIDタグをスキャン中...';

  @override
  String get pleaseWaitScanning => 'アセットのスキャン中です。しばらくお待ちください';

  // Scan Page - Error State
  @override
  String get scanFailed => 'スキャン失敗';

  @override
  String get tryAgain => '再試行';

  // Scan Page - Success State
  @override
  String scannedItemsCount(int count) => '$count件をスキャンしました';

  // Asset Detail Page - Section Titles
  @override
  String get basicInformation => '基本情報';

  @override
  String get locationInformation => '場所情報';

  @override
  String get quantityInformation => '数量情報';

  @override
  String get scanActivity => 'スキャン履歴';

  @override
  String get creationInformation => '作成情報';

  // Asset Detail Page - Field Labels
  @override
  String get assetNumber => 'アセット番号';

  @override
  String get description => '説明';

  @override
  String get serialNumber => 'シリアル番号';

  @override
  String get inventoryNumber => '在庫番号';

  @override
  String get plant => '工場';

  @override
  String get location => '場所';

  @override
  String get department => '部門';

  @override
  String get quantity => '数量';

  @override
  String get unit => '単位';

  @override
  String get lastScan => '最終スキャン';

  @override
  String get scannedBy => 'スキャン者';

  @override
  String get createdBy => '作成者';

  @override
  String get createdDate => '作成日';

  @override
  String get epcCode => 'EPCコード';

  // Asset Status Labels
  @override
  String get statusActive => 'アクティブ';

  @override
  String get statusChecked => 'チェック済み';

  @override
  String get statusInactive => '非アクティブ';

  @override
  String get statusUnknown => '不明';

  @override
  String get statusAwaiting => '待機中';

  // Asset Detail Page - Actions
  @override
  String get markAsChecked => 'チェック済みにする';

  @override
  String get markingAsChecked => 'チェック済みにしています...';

  // Asset Detail Page - Messages
  @override
  String get assetMarkedSuccess => 'アセットをチェック済みにマークしました';

  @override
  String get neverScanned => 'スキャンされていません';

  @override
  String get unknownUser => '不明なユーザー';

  // Create Asset Page - Header
  @override
  String get creatingUnknownAsset => '不明なアセットを作成中';

  // Create Asset Page - Loading States
  @override
  String get loadingFormData => 'フォームデータを読み込み中...';

  @override
  String get creatingAsset => 'アセットを作成中...';

  @override
  String get loadingFailed => '読み込み失敗';

  @override
  String get pleaseWaitCreating => 'アセットを作成中です。しばらくお待ちください';

  // Create Asset Page - Form Hints
  @override
  String get assetNumberHint => 'アセット番号を入力してください（例：A001234）';

  @override
  String get descriptionHint => 'アセットの説明を入力してください';

  @override
  String get optional => 'オプション';

  // Create Asset Page - Validation
  @override
  String get pleaseSelectPlant => '工場を選択してください';

  @override
  String get pleaseSelectLocation => '場所を選択してください';

  @override
  String get pleaseSelectUnit => '単位を選択してください';

  // Create Asset Page - Sections
  @override
  String get optionalInformation => 'オプション情報';

  // Create Asset Page - Actions
  @override
  String get createAsset => 'アセットを作成';

  // Create Asset Page - Messages
  @override
  String get assetCreatedSuccess => 'アセットが正常に作成されました';

  @override
  String get failedToGetCurrentUser => '現在のユーザー情報を取得できませんでした';

  // Location Selection
  @override
  String get selectCurrentLocation => '現在地を選択';

  @override
  String get chooseLocationToVerify => 'スキャンしたアセットを確認するため、現在地を選択してください';

  // Scan List View - Filters
  @override
  String get filterByLocation => '場所でフィルター';

  @override
  String get filterByStatus => 'ステータスでフィルター';

  @override
  String get searchLocations => '場所を検索...';

  @override
  String get allLocations => 'すべての場所';

  @override
  String get all => 'すべて';

  // Scan List View - Empty States
  @override
  String get noScannedItems => 'スキャンされたアイテムがありません';

  @override
  String get tapScanButtonToStart => 'スキャンボタンをタップしてRFIDタグのスキャンを開始してください';

  @override
  String noItemsInLocation(String location) => '$locationにアイテムがありません';

  @override
  String noFilteredItems(String filter) => '$filterのアイテムがありません';

  @override
  String get tryDifferentLocationOrScan => '別の場所を選択するか、再度スキャンしてください';

  @override
  String get tryDifferentFilterOrScan => '別のフィルターを選択するか、再度スキャンしてください';

  // Scan List View - Search
  @override
  String noLocationsFound(String query) => '"$query"に一致する場所が見つかりません';

  // Field Labels with Context
  @override
  String epcCodeField(String code) => 'EPCコード: $code';

  // Loading Messages
  @override
  String get loading => '読み込み中...';

  // Error Messages
  @override
  String get errorGeneric => '予期しないエラーが発生しました';

  // Image Gallery Section
  @override
  String get images => '画像';

  @override
  String get primary => 'プライマリ';

  @override
  String get noImagesAvailable => '利用可能な画像がありません';

  @override
  String get imagesWillAppearHere => 'アップロード時に画像がここに表示されます';

  @override
  String get imageLoadError => '画像の読み込みに失敗しました';
}
