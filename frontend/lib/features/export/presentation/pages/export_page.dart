// Path: frontend/lib/features/export/presentation/pages/export_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tp_rfid/app/theme/app_decorations.dart';
import '../../../../di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/app_constants.dart';
import '../../../../l10n/features/export/export_localizations.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= AppConstants.tabletBreakpoint;
    final l10n = ExportLocalizations.of(context);

    return BlocProvider(
      create: (context) => getIt<ExportBloc>()..add(const LoadExportHistory()),
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
        appBar: _buildAppBar(context, theme, isDark, isLargeScreen, l10n),
        body: _buildBody(context, isLargeScreen),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isLargeScreen,
    ExportLocalizations l10n,
  ) {
    if (isLargeScreen) {
      return AppBar(
        title: Text(
          l10n.pageTitle,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkText
                : AppColors.primary,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkSurface
            : theme.colorScheme.surface,
        foregroundColor: isDark
            ? AppColors.darkText
            : theme.colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      );
    } else {
      return AppBar(
        title: Text(
          l10n.exportPageTitle,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.primary,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkSurface
            : theme.colorScheme.surface,
        foregroundColor: isDark
            ? AppColors.darkText
            : theme.colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark
              ? theme.colorScheme.primary
              : AppColors.primary,
          indicatorWeight: 3,
          labelColor: isDark ? theme.colorScheme.primary : AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.darkTextSecondary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          labelStyle: AppTextStyles.button.copyWith(fontSize: 13),
          unselectedLabelStyle: AppTextStyles.button.copyWith(fontSize: 13),
          tabs: [
            Tab(
              icon: const Icon(Icons.upload, size: 20),
              text: l10n.createExportTab,
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: const Icon(Icons.history, size: 20),
              text: l10n.historyTab,
              iconMargin: const EdgeInsets.only(bottom: 4),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = ExportLocalizations.of(context);

    return Row(
      children: [
        // Sidebar Navigation
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return Container(
              width: 280,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                border: Border(
                  right: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.3)
                        : AppColors.divider.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: AppSpacing.paddingXL,
                    child: Text(
                      l10n.exportTools,
                      style: AppTextStyles.headline6.copyWith(
                        color: isDark ? AppColors.darkText : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildSidebarTab(
                    context,
                    isDark,
                    l10n,
                    icon: Icons.upload,
                    title: l10n.createExportTab,
                    subtitle: l10n.createExportDescription,
                    isSelected: _tabController.index == 0,
                    onTap: () => _tabController.animateTo(0),
                  ),
                  _buildSidebarTab(
                    context,
                    isDark,
                    l10n,
                    icon: Icons.history,
                    title: l10n.historyTab,
                    subtitle: l10n.exportHistoryDescription,
                    isSelected: _tabController.index == 1,
                    onTap: () => _tabController.animateTo(1),
                  ),
                  const Spacer(),
                  Padding(
                    padding: AppSpacing.paddingXL,
                    child: Container(
                      padding: AppSpacing.paddingMD,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.primarySurface,
                        borderRadius: AppBorders.md,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder.withValues(alpha: 0.3)
                              : AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: isDark
                                ? AppColors.primary
                                : AppColors.primary,
                            size: 16,
                          ),
                          AppSpacing.horizontalSpaceSM,
                          Expanded(
                            child: Text(
                              l10n.exportFilesExpire,
                              style: AppTextStyles.caption.copyWith(
                                color: isDark
                                    ? AppColors.primary
                                    : AppColors.primary,
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
    BuildContext context,
    bool isDark,
    ExportLocalizations l10n, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
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
          color: isSelected
              ? AppColors.onPrimary
              : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary),
          size: 24,
        ),
        title: Text(
          title,
          style: AppTextStyles.body1.copyWith(
            color: isSelected
                ? AppColors.onPrimary
                : (isDark ? AppColors.darkText : AppColors.textPrimary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: isSelected
                ? AppColors.onPrimary.withValues(alpha: 0.8)
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
      ),
    );
  }
}
