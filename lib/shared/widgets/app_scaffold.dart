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
    this.floatingActionButton,
    this.unreadNotificationsCount = 0,
  });
  final Widget? floatingActionButton;
  final String title;
  final Widget body;
  final int currentIndex;
  final List<Widget>? actions;
  final int unreadNotificationsCount;

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
      case 4:
        Navigator.pushReplacementNamed(context, RouteNames.classes);
        break;
      case 5:
        Navigator.pushReplacementNamed(context, RouteNames.feedback);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarActions = <Widget>[
      IconButton(
        onPressed: () => Navigator.pushNamed(context, RouteNames.notifications),
        icon: Badge(
          isLabelVisible: unreadNotificationsCount > 0,
          label: unreadNotificationsCount > 0
              ? Text('$unreadNotificationsCount')
              : null,
          child: const Icon(Icons.notifications_none_outlined),
        ),
      ),
      ...?(actions ?? []),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 16,
        title: Text(title),
        actions: appBarActions,
      ),
      body: body,

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onTabSelected(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'الحضور',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'الجدول',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'الأخبار',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            selectedIcon: Icon(Icons.class_outlined),
            label: 'الصفوف',
          ),
          //  NavigationDestination(icon: Icon(Icons.feedback_outlined), selectedIcon: Icon(Icons.feedback), label: 'الاقتراحات'),
        ],
      ),

      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteNames.absenceRequests),
              icon: const Icon(Icons.assignment_late_outlined),
              label: const Text('طلبات الغياب'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            )
          : null,
    );
  }
}
