// lib/presentation/layouts/root_layout.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/dashboard_page.dart';

class RootLayout extends StatefulWidget {
  const RootLayout({super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  int _currentIndex = 0;
  bool _isRailExtended = true;

  final List<Widget> _pages = const [
    DashboardPage(),
    // SearchPage(),
    // ScanPage(),
    // ReportPage(),
    // ExportPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 600;
    final primaryColor = Color(0xFF4F46E5);
    final indicatorColor = primaryColor.withOpacity(0.12);

    return Scaffold(
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) =>
                  setState(() => _currentIndex = index),
              extended: _isRailExtended,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.qr_code_scanner),
                  label: Text('Scan'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart),
                  label: Text('Report'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.upload),
                  label: Text('Export'),
                ),
              ],
              selectedIconTheme: IconThemeData(color: primaryColor),
              selectedLabelTextStyle: TextStyle(color: primaryColor),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              indicatorColor: indicatorColor,
              backgroundColor: Colors.white,
              leading: FloatingActionButton(
                mini: true,
                onPressed: () {
                  setState(() {
                    _isRailExtended = !_isRailExtended;
                  });
                },
                child: Icon(
                  _isRailExtended ? Icons.menu_open : Icons.menu,
                  color: primaryColor,
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          Expanded(
            child: Navigator(
              pages: [MaterialPage(child: _pages[_currentIndex])],
              onPopPage: (route, result) => route.didPop(result),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Report',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.upload),
                  label: 'Export',
                ),
              ],
            ),
    );
  }
}
