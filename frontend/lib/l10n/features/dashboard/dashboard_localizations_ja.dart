// Path: frontend/lib/l10n/features/dashboard/dashboard_localizations_ja.dart
import 'dashboard_localizations.dart';

/// Japanese localization for Dashboard feature
class DashboardLocalizationsJa extends DashboardLocalizations {
  @override
  String get pageTitle => 'ダッシュボード';

  @override
  String get dashboard => 'ダッシュボード';

  // Loading States
  @override
  String get loading => '読み込み中...';
  
  @override
  String get initializing => 'ダッシュボードを初期化中...';
  
  @override
  String get loadingDashboard => 'ダッシュボードを読み込み中...';

  // Error States
  @override
  String get dashboardError => 'ダッシュボードエラー';
  
  @override
  String get retry => '再試行';
  
  @override
  String get loadDashboard => 'ダッシュボードを読み込む';

  // Empty States
  @override
  String get noDashboardData => 'ダッシュボードデータがありません';
  
  @override
  String get noDashboardDataDescription => 'ダッシュボードデータは現在利用できません';
  
  @override
  String get noDataAvailable => 'データがありません';
  
  @override
  String get noDataFound => 'データが見つかりません';
  
  @override
  String get noDataToDisplay => '現在表示するデータがありません。';
  
  @override
  String get reload => '再読み込み';
  
  @override
  String get noResultsFound => '結果が見つかりません';
  
  @override
  String get clearSearch => '検索をクリア';
  
  @override
  String get noConnection => '接続がありません';
  
  @override
  String get checkInternetConnection => 'インターネット接続を確認して、もう一度お試しください。';
  
  @override
  String get tryAgain => 'もう一度試す';
  
  @override
  String get refreshDashboard => 'ダッシュボードを更新';
  
  @override
  String get addAsset => 'アセットを追加';
  
  @override
  String get noAssetsInSystem => 'システムにアセットがありません。\n最初のアセットを追加してください。';

  // Summary Cards
  @override
  String get allAssets => '全アセット';
  
  @override
  String get newAssets => '新しいアセット';

  // Chart Titles
  @override
  String get auditProgress => '監査進捗';
  
  @override
  String get assetDistribution => 'アセット配分';
  
  @override
  String get assetGrowthDepartment => '部門別アセット成長';
  
  @override
  String get assetGrowthLocation => '場所別アセット成長';

  // Filters
  @override
  String get allDepartments => '全部門';
  
  @override
  String get allLocations => '全場所';
  
  @override
  String get filtered => 'フィルタ済み';

  // Audit Progress
  @override
  String get auditProgressPrefix => '監査進捗 - ';
  
  @override
  String get auditProgressAllDepartments => '監査進捗 - 全部門';
  
  @override
  String get overallProgress => '全体進捗';
  
  @override
  String get checked => 'チェック済み';
  
  @override
  String get awaiting => '待機中';
  
  @override
  String get total => '合計';
  
  @override
  String get completed => '完了';
  
  @override
  String get critical => '重要';
  
  @override
  String get totalDepts => '総部門数';
  
  @override
  String get departmentSummary => '部門サマリー';
  
  @override
  String get recommendations => '推奨事項';
  
  @override
  String get complete => '完了';

  // Asset Distribution
  @override
  String get totalAssets => '総アセット数';
  
  @override
  String get departments => '部門';
  
  @override
  String get filter => 'フィルタ';
  
  @override
  String get summary => 'サマリー';
  
  @override
  String get assets => 'アセット';
  
  @override
  String get noDistributionData => '配分データがありません';
  
  @override
  String get noDistributionDataAvailable => '配分データがありません';

  // Growth Trends
  @override
  String get period => '期間';
  
  @override
  String get currentYear => '今年';
  
  @override
  String get latestYear => '最新年';
  
  @override
  String get averageGrowth => '平均成長';
  
  @override
  String get periods => '期間';
  
  @override
  String get noTrendData => 'トレンドデータがありません';
  
  @override
  String get noTrendDataAvailable => 'トレンドデータがありません';
  
  @override
  String get noLocationTrendData => '場所トレンドデータがありません';
  
  @override
  String get noLocationTrendDataAvailable => '場所トレンドデータがありません';

  // Chart Data Labels
  @override
  String get year => '年';

  // Time Info
  @override
  String get lastUpdated => '最終更新';
  
  @override
  String get fresh => '最新';
  
  @override
  String get stale => '古い';
  
  @override
  String get ok => 'OK';
  
  @override
  String get timeAgo => '前';

  // Refresh
  @override
  String get refresh => '更新';
  
  @override
  String get refreshing => '更新中...';
  
  @override
  String get refreshData => 'データを更新';
  
  @override
  String get clearCache => 'キャッシュをクリア';
  
  @override
  String get autoRefresh => '自動更新';
  
  @override
  String get autoRefreshSettings => '自動更新設定';
  
  @override
  String get enableAutoRefresh => '自動更新を有効にする';
  
  @override
  String get autoRefreshDescription => 'ダッシュボードデータを自動更新';
  
  @override
  String get refreshInterval => '更新間隔:';
  
  @override
  String get autoRefreshWarning => '自動更新はバッテリーとデータをより多く消費します。';
  
  @override
  String get cancel => 'キャンセル';
  
  @override
  String get apply => '適用';
  
  @override
  String get autoRefreshEnabled => '自動更新が有効になりました';
  
  @override
  String get autoRefreshDisabled => '自動更新が無効になりました';

  // Data Status
  @override
  String get noDepartmentData => '部門データがありません';
  
  @override
  String get noLocationData => '場所データがありません';
  
  @override
  String get noAuditData => '監査データがありません';
  
  @override
  String get noChartData => 'チャートデータがありません';
  
  @override
  String get noChartDataAvailable => 'チャートデータがありません';

  // Chart Types
  @override
  String get pieChart => '円グラフ';

  @override
  String get barChart => '棒グラフ';

  @override
  String get lineChart => '折れ線グラフ';

  // Error Messages
  @override
  String get noDepartmentDataForThisDepartment => 'この部門のデータがありません。';
  
  @override
  String get failedToLoadDashboard => 'ダッシュボードの読み込みに失敗しました';
  
  @override
  String get dashboardDataNotAvailable => 'ダッシュボードデータは現在利用できません';

  // Dynamic Functions
  @override
  String assetsCount(int count) => '$countアセット';
  
  @override
  String percentComplete(double percent) => '${percent.toStringAsFixed(0)}%完了';
  
  @override
  String moreRecommendations(int count) => '+ さらに$count件の推奨事項';
  
  @override
  String chartTooltip(String year, int assets, String percentage) => 
      '年 $year\n$assets アセット\n$percentage';
  
  @override
  String lastUpdatedTooltip(String dateTime) => '最終更新: $dateTime';
  
  @override
  String noResultsFor(String searchTerm) => '"$searchTerm"の結果が見つかりません。\n他のキーワードを試してください。';
  
  @override
  String autoRefreshEnabledWithInterval(String interval) => '自動更新が有効になりました ($interval)';
}