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
import '../../../reports/presentation/types/view_mode.dart';
import '../widgets/admin_reports_card_view.dart';
import '../widgets/admin_reports_table_view.dart';
import '../widgets/all_reports_filter_bar.dart';

class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});

  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  List<dynamic> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;
  ViewMode _viewMode = ViewMode.table;

  // Filter state
  String? _selectedStatus;
  String? _selectedPriority;
  String? _selectedProblemType;
  String? _selectedPlantCode;
  String? _selectedLocationCode;

  // Master data for dropdowns
  List<dynamic> _plants = [];
  List<dynamic> _locations = [];
  bool _masterDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
    _loadAllReports();
  }

  Future<void> _loadAllReports() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authState = context.read<AuthBloc>().state;
      final isAdmin =
          authState is AuthAuthenticated &&
          (authState.user.isAdmin || authState.user.isManager);

      final notificationService = getIt<NotificationService>();

      final response = isAdmin
          ? await notificationService.getAllReports(
              limit: 100,
              sortBy: 'created_at',
              sortOrder: 'desc',
              status: _selectedStatus,
              priority: _selectedPriority,
              problemType: _selectedProblemType,
              plantCode: _selectedPlantCode,
              locationCode: _selectedLocationCode,
            )
          : await notificationService.getMyReports();

      if (response.success && response.data != null) {
        List<dynamic> notifications = [];

        if (isAdmin) {
          final data = response.data! as Map<String, dynamic>;
          if (data['notifications'] != null) {
            notifications = data['notifications'] as List<dynamic>;
          }
        } else {
          notifications = response.data! as List<dynamic>;
        }

        setState(() {
          _reports = notifications;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading reports: $e';
        _isLoading = false;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPriority = null;
      _selectedProblemType = null;
      _selectedPlantCode = null;
      _selectedLocationCode = null;
    });
    _loadAllReports();
  }

  Future<void> _loadMasterData() async {
    try {
      final notificationService = getIt<NotificationService>();
      final response = await notificationService.getMasterData();

      if (response.success && response.data != null) {
        final data = response.data!;
        setState(() {
          _plants = data['plants'] ?? [];
          _locations = data['locations'] ?? [];
          _masterDataLoaded = true;
        });
      } else {
        print('Failed to load master data: ${response.message}');
      }
    } catch (e) {
      print('Error loading master data: $e');
    }
  }

  Future<void> _onRefresh() async {
    await _loadAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AllReportsFilterBar(
        viewMode: _viewMode,
        onViewModeChanged: (ViewMode mode) {
          setState(() {
            _viewMode = mode;
          });
        },
        onRefresh: _onRefresh,
        selectedStatus: _selectedStatus,
        selectedPriority: _selectedPriority,
        selectedProblemType: _selectedProblemType,
        selectedPlantCode: _selectedPlantCode,
        selectedLocationCode: _selectedLocationCode,
        onStatusChanged: (value) {
          setState(() {
            _selectedStatus = value;
          });
          _loadAllReports();
        },
        onPriorityChanged: (value) {
          setState(() {
            _selectedPriority = value;
          });
          _loadAllReports();
        },
        onProblemTypeChanged: (value) {
          setState(() {
            _selectedProblemType = value;
          });
          _loadAllReports();
        },
        onPlantChanged: (value) {
          setState(() {
            _selectedPlantCode = value;
            _selectedLocationCode = null; // Reset location when plant changes
          });
          _loadAllReports();
        },
        onLocationChanged: (value) {
          setState(() {
            _selectedLocationCode = value;
          });
          _loadAllReports();
        },
        onClearFilters: _clearFilters,
        plants: _plants,
        locations: _locations,
        masterDataLoaded: _masterDataLoaded,
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
      child: _viewMode.isCard
        ? AdminReportsCardView(
            reports: _reports,
            onReportUpdated: _loadAllReports,
          )
        : SingleChildScrollView(
            padding: AppSpacing.screenPaddingAll,
            child: AdminReportsTableView(
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
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
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
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                color: AppColors.primary,
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
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXL,
            ElevatedButton.icon(
              onPressed: _loadAllReports,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
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
}