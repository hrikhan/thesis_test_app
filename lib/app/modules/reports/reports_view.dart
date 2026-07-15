import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shared_widgets/loading_shimmer.dart';
import '../shared_widgets/medical_card.dart';
import 'reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Interactive Payload Selectors
            Text(
              'Mock Payload Size Simulator',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final latency = controller.lastLatencyMs.value;
              final size = controller.lastPayloadSizeKB.value;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.12),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPayloadOption('Small', '5KB', theme),
                        _buildPayloadOption('Medium', '200KB', theme),
                        _buildPayloadOption('Large', '1.5MB', theme),
                      ],
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Latency: ${latency}ms',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Payload size: ${size.toStringAsFixed(2)} KB',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Telemetry loader shimmer or actual views
            Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmerView();
              }

              if (controller.reports.isEmpty) {
                return const Center(child: Text('No reports loaded.'));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SMALL DATA LIST (Recent Summaries)
                  Text(
                    '1. Recent Reports Summary (Small List)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.reports.length > 3
                        ? 3
                        : controller.reports.length,
                    itemBuilder: (context, index) {
                      final r = controller.reports[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Date: ${r.date} • ${r.patientName}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: r.status.toLowerCase() == 'completed'
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.orange.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                r.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: r.status.toLowerCase() == 'completed'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // 2. MEDIUM CARDS (Diagnostic Categories)
                  Text(
                    '2. Categorized Diagnostics (Medium Cards)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.4,
                        ),
                    itemCount: controller.reports.length > 4
                        ? 4
                        : controller.reports.length,
                    itemBuilder: (context, index) {
                      final r = controller.reports[index];
                      return MedicalCard(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    r.category,
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              r.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Result: ${r.resultValue}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // 3. LARGE TABLE (Scrollable Table)
                  Text(
                    '3. Detailed Records (Large Scrollable Table)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            theme.primaryColor.withOpacity(0.06),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Report ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Test Title',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Patient Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Category',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ResultValueColumn(),
                            DataColumn(
                              label: Text(
                                'Ref Range',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Technician Notes',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: controller.reports.map((r) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    r.id,
                                    style: const TextStyle(
                                      fontFamily: 'Courier',
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataCell(Text(r.title)),
                                DataCell(Text(r.patientName)),
                                DataCell(Text(r.category)),
                                DataCell(
                                  Text(
                                    r.resultValue,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataCell(Text(r.referenceRange)),
                                DataCell(Text(r.technician, maxLines: 1)),
                                DataCell(Text(r.status)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPayloadOption(String label, String sizeStr, ThemeData theme) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => controller.fetchReports(size: label.toLowerCase()),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(label),
        ),
        const SizedBox(height: 4),
        Text(sizeStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildShimmerView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LoadingShimmer(width: 250, height: 20),
        const SizedBox(height: 10),
        const LoadingShimmer(
          width: double.infinity,
          height: 60,
          borderRadius: 12,
        ),
        const SizedBox(height: 8),
        const LoadingShimmer(
          width: double.infinity,
          height: 60,
          borderRadius: 12,
        ),
        const SizedBox(height: 28),
        const LoadingShimmer(width: 250, height: 20),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(
              child: LoadingShimmer(width: 150, height: 90, borderRadius: 16),
            ),
            SizedBox(width: 12),
            Expanded(
              child: LoadingShimmer(width: 150, height: 90, borderRadius: 16),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const LoadingShimmer(width: 250, height: 20),
        const SizedBox(height: 10),
        const LoadingShimmer(
          width: double.infinity,
          height: 180,
          borderRadius: 16,
        ),
      ],
    );
  }
}

// Separate stateless widget helper for the Result Value DataColumn
class ResultValueColumn extends DataColumn {
  const ResultValueColumn()
    : super(
        label: const Text(
          'Result Value',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
}
