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
  
  // Reports Section
  @override
  String get allReports => 'すべてのレポート';

  @override
  String get loadingAllReports => 'すべてのレポートを読み込み中...';

  @override
  String get errorLoadingReports => 'レポート読み込みエラー';

  @override
  String get noReportsFound => 'レポートが見つかりません';

  @override
  String get noReportsFoundMessage => 'システムにはまだレポートがありません。';
  
  // Report Actions Dialog
  @override
  String get acknowledgeReportTitle => 'レポートを確認';

  @override
  String get completeReportTitle => 'レポートを完了';

  @override
  String get rejectReportTitle => 'レポートを拒否';

  @override
  String get updateReportTitle => 'レポートを更新';

  @override
  String get acknowledgeDescription => 'このレポートを確認し、進行中ステータスに移動します。';

  @override
  String get completeDescription => 'このレポートを解決済みとしてマークします。解決詳細を入力してください。';

  @override
  String get rejectDescription => 'このレポートを拒否し、キャンセル済みとしてマークします。理由を入力してください。';

  @override
  String get updateDescription => 'このレポートを更新します。';

  @override
  String get resolutionNoteRequired => '解決メモ *';

  @override
  String get rejectionReasonRequired => '拒否理由 *';

  @override
  String get acknowledgmentNoteOptional => '確認メモ（任意）';

  @override
  String get resolutionNotePlaceholder => '問題がどのように解決されたかを説明...';

  @override
  String get rejectionReasonPlaceholder => 'このレポートが拒否される理由を説明...';

  @override
  String get acknowledgmentNotePlaceholder => 'この確認についてのメモを追加...';

  @override
  String get acknowledgeButton => '確認';

  @override
  String get markCompleteButton => '完了とマーク';

  @override
  String get rejectReportButton => 'レポートを拒否';

  @override
  String get updateButton => '更新';

  @override
  String get reportAcknowledgedMessage => 'レポートを確認し、進行中に移動しました';

  @override
  String get reportCompletedMessage => 'レポートを解決済みとしてマークしました';

  @override
  String get reportRejectedMessage => 'レポートを拒否しキャンセルしました';

  @override
  String get reportUpdatedMessage => 'レポートを更新しました';

  @override
  String get noSubject => '件名なし';

  @override
  String get noDescription => '説明なし';

  @override
  String get asset => '資産';

  @override
  String get reportNumber => 'レポート #';

  @override
  String get pleaseProvideResolution => '解決詳細を入力してください';

  @override
  String get pleaseProvideRejection => '拒否理由を入力してください';
  
  // Role Management
  @override
  String get roleManagement => 'ロール管理';

  @override
  String get totalUsers => '総ユーザー数';

  @override
  String get filterByRole => 'ロールで絞り込み';

  @override
  String get allRoles => '全てのロール';

  @override
  String get filterByStatus => 'ステータスで絞り込み';

  @override
  String get allStatus => '全て';

  @override
  String get roleLabel => 'ロール';

  @override
  String get statusFilterLabel => 'ステータス';

  @override
  String get noUsersFound => 'ユーザーが見つかりません';

  @override
  String get activateUser => '有効化';

  @override
  String get deactivateUser => '無効化';

  @override
  String get activeStatus => '有効';

  @override
  String get inactiveStatus => '無効';

  @override
  String get neverLoggedIn => 'なし';

  @override
  String get searchAndFilters => '検索とフィルター';

  @override
  String get searchByNameEmployeeId => '名前、従業員ID、またはメールで検索...';

  @override
  String get searchUsers => 'ユーザーを検索...';

  @override
  String get primaryImage => 'プライマリ';
}