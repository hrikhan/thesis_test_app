import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/patient_model.dart';

class GraphqlService {
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
    final List<String> statuses = ['Stable', 'Critical'];

    return List.generate(count, (index) {
      final id = 'GQL-PAT-${2000 + index}';
      final name = _names[index % _names.length];
      final age = 20 + (index % 65);
      final gender = genders[index % genders.length];
      final condition = conditions[index % conditions.length];
      final status = (index % 7 == 0) ? 'Critical' : 'Stable';

      String notes = 'GraphQL node data representation.';
      if (addHeavyData) {
        notes =
            'Comprehensive GraphQL patient record node including connected medical history records, detailed active prescription logs, and laboratory diagnostic reports. ' *
            15;
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
    int count = 5;
    int delay = 200;
    bool heavy = false;

    switch (payloadSize.toLowerCase()) {
      case 'small':
        count = 5;
        delay = 200;
        heavy = false;
        break;
      case 'medium':
        count = 45;
        delay = 800;
        heavy = true;
        break;
      case 'large':
        count = 320;
        delay = 1500;
        heavy = true;
        break;
    }

    if (kDebugMode) {
      print(
        '[GraphQL API] Querying patients. Payload: $payloadSize, Delay: ${delay}ms',
      );
    }

    await Future.delayed(Duration(milliseconds: delay));
    final list = _generateMockPatients(count, addHeavyData: heavy);

    // GraphQL Response wrapper: { "data": { "patients": [...] } }
    final responsePayload = {
      'data': {'patients': list.map((e) => e.toJson()).toList()},
    };

    final jsonStr = json.encode(responsePayload);
    final actualSizeKB = utf8.encode(jsonStr).length / 1024;

    String queryStr = '''
query GetPatients {
  patients {
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

    return {
      'data': list,
      'latencyMs': delay,
      'payloadSizeKB': actualSizeKB,
      'query': queryStr,
      'rawResponse': responsePayload,
    };
  }

  Future<Map<String, dynamic>> addPatient(Patient patient) async {
    if (kDebugMode) {
      print('[GraphQL API] Executing mutation addPatient: ${patient.name}');
    }
    await Future.delayed(const Duration(milliseconds: 500));

    final newPatient = patient.copyWith(
      id: 'GQL-PAT-${DateTime.now().millisecondsSinceEpoch % 10000}',
    );

    final responsePayload = {
      'data': {'createPatient': newPatient.toJson()},
    };

    final jsonStr = json.encode(responsePayload);
    final actualSizeKB = utf8.encode(jsonStr).length / 1024;

    String mutationStr = '''
mutation CreatePatient(\$input: CreatePatientInput!) {
  createPatient(input: \$input) {
    id
    name
    age
    gender
    condition
    status
  }
}
''';

    return {
      'data': newPatient,
      'latencyMs': 500,
      'payloadSizeKB': actualSizeKB,
      'query': mutationStr,
      'rawResponse': responsePayload,
    };
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
