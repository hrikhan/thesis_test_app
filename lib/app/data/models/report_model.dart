class MedicalReport {
  final String id;
  final String title;
  final String patientName;
  final String category;
  final String date;
  final String status;
  final String resultValue;
  final String referenceRange;
  final String technician;

  MedicalReport({
    required this.id,
    required this.title,
    required this.patientName,
    required this.category,
    required this.date,
    required this.status,
    required this.resultValue,
    required this.referenceRange,
    required this.technician,
  });

  factory MedicalReport.fromJson(Map<String, dynamic> json) {
    return MedicalReport(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      patientName: json['patientName'] ?? '',
      category: json['category'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'Pending',
      resultValue: json['resultValue'] ?? '',
      referenceRange: json['referenceRange'] ?? '',
      technician: json['technician'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'patientName': patientName,
      'category': category,
      'date': date,
      'status': status,
      'resultValue': resultValue,
      'referenceRange': referenceRange,
      'technician': technician,
    };
  }
}
