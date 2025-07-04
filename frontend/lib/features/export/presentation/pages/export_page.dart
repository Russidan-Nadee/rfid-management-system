// Path: frontend/lib/features/export/presentation/pages/export_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/theme/app_decorations.dart';
import '../../../../di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/app_constants.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../widgets/export_config_widget.dart';
import '../widgets/export_history_widget.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= AppConstants.tabletBreakpoint;

    return BlocProvider(
      create: (context) => getIt<ExportBloc>()..add(const LoadExportHistory()),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: _buildAppBar(context, theme, isLargeScreen),
        body: _buildBody(context, isLargeScreen),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    bool isLargeScreen,
  ) {
    if (isLargeScreen) {
      return AppBar(
        title: Text(
          'Export Management',
          style: AppTextStyles.responsive(
            context: context,
            style: AppTextStyles.headline4.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            desktopFactor: 1.1,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      );
    } else {
      return AppBar(
        title: Text(
          'Export',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          labelStyle: AppTextStyles.button.copyWith(fontSize: 13),
          unselectedLabelStyle: AppTextStyles.button.copyWith(fontSize: 13),
          tabs: const [
            Tab(
              icon: Icon(Icons.upload, size: 20),
              text: 'Create Export',
              iconMargin: EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: Icon(Icons.history, size: 20),
              text: 'History',
              iconMargin: EdgeInsets.only(bottom: 4),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBody(BuildContext context, bool isLargeScreen) {
    if (isLargeScreen) {
      return _buildLargeScreenLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildLargeScreenLayout(BuildContext context) {
    return Row(
      children: [
        // Sidebar Navigation
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return Container(
              width: 280,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  right: BorderSide(
                    color: AppColors.divider.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: AppSpacing.paddingXL,
                    child: Text(
                      'Export Tools',
                      style: AppTextStyles.headline6.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildSidebarTab(
                    context,
                    icon: Icons.upload,
                    title: 'Create Export',
                    subtitle: 'Generate new export files',
                    isSelected: _tabController.index == 0,
                    onTap: () => _tabController.animateTo(0),
                  ),
                  _buildSidebarTab(
                    context,
                    icon: Icons.history,
                    title: 'Export History',
                    subtitle: 'View and download exports',
                    isSelected: _tabController.index == 1,
                    onTap: () => _tabController.animateTo(1),
                  ),
                  const Spacer(),
                  Padding(
                    padding: AppSpacing.paddingXL,
                    child: Container(
                      padding: AppSpacing.paddingMD,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppBorders.md,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          AppSpacing.horizontalSpaceSM,
                          Expanded(
                            child: Text(
                              'Export files expire after 7 days',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Main Content Area
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [ExportConfigWidget(), ExportHistoryWidget()],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: const [ExportConfigWidget(), ExportHistoryWidget()],
    );
  }

  Widget _buildSidebarTab(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: AppBorders.md,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          size: 24,
        ),
        title: Text(
          title,
          style: AppTextStyles.body1.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: isSelected
                ? AppColors.onPrimary.withOpacity(0.8)
                : AppColors.textSecondary,
          ),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
      ),
    );
  }
}
