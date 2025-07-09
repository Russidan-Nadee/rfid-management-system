// Path: frontend/lib/features/setting/presentation/widgets/app_info_widget.dart
import 'package:flutter/material.dart';
import '../../../../app/app_constants.dart';
import '../../../../l10n/features/settings/settings_localizations.dart';

class AppInfoWidget extends StatelessWidget {
  const AppInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = SettingsLocalizations.of(context);

    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // App Logo and Name
          _buildAppHeader(theme, context),

          const Divider(height: 1),

          // Version Info
          _buildInfoTile(
            theme,
            Icons.info_outline,
            l10n.version,
            AppConstants.appVersion,
          ),

          // Build Info
          _buildInfoTile(theme, Icons.build_outlined, l10n.build, 'Release'),

          // Device Info
          _buildInfoTile(theme, Icons.phone_android, l10n.platform, 'Flutter'),

          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildAppHeader(ThemeData theme, BuildContext context) {
    final l10n = SettingsLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // App Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // App Name and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  l10n.appDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle, {
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: isAction
          ? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            )
          : null,
      onTap: onTap,
      dense: true,
    );
  }
}
