// Path: frontend/lib/layouts/root_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/browser_api.dart';
import '../core/services/session_timer_service.dart';
import 'package:tp_rfid/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:tp_rfid/features/export/presentation/pages/export_page.dart';
import 'package:tp_rfid/features/search/presentation/pages/search_page.dart';
import 'package:tp_rfid/features/setting/presentation/pages/settings_page.dart';
import '../features/scan/presentation/pages/scan_page.dart';
import '../features/admin/presentation/pages/admin_page.dart';
import '../features/reports/presentation/pages/my_reports_page.dart';
import '../features/setting/presentation/bloc/settings_bloc.dart';
import '../features/setting/presentation/bloc/settings_state.dart';
import '../app/app_constants.dart';
import '../app/theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class RootLayout extends StatefulWidget {
  const RootLayout({super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  late int _currentIndex;
  bool _isRailExtended = true;

  // ✅ TEMPORARY: Enable scanner on desktop for testing
  bool _enableScannerOnDesktop = true; // Set to false to disable

  late List<GlobalKey<NavigatorState>> _navigatorKeys;
  late BrowserApi _browserApi;
  final SessionTimerService _sessionTimer = SessionTimerService();

  // Platform detection

  @override
  void initState() {
    super.initState();
    _browserApi = BrowserApiService.instance;
    // Set default index based on platform
    _currentIndex = _isMobile ? 0 : _getDefaultDesktopIndex();
    _navigatorKeys = List.generate(
      _getDestinationsCount(),
      (index) => GlobalKey<NavigatorState>(),
    );
  }

  // Platform detection helpers - same logic, works on all platforms
  bool get _isMobile => _browserApi.isMobilePlatform;

  // Get total destinations count
  int _getDestinationsCount() {
    int count = 4; // Dashboard, Search, Reports, Settings (always present)
    if (_isMobile || _enableScannerOnDesktop) count++; // Scan
    if (!_isMobile) count += 2; // Export, Admin
    return count;
  }

  // Get default index for desktop/web (Dashboard should be first for desktop)
  int _getDefaultDesktopIndex() {
    return _isMobile
        ? 1
        : 0; // Dashboard is at index 1 for mobile (after Scan), index 0 for desktop
  }

  // Platform-specific destinations for bottom navigation
  List<NavigationDestination> _getDestinations(AppLocalizations appLoc) {
    List<NavigationDestination> destinations = [];

    // Scan - Mobile or enabled on desktop
    if (_isMobile || _enableScannerOnDesktop) {
      destinations.add(
        NavigationDestination(
          icon: const Icon(Icons.sensors_outlined),
          selectedIcon: const Icon(Icons.sensors_rounded),
          label: appLoc.scan,
        ),
      );
    }

    // Dashboard - All platforms
    destinations.add(
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard_rounded),
        label: appLoc.dashboard,
      ),
    );

    // Search - All platforms
    destinations.add(
      NavigationDestination(
        icon: const Icon(Icons.search_outlined),
        selectedIcon: const Icon(Icons.search_rounded),
        label: appLoc.search,
      ),
    );

    // Reports - All platforms
    destinations.add(
      NavigationDestination(
        icon: const Icon(Icons.assignment_outlined),
        selectedIcon: const Icon(Icons.assignment_rounded),
        label: appLoc.reports,
      ),
    );

    // Export - Desktop/Web only
    if (!_isMobile) {
      destinations.add(
        NavigationDestination(
          icon: const Icon(Icons.upload_outlined),
          selectedIcon: const Icon(Icons.upload_rounded),
          label: appLoc.export,
        ),
      );
    }

    // Admin - Desktop/Web only
    if (!_isMobile) {
      destinations.add(
        NavigationDestination(
          icon: const Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: const Icon(Icons.admin_panel_settings_rounded),
          label: appLoc.admin,
        ),
      );
    }

    // Settings - All platforms
    destinations.add(
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person_rounded),
        label: appLoc.settings,
      ),
    );

    return destinations;
  }

  // Platform-specific destinations for navigation rail
  List<NavigationRailDestination> _getRailDestinations(
    AppLocalizations appLoc,
  ) {
    List<NavigationRailDestination> destinations = [];

    // Scan - Mobile or enabled on desktop
    if (_isMobile || _enableScannerOnDesktop) {
      destinations.add(
        NavigationRailDestination(
          icon: const Icon(Icons.sensors_outlined),
          selectedIcon: const Icon(Icons.sensors_rounded),
          label: Text(appLoc.scan),
        ),
      );
    }

    // Dashboard - All platforms
    destinations.add(
      NavigationRailDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard_rounded),
        label: Text(appLoc.dashboard),
      ),
    );

    // Search - All platforms
    destinations.add(
      NavigationRailDestination(
        icon: const Icon(Icons.search_outlined),
        selectedIcon: const Icon(Icons.search_rounded),
        label: Text(appLoc.search),
      ),
    );

    // Reports - All platforms
    destinations.add(
      NavigationRailDestination(
        icon: const Icon(Icons.assignment_outlined),
        selectedIcon: const Icon(Icons.assignment_rounded),
        label: Text(appLoc.reports),
      ),
    );

    // Export - Desktop/Web only
    if (!_isMobile) {
      destinations.add(
        NavigationRailDestination(
          icon: const Icon(Icons.upload_outlined),
          selectedIcon: const Icon(Icons.upload_rounded),
          label: Text(appLoc.export),
        ),
      );
    }

    // Admin - Desktop/Web only
    if (!_isMobile) {
      destinations.add(
        NavigationRailDestination(
          icon: const Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: const Icon(Icons.admin_panel_settings_rounded),
          label: Text(appLoc.admin),
        ),
      );
    }

    // Settings - All platforms
    destinations.add(
      NavigationRailDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person_rounded),
        label: Text(appLoc.settings),
      ),
    );

    return destinations;
  }

  // Platform-specific pages
  List<Widget> _getPages() {
    List<Widget> pages = [];

    // Scan - Mobile or enabled on desktop
    if (_isMobile || _enableScannerOnDesktop) {
      pages.add(const ScanPage());
    }

    // Dashboard - All platforms
    pages.add(const DashboardPage());

    // Search - All platforms
    pages.add(const SearchPage());

    // Reports - All platforms
    pages.add(const MyReportsPage());

    // Export - Desktop/Web only
    if (!_isMobile) {
      pages.add(const ExportPage());
    }

    // Admin - Desktop/Web only
    if (!_isMobile) {
      pages.add(const AdminPage());
    }

    // Settings - All platforms
    pages.add(const SettingsPage());

    return pages;
  }

  void _onNavTap(int index) {
    // Record user activity on any navigation
    _sessionTimer.recordActivity();

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
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        // Get current language from settings, fallback to 'en'
        String currentLanguage = 'en';
        if (settingsState is SettingsLoaded) {
          currentLanguage = settingsState.settings.language;
        }

        // Create locale and override context
        final locale = Locale(currentLanguage);

        return Localizations.override(
          context: context,
          locale: locale,
          child: Builder(
            builder: (localizedContext) {
              final theme = Theme.of(localizedContext);
              final appLoc = AppLocalizations.of(localizedContext);

              final scaffold = Scaffold(
                body: Row(
                  children: [
                    // Navigation Rail for wide screens
                    if (_isWideScreen) _buildNavigationRail(theme, appLoc),

                    // Main content area
                    Expanded(child: _buildMainContent()),
                  ],
                ),

                // Bottom Navigation Bar for narrow screens
                bottomNavigationBar: _isWideScreen
                    ? null
                    : _buildCustomBottomNav(appLoc),
              );

              // Enhanced activity detection for Windows - disabled temporarily to fix crashes
              // if (_isWindows) {
              //   return _buildWindowsActivityWrapper(scaffold);
              // } else {
              return scaffold;
              // }
            },
          ),
        );
      },
    );
  }

  Widget _buildNavigationRail(ThemeData theme, AppLocalizations appLoc) {
    final railDestinations = _getRailDestinations(appLoc);

    return SizedBox(
      width: _isRailExtended ? 256 : 80,
      child: Material(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.primaryDark
            : AppColors.primary,
        child: Column(
          children: [
            // Header with toggle button
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: _buildRailToggleButton(theme),
            ),

            // Custom Navigation Items
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
          onTap: () {
            _sessionTimer.recordActivity();
            setState(() => _isRailExtended = !_isRailExtended);
          },
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

  Widget _buildCustomBottomNav(AppLocalizations appLoc) {
    final destinations = _getDestinations(appLoc);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.primaryDark
            : AppColors.primary,
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
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
      onDidRemovePage: (page) {},
    );
  }
}
