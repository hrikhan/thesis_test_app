import 'package:get/get.dart';
import '../dashboard/dashboard_controller.dart';
import '../reports/reports_controller.dart';
import '../settings/settings_controller.dart';
import 'navigation_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ReportsController>(() => ReportsController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
