import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';
import '../widgets/admin_report_card_widget.dart';

class AdminAllReportsPage extends StatefulWidget {
  const AdminAllReportsPage({super.key});

  @override
  State<AdminAllReportsPage> createState() => _AdminAllReportsPageState();
}

class _AdminAllReportsPageState extends State<AdminAllReportsPage> {
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

      // Get current user to check role
      final authState = context.read<AuthBloc>().state;
      final isAdmin = authState is AuthAuthenticated && (authState.user.isAdmin || authState.user.isManager);

      print('🔍 AdminAllReportsPage: Loading reports...');
      print('🔍 AdminAllReportsPage: User is admin/manager: $isAdmin');

      final notificationService = getIt<NotificationService>();
      
      // Use different endpoints based on user role
      final response = isAdmin
          ? await notificationService.getAllReports(
              limit: 100, // Get more reports for admin view
              sortBy: 'created_at',
              sortOrder: 'desc',
            )
          : await notificationService.getMyReports();

      print('🔍 AdminAllReportsPage: API Response - Success: ${response.success}');
      print('🔍 AdminAllReportsPage: API Response - Message: ${response.message}');
      
      if (response.success && response.data != null) {
        List<dynamic> notifications = [];
        
        if (isAdmin) {
          // Admin endpoint returns Map with 'notifications' key
          final data = response.data! as Map<String, dynamic>;
          print('🔍 AdminAllReportsPage: Admin response data keys: ${data.keys}');
          
          if (data['notifications'] != null) {
            notifications = data['notifications'] as List<dynamic>;
            print('🔍 AdminAllReportsPage: Found ${notifications.length} reports from all users');
          }
        } else {
          // Regular user endpoint returns List directly
          notifications = response.data! as List<dynamic>;
          print('🔍 AdminAllReportsPage: Found ${notifications.length} personal reports');
        }
        
        setState(() {
          _reports = notifications;
          _isLoading = false;
        });
      } else {
        print('🔍 AdminAllReportsPage: API call failed - ${response.message}');
        setState(() {
          _errorMessage = response.message ?? 'Failed to load reports';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔍 AdminAllReportsPage: Exception occurred - $e');
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
    // Since this is in admin, always show admin title
    return Scaffold(
      body: _buildBody(),
    );
  }

  Future<void> _testApiConnection() async {
    print('🧪 Testing Frontend API Connection...');
    
    try {
      final notificationService = getIt<NotificationService>();
      
      // Get current user role
      final authState = context.read<AuthBloc>().state;
      final isAdmin = authState is AuthAuthenticated && (authState.user.isAdmin || authState.user.isManager);
      
      print('🔍 Current user is admin/manager: $isAdmin');
      
      if (isAdmin) {
        // Test 1: Check counts endpoint (admin only)
        print('📊 Testing notification counts...');
        final countsResponse = await notificationService.getNotificationCounts();
        print('Counts Response - Success: ${countsResponse.success}');
        print('Counts Response - Message: ${countsResponse.message}');
        print('Counts Response - Data: ${countsResponse.data}');
        
        // Test 2: Check all reports endpoint (admin only)
        print('📋 Testing all-reports endpoint...');
        final notificationsResponse = await notificationService.getAllReports(
          limit: 10,
          sortBy: 'created_at',
          sortOrder: 'desc',
        );
        print('All Reports Response - Success: ${notificationsResponse.success}');
        print('All Reports Response - Message: ${notificationsResponse.message}');
        if (notificationsResponse.data != null) {
          print('All Reports Response - Data Keys: ${notificationsResponse.data!.keys}');
          if (notificationsResponse.data!['notifications'] != null) {
            final notifications = notificationsResponse.data!['notifications'] as List;
            print('Found ${notifications.length} notifications from all users');
          }
        }
      } else {
        // Test: Check my reports endpoint (regular user)
        print('📋 Testing my-reports endpoint...');
        final myReportsResponse = await notificationService.getMyReports();
        print('My Reports Response - Success: ${myReportsResponse.success}');
        print('My Reports Response - Message: ${myReportsResponse.message}');
        if (myReportsResponse.data != null) {
          final myReports = myReportsResponse.data as List;
          print('Found ${myReports.length} personal reports');
        }
      }
      
      // Show results in UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API Test Complete (Admin Mode) - Check console'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
    } catch (e) {
      print('❌ Frontend API test failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API Test Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(AdminLocalizations.of(context).loadingAllReports),
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
              AdminLocalizations.of(context).errorLoadingReports,
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
              AdminLocalizations.of(context).noReportsFound,
              style: AppTextStyles.headline4.copyWith(
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              AdminLocalizations.of(context).noReportsFoundMessage,
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

// Auto-adjusting grid where each row height adjusts to its tallest card
class _UniformCardGrid extends StatelessWidget {
  final List<dynamic> reports;
  final VoidCallback onReportUpdated;

  const _UniformCardGrid({
    required this.reports,
    required this.onReportUpdated,
  });

  @override
  Widget build(BuildContext context) {
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

        return _buildAutoAdjustingGrid(crossAxisCount: crossAxisCount);
      },
    );
  }

  Widget _buildAutoAdjustingGrid({required int crossAxisCount}) {
    final rows = <Widget>[];
    
    // Group reports into rows
    for (int i = 0; i < reports.length; i += crossAxisCount) {
      final rowReports = <dynamic>[];
      
      // Collect reports for this row
      for (int j = 0; j < crossAxisCount; j++) {
        final index = i + j;
        if (index < reports.length) {
          rowReports.add(reports[index]);
        }
      }
      
      // Create row with IntrinsicHeight to auto-adjust height
      rows.add(
        Container(
          margin: EdgeInsets.only(bottom: i + crossAxisCount < reports.length ? 16 : 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rowReports.asMap().entries.map((entry) {
                final j = entry.key;
                final report = entry.value;
                
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: j < rowReports.length - 1 ? 16 : 0,
                    ),
                    child: AdminReportCardWidget(
                      report: report,
                      onReportUpdated: onReportUpdated,
                    ),
                  ),
                );
              }).toList() +
              // Add empty spaces for incomplete rows
              List.generate(crossAxisCount - rowReports.length, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: (rowReports.length + index) < crossAxisCount - 1 ? 16 : 0,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(children: rows),
    );
  }
}