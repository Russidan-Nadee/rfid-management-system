// Path: frontend/lib/l10n/features/export/export_localizations_ja.dart
import 'export_localizations.dart';

/// Japanese localization for Export feature
class ExportLocalizationsJa extends ExportLocalizations {
  // Page Title
  @override
  String get pageTitle => 'エクスポート管理';

  @override
  String get exportPageTitle => 'エクスポート';

  // Tab Labels
  @override
  String get createExportTab => 'エクスポート作成';

  @override
  String get historyTab => '履歴';

  // Export Configuration
  @override
  String get exportConfiguration => 'エクスポート設定';

  @override
  String get exportConfigurationDescription => 'フォーマットとフィルターを設定してカスタムレポートを生成';

  @override
  String get exportType => 'エクスポートタイプ';

  @override
  String get fileFormat => 'ファイルフォーマット';

  // Export Types
  @override
  String get assetsExport => 'アセットエクスポート';

  @override
  String get assetsExportDescription => '場所、ステータス、説明を含むすべてのアセット情報をエクスポート';

  @override
  String get allStatusLabel => 'すべてのステータス (Active, Inactive, Created)';

  // File Formats
  @override
  String get excelFormat => 'Excel (.xlsx)';

  @override
  String get excelFormatDescription => 'フォーマット付きスプレッドシート';

  @override
  String get csvFormat => 'CSV (.csv)';

  @override
  String get csvFormatDescription => 'プレーンテキスト、カンマ区切り';

  // Export Data Notice
  @override
  String get exportData => 'エクスポートデータ';

  @override
  String get exportDataDescription =>
      '日付制限なしですべてのアセットデータをエクスポートします。すべての履歴レコードが含まれます。';

  // Buttons
  @override
  String get exportAllData => 'エクスポートデータ';

  @override
  String get exportFile => 'ファイルをエクスポート';

  @override
  String get download => 'ダウンロード';

  @override
  String get retry => '再試行';

  @override
  String get cancel => 'キャンセル';

  // Loading Messages
  @override
  String get creatingExportJob => 'エクスポートジョブを作成中...';

  @override
  String get processingExport => 'エクスポートを処理中...';

  @override
  String get downloadingFile => 'ファイルをダウンロード中...';

  @override
  String get loadingExportHistory => 'エクスポート履歴を読み込み中...';

  @override
  String get loading => '読み込み中...';

  @override
  String get searching => '検索中...';

  @override
  String get processing => '処理中...';

  // Success Messages
  @override
  String get exportJobCreated => 'エクスポートジョブが作成されました！処理中...';

  @override
  String get exportCompleted => 'エクスポートが完了しダウンロード準備ができました！';

  @override
  String get exportDownloadSuccess => 'ファイルのダウンロードに成功しました！';

  @override
  String get fileShared => 'ファイルを共有しました';

  // Export History
  @override
  String get exportHistory => 'エクスポート履歴';

  @override
  String get noExportHistory => 'エクスポート履歴がありません';

  @override
  String get createFirstExport => '最初のエクスポートを作成してここに表示してください';

  @override
  String get goToCreateExportTab => 'エクスポート作成タブに移動して開始してください';

  @override
  String get exportFilesExpire => 'エクスポートファイルは7日後に期限切れになります';

  // Export Item Details
  @override
  String get exportId => 'エクスポートID';

  @override
  String get exportIdNumber => 'エクスポート #';

  @override
  String get status => 'ステータス';

  @override
  String get records => 'レコード';

  @override
  String get totalRecords => 'レコード';

  @override
  String get fileSize => 'ファイルサイズ';

  @override
  String get createdAt => '作成日時';

  @override
  String get createdDate => '作成日';

  // Formatting Labels (with colons)
  @override
  String get statusLabel => 'ステータス: ';

  @override
  String get recordsLabel => 'レコード: ';

  @override
  String get createdLabel => '作成日時: ';

  @override
  String get formatLabel => 'フォーマット: ';

  @override
  String get selectedFormatLabel => '選択されたフォーマット: ';

  @override
  String get configFormatLabel => '設定フォーマット: ';

  // Status Labels
  @override
  String get statusCompleted => '完了';

