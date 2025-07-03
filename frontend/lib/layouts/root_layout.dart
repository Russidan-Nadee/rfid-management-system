// Path: frontend/lib/layouts/root_layout.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:frontend/features/export/presentation/pages/export_page.dart';
import 'package:frontend/features/search/presentation/pages/search_page.dart';
import 'package:frontend/features/setting/presentation/pages/settings_page.dart';
import '../features/scan/presentation/pages/scan_page.dart';
import '../app/theme/app_spacing.dart';
import '../app/app_constants.dart';
import '../app/theme/app_colors.dart';

class RootLayout extends StatefulWidget {
  const RootLayout({super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  int _currentIndex = 0;
  bool _isRailExtended = true;

  final _navigatorKeys = List.generate(
    5,
    (index) => GlobalKey<NavigatorState>(),
  );

  // Navigation destinations data
  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.qr_code_scanner_outlined),
      selectedIcon: Icon(Icons.qr_code_scanner_rounded),
      label: 'Scan',
    ),
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search_rounded),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.upload_outlined),
      selectedIcon: Icon(Icons.upload_rounded),
      label: 'Export',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Settings',
    ),
  ];

  // Navigation rail destinations
  static const List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.qr_code_scanner_outlined),
      selectedIcon: Icon(Icons.qr_code_scanner_rounded),
      label: Text('Scan'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search_rounded),
      label: Text('Search'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.upload_outlined),
      selectedIcon: Icon(Icons.upload_rounded),
      label: Text('Export'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person_rounded),
      label: Text('Settings'),
    ),
  ];

  List<Widget> get _pages => [
    const ScanPage(),
    const DashboardPage(),
    const SearchPage(),
    const ExportPage(),
    const SettingsPage(),
  ];

  void _onNavTap(int index) {
    if (index == _currentIndex) {
      // Pop to first route if same tab is tapped
      _navigatorKeys[_currentIndex].currentState?.popUntil(
        (route) => route.isFirst,
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  bool get _isWideScreen =>
      MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail for wide screens
          if (_isWideScreen) _buildNavigationRail(theme),

          // Main content area
          Expanded(child: _buildMainContent()),
        ],
      ),

      // Bottom Navigation Bar for narrow screens
      bottomNavigationBar: _isWideScreen ? null : _buildCustomBottomNav(),
    );
  }

  Widget _buildNavigationRail(ThemeData theme) {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onNavTap,
      extended: _isRailExtended,
      destinations: _railDestinations,

      // Use theme values
      backgroundColor: theme.navigationRailTheme.backgroundColor,
      selectedIconTheme: theme.navigationRailTheme.selectedIconTheme,
      unselectedIconTheme: theme.navigationRailTheme.unselectedIconTheme,
      selectedLabelTextStyle: theme.navigationRailTheme.selectedLabelTextStyle,
      unselectedLabelTextStyle:
          theme.navigationRailTheme.unselectedLabelTextStyle,
      indicatorColor: theme.navigationRailTheme.indicatorColor,

      // Toggle button
      leading: _buildRailToggleButton(theme),

      // Optional trailing widget
      trailing: _buildRailTrailing(),
    );
  }

  Widget _buildRailToggleButton(ThemeData theme) {
    return Padding(
      padding: AppSpacing.paddingSmall,
      child: FloatingActionButton.small(
        heroTag: 'rail_toggle',
        onPressed: () => setState(() => _isRailExtended = !_isRailExtended),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        elevation: 0,
        child: Icon(_isRailExtended ? Icons.menu_open : Icons.menu),
      ),
    );
  }

  Widget? _buildRailTrailing() {
    // Optional: Add user profile or other trailing widgets
    return null;
  }

  Widget _buildCustomBottomNav() {
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.primary,
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: Row(
          children: _destinations.asMap().entries.map((entry) {
            final index = entry.key;
            final destination = entry.value;
            final isSelected = index == _currentIndex;

            return Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: InkResponse(
                    onTap: () => _onNavTap(index),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    radius: 28,
                    child: Icon(
                      isSelected
                          ? (destination.selectedIcon as Icon).icon
                          : (destination.icon as Icon).icon,
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onPrimary.withOpacity(0.6),
                      size: isSelected ? 28 : 26,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Navigator(
      key: _navigatorKeys[_currentIndex],
      pages: [
        MaterialPage(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }
}

// Alternative implementation with TabBar
class TabBarRootLayout extends StatefulWidget {
  const TabBarRootLayout({super.key});

  @override
  State<TabBarRootLayout> createState() => _TabBarRootLayoutState();
}

class _TabBarRootLayoutState extends State<TabBarRootLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan'),
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
            Tab(icon: Icon(Icons.upload), text: 'Export'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
          isScrollable:
              MediaQuery.of(context).size.width < AppConstants.tabletBreakpoint,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ScanPage(),
          DashboardPage(),
          SearchPage(),
          ExportPage(),
          SettingsPage(),
        ],
      ),
    );
  }
}
