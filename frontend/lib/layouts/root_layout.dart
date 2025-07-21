// Path: frontend/lib/layouts/root_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:frontend/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:frontend/features/export/presentation/pages/export_page.dart';
import 'package:frontend/features/search/presentation/pages/search_page.dart';
import 'package:frontend/features/setting/presentation/pages/settings_page.dart';
import '../features/scan/presentation/pages/scan_page.dart';
import '../app/app_constants.dart';
import '../app/theme/app_colors.dart';

class RootLayout extends StatefulWidget {
  const RootLayout({super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  late int _currentIndex;
  bool _isRailExtended = true;

  late List<GlobalKey<NavigatorState>> _navigatorKeys;

  @override
  void initState() {
    super.initState();
    // Set default index based on platform
    _currentIndex = _isMobile ? 0 : _getDefaultDesktopIndex();
    _navigatorKeys = List.generate(
      _getDestinations().length,
      (index) => GlobalKey<NavigatorState>(),
    );
  }

  // Platform detection helpers
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  bool get _isWeb => kIsWeb;

  // Get default index for desktop/web (Dashboard = index 1 in mobile, but could be 0 in desktop)
  int _getDefaultDesktopIndex() {
    final destinations = _getDestinations();
    for (int i = 0; i < destinations.length; i++) {
      if (destinations[i].label == 'Dashboard') {
        return i;
      }
    }
    return 0; // fallback
  }

  // Platform-specific destinations for bottom navigation
  List<NavigationDestination> _getDestinations() {
    List<NavigationDestination> destinations = [];

    // Scan - Mobile only
    if (_isMobile) {
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.sensors_outlined),
          selectedIcon: Icon(Icons.sensors_rounded),
          label: 'Scan',
        ),
      );
    }

