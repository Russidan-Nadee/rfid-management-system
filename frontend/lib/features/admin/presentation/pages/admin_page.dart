import 'package:flutter/material.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import 'asset_management_page.dart';
import 'all_reports_page.dart';
import 'role_management_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPageView();
  }
}

class AdminPageView extends StatelessWidget {
  const AdminPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AdminLocalizations.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.menuTitle,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkText
                  : AppColors.primary,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkText
              : AppColors.primary,
          elevation: 0,
          scrolledUnderElevation: 1,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.inventory_2_outlined),
                text: 'Asset Management',
              ),
              Tab(icon: Icon(Icons.assignment_outlined), text: 'All Reports'),
              Tab(icon: Icon(Icons.people_outlined), text: 'Role Management'),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: const TabBarView(
          children: [
            // Asset Management Tab
            AssetManagementPage(),
            // All Reports Tab
            AllReportsPage(),
            // Role Management Tab
            RoleManagementPage(),
          ],
        ),
      ),
    );
  }
}


