import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/patient_model.dart';
import '../../data/services/app_controller.dart';
import '../../data/services/graphql_service.dart';
import '../../data/services/rest_api_service.dart';

class PatientsController extends GetxController {
  final RestApiService _restService = Get.find<RestApiService>();
  final GraphqlService _graphqlService = Get.find<GraphqlService>();
  final AppController _appController = Get.find<AppController>();

  // State Variables
  final RxList<Patient> patients = <Patient>[].obs;
  final RxBool isLoading = false.obs;

  // Search & Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs; // All, Critical, Stable

  // Debug/Simulation telemetry fields
  final RxDouble lastPayloadSizeKB = 0.0.obs;
  final RxInt lastLatencyMs = 0.obs;
  final RxString lastEndpoint = ''.obs;
  final RxString lastQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Thesis Offline-first sync worker
    ever(_appController.localCacheEnabled, (bool cacheEnabled) {
      if (!cacheEnabled && _appController.syncQueue.isNotEmpty) {
        _syncOfflineQueue();
      }
    });
    // Fetch initial list with small size
    fetchPatients(size: 'small');
  }

  // Filtered list of patients based on search query and status filter
  List<Patient> get filteredPatients {
    return patients.where((patient) {
      final matchesSearch =
          patient.name.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          patient.condition.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );

      final matchesFilter =
          selectedFilter.value == 'All' ||
          patient.status.toLowerCase() == selectedFilter.value.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // Statistics for Dashboard
  int get totalPatientsCount => patients.length;
  int get criticalCount =>
      patients.where((p) => p.status.toLowerCase() == 'critical').length;
  int get stableCount =>
      patients.where((p) => p.status.toLowerCase() == 'stable').length;

  Future<void> fetchPatients({String? size}) async {
    final payloadSize = size ?? 'small';
    isLoading.value = true;

    try {
      // Local Database Cache Mode
      if (_appController.localCacheEnabled.value) {
        if (_appController.localDatabase.isEmpty) {
          // Fill local cache on first access
          final isGraphQL = _appController.apiMode.value == ApiMode.graphql;
          final initialData = isGraphQL
              ? await _graphqlService.fetchPatients('small')
              : await _restService.fetchPatients('small');
          _appController.localDatabase.assignAll(
            initialData['data'] as List<Patient>,
          );
        }

        // Fast local memory/db read
        await Future.delayed(const Duration(milliseconds: 40));
        patients.assignAll(_appController.localDatabase);

        lastPayloadSizeKB.value = 0.0;
        lastLatencyMs.value = 40;
        lastEndpoint.value = 'Local Cache: SQLite/Hive Read';
        lastQuery.value = '';
        return;
      }

      final isGraphQL = _appController.apiMode.value == ApiMode.graphql;
      // Calculate multiplier
      final multiplier = _appController.latencyMultiplier;

      Map<String, dynamic> result;
      if (isGraphQL) {
        result = await _graphqlService.fetchPatients(payloadSize);
        // Apply latency multiplier dynamically if it's not 1.0
        if (multiplier > 1.0) {
          final additionalDelay =
              (result['latencyMs'] as int) * (multiplier - 1);
          await Future.delayed(Duration(milliseconds: additionalDelay.round()));
        }

        lastQuery.value = result['query'] ?? '';
        lastEndpoint.value = 'GraphQL POST /graphql';
      } else {
        result = await _restService.fetchPatients(payloadSize);
        // Apply latency multiplier dynamically
        if (multiplier > 1.0) {
          final additionalDelay =
              (result['latencyMs'] as int) * (multiplier - 1);
          await Future.delayed(Duration(milliseconds: additionalDelay.round()));
        }

        lastQuery.value = '';
        lastEndpoint.value = result['endpoint'] ?? '';
      }

      patients.assignAll(result['data'] as List<Patient>);
      lastPayloadSizeKB.value = result['payloadSizeKB'] as double;
      // Actual latency including network simulation scale factor
      lastLatencyMs.value = ((result['latencyMs'] as int) * multiplier).round();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching patients: $e');
      }
      _showSnackbar('Error', 'Failed to fetch patient data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addPatient(Patient newPatient) async {
    isLoading.value = true;
    try {
      // Local Database Cache Mode
      if (_appController.localCacheEnabled.value) {
        await Future.delayed(const Duration(milliseconds: 50));

        final added = newPatient.copyWith(
          id: 'LOCAL-PAT-${DateTime.now().millisecondsSinceEpoch % 10000}',
        );

        // Write locally, enqueue to sync, and update reactive UI list
        _appController.localDatabase.insert(0, added);
        _appController.syncQueue.add(added);
        patients.insert(0, added);

        lastPayloadSizeKB.value = 0.0;
        lastLatencyMs.value = 50;
        lastEndpoint.value = 'Local Cache: SQLite/Hive Write';
        lastQuery.value = '';

        _showSnackbar(
          'Offline Mode Active',
          'Record saved to local cache. Sync queue is waiting.',
          backgroundColor: Colors.orange.shade50,
          colorText: Colors.orange.shade900,
          icon: const Icon(Icons.cloud_off, color: Colors.orange),
          duration: const Duration(seconds: 4),
        );
        return true;
      }

      final isGraphQL = _appController.apiMode.value == ApiMode.graphql;
      Map<String, dynamic> result;

      if (isGraphQL) {
        result = await _graphqlService.addPatient(newPatient);
        lastQuery.value = result['query'] ?? '';
        lastEndpoint.value = 'GraphQL Mutation addPatient';
      } else {
        result = await _restService.addPatient(newPatient);
        lastQuery.value = '';
        lastEndpoint.value = result['endpoint'] ?? '';
      }

      final added = result['data'] as Patient;
      patients.insert(0, added); // Add to the top of the list

      lastPayloadSizeKB.value = result['payloadSizeKB'] as double;
      lastLatencyMs.value = result['latencyMs'] as int;

      // Show success snackbar
      _showSnackbar(
        'Success',
        'Patient "${added.name}" added successfully!',
        backgroundColor: const Color(0xffe8f5e9),
        colorText: const Color(0xff2e7d32),
        icon: const Icon(Icons.check_circle, color: Color(0xff2e7d32)),
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding patient: $e');
      }
      _showSnackbar(
        'Error',
        'Failed to add patient',
        backgroundColor: const Color(0xffffebee),
        colorText: const Color(0xffc62828),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _syncOfflineQueue() async {
    isLoading.value = true;
    final listToSync = List<Patient>.from(_appController.syncQueue);
    _appController.syncQueue.clear();

    _showSnackbar(
      'Cloud Syncing',
      'Syncing ${listToSync.length} offline records to cloud...',
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
      showProgressIndicator: true,
      duration: const Duration(seconds: 2),
    );

    int count = 0;
    for (var patient in listToSync) {
      final isGraphQL = _appController.apiMode.value == ApiMode.graphql;
      if (isGraphQL) {
        await _graphqlService.addPatient(patient);
      } else {
        await _restService.addPatient(patient);
      }
      count++;
    }

    // Refresh online list
    await fetchPatients(size: 'small');

    _showSnackbar(
      'Sync Completed',
      'Successfully synchronized $count offline records to cloud!',
      backgroundColor: const Color(0xffe8f5e9),
      colorText: const Color(0xff2e7d32),
      icon: const Icon(Icons.cloud_done, color: Color(0xff2e7d32)),
      duration: const Duration(seconds: 4),
    );
  }

  void _showSnackbar(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
    Widget? icon,
    Duration? duration,
    bool showProgressIndicator = false,
  }) {
    if (Get.context != null) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor,
        colorText: colorText,
        icon: icon,
        duration: duration,
        showProgressIndicator: showProgressIndicator,
      );
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
  }
}