  @override
  String get statusProcessing => '処理中';

  @override
  String get statusFailed => '失敗';

  @override
  String get statusCancelled => 'キャンセル済み';

  @override
  String get statusPending => '保留中';

  // Error Messages
  @override
  String get errorLoadingHistory => '履歴の読み込みエラー';

  @override
  String get errorCreatingExport => 'エクスポートの作成に失敗しました';

  @override
  String get errorDownloadFailed => 'ダウンロードに失敗しました';

  @override
  String get errorExportFailed => 'エクスポートに失敗しました';

  @override
  String get errorGeneric => 'エラーが発生しました';

  @override
  String get errorInvalidFormat => '無効なエクスポートフォーマットです。xlsxまたはcsvを選択してください。';

  @override
  String get platformNotSupported =>
      'エクスポート機能はWebブラウザまたはデスクトップでのみ利用可能です。Webバージョンをご利用ください。';

  // Detailed Error Messages (with prefixes)
  @override
  String get failedToCreateExport => 'エクスポートの作成に失敗しました: ';

  @override
  String get failedToCheckStatus => 'ステータスの確認に失敗しました: ';

  @override
  String get failedToDownload => 'ダウンロードに失敗しました: ';

  @override
  String get failedToLoadHistory => '履歴の読み込みに失敗しました: ';

  @override
  String get failedToCancelExport => 'エクスポートのキャンセルに失敗しました: ';

  @override
  String get failedToSaveSettings => '設定の保存に失敗しました: ';

  // Format-specific Labels
  @override
  String get exportXLSX => 'XLSX エクスポート';

  @override
  String get exportCSV => 'CSV エクスポート';

  @override
  String get exportXLSXFiltered => 'XLSX エクスポート（フィルター済み）';

  @override
  String get exportCSVFiltered => 'CSV エクスポート（フィルター済み）';

  @override
  String get exportXLSXDateRange => 'XLSX エクスポート（日付範囲）';

  @override
  String get exportCSVDateRange => 'CSV エクスポート（日付範囲）';

  // Sidebar Navigation (Large Screen)
  @override
  String get exportTools => 'エクスポートツール';

  @override
  String get createExportDescription => '新しいエクスポートファイルを生成';

  @override
  String get exportHistoryDescription => 'エクスポートを表示・ダウンロード';

  // Empty States
  @override
  String get noResultsFound => '結果が見つかりません';

  @override
  String get tryAgainLater => '後でもう一度お試しください';

  // Confirmation Messages
  @override
  String get confirmCancel => 'このエクスポートをキャンセルしてもよろしいですか？';

  @override
  String get confirmDelete => 'このエクスポートを削除してもよろしいですか？';

  // Time Related
  @override
  String get expiresIn => '期限まで';

  @override
  String get expired => '期限切れ';

  @override
  String get daysLeft => '日残り';

  @override
  String get hoursLeft => '時間残り';

  @override
  String get minutesLeft => '分残り';

  // Debug & Development Messages
  @override
  String get formatSelected => 'フォーマットが選択されました: ';

  @override
  String get exportPressed => 'エクスポートが押されました - すべてのデータをエクスポート';

  @override
  String get exportingAllData => 'すべてのデータをエクスポート中';

  @override
  String get hasFiltersLabel => 'フィルターあり: ';

  @override
  String get noDateRestrictions => '注意: すべてのデータをエクスポート（日付制限なし）';

  // Additional Status and Progress
  @override
  String get exportInProgress => 'エクスポート進行中...';

  @override
  String get preparingDownload => 'ダウンロード準備中...';

  @override
  String get initiatingExport => 'エクスポート開始中...';

  // Configuration Debug Info
  @override
  String get exportConfigurationDebug => 'エクスポート設定:';

  @override
  String get plantsFilter => '工場: ';

  @override
  String get locationsFilter => '場所: ';

  @override
  String get statusFilter => 'ステータス: ';

  // Additional Info
  @override
  String get totalSize => '合計サイズ';

  @override
  String get exportFormat => 'フォーマット';

  @override
  String get exportProgress => '進捗';

  @override
  String get estimatedTime => '推定時間';

  @override
  String get remainingTime => '残り時間';
}
