// Path: frontend/lib/features/setting/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tp_rfid/app/theme/app_colors.dart';
import 'package:tp_rfid/features/setting/presentation/widgets/language_selector_widget.dart';
import 'package:tp_rfid/features/setting/presentation/widgets/theme_selector_widget.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../l10n/features/settings/settings_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/user_profile_widget.dart';
import '../widgets/app_info_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsPageView();
  }
}

class SettingsPageView extends StatelessWidget {
  const SettingsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = SettingsLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.pageTitle,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 1,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface.withValues(
              alpha: 0.5,
            ) // #526D82 - เข้มกว่า SurfaceVariant
          : theme.colorScheme.surface,
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsUpdated) {
            Helpers.showSuccess(context, state.message);
          } else if (state is SettingsError) {
            Helpers.showError(context, state.message);
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return _buildLoadingView(context, theme, l10n);
            } else if (state is SettingsLoaded || state is SettingsUpdating) {
              final settings = state is SettingsLoaded
                  ? state.settings
                  : (state as SettingsUpdating).settings;
              return _buildSettingsView(context, settings, theme, l10n);
            } else if (state is SettingsError) {
              return _buildErrorView(context, state.message, theme, l10n);
            }
            return _buildLoadingView(context, theme, l10n);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView(
    BuildContext context,
    ThemeData theme,
    SettingsLocalizations l10n,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).brightness == Brightness.dark
                ? theme
                      .colorScheme
                      .onSurface // Dark Mode: ขาว
                : theme.colorScheme.primary, // Light Mode: น้ำเงิน
          ),
          const SizedBox(height: 16),
          Text(l10n.loading),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String message,
    ThemeData theme,
    SettingsLocalizations l10n,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsBloc>().add(const LoadSettings());
            },
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView(
    BuildContext context,
    settings,
    ThemeData theme,
    SettingsLocalizations l10n,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double spacing = 16.0;

        bool isMobile = maxWidth < 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const UserProfileWidget(),
              const SizedBox(height: 24),

              // แก้ไขตรงนี้ เอา const ออกจาก SizedBox ที่ใช้ spacing
              isMobile
                  ? Column(
                      children: [
                        _buildFlexibleCard(
                          context,
                          theme,
                          l10n.theme,
                          const ThemeSelectorWidget(),
                          maxWidth,
                        ),
                        SizedBox(height: spacing),
                        _buildFlexibleCard(
                          context,
                          theme,
                          l10n.language,
                          const LanguageSelectorWidget(),
                          maxWidth,
                        ),
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildFlexibleCard(
                              context,
                              theme,
                              l10n.theme,
                              const ThemeSelectorWidget(),
                              (maxWidth - spacing) / 2,
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: _buildFlexibleCard(
                              context,
                              theme,
                              l10n.language,
                              const LanguageSelectorWidget(),
                              (maxWidth - spacing) / 2,
                            ),
                          ),
                        ],
                      ),
                    ),

              const SizedBox(height: 16),
              _buildFlexibleCard(
                context,
                theme,
                l10n.about,
                const AppInfoWidget(),
                maxWidth,
              ),
              const SizedBox(height: 24),
              _buildLogoutButton(context, theme, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlexibleCard(
    BuildContext context,
    ThemeData theme,
    String title,
    Widget content,
    double width,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, theme, title),
              const SizedBox(height: 12),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    ThemeData theme,
    String title,
  ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).brightness == Brightness.dark
            ? theme
                  .colorScheme
                  .onSurface // Dark Mode: สีขาว
            : theme.colorScheme.primary, // Light Mode: สีน้ำเงิน
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    ThemeData theme,
    SettingsLocalizations l10n,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _showLogoutDialog(context, l10n);
        },
        icon: const Icon(Icons.logout),
        label: Text(l10n.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, SettingsLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.logoutConfirmTitle),
          content: Text(l10n.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const LogoutRequested());
              },
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }
}
