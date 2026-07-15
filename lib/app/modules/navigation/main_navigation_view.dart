import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard/dashboard_view.dart';
import '../patients/patients_view.dart';
import '../reports/reports_view.dart';
import '../settings/settings_view.dart';
import 'navigation_controller.dart';

class MainNavigationView extends GetView<NavigationController> {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DashboardView(),
      const PatientsView(),
      const ReportsView(),
      const SettingsView(),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Obx(() {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: controller.changeTab,
            backgroundColor: theme.brightness == Brightness.light
                ? Colors.white
                : theme.colorScheme.surface,
            indicatorColor: theme.colorScheme.primary.withOpacity(0.12),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: Color(0xff1976d2)),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people, color: Color(0xff1976d2)),
                label: 'Patients',
              ),
              NavigationDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description, color: Color(0xff1976d2)),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings, color: Color(0xff1976d2)),
                label: 'Settings',
              ),
            ],
          ),
        );
      }),
    );
  }
}