    // Dashboard - All platforms
    destinations.add(
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: 'Dashboard',
      ),
    );

    // Search - All platforms
    destinations.add(
      const NavigationDestination(
        icon: Icon(Icons.search_outlined),
        selectedIcon: Icon(Icons.search_rounded),
        label: 'Search',
      ),
    );

    // Export - Desktop/Web only
    if (!_isMobile) {
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.upload_outlined),
          selectedIcon: Icon(Icons.upload_rounded),
          label: 'Export',
        ),
      );
    }

    // Settings - All platforms
    destinations.add(
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Settings',
      ),
    );

    return destinations;
  }

  // Platform-specific destinations for navigation rail
  List<NavigationRailDestination> _getRailDestinations() {
    List<NavigationRailDestination> destinations = [];

    // Scan - Mobile only (but this won't be used since rail is for desktop)
    if (_isMobile) {
      destinations.add(
        const NavigationRailDestination(
          icon: Icon(Icons.sensors_outlined),
          selectedIcon: Icon(Icons.sensors_rounded),
          label: Text('Scan'),
        ),
      );
    }

    // Dashboard - All platforms
    destinations.add(
      const NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: Text('Dashboard'),
      ),
    );

    // Search - All platforms
    destinations.add(
      const NavigationRailDestination(
        icon: Icon(Icons.search_outlined),
        selectedIcon: Icon(Icons.search_rounded),
        label: Text('Search'),
      ),
    );

    // Export - Desktop/Web only
    if (!_isMobile) {
      destinations.add(
        const NavigationRailDestination(
          icon: Icon(Icons.upload_outlined),
          selectedIcon: Icon(Icons.upload_rounded),
          label: Text('Export'),
        ),
      );
    }

    // Settings - All platforms
    destinations.add(
      const NavigationRailDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person_rounded),
        label: Text('Settings'),
      ),
    );

    return destinations;
  }

  // Platform-specific pages
  List<Widget> _getPages() {
    List<Widget> pages = [];

    // Scan - Mobile only
    if (_isMobile) {
      pages.add(const ScanPage());
    }

    // Dashboard - All platforms
    pages.add(const DashboardPage());

    // Search - All platforms
    pages.add(const SearchPage());

    // Export - Desktop/Web only
    if (!_isMobile) {
      pages.add(const ExportPage());
    }

    // Settings - All platforms
    pages.add(const SettingsPage());

    return pages;
  }

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
      MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint;

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
    final railDestinations = _getRailDestinations();

    return SizedBox(
      width: _isRailExtended ? 256 : 80,
      child: Material(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.primaryDark
            : AppColors.primary,
        child: Column(
          children: [
            // Header ที่มีปุ่มคงที่
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: _buildRailToggleButton(theme),
            ),

            // Custom Navigation Items แทน NavigationRail
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                itemCount: railDestinations.length,
                itemBuilder: (context, index) {
                  final destination = railDestinations[index];
                  final isSelected = index == _currentIndex;

                  return _buildCustomNavItem(
                    destination: destination,
                    isSelected: isSelected,
                    onTap: () => _onNavTap(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRailToggleButton(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _isRailExtended = !_isRailExtended),
          child: Icon(
            _isRailExtended ? Icons.menu_open : Icons.menu,
            color: AppColors.onPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavItem({
    required NavigationRailDestination destination,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.onPrimary.withValues(alpha: 0.08),
          splashColor: AppColors.onPrimary.withValues(alpha: 0.12),
          highlightColor: AppColors.onPrimary.withValues(alpha: 0.08),
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.onPrimary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  child: IconTheme(
                    data: IconThemeData(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onPrimary.withValues(alpha: 0.6),
                      size: isSelected ? 28 : 26,
                    ),
                    child: isSelected
                        ? destination.selectedIcon
                        : destination.icon,
                  ),
                ),

                // Label (only when extended)
                if (_isRailExtended) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.onPrimary.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      child: destination.label,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    final destinations = _getDestinations();

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.primaryDark
            : AppColors.primary,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: destinations.asMap().entries.map((entry) {
            final index = entry.key;
            final destination = entry.value;
            final isSelected = index == _currentIndex;

            return Expanded(
              child: InkResponse(
                onTap: () => _onNavTap(index),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                radius: 28,
                child: Container(
                  height: double.infinity,
                  alignment: Alignment.center,
                  child: Icon(
                    isSelected
                        ? (destination.selectedIcon as Icon).icon
                        : (destination.icon as Icon).icon,
                    color: isSelected
                        ? AppColors.onPrimary
                        : AppColors.onPrimary.withValues(alpha: 0.6),
                    size: isSelected ? 28 : 26,
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
    final pages = _getPages();

    return Navigator(
      key: _navigatorKeys[_currentIndex],
      pages: [
        MaterialPage(key: ValueKey(_currentIndex), child: pages[_currentIndex]),
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
  late int _initialIndex;

  // Platform detection helpers
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // Platform-specific tabs
  List<Tab> _getTabs() {
    List<Tab> tabs = [];

    // Scan - Mobile only
    if (_isMobile) {
      tabs.add(const Tab(icon: Icon(Icons.sensors), text: 'Scan'));
    }

    // Dashboard - All platforms
    tabs.add(const Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'));

    // Search - All platforms
    tabs.add(const Tab(icon: Icon(Icons.search), text: 'Search'));

    // Export - Desktop/Web only
    if (!_isMobile) {
      tabs.add(const Tab(icon: Icon(Icons.upload), text: 'Export'));
    }

    // Settings - All platforms
    tabs.add(const Tab(icon: Icon(Icons.settings), text: 'Settings'));

    return tabs;
  }

  // Platform-specific pages
  List<Widget> _getTabPages() {
    List<Widget> pages = [];

    // Scan - Mobile only
    if (_isMobile) {
      pages.add(const ScanPage());
    }

    // Dashboard - All platforms
    pages.add(const DashboardPage());

    // Search - All platforms
    pages.add(const SearchPage());

    // Export - Desktop/Web only
    if (!_isMobile) {
      pages.add(const ExportPage());
    }

    // Settings - All platforms
    pages.add(const SettingsPage());

    return pages;
  }

  int _getDefaultIndex() {
    final tabs = _getTabs();
    if (_isMobile) return 0; // Start with Scan on mobile

    // Find Dashboard index for desktop/web
    for (int i = 0; i < tabs.length; i++) {
      if (tabs[i].text == 'Dashboard') {
        return i;
      }
    }
    return 0; // fallback
  }

  @override
  void initState() {
    super.initState();
    _initialIndex = _getDefaultIndex();
    _tabController = TabController(
      length: _getTabs().length,
      vsync: this,
      initialIndex: _initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _getTabs();
    final pages = _getTabPages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          isScrollable:
              MediaQuery.of(context).size.width < AppConstants.tabletBreakpoint,
        ),
      ),
      body: TabBarView(controller: _tabController, children: pages),
    );
  }
}
