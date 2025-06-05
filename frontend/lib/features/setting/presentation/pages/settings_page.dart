// Path: frontend/lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/theme_setting_widget.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
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
              return _buildLoadingView(theme);
            } else if (state is SettingsLoaded || state is SettingsUpdating) {
              final settings = state is SettingsLoaded
                  ? state.settings
                  : (state as SettingsUpdating).settings;
              return _buildSettingsView(context, settings, theme);
            } else if (state is SettingsError) {
              return _buildErrorView(context, state.message, theme);
            }
            return _buildLoadingView(theme);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView(ThemeData theme) {
    return Center(
      child: CircularProgressIndicator(color: theme.colorScheme.primary),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String message,
    ThemeData theme,
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
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView(BuildContext context, settings, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Section
          const UserProfileWidget(),

          const SizedBox(height: 24),

          // App Preferences Section
          _buildSectionTitle(theme, 'App Preferences'),
          const SizedBox(height: 12),
          ThemeSettingWidget(settings: settings),

          const SizedBox(height: 16),

          // Language Setting
          _buildLanguageSetting(context, settings, theme),

          const SizedBox(height: 16),

          // Remember Login Setting
          _buildRememberLoginSetting(context, settings, theme),

          const SizedBox(height: 24),

          // About Section
          _buildSectionTitle(theme, 'About'),
          const SizedBox(height: 12),
          const AppInfoWidget(),

          const SizedBox(height: 24),

          // Logout Button
          _buildLogoutButton(context, theme),
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

  Widget _buildLanguageSetting(
    BuildContext context,
    settings,
    ThemeData theme,
  ) {
    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      child: ListTile(
        leading: Icon(Icons.language, color: theme.colorScheme.primary),
        title: const Text('Language'),
        subtitle: Text(settings.language == 'en' ? 'English' : 'ไทย'),
        trailing: DropdownButton<String>(
          value: settings.language,
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'th', child: Text('ไทย')),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<SettingsBloc>().add(UpdateLanguage(value));
            }
          },
        ),
      ),
    );
  }

  Widget _buildRememberLoginSetting(
    BuildContext context,
    settings,
    ThemeData theme,
  ) {
    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      child: SwitchListTile(
        secondary: Icon(Icons.memory, color: theme.colorScheme.primary),
        title: const Text('Remember Login'),
        subtitle: const Text('Stay logged in after app restart'),
        value: settings.rememberLogin,
        onChanged: (value) {
          context.read<SettingsBloc>().add(UpdateRememberLogin(value));
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _showLogoutDialog(context);
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const LogoutRequested());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
