import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../widgets/report_card_widget.dart';

class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});

  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  List<dynamic> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllReports();
  }

  Future<void> _loadAllReports() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('🔍 AllReportsPage: Loading all reports for admin...');

      final notificationService = getIt<NotificationService>();
      final response = await notificationService.getNotifications(
        limit: 100, // Get more reports for admin view
        sortBy: 'created_at',
        sortOrder: 'desc',
      );

      print('🔍 AllReportsPage: API Response - Success: ${response.success}');
      print('🔍 AllReportsPage: API Response - Message: ${response.message}');
      
      if (response.success && response.data != null) {
        final data = response.data!;
        print('🔍 AllReportsPage: Response data keys: ${data.keys}');
        
        if (data['notifications'] != null) {
          final notifications = data['notifications'] as List<dynamic>;
          print('🔍 AllReportsPage: Found ${notifications.length} reports');
          setState(() {
            _reports = notifications;
            _isLoading = false;
          });
        } else {
          print('🔍 AllReportsPage: No notifications found in response');
          setState(() {
            _reports = [];
            _isLoading = false;
          });
        }
      } else {
        print('🔍 AllReportsPage: API call failed - ${response.message}');
        setState(() {
          _errorMessage = response.message ?? 'Failed to load reports';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔍 AllReportsPage: Exception occurred - $e');
      setState(() {
        _errorMessage = 'Error loading reports: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reports (Admin)'),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_reports.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: _UniformCardGrid(
          reports: _reports,
          onReportUpdated: _loadAllReports,
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading all reports...'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
            ),
            AppSpacing.verticalSpaceXXL,
            Text(
              'Error Loading Reports',
              style: AppTextStyles.headline4.copyWith(
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              _errorMessage ?? 'An unknown error occurred',
              style: AppTextStyles.body1.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXL,
            ElevatedButton.icon(
              onPressed: _loadAllReports,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: AppSpacing.buttonPaddingSymmetric,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: isDark ? AppColors.darkText : AppColors.primary,
                size: 60,
              ),
            ),
            AppSpacing.verticalSpaceXXL,
            Text(
              'No Reports Found',
              style: AppTextStyles.headline4.copyWith(
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'There are no reports in the system yet.',
              style: AppTextStyles.body1.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Reuse the same uniform card grid from MyReportsPage
class _UniformCardGrid extends StatefulWidget {
  final List<dynamic> reports;
  final VoidCallback onReportUpdated;

  const _UniformCardGrid({
    required this.reports,
    required this.onReportUpdated,
  });

  @override
  State<_UniformCardGrid> createState() => _UniformCardGridState();
}

class _UniformCardGridState extends State<_UniformCardGrid> {
  Size? _maxCardSize;
  final List<GlobalKey> _cardKeys = [];

  @override
  void initState() {
    super.initState();
    _initializeCardKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureCards();
    });
  }

  void _initializeCardKeys() {
    _cardKeys.clear();
    for (int i = 0; i < widget.reports.length; i++) {
      _cardKeys.add(GlobalKey());
    }
  }

  void _measureCards() {
    double maxWidth = 0;
    double maxHeight = 0;

    for (final key in _cardKeys) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final size = renderBox.size;
        if (size.width > maxWidth) maxWidth = size.width;
        if (size.height > maxHeight) maxHeight = size.height;
      }
    }

    if (maxWidth > 0 && maxHeight > 0) {
      setState(() {
        _maxCardSize = Size(maxWidth, maxHeight);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_maxCardSize == null) {
      // First render - measure cards
      return _buildMeasuringLayout();
    } else {
      // Second render - with uniform sizing
      return _buildUniformLayout();
    }
  }

  Widget _buildMeasuringLayout() {
    return Opacity(
      opacity: 0.0, // Hide while measuring
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: widget.reports.asMap().entries.map((entry) {
              final index = entry.key;
              final report = entry.value;
              return Container(
                key: _cardKeys[index],
                child: ReportCardWidget(
                  report: report,
                  onReportUpdated: widget.onReportUpdated,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildUniformLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive column count based on screen width
        int crossAxisCount;
        
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4; // Extra large screens: 4 columns
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 3; // Large screens: 3 columns
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2; // Medium screens: 2 columns
        } else {
          crossAxisCount = 1; // Small screens: 1 column
        }

        // Calculate available width per card
        final totalSpacing = (crossAxisCount - 1) * 16; // 16px spacing between cards
        final availableWidth = constraints.maxWidth - totalSpacing;
        final cardWidth = availableWidth / crossAxisCount;
        
        // Use the measured max size, but respect the available width
        final finalCardWidth = cardWidth.clamp(0.0, _maxCardSize!.width).toDouble();
        final finalCardHeight = _maxCardSize!.height;

        return _buildFlexGrid(
          crossAxisCount: crossAxisCount,
          cardWidth: finalCardWidth,
          cardHeight: finalCardHeight,
        );
      },
    );
  }

  Widget _buildFlexGrid({
    required int crossAxisCount,
    required double cardWidth,
    required double cardHeight,
  }) {
    final rows = <Widget>[];
    
    for (int i = 0; i < widget.reports.length; i += crossAxisCount) {
      final rowChildren = <Widget>[];
      
      for (int j = 0; j < crossAxisCount; j++) {
        final index = i + j;
        
        if (index < widget.reports.length) {
          rowChildren.add(
            Expanded(
              child: Container(
                width: cardWidth,
                height: cardHeight,
                margin: EdgeInsets.only(
                  right: j < crossAxisCount - 1 ? 16 : 0,
                ),
                child: ReportCardWidget(
                  report: widget.reports[index],
                  onReportUpdated: widget.onReportUpdated,
                ),
              ),
            ),
          );
        } else {
          // Empty space for incomplete rows
          rowChildren.add(
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: j < crossAxisCount - 1 ? 16 : 0,
                ),
              ),
            ),
          );
        }
      }
      
      rows.add(
        Container(
          margin: EdgeInsets.only(bottom: i + crossAxisCount < widget.reports.length ? 16 : 0),
          child: Row(children: rowChildren),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(children: rows),
    );
  }
}