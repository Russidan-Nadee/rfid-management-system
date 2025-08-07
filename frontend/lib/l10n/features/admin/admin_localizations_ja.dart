// Path: frontend/lib/l10n/features/admin/admin_localizations_ja.dart
import 'admin_localizations.dart';

/// Japanese localization for Admin feature
class AdminLocalizationsJa extends AdminLocalizations {
  @override
  String get pageTitle => '管理者 - 資産管理';

  @override
  String get menuTitle => '管理者メニュー';
  
  // Search Section
  @override
  String get searchTitle => '資産検索';

  @override
  String get searchHint => '資産番号、説明、シリアル番号で検索...';

  @override
  String get searchButton => '検索';

  @override
  String get clearButton => 'クリア';

  @override
  String get statusFilter => 'ステータス';

  @override
  String get statusAll => 'すべて';

  @override
  String get statusAwaiting => '待機中';

  @override
  String get statusChecked => 'チェック済み';

  @override
  String get statusInactive => '非アクティブ';
  
  // Asset List
  @override
  String get totalAssets => '総資産数';

  @override
  String get assetNo => '資産番号';

  @override
  String get description => '説明';

  @override
  String get serialNo => 'シリアル番号';

  @override
  String get status => 'ステータス';

  @override
  String get plant => '工場';

  @override
  String get location => '場所';

  @override
  String get actions => 'アクション';
  
  // Asset Status
  @override
  String get awaiting => '待機中';

  @override
  String get checked => 'チェック済み';

  @override
  String get inactive => '非アクティブ';

  @override
  String get unknown => '不明';
  
  // Actions
  @override
  String get edit => '編集';

  @override
  String get deactivate => '無効化';

  @override
  String get update => '更新';

  @override
  String get cancel => 'キャンセル';

  @override
  String get retry => '再試行';
  
  // Edit Dialog
  @override
  String get editAssetTitle => '資産編集';

  @override
  String get descriptionLabel => '説明';

  @override
  String get serialNoLabel => 'シリアル番号';

  @override
  String get inventoryNoLabel => '在庫番号';

  @override
  String get quantityLabel => '数量';

  @override
  String get statusLabel => 'ステータス';

  @override
  String get readOnlyInfoTitle => '読み取り専用情報:';

  @override
  String get epcCodeLabel => 'EPCコード';

  @override
  String get plantLabel => '工場';

  @override
  String get locationLabel => '場所';

  @override
  String get unitLabel => '単位';
  
  // Delete/Deactivate Dialog
  @override
  String get deactivateAssetTitle => '資産の無効化';

  @override
  String get deactivateConfirmMessage => 'この資産を無効化してもよろしいですか？';

  @override
  String get deactivateExplanation => '資産のステータスが非アクティブに設定されます。資産データは保持され、後で再アクティブ化できます。';
  
  // Messages
  @override
  String get assetUpdatedSuccess => '資産が正常に更新されました';

  @override
  String get assetDeactivatedSuccess => '資産が正常に無効化されました';

  @override
  String get noAssetsFound => '資産が見つかりません';

  @override
  String get loading => '読み込み中...';

  @override
  String get dismiss => '閉じる';
  
  // Error Messages
  @override
  String get errorGeneric => '予期しないエラーが発生しました';

  @override
  String get errorLoadingAssets => '資産データの読み込みに失敗しました';

  @override
  String get errorUpdatingAsset => '資産の更新に失敗しました';

  @override
  String get errorDeactivatingAsset => '資産の無効化に失敗しました';

  @override
  String get validationFailed => '検証に失敗しました';

  @override
  String get internalServerError => 'サーバー内部エラー';
}