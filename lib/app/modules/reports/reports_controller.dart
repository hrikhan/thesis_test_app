import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/report_model.dart';
import '../../data/services/app_controller.dart';

class ReportsController extends GetxController {
  final AppController _appController = Get.find<AppController>();

  final RxList<MedicalReport> reports = <MedicalReport>[].obs;
  final RxBool isLoading = false.obs;

  // Debug/Telemetry states
  final RxDouble lastPayloadSizeKB = 0.0.obs;
  final RxInt lastLatencyMs = 0.obs;
  final RxString lastEndpoint = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReports(size: 'small');
  }

  Future<void> fetchReports({required String size}) async {
    isLoading.value = true;

    int delay = 200;
    int count = 3;
    bool heavyData = false;

    switch (size.toLowerCase()) {
      case 'small':
        delay = 200;
        count = 3;
        heavyData = false;
        break;
      case 'medium':
        delay = 800;
        count = 15;
        heavyData = true;
        break;
      case 'large':
        delay = 1500;
        count = 80;
        heavyData = true;
        break;
    }

    final multiplier = _appController.latencyMultiplier;
    final totalDelay = (delay * multiplier).round();

    if (kDebugMode) {
      print(
        '[Reports Service] Fetching. Size: $size, Simulated delay: ${totalDelay}ms',
      );
    }

    try {
      await Future.delayed(Duration(milliseconds: totalDelay));

      final list = _generateMockReports(count, addHeavyData: heavyData);
      reports.assignAll(list);

      // Calculate actual size of JSON payload to demonstrate simulator accuracy
      final jsonStr = json.encode(list.map((e) => e.toJson()).toList());
      final actualSizeKB = utf8.encode(jsonStr).length / 1024;

      lastPayloadSizeKB.value = actualSizeKB;
      lastLatencyMs.value = totalDelay;
      lastEndpoint.value =
          'GET /api/v1/reports?limit=$count&detailed=$heavyData';
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching reports: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<MedicalReport> _generateMockReports(
    int count, {
    bool addHeavyData = false,
  }) {
    final categories = [
      'Hematology',
      'Cardiology',
      'Radiology',
      'Biochemistry',
      'Immunology',
    ];
    final technicians = [
      'Dr. Sarah Carter',
      'Dr. James Wilson',
      'Dr. Allison Cameron',
      'Dr. Gregory House',
    ];
    final titles = [
      'Complete Blood Count (CBC)',
      'Electrocardiogram (ECG)',
      'Chest X-Ray',
      'Liver Function Test (LFT)',
      'Thyroid Profile (T3 T4 TSH)',
      'Urinalysis Summary',
      'Lipid Panel Profile',
      'Basic Metabolic Panel (BMP)',
      'Hemoglobin A1c Test',
    ];
    final referenceRanges = [
      '4.5 - 11.0 x10^3/uL',
      'Normal sinus rhythm',
      'No acute cardiopulmonary disease',
      'ALT: 7-56 U/L, AST: 10-40 U/L',
      'TSH: 0.4 - 4.0 mIU/L',
      'Clear/Normal',
      'LDL < 100 mg/dL',
      'Sodium: 135-145 mEq/L',
      '4.0% - 5.6%',
    ];
    final values = [
      '7.2 x10^3/uL (Normal)',
      'Sinus Bradycardia (62 bpm)',
      'Clear lung fields',
      'ALT: 42 U/L (Normal)',
      'TSH: 2.1 mIU/L',
      'Trace proteins detected',
      'LDL: 124 mg/dL (Borderline)',
      'Sodium: 138 mEq/L',
      '5.2% (Normal)',
    ];

    return List.generate(count, (index) {
      final id = 'REP-${3000 + index}';
      final title = titles[index % titles.length];
      final category = categories[index % categories.length];
      final referenceRange = referenceRanges[index % referenceRanges.length];
      final resultValue = values[index % values.length];
      final technician = technicians[index % technicians.length];
      final patientName = _patients[index % _patients.length];

      // Heavy mock string for large payload logs
      final String formattedNotes = addHeavyData
          ? 'Comprehensive diagnostic record node. Technican notes: verified patient credentials, calibrated machinery prior to scan, double-checked findings. ' *
                12
          : 'Verified result.';

      return MedicalReport(
        id: id,
        title: title,
        patientName: patientName,
        category: category,
        date: '2026-07-${(15 - (index % 12)).toString().padLeft(2, '0')}',
        status: (index % 8 == 0) ? 'Pending' : 'Completed',
        resultValue: resultValue,
        referenceRange: referenceRange,
        technician: '$technician - $formattedNotes',
      );
    });
  }

  static const List<String> _patients = [
    'Alice Smith',
    'Bob Jones',
    'Charlie Brown',
    'Diana Prince',
    'Evan Wright',
    'Fiona Gallagher',
    'George Clooney',
    'Hannah Abbott',
    'Ian Malcolm',
    'Julia Roberts',
  ];
}
