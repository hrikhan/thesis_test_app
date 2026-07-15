import 'package:get/get.dart';
import 'app_controller.dart';
import 'graphql_service.dart';
import 'rest_api_service.dart';
import '../../modules/patients/patients_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<RestApiService>(RestApiService(), permanent: true);
    Get.put<GraphqlService>(GraphqlService(), permanent: true);
    Get.put<AppController>(AppController(), permanent: true);
    Get.put<PatientsController>(PatientsController(), permanent: true);
  }
}
