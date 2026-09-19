import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lighting_provider.dart';
import 'calculator_screen.dart';
import 'standards_guide_screen.dart';
import 'project_summary_screen.dart';
import '../utils/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LightingProvider>();
    final savedRoomsCount = provider.totalRoomsCount;

    final List<Widget> screens = [
      CalculatorScreen(
        onNavigateToProject: () => _switchTab(2),
      ),
      StandardsGuideScreen(
        onSelectStandard: () => _switchTab(0),
      ),
      ProjectSummaryScreen(
        onAddRoom: () => _switchTab(0),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _switchTab,
        indicatorColor: AppTheme.primaryAmber.withValues(alpha: 0.25),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded, color: AppTheme.primaryDarkAmber),
            label: 'حاسبة الإضاءة',
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded, color: AppTheme.primaryDarkAmber),
            label: 'دليل المعايير',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: savedRoomsCount > 0,
              label: Text('$savedRoomsCount'),
              backgroundColor: AppTheme.primaryDarkAmber,
              child: const Icon(Icons.home_work_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: savedRoomsCount > 0,
              label: Text('$savedRoomsCount'),
              backgroundColor: AppTheme.primaryDarkAmber,
              child: const Icon(Icons.home_work_rounded, color: AppTheme.primaryDarkAmber),
            ),
            label: 'مشروع المنزل',
          ),
        ],
      ),
    );
  }
}
