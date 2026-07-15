import 'package:get/get.dart';
import '../modules/navigation/main_navigation_view.dart';
import '../modules/navigation/navigation_binding.dart';
import '../modules/patients/add_patient_view.dart';
import '../modules/patients/patient_details_view.dart';
import '../modules/settings/benchmark_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.INITIAL;

  static final routes = [
    GetPage(
      name: Routes.INITIAL,
      page: () => const MainNavigationView(),
      binding: NavigationBinding(),
    ),
    GetPage(
      name: Routes.ADD_PATIENT,
      page: () => const AddPatientView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.PATIENT_DETAILS,
      page: () => const PatientDetailsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.BENCHMARK,
      page: () => const BenchmarkView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
