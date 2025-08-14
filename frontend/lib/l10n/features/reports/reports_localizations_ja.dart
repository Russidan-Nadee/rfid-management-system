// Path: frontend/lib/l10n/features/reports/reports_localizations_ja.dart
import 'reports_localizations.dart';

/// Japanese localization for Reports feature
class ReportsLocalizationsJa extends ReportsLocalizations {
  @override
  String get allReportsTitle => 'すべてのレポート';

  @override
  String get allReportsAdminTitle => 'すべてのレポート（管理者）';

  @override
  String get myReportsTitle => 'マイレポート';
  
  // Loading States
  @override
  String get loadingAllReports => 'すべてのレポートを読み込み中...';

  @override
  String get loadingReports => 'レポートを読み込み中...';
  
  // Error States
  @override
  String get errorLoadingReports => 'レポート読み込みエラー';

  @override
  String get errorLoadingReportsMessage => '不明なエラーが発生しました';

  @override
  String get tryAgain => '再試行';
  
  // Empty States
  @override
  String get noReportsFound => 'レポートが見つかりません';

  @override
  String get noReportsFoundAdmin => 'システムにはまだレポートがありません。';

  @override
  String get noReportsFoundUser => 'まだレポートを送信していません。';
  
  // Actions
  @override
  String get refresh => '更新';

  @override
  String get testApiConnection => 'API接続テスト';

  @override
  String get apiTestComplete => 'APIテスト完了';

  @override
  String get apiTestCompleteAdmin => 'APIテスト完了（管理者モード）- コンソールを確認';

  @override
  String get apiTestCompleteUser => 'APIテスト完了（ユーザーモード）- コンソールを確認';

  @override
  String get apiTestFailed => 'APIテスト失敗';

  @override
  String get checkConsole => 'コンソールを確認';
  
  // General
  @override
  String get adminMode => '管理者モード';

  @override
  String get userMode => 'ユーザーモード';

  @override
  String get reports => 'レポート';

  @override
  String get report => 'レポート';

  @override
  String get allReports => 'すべてのレポート';

  @override
  String get myReports => 'マイレポート';
  
  // Report Card Content
  @override
  String get noSubject => '件名なし';

  @override
  String get noDescription => '説明なし';

  @override
  String get reportId => 'ID';

  @override
  String get reported => '報告日時';

  @override
  String get updated => '更新日時';

  @override
  String get reportedBy => '報告者';

  @override
  String get acknowledged => '承認済み';

  @override
  String get resolved => '解決済み';

  @override
  String get rejected => '拒否';
  
  // Report Actions
  @override
  String get acknowledge => '承認';

  @override
  String get reject => '拒否';

  @override
  String get complete => '完了';

  @override
  String get reportAcknowledgedSuccess => 'レポートが承認され、進行中に移動しました';

  @override
  String get failedToAcknowledgeReport => 'レポートの承認に失敗しました';

  @override
  String get errorAcknowledgingReport => 'レポート承認エラー';
  
  // Problem Types
  @override
  String get assetDamage => '資産損傷';

  @override
  String get missingAsset => '資産紛失';

  @override
  String get locationIssue => '場所の問題';

  @override
  String get dataError => 'データエラー';

  @override
  String get urgentIssue => '緊急事項';

  @override
  String get other => 'その他';
  
  // Status Types
  @override
  String get pending => '保留中';

  @override
  String get acknowledgedStatus => '承認済み';

  @override
  String get inProgress => '進行中';

  @override
  String get resolvedStatus => '解決済み';

  @override
  String get cancelled => 'キャンセル';
  
  // Priority Types
  @override
  String get low => '低';

  @override
  String get normal => '通常';

  @override
  String get high => '高';

  @override
  String get critical => '緊急';
  
  // General Labels
  @override
  String get notAvailable => '該当なし';

  @override
  String get by => '';

  @override
  String get reportedLabel => '報告日時';

  @override
  String get updatedLabel => '更新日時';

  @override
  String get acknowledgedLabel => '確認日時';

  @override
  String get resolvedLabel => '解決日時';
}