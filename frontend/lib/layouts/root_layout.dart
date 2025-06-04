// Path: frontend/lib/layouts/root_layout.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/dashboard_page.dart';
import '../features/scan/presentation/pages/scan_page.dart';

class RootLayout extends StatefulWidget {
  const RootLayout({super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  int _currentIndex = 0;
  bool _isRailExtended = true;

  // เพิ่ม placeholder pages ให้ครบ 5 หน้า
  final List<Widget> _pages = const [
    DashboardPage(),
    _PlaceholderPage(title: 'Search', icon: Icons.search),
    ScanPage(),
    _PlaceholderPage(title: 'Report', icon: Icons.bar_chart),
    _PlaceholderPage(title: 'Export', icon: Icons.upload),
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

// Placeholder widget สำหรับหน้าที่ยังไม่ได้ implement
class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderPage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF4F46E5), size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              '$title Feature',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Coming Soon',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
