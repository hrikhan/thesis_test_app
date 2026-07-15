import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/patient_model.dart';
import '../shared_widgets/medical_card.dart';
import '../shared_widgets/status_badge.dart';

class PatientDetailsView extends StatefulWidget {
  const PatientDetailsView({super.key});

  @override
  State<PatientDetailsView> createState() => _PatientDetailsViewState();
}

class _PatientDetailsViewState extends State<PatientDetailsView> {
  // Collapsible panel status states
  bool _historyExpanded = true;
  bool _prescriptionsExpanded = true;
  bool _labReportsExpanded = true;
  bool _gqlSchemaExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Patient patient = Get.arguments as Patient;

    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Patient Card
            _buildPatientHeaderCard(patient, theme),
            const SizedBox(height: 20),

            // NOTES SECTION
            if (patient.notes != null && patient.notes!.isNotEmpty) ...[
              Text(
                'Clinical Observations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  patient.notes!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // EXPANDABLE SECTION: Medical History
            _buildExpandableSection(
              title: 'Medical History Records',
              icon: Icons.history_edu_rounded,
              isExpanded: _historyExpanded,
              onToggle: () =>
                  setState(() => _historyExpanded = !_historyExpanded),
              theme: theme,
              child: Column(
                children: patient.medicalHistory.isEmpty
                    ? [const Text('No recorded medical history.')]
                    : patient.medicalHistory.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // EXPANDABLE SECTION: Prescriptions
            _buildExpandableSection(
              title: 'Active Medication & Prescriptions',
              icon: Icons.medication_liquid_rounded,
              isExpanded: _prescriptionsExpanded,
              onToggle: () => setState(
                () => _prescriptionsExpanded = !_prescriptionsExpanded,
              ),
              theme: theme,
              child: patient.prescriptions.isEmpty
                  ? const Text('No active prescriptions.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: patient.prescriptions.length,
                      itemBuilder: (context, index) {
                        final pres = patient.prescriptions[index];
                        return Card(
                          color: theme.brightness == Brightness.light
                              ? Colors.grey.shade50
                              : const Color(0xff272727),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey.shade200.withOpacity(0.5),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.vaccines,
                              color: theme.colorScheme.secondary,
                            ),
                            title: Text(
                              pres['medication'] ?? 'Unknown Med',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('Dosage: ${pres['dosage'] ?? ''}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                pres['frequency'] ?? '',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // EXPANDABLE SECTION: Lab Reports
            _buildExpandableSection(
              title: 'Laboratory Diagnostic Reports',
              icon: Icons.science_outlined,
              isExpanded: _labReportsExpanded,
              onToggle: () =>
                  setState(() => _labReportsExpanded = !_labReportsExpanded),
              theme: theme,
              child: patient.labReports.isEmpty
                  ? const Text('No laboratory entries available.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: patient.labReports.length,
                      itemBuilder: (context, index) {
                        final lab = patient.labReports[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.science,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lab['test'] ?? 'Diagnostic Scan',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Checked: ${lab['date'] ?? 'N/A'}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                lab['result'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),

            // GRAPHQL DEEP RESOLVER DETAILS (Visual Indicator)
            _buildExpandableSection(
              title: 'Simulated GraphQL Node Schema',
              icon: Icons.hub_rounded,
              isExpanded: _gqlSchemaExpanded,
              onToggle: () =>
                  setState(() => _gqlSchemaExpanded = !_gqlSchemaExpanded),
              theme: theme,
              backgroundColor: theme.brightness == Brightness.light
                  ? Colors.grey.shade900
                  : const Color(0xff121212),
              titleColor: Colors.purpleAccent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This view parsed a nested GraphQL JSON graph representation:',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getMockGraphQLJSON(patient),
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        color: Colors.greenAccent,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeaderCard(Patient patient, ThemeData theme) {
    final bool isMale = patient.gender.toLowerCase() == 'male';
    final Color headerColor = isMale
        ? const Color(0xff1565c0)
        : const Color(0xffc2185b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: headerColor.withOpacity(0.1),
                child: Icon(
                  isMale ? Icons.face_retouching_natural : Icons.face,
                  color: headerColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Patient ID: ${patient.id.isEmpty ? 'TEMP-ID' : patient.id}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Courier',
                      ),
                    ),
                    Text(
                      '${patient.age} years old • ${patient.gender}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Condition',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                    Text(
                      patient.condition,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              StatusBadge(status: patient.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required ThemeData theme,
    required Widget child,
    Color? backgroundColor,
    Color? titleColor,
  }) {
    final boxBgColor = backgroundColor ?? theme.colorScheme.surface;
    final isDarkBackground = boxBgColor.computeLuminance() < 0.3;

    return Container(
      decoration: BoxDecoration(
        color: boxBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDarkBackground)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
        border: Border.all(
          color: isDarkBackground ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: titleColor ?? theme.primaryColor),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    titleColor ??
                    (isDarkBackground ? Colors.white : Colors.black87),
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: isDarkBackground ? Colors.grey : Colors.grey.shade600,
            ),
            onTap: onToggle,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(width: double.infinity, child: child),
            ),
        ],
      ),
    );
  }

  String _getMockGraphQLJSON(Patient p) {
    return '''
{
  "data": {
    "patient": {
      "id": "${p.id}",
      "name": "${p.name}",
      "gender": "${p.gender}",
      "medicalHistory": ${p.medicalHistory.map((s) => '"$s"').toList()},
      "prescriptions": [
        ${p.prescriptions.map((m) => '{\n          "medication": "${m['medication']}",\n          "dosage": "${m['dosage']}",\n          "frequency": "${m['frequency']}"\n        }').join(',\n        ')}
      ],
      "labReports": [
        ${p.labReports.map((m) => '{\n          "test": "${m['test']}",\n          "result": "${m['result']}",\n          "date": "${m['date']}"\n        }').join(',\n        ')}
      ]
    }
  }
}
''';
  }
}
