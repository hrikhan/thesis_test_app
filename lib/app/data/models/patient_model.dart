class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String condition;
  final String status;
  final String? notes;
  final List<String> medicalHistory;
  final List<Map<String, String>> prescriptions;
  final List<Map<String, String>> labReports;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.condition,
    required this.status,
    this.notes,
    this.medicalHistory = const [],
    this.prescriptions = const [],
    this.labReports = const [],
  });

  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? condition,
    String? status,
    String? notes,
    List<String>? medicalHistory,
    List<Map<String, String>>? prescriptions,
    List<Map<String, String>>? labReports,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      prescriptions: prescriptions ?? this.prescriptions,
      labReports: labReports ?? this.labReports,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'condition': condition,
      'status': status,
      'notes': notes,
      'medicalHistory': medicalHistory,
      'prescriptions': prescriptions,
      'labReports': labReports,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      gender: json['gender'] ?? '',
      condition: json['condition'] ?? '',
      status: json['status'] ?? 'Stable',
      notes: json['notes'],
      medicalHistory: List<String>.from(json['medicalHistory'] ?? []),
      prescriptions:
          (json['prescriptions'] as List?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      labReports:
          (json['labReports'] as List?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
    );
  }
}
