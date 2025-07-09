// Path: frontend/lib/features/setting/presentation/widgets/theme_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/features/settings/settings_localizations.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_state.dart';
import '../bloc/settings_event.dart';

class ThemeSelectorWidget extends StatelessWidget {
  const ThemeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = SettingsLocalizations.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoaded || state is SettingsUpdating) {
          final settings = state is SettingsLoaded
              ? state.settings
              : (state as SettingsUpdating).settings;
          return _buildThemeSelector(context, settings, l10n);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    settings,
    SettingsLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final currentTheme = settings.themeMode;

    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildThemeOption(
            context,
            Icons.light_mode_outlined,
            Icons.light_mode,
            l10n.themeLight,
            l10n.themeLightDescription,
            'light',
            currentTheme == 'light',
            l10n,
          ),
          const Divider(height: 1),
          _buildThemeOption(
            context,
            Icons.dark_mode_outlined,
            Icons.dark_mode,
            l10n.themeDark,
            l10n.themeDarkDescription,
            'dark',
            currentTheme == 'dark',
            l10n,
          ),
          const Divider(height: 1),
          _buildThemeOption(
            context,
            Icons.settings_system_daydream_outlined,
            Icons.settings_system_daydream,
            l10n.themeSystem,
            l10n.themeSystemDescription,
            'system',
            currentTheme == 'system',
            l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    IconData outlinedIcon,
    IconData filledIcon,
    String title,
    String description,
    String themeMode,
    bool isSelected,
    SettingsLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    // แก้สีให้แตกต่างกันระหว่าง Light และ Dark Mode
    final textColor = isSelected
        ? (Theme.of(context).brightness == Brightness.dark
              ? theme
                    .colorScheme
                    .onSurface // Dark Mode: สีขาว
              : theme.colorScheme.primary) // Light Mode: สีน้ำเงิน
        : theme.colorScheme.onSurface.withValues(alpha: 0.3);

    final iconColor = isSelected
        ? (Theme.of(context).brightness == Brightness.dark
              ? theme
                    .colorScheme
                    .onSurface // Dark Mode: สีขาว
              : theme.colorScheme.primary) // Light Mode: สีน้ำเงิน
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    final trailingIconColor = isSelected
        ? (Theme.of(context).brightness == Brightness.dark
              ? theme
                    .colorScheme
                    .onSurface // Dark Mode: สีขาว
              : theme.colorScheme.primary) // Light Mode: สีน้ำเงิน
        : theme.colorScheme.onSurface.withValues(alpha: 0.3);

    return ListTile(
      leading: Icon(
        isSelected ? filledIcon : outlinedIcon,
        color: iconColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: textColor,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: trailingIconColor, size: 20)
          : Icon(
              Icons.radio_button_unchecked,
              color: trailingIconColor,
              size: 20,
            ),
      onTap: isSelected
          ? null
          : () {
              _changeTheme(context, themeMode, l10n);
            },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _changeTheme(
    BuildContext context,
    String themeMode,
    SettingsLocalizations l10n,
  ) {
    // Send theme update event to SettingsBloc
    context.read<SettingsBloc>().add(UpdateTheme(themeMode));

    // Show confirmation snackbar
    String message;
    switch (themeMode) {
      case 'light':
        message = l10n.themeChangedToLight;
        break;
      case 'dark':
        message = l10n.themeChangedToDark;
        break;
      case 'system':
        message = l10n.themeChangedToSystem;
        break;
      default:
        message = l10n.themeChanged;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
