// Path: frontend/lib/features/settings/presentation/widgets/theme_setting_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/settings_entity.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class ThemeSettingWidget extends StatelessWidget {
  final SettingsEntity settings;

  const ThemeSettingWidget({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final isUpdating =
            state is SettingsUpdating && state.updatingField == 'theme';

        return Card(
          elevation: 1,
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (isUpdating) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Theme Options
                _buildThemeOption(
                  context,
                  'Light',
                  'light',
                  Icons.light_mode,
                  settings.themeMode == 'light',
                  isUpdating,
                ),

                const SizedBox(height: 8),

                _buildThemeOption(
                  context,
                  'Dark',
                  'dark',
                  Icons.dark_mode,
                  settings.themeMode == 'dark',
                  isUpdating,
                ),

                const SizedBox(height: 8),

                _buildThemeOption(
                  context,
                  'System',
                  'system',
                  Icons.settings_system_daydream,
                  settings.themeMode == 'system',
                  isUpdating,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    bool isSelected,
    bool isDisabled,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isDisabled
          ? null
          : () {
              context.read<SettingsBloc>().add(UpdateTheme(value));
            },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),

            if (isSelected)
              Icon(Icons.check, color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
