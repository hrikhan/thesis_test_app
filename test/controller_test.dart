import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rural_medical/app/data/models/patient_model.dart';
import 'package:rural_medical/app/data/services/app_controller.dart';
import 'package:rural_medical/app/data/services/graphql_service.dart';
import 'package:rural_medical/app/data/services/rest_api_service.dart';
import 'package:rural_medical/app/modules/patients/patients_controller.dart';

void main() {
  setUp(() {
    // Inject mock dependencies
    Get.put<RestApiService>(RestApiService());
    Get.put<GraphqlService>(GraphqlService());
    Get.put<AppController>(AppController());
    Get.put<PatientsController>(PatientsController());
  });

  tearDown(() {
    Get.reset();
  });

  group('PatientsController State Tests', () {
    test('Initial Fetch Populates Patients List', () async {
      final controller = Get.find<PatientsController>();

      // Wait for onInit fetch
      await controller.fetchPatients(size: 'small');

      expect(controller.patients.isNotEmpty, true);
      expect(controller.totalPatientsCount, equals(controller.patients.length));
    });

    test('Search Query Filters Patients List', () async {
      final controller = Get.find<PatientsController>();

      // Seed specific patients
      controller.patients.assignAll([
        Patient(
          id: '1',
          name: 'Alice Smith',
          age: 30,
          gender: 'Female',
          condition: 'Asthma',
          status: 'Stable',
        ),
        Patient(
          id: '2',
          name: 'Bob Jones',
          age: 40,
          gender: 'Male',
          condition: 'Diabetes',
          status: 'Critical',
        ),
      ]);

      controller.updateSearchQuery('Diabetes');
      expect(controller.filteredPatients.length, 1);
      expect(controller.filteredPatients.first.name, 'Bob Jones');

      controller.updateSearchQuery('Smith');
      expect(controller.filteredPatients.length, 1);
      expect(controller.filteredPatients.first.name, 'Alice Smith');
    });

    test('Filter Chips Categorize Critical vs Stable', () {
      final controller = Get.find<PatientsController>();

      controller.patients.assignAll([
        Patient(
          id: '1',
          name: 'Alice Smith',
          age: 30,
          gender: 'Female',
          condition: 'Asthma',
          status: 'Stable',
        ),
        Patient(
          id: '2',
          name: 'Bob Jones',
          age: 40,
          gender: 'Male',
          condition: 'Diabetes',
          status: 'Critical',
        ),
        Patient(
          id: '3',
          name: 'Charlie Brown',
          age: 50,
          gender: 'Male',
          condition: 'Hypertension',
          status: 'Stable',
        ),
      ]);

      controller.updateFilter('Stable');
      expect(controller.filteredPatients.length, 2);

      controller.updateFilter('Critical');
      expect(controller.filteredPatients.length, 1);
      expect(controller.filteredPatients.first.name, 'Bob Jones');
    });
  });

  group('Offline Caching & Cloud Syncing Tests', () {
    test(
      'Offline Caching saves patient to local cache and sync queue',
      () async {
        final appController = Get.find<AppController>();
        final patientsController = Get.find<PatientsController>();

        // Enable local caching
        appController.toggleLocalCache(true);

        final patient = Patient(
          id: '',
          name: 'Offline Test Patient',
          age: 45,
          gender: 'Male',
          condition: 'Migraine',
          status: 'Stable',
        );

        final success = await patientsController.addPatient(patient);
        expect(success, true);

        // Verify it was added to local cache and sync queue
        expect(appController.localDatabase.length, 1);
        expect(appController.syncQueue.length, 1);
        expect(appController.localDatabase.first.name, 'Offline Test Patient');
        expect(appController.syncQueue.first.name, 'Offline Test Patient');
      },
    );

    test(
      'Turning off Local Cache triggers cloud synchronization queue',
      () async {
        final appController = Get.find<AppController>();
        final patientsController = Get.find<PatientsController>();

        // Initialize
        await patientsController.fetchPatients(size: 'small');

        // Enable cache & add offline patient
        appController.toggleLocalCache(true);
        final patient = Patient(
          id: '',
          name: 'Queued Patient',
          age: 25,
          gender: 'Female',
          condition: 'Flu',
          status: 'Stable',
        );
        await patientsController.addPatient(patient);

        expect(appController.syncQueue.length, 1);

        // Disable caching to trigger sync worker
        appController.toggleLocalCache(false);

        // Wait brief moment for worker future
        await Future.delayed(const Duration(milliseconds: 300));

        // Sync queue should be flushed and records pushed to patients list
        expect(appController.syncQueue.isEmpty, true);
      },
    );
  });
}
