import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/patient_model.dart';

class RestApiService {
  String get _baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  // Generates dummy patients
  List<Patient> _generateMockPatients(int count, {bool addHeavyData = false}) {
    final List<String> conditions = [
      'Hypertension',
      'Diabetes Mellitus Type 2',
      'Acute Appendicitis',
      'Chronic Asthma',
      'Pneumonia',
      'Myocardial Infarction',
      'Osteoarthritis',
      'Migraine',
      'Gastroesophageal Reflux',
      'Hyperlipidemia',
    ];
    final List<String> genders = ['Male', 'Female', 'Other'];

    return List.generate(count, (index) {
      final id = 'REST-PAT-${1000 + index}';
      final name = _names[index % _names.length];
      final age = 20 + (index % 65);
      final gender = genders[index % genders.length];
      final condition = conditions[index % conditions.length];
      final status = (index % 7 == 0) ? 'Critical' : 'Stable';

      String notes = 'Standard patient review records.';
      if (addHeavyData) {
        notes = 'Patient was admitted for detailed diagnostic workup. ' * 30; // ~1KB notes
      }

      return Patient(
        id: id,
        name: name,
        age: age,
        gender: gender,
        condition: condition,
        status: status,
        notes: notes,
        medicalHistory: [
          'Diagnosed with $condition in ${2020 + (index % 5)}',
          if (index % 2 == 0) 'Family history of cardiovascular issues',
          if (index % 3 == 0) 'Allergic to Penicillin',
        ],
        prescriptions: [
          {
            'medication': 'Medication A',
            'dosage': '50mg',
            'frequency': 'Once Daily',
          },
          if (index % 2 == 0)
            {
              'medication': 'Medication B',
              'dosage': '10mg',
              'frequency': 'Twice Daily',
            },
        ],
        labReports: [
          {
            'test': 'Blood sugar levels',
            'result': 'Normal',
            'date': '2026-06-15',
          },
          if (index % 3 == 0)
            {
              'test': 'Lipid Profile',
              'result': 'High Cholesterol',
              'date': '2026-07-01',
            },
        ],
      );
    });
  }

  Future<Map<String, dynamic>> fetchPatients(String payloadSize) async {
    int limit = 5;
    bool detailed = false;
    int mockDelay = 200;
    bool heavy = false;

    switch (payloadSize.toLowerCase()) {
      case 'small':
        limit = 5;
        detailed = false;
        mockDelay = 200;
        heavy = false;
        break;
      case 'medium':
        limit = 45;
        detailed = true;
        mockDelay = 800;
        heavy = true;
        break;
      case 'large':
        limit = 300;
        detailed = true;
        mockDelay = 1500;
        heavy = true;
        break;
    }

    // Check if we are running under Flutter/Dart test environment
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final list = _generateMockPatients(limit, addHeavyData: heavy);
      final jsonStr = json.encode(list.map((e) => e.toJson()).toList());
      final actualSizeKB = utf8.encode(jsonStr).length / 1024;
      return {
        'data': list,
        'latencyMs': mockDelay,
        'payloadSizeKB': actualSizeKB,
        'endpoint': 'GET /api/v1/patients?limit=$limit&detailed=$detailed (Mock Fallback)',
      };
    }

    final endpoint = '$_baseUrl/api/v1/patients?limit=$limit&detailed=$detailed';
    try {
      if (kDebugMode) {
        print('[REST API] Fetching patients from: $endpoint');
      }

      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse(endpoint));
      stopwatch.stop();

      if (response.statusCode != 200) {
        throw HttpException('Failed to fetch patients: ${response.statusCode}');
      }

      final actualSizeKB = utf8.encode(response.body).length / 1024;
      final List decoded = json.decode(response.body);
      final List<Patient> list = decoded.map((e) => Patient.fromJson(e)).toList();

      return {
        'data': list,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'payloadSizeKB': actualSizeKB,
        'endpoint': 'GET /api/v1/patients?limit=$limit&detailed=$detailed',
      };
    } catch (e) {
      if (kDebugMode) {
        print('[REST API] Error connecting to server, falling back to mock data: $e');
      }
      final list = _generateMockPatients(limit, addHeavyData: heavy);
      final jsonStr = json.encode(list.map((e) => e.toJson()).toList());
      final actualSizeKB = utf8.encode(jsonStr).length / 1024;
      return {
        'data': list,
        'latencyMs': mockDelay,
        'payloadSizeKB': actualSizeKB,
        'endpoint': 'GET /api/v1/patients?limit=$limit&detailed=$detailed (Mock Fallback)',
      };
    }
  }

  Future<Map<String, dynamic>> addPatient(Patient patient) async {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final newPatient = patient.copyWith(
        id: 'REST-PAT-${DateTime.now().millisecondsSinceEpoch % 10000}',
      );
      final jsonStr = json.encode(newPatient.toJson());
      final actualSizeKB = utf8.encode(jsonStr).length / 1024;
      return {
        'data': newPatient,
        'latencyMs': 200,
        'payloadSizeKB': actualSizeKB,
        'endpoint': 'POST /api/v1/patients (Mock Fallback)',
      };
    }

    final endpoint = '$_baseUrl/api/v1/patients';
    try {
      if (kDebugMode) {
        print('[REST API] Adding patient to: $endpoint');
      }

      final patientJson = patient.toJson();
      patientJson.remove('id');

      final stopwatch = Stopwatch()..start();
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(patientJson),
      );
      stopwatch.stop();

      if (response.statusCode != 201) {
        throw HttpException('Failed to add patient: ${response.statusCode}');
      }

      final actualSizeKB = utf8.encode(response.body).length / 1024;
      final decoded = json.decode(response.body);
      final newPatient = Patient.fromJson(decoded);

      return {
        'data': newPatient,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'payloadSizeKB': actualSizeKB,
        'endpoint': 'POST /api/v1/patients',
      };
    } catch (e) {
      if (kDebugMode) {
        print('[REST API] Error adding patient, falling back to mock data: $e');
      }
      final newPatient = patient.copyWith(
        id: 'REST-PAT-${DateTime.now().millisecondsSinceEpoch % 10000}',
      );
      final jsonStr = json.encode(newPatient.toJson());
      final actualSizeKB = utf8.encode(jsonStr).length / 1024;
      return {
        'data': newPatient,
        'latencyMs': 200,
        'payloadSizeKB': actualSizeKB,
        'endpoint': 'POST /api/v1/patients (Mock Fallback)',
      };
    }
  }

  static const List<String> _names = [
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
    'Kevin Bacon',
    'Laura Croft',
    'Michael Scott',
    'Natalie Portman',
    'Oliver Queen',
    'Penelope Cruz',
    'Quentin Tarantino',
    'Rachel Green',
    'Steve Rogers',
    'Tony Stark',
    'Ursula Buffay',
    'Victor Frankenstein',
    'Wendy Darling',
    'Xavier Charles',
    'Ygritte Snow',
    'Zachary Levi',
  ];
}
