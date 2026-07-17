import 'package:flutter/material.dart';
import '../dashboard/presentation/dashboard_screen.dart';
import '../groups/presentation/groups_screen.dart';
import '../students/presentation/students_search_screen.dart';
import '../settings/presentation/settings_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    GroupsScreen(),
    StudentsSearchScreen(),
    SettingsScreen(),
  ];

  final List<({IconData icon, IconData selectedIcon, String label})> _navItems = const [
    (icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'الرئيسية'),
    (icon: Icons.class_outlined, selectedIcon: Icons.class_, label: 'المجموعات'),
    (icon: Icons.search_outlined, selectedIcon: Icons.search, label: 'الطلاب'),
    (icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'الإعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = !ResponsiveLayout.isMobile(context);

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            if (isWide)
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                extended: ResponsiveLayout.isDesktop(context),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school, color: AppColors.primary, size: 28),
                      ),
                      if (ResponsiveLayout.isDesktop(context)) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'مستر بيست',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                destinations: _navItems.map((item) {
                  return NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon, color: AppColors.primary),
                    label: Text(item.label),
                  );
                }).toList(),
              ),
            if (isWide) const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : Directionality(
              textDirection: TextDirection.rtl,
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                destinations: _navItems.map((item) {
                  return NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon, color: AppColors.primary),
                    label: item.label,
                  );
                }).toList(),
              ),
            ),
    );
  }
}
