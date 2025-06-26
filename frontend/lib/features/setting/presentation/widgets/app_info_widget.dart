// Path: frontend/lib/features/settings/presentation/widgets/app_info_widget.dart
import 'package:flutter/material.dart';
import '../../../../app/app_constants.dart';

class AppInfoWidget extends StatelessWidget {
  const AppInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // App Logo and Name
          _buildAppHeader(theme),

          const Divider(height: 1),

          // Version Info
          _buildInfoTile(
            theme,
            Icons.info_outline,
            'Version',
            AppConstants.appVersion,
          ),

          // Build Info
          _buildInfoTile(theme, Icons.build_outlined, 'Build', 'Release'),

          // Device Info
          _buildInfoTile(theme, Icons.phone_android, 'Platform', 'Flutter'),

          const Divider(height: 1),

          // Support Info
          _buildInfoTile(
            theme,
            Icons.support_agent,
            'Support',
            'Contact Administrator',
            isAction: true,
            onTap: () => _showSupportDialog(context),
          ),

          // About
          _buildInfoTile(
            theme,
            Icons.article_outlined,
            'About',
            'Terms & Privacy',
            isAction: true,
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppHeader(ThemeData theme) {
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
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Asset Management System',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: isAction
          ? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            )
          : null,
      onTap: onTap,
      dense: true,
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.support_agent),
              SizedBox(width: 8),
              Text('Support'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Need help with the application?'),
              SizedBox(height: 16),
              Text('Contact Information:'),
              SizedBox(height: 8),
              Text('• Email: support@company.com'),
              Text('• Phone: +66 2-XXX-XXXX'),
              Text('• Office Hours: 9:00 AM - 5:00 PM'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.inventory_2_outlined,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Asset Management System for tracking and managing company assets efficiently.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Terms of Service:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text(
          '• Use this application responsibly\n'
          '• Do not share your login credentials\n'
          '• Report any issues to system administrator',
        ),
        const SizedBox(height: 16),
        const Text(
          'Privacy Policy:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text(
          '• Your data is stored securely\n'
          '• We do not share personal information\n'
          '• Activity logs are kept for security purposes',
        ),
      ],
    );
  }
}
