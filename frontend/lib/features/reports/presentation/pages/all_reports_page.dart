import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
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

      // Get current user to check role
      final authState = context.read<AuthBloc>().state;
      final isAdmin = authState is AuthAuthenticated && (authState.user.isAdmin || authState.user.isManager);

      print('🔍 AllReportsPage: Loading reports...');
      print('🔍 AllReportsPage: User is admin/manager: $isAdmin');

      final notificationService = getIt<NotificationService>();
      
      // Use different endpoints based on user role
      final response = isAdmin
          ? await notificationService.getAllReports(
              limit: 100, // Get more reports for admin view
              sortBy: 'created_at',
              sortOrder: 'desc',
            )
          : await notificationService.getMyReports();

      print('🔍 AllReportsPage: API Response - Success: ${response.success}');
      print('🔍 AllReportsPage: API Response - Message: ${response.message}');
      
      if (response.success && response.data != null) {
        List<dynamic> notifications = [];
        
        if (isAdmin) {
          // Admin endpoint returns Map with 'notifications' key
          final data = response.data! as Map<String, dynamic>;
          print('🔍 AllReportsPage: Admin response data keys: ${data.keys}');
          
          if (data['notifications'] != null) {
            notifications = data['notifications'] as List<dynamic>;
            print('🔍 AllReportsPage: Found ${notifications.length} reports from all users');
          }
        } else {
          // Regular user endpoint returns List directly
          notifications = response.data! as List<dynamic>;
          print('🔍 AllReportsPage: Found ${notifications.length} personal reports');
        }
        
        setState(() {
          _reports = notifications;
          _isLoading = false;
        });
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
    // Get current user to determine title
    final authState = context.read<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && (authState.user.isAdmin || authState.user.isManager);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'All Reports (Admin)' : 'My Reports'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _testApiConnection,
            tooltip: 'Test API Connection',
          ),
        ],
      ),
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
          SnackBar(
            content: Text('API Test Complete (${isAdmin ? 'Admin' : 'User'} Mode) - Check console'),
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
    
    // Get current user role to determine message
    final authState = context.read<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && (authState.user.isAdmin || authState.user.isManager);

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
                isAdmin ? Icons.admin_panel_settings_outlined : Icons.assignment_outlined,
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
              isAdmin 
                ? 'There are no reports in the system yet.'
                : 'You haven\'t submitted any reports yet.',
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
                    child: ReportCardWidget(
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