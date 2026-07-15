import 'package:get/get.dart';
import '../patients/patients_controller.dart';

class DashboardController extends GetxController {
  final PatientsController _patientsController = Get.find<PatientsController>();

  // Expose states
  bool get isLoading => _patientsController.isLoading.value;

  int get totalPatients => _patientsController.totalPatientsCount;
  int get criticalCases => _patientsController.criticalCount;
  int get stableCases => _patientsController.stableCount;

  // Let the user trigger re-fetching with different payload sizes
  Future<void> simulateLoad(String size) async {
    await _patientsController.fetchPatients(size: size);
  }
}
