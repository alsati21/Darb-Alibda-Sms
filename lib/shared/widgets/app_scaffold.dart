import 'package:flutter/material.dart';

import '../../core/navigation/route_names.dart';
import '../theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentIndex,
    this.actions,
  });

  final String title;
  final Widget body;
  final int currentIndex;
  final List<Widget>? actions;

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, RouteNames.dashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, RouteNames.attendance);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, RouteNames.schedule);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, RouteNames.news);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 16,
        title: Text(title),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onTabSelected(context, index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: 'الحضور'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule), label: 'الجدول'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'الأخبار'),
        ],
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, RouteNames.absenceRequests),
              icon: const Icon(Icons.assignment_late_outlined),
              label: const Text('طلبات الغياب'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            )
          : null,
    );
  }
}
