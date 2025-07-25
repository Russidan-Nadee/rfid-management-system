// Path: frontend/lib/l10n/features/search/search_localizations_ja.dart
import 'search_localizations.dart';

/// Japanese localization for Search feature
class SearchLocalizationsJa extends SearchLocalizations {
  // Page Title
  @override
  String get pageTitle => '検索';

  // Search Input
  @override
  String get searchPlaceholder => '検索...';
  @override
  String get searchHint => 'クエリを入力して結果を表示';

  // Search States
  @override
  String get searchingFor => '検索中';
  @override
  String get startYourSearch => '検索を開始';
  @override
  String get typeQueryToSeeResults => 'クエリを入力して結果を表示';

  // Results
  @override
  String get searchResults => '検索結果';
  @override
  String get searchResultsFor => '検索結果：';
  @override
  String get totalItems => '件';
  @override
  String get noResultsFound => '検索結果が見つかりません：';
  @override
  String get noResultsFoundMessage => '別の検索語句を試すか、スペルを確認してください。';
  @override
  String get cached => 'キャッシュ';

  // Loading States
  @override
  String get loading => '読み込み中...';
  @override
  String get searchingMessage => '検索中...';

  // Error States
  @override
  String get errorOccurred => '検索中にエラーが発生しました：';
  @override
  String get searchFailed => '検索に失敗しました';
  @override
  String get failedToSearch => '検索できませんでした';
  @override
  String get retry => '再試行';

  // Entity Types
  @override
  String get assets => '資産';
  @override
  String get plants => '工場';
  @override
  String get locations => '場所';
  @override
  String get departments => '部門';
  @override
  String get users => 'ユーザー';

  // Asset Information
  @override
  String get assetNo => '資産番号';
  @override
  String get assetNumber => '資産ナンバー';
  @override
  String get description => '説明';
  @override
  String get serialNumber => 'シリアル番号';
  @override
  String get inventoryNumber => '在庫番号';
  @override
  String get quantity => '数量';
  @override
  String get unit => '単位';
  @override
  String get status => 'ステータス';

  // Status Values
  @override
  String get active => 'アクティブ';
  @override
  String get inactive => '非アクティブ';
  @override
  String get created => '作成済み';

  // Detail Dialog
  @override
  String get itemDetails => 'アイテム詳細';
  @override
  String get completeInformation => '完全な情報';
  @override
  String get close => '閉じる';
  @override
  String get copied => 'コピーしました';

  // Sections in Detail Dialog
  @override
  String get assetInformation => '資産情報';
  @override
  String get locationAndPlant => '場所と工場';
  @override
  String get department => '部門';
  @override
  String get userInformation => 'ユーザー情報';
  @override
  String get timestamps => 'タイムスタンプ';
  @override
  String get otherInformation => 'その他の情報';

  // Common Fields
  @override
  String get noDescription => '説明なし';
  @override
  String get noAssetNumber => '資産番号なし';
  @override
  String get empty => '(空)';

  // Time Related
  @override
  String get createdAt => '作成日時';
  @override
  String get updatedAt => '更新日時';
  @override
  String get deactivatedAt => '無効化日時';

  // Plant & Location
  @override
  String get plantCode => '工場コード';
  @override
  String get plantDescription => '工場説明';
  @override
  String get locationCode => '場所コード';
  @override
  String get locationDescription => '場所説明';

  // Department
  @override
  String get deptCode => '部門コード';
  @override
  String get deptDescription => '部門説明';

  // User Fields
  @override
  String get createdBy => '作成者';
  @override
  String get userRole => 'ユーザー役割';
}
