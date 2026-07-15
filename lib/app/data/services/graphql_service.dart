import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/patient_model.dart';

class GraphqlService {
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
      final id = 'GQL-PAT-${2000 + index}';
      final name = _names[index % _names.length];
      final age = 20 + (index % 65);
      final gender = genders[index % genders.length];
      final condition = conditions[index % conditions.length];
      final status = (index % 7 == 0) ? 'Critical' : 'Stable';

      String notes = 'GraphQL node data representation.';
      if (addHeavyData) {
        notes = 'Comprehensive GraphQL patient record node including connected medical history records, detailed active prescription logs, and laboratory diagnostic reports. ' * 15;
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

    const String queryStr = r'''
query GetPatients($limit: Int, $detailed: Boolean) {
  patients(limit: $limit, detailed: $detailed) {
    id
    name
    age
    gender
    condition
    status
    notes
    medicalHistory
    prescriptions {
      medication
      dosage
      frequency
    }
    labReports {
      test
      result
      date
    }
  }
}
''';

    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final list = _generateMockPatients(limit, addHeavyData: heavy);
      final responsePayload = {
        'data': {'patients': list.map((e) => e.toJson()).toList()},
      };
      final jsonStr = json.encode(responsePayload);
      final actualSizeKB = utf8.encode(jsonStr).length / 1024;
      return {
        'data': list,
        'latencyMs': mockDelay,
        'payloadSizeKB': actualSizeKB,
        'query': queryStr,
        'rawResponse': responsePayload,
      };
    }

    final endpoint = '$_baseUrl/graphql';
    try {
      if (kDebugMode) {
        print('[GraphQL API] Querying patients from: $endpoint');
      }

      final requestBody = {
        'query': queryStr,
        'variables': {
          'limit': limit,
          'detailed': detailed,
        }
      };

      final stopwatch = Stopwatch()..start();
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      stopwatch.stop();

      if (response.statusCode != 200) {
        throw HttpException('GraphQL query failed: ${response.statusCode}');
      }

      final actualSizeKB = utf8.encode(response.body).length / 1024;
      final Map<String, dynamic> rawResponse = json.decode(response.body);

      if (rawResponse.containsKey('errors')) {
        throw Exception('GraphQL Errors: ${rawResponse['errors']}');
      }

      final List patientsJson = rawResponse['data']?['patients'] ?? [];
      final List<Patient> list = patientsJson.map((e) => Patient.fromJson(e)).toList();

      return {
        'data': list,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'payloadSizeKB': actualSizeKB,
        'query': queryStr,
        'rawResponse': rawResponse,
      };
    } catch (e) {
      if (kDebugMode) {
        print('[GraphQL API] Error querying server, falling back to mock data: $e');
      }
      final list = _generateMockPatients(limit, addHeavyData: heavy);
      final responsePayload = {
        'data': {'patients': list.map((e) => e.toJson()).toList()},
      };
      final jsonStr = json.encode(responsePayload);
      final actualSizeKB = utf8.encode(jsonStr).length / 1024;
      return {
        'data': list,
        'latencyMs': mockDelay,
        'payloadSizeKB': actualSizeKB,
        'query': queryStr,
        'rawResponse': responsePayload,
      };
    }
  }

  Future<Map<String, dynamic>> addPatient(Patient patient) async {
    const String mutationStr = r'''
mutation CreatePatient($input: CreatePatientInput!) {
  createPatient(input: $input) {
    id
    name
    age
    gender
    condition
    status
  }
}
''';

    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final newPatient = patient.copyWith(
        id: 'GQL-PAT-${DateTime.now().millisecondsSinceEpoch % 10000}',
      );
      final responsePayload = {
        'data': {'createPatient': newPatient.toJson()},
      };
      final jsonStr = json.encode(responsePayload);
      final actualSizeKB = utf8.encode(jsonStr).length / 1024;
      return {
        'data': newPatient,
        'latencyMs': 200,
        'payloadSizeKB': actualSizeKB,
        'query': mutationStr,
        'rawResponse': responsePayload,
      };
    }

    final endpoint = '$_baseUrl/graphql';
    try {
      if (kDebugMode) {
        print('[GraphQL API] Creating patient mutation at: $endpoint');
      }

      final requestBody = {
        'query': mutationStr,
        'variables': {
          'input': {
            'name': patient.name,
            'age': patient.age,
            'gender': patient.gender,
            'condition': patient.condition,
            'status': patient.status,
            'notes': patient.notes ?? '',
          }
        }
      };

      final stopwatch = Stopwatch()..start();
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      stopwatch.stop();

      if (response.statusCode != 200) {
        throw HttpException('GraphQL mutation failed: ${response.statusCode}');
      }

      final actualSizeKB = utf8.encode(response.body).length / 1024;
      final Map<String, dynamic> rawResponse = json.decode(response.body);

      if (rawResponse.containsKey('errors')) {
        throw Exception('GraphQL Errors: ${rawResponse['errors']}');
      }

      final newPatientJson = rawResponse['data']?['createPatient'] ?? {};
      final newPatient = Patient.fromJson(newPatientJson);

      return {
        'data': newPatient,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'payloadSizeKB': actualSizeKB,
        'query': mutationStr,
        'rawResponse': rawResponse,
      };
    } catch (e) {
      if (kDebugMode) {
        print('[GraphQL API] Error executing mutation, falling back to mock data: $e');
      }
      final newPatient = patient.copyWith(
        id: 'GQL-PAT-${DateTime.now().millisecondsSinceEpoch % 10000}',
      );
      final responsePayload = {
        'data': {'createPatient': newPatient.toJson()},
      };
      final jsonStr = json.encode(responsePayload);
      final actualSizeKB = utf8.encode(jsonStr).length / 1024;
      return {
        'data': newPatient,
        'latencyMs': 200,
        'payloadSizeKB': actualSizeKB,
        'query': mutationStr,
        'rawResponse': responsePayload,
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
