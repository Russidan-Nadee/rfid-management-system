// Path: frontend/lib/features/setting/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/setting/presentation/widgets/language_selector_widget.dart';
import 'package:frontend/features/setting/presentation/widgets/theme_selector_widget.dart';
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
    // ใช้ existing SettingsBloc จาก app.dart
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
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 1,
      ),
      backgroundColor: theme.colorScheme.background,
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
              return _buildLoadingView(theme, l10n);
            } else if (state is SettingsLoaded || state is SettingsUpdating) {
              final settings = state is SettingsLoaded
                  ? state.settings
                  : (state as SettingsUpdating).settings;
              return _buildSettingsView(context, settings, theme, l10n);
            } else if (state is SettingsError) {
              return _buildErrorView(context, state.message, theme, l10n);
            }
            return _buildLoadingView(theme, l10n);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView(ThemeData theme, SettingsLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
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
          Icon(Icons.error_outline, size: 64, color: Colors.red),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Section
          const UserProfileWidget(),

          const SizedBox(height: 24),

          _buildSectionTitle(theme, l10n.theme),

          const SizedBox(height: 12),

          const ThemeSelectorWidget(),

          const SizedBox(height: 24),

          // Language Section
          _buildSectionTitle(theme, l10n.language),

          const SizedBox(height: 12),

          const LanguageSelectorWidget(),

          const SizedBox(height: 24),

          // About Section
          _buildSectionTitle(theme, l10n.about),

          const SizedBox(height: 12),

          const AppInfoWidget(),

          const SizedBox(height: 24),

          // Logout Button
          _buildLogoutButton(context, theme, l10n),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
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
