// Path: frontend/lib/features/setting/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
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
    return BlocProvider(
      create: (context) => getIt<SettingsBloc>()..add(const LoadSettings()),
      child: const SettingsPageView(),
    );
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

          // Language Section
          _buildSectionTitle(theme, 'Language'), // TODO: Add to localization
          const SizedBox(height: 12),
          _buildLanguageSelector(context, theme),

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

  Widget _buildLanguageSelector(BuildContext context, ThemeData theme) {
    final currentLocale = Localizations.localeOf(context);

    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildLanguageOption(
            context,
            'English',
            'en',
            Icons.language,
            currentLocale.languageCode == 'en',
          ),
          const Divider(height: 1),
          _buildLanguageOption(
            context,
            'ไทย',
            'th',
            Icons.language,
            currentLocale.languageCode == 'th',
          ),
          const Divider(height: 1),
          _buildLanguageOption(
            context,
            '日本語',
            'ja',
            Icons.language,
            currentLocale.languageCode == 'ja',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    String languageCode,
    IconData icon,
    bool isSelected,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        _changeLanguage(context, languageCode);
      },
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    // แสดง SnackBar ยืนยันการเปลี่ยนภาษา
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to: $languageCode'),
        duration: const Duration(seconds: 2),
      ),
    );

    // TODO: บันทึกภาษาใน SharedPreferences
    // TODO: เชื่อมต่อกับ SettingsBloc ในอนาคต

    // แสดงข้อความให้ restart แอปด้วยตนเอง
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Language Changed'),
          content: const Text('Please restart the app to see changes.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
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
