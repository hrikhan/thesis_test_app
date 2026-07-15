import 'package:flutter/material.dart';
import '../../data/models/patient_model.dart';
import 'status_badge.dart';

class PatientTile extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientTile({super.key, required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.light
                ? Colors.black.withOpacity(0.03)
                : Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.brightness == Brightness.light
              ? Colors.grey.shade100
              : Colors.grey.shade800,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Avatar representation with gender coloring
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getGenderBgColor(patient.gender),
                  child: Text(
                    patient.name.isNotEmpty
                        ? patient.name[0].toUpperCase()
                        : 'P',
                    style: TextStyle(
                      color: _getGenderTextColor(patient.gender),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Patient Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${patient.age} yrs • ${patient.gender} • ${patient.condition}',
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status Badge
                StatusBadge(status: patient.status),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: theme.brightness == Brightness.light
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGenderBgColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return const Color(0xffe3f2fd); // Soft blue
      case 'female':
        return const Color(0xfffce4ec); // Soft pink
      default:
        return const Color(0xffede7f6); // Soft purple
    }
  }

  Color _getGenderTextColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return const Color(0xff1565c0); // Dark blue
      case 'female':
        return const Color(0xffc2185b); // Dark pink
      default:
        return const Color(0xff5e35b1); // Dark purple
    }
  }
}
