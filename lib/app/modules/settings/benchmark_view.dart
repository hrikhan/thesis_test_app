import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'benchmark_controller.dart';

class BenchmarkView extends StatelessWidget {
  const BenchmarkView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.put(BenchmarkController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Benchmark'),
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
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.primaryColor.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: theme.primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Empirical Thesis Diagnostic Tools',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'This benchmarking utility evaluates and records the exact network latency, bandwidth consumption, and parse-efficiency differences between REST and GraphQL endpoints across 2G, 3G, and 4G mock network layers.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Controls Block
            Obx(() {
              final active = controller.isBenchmarking.value;
              final progress = controller.progress.value;
              final testName = controller.currentTestName.value;

              return Column(
                children: [
                  if (active) ...[
                    LinearProgressIndicator(
                      value: progress,
                      borderRadius: BorderRadius.circular(8),
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Running: $testName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}% Completed',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => controller.runFullSuite(),
                            icon: const Icon(Icons.play_circle_fill),
                            label: const Text('Run Test Suite'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        if (controller.results.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => controller.copyCsvToClipboard(),
                              icon: const Icon(Icons.copy_all),
                              label: const Text('Copy CSV Logs'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: 24),

            // Results Section
            Obx(() {
              if (controller.results.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.rule, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        const Text(
                          'No Results Available',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const Text(
                          'Click "Run Test Suite" to generate diagnostics.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Measured Latency Comparison Grid',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Table wrapper
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            theme.primaryColor.withOpacity(0.06),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Protocol',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Network Speed',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Payload Size',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actual KB',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Latency (ms)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: controller.results.map((r) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    r.protocol,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: r.protocol == 'GraphQL'
                                          ? Colors.purple
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                                DataCell(Text(r.network)),
                                DataCell(Text(r.size)),
                                DataCell(
                                  Text('${r.payloadKB.toStringAsFixed(1)} KB'),
                                ),
                                DataCell(
                                  Text(
                                    '${r.latencyMs} ms',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Analysis Card
                  _buildAnalysisCard(controller.results, theme),
                ],
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(List<BenchmarkResult> list, ThemeData theme) {
    final restList = list.where((r) => r.protocol == 'REST').toList();
    final gqlList = list.where((r) => r.protocol == 'GraphQL').toList();

    double restAvg = 0.0;
    double gqlAvg = 0.0;

    if (restList.isNotEmpty) {
      restAvg =
          restList.map((r) => r.latencyMs).reduce((a, b) => a + b) /
          restList.length;
    }
    if (gqlList.isNotEmpty) {
      gqlAvg =
          gqlList.map((r) => r.latencyMs).reduce((a, b) => a + b) /
          gqlList.length;
    }

    final isGqlFaster = gqlAvg < restAvg;
    final percentDiff = restAvg > 0
        ? (((restAvg - gqlAvg).abs() / restAvg) * 100).round()
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.grey.shade100
            : const Color(0xff222222),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparative Telemetry Analytics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('REST Average Latency:', style: theme.textTheme.bodyMedium),
              Text(
                '${restAvg.round()} ms',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GraphQL Average Latency:',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${gqlAvg.round()} ms',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            isGqlFaster
                ? 'Under current conditions, GraphQL resolvers executed ~$percentDiff% faster than standard RESTful endpoints due to payload payload size optimization.'
                : 'Under current conditions, REST endpoints executed ~$percentDiff% faster due to lack of query schema validation overheads.',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
