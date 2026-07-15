import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/app_controller.dart';
import '../patients/patients_controller.dart';
import '../shared_widgets/loading_shimmer.dart';
import '../shared_widgets/medical_card.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final PatientsController patientsController =
        Get.find<PatientsController>();
    final AppController appController = Get.find<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Dashboard'),
        actions: [
          Obx(() {
            final isGql = appController.apiMode.value == ApiMode.graphql;
            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isGql
                    ? const Color(0xffe1f5fe)
                    : const Color(0xffefebe9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isGql
                      ? const Color(0xff03a9f4)
                      : const Color(0xff8d6e63),
                  width: 0.8,
                ),
              ),
              child: Text(
                isGql ? 'GraphQL' : 'REST API',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isGql
                      ? const Color(0xff0288d1)
                      : const Color(0xff5d4037),
                ),
              ),
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.simulateLoad('small'),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Welcome Back, Doctor',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here is the daily overview for your clinic.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // STATS SECTION (Uses Shimmer Loading)
              Obx(() {
                if (controller.isLoading) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: const [
                      LoadingShimmer(width: 150, height: 110),
                      LoadingShimmer(width: 150, height: 110),
                      LoadingShimmer(width: 150, height: 110),
                      LoadingShimmer(width: 150, height: 110),
                    ],
                  );
                }

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.25,
                  children: [
                    MedicalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xff1976d2,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.people_alt_rounded,
                                  color: Color(0xff1976d2),
                                  size: 20,
                                ),
                              ),
                              Text(
                                '${controller.totalPatients}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: const Color(0xff1976d2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Total Patients',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MedicalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xffd32f2f,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xffd32f2f),
                                  size: 20,
                                ),
                              ),
                              Text(
                                '${controller.criticalCases}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: const Color(0xffd32f2f),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Critical Cases',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MedicalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xff2e7d32,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.health_and_safety_rounded,
                                  color: Color(0xff2e7d32),
                                  size: 20,
                                ),
                              ),
                              Text(
                                '${controller.stableCases}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: const Color(0xff2e7d32),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Stable Cases',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MedicalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xffe65100,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.assignment_turned_in_rounded,
                                  color: Color(0xffe65100),
                                  size: 20,
                                ),
                              ),
                              Text(
                                '12',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: const Color(0xffe65100),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Reports Pending',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 28),

              // SIMULATION TELEMETRY BOX
              Text(
                'Live Connection Telemetry',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                final latency = patientsController.lastLatencyMs.value;
                final size = patientsController.lastPayloadSizeKB.value;
                final endpoint = patientsController.lastEndpoint.value;
                final query = patientsController.lastQuery.value;
                final netName = appController.networkName;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.light
                        ? Colors.grey.shade900
                        : const Color(0xff1a1a1a),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTelemetryRow(
                        context,
                        'Endpoint:',
                        endpoint.isEmpty ? 'None' : endpoint,
                        Colors.greenAccent,
                      ),
                      _buildTelemetryRow(
                        context,
                        'Network Mock:',
                        netName,
                        Colors.amberAccent,
                      ),
                      _buildTelemetryRow(
                        context,
                        'Latency Delay:',
                        '${latency}ms',
                        Colors.cyanAccent,
                      ),
                      _buildTelemetryRow(
                        context,
                        'JSON Payload:',
                        '${size.toStringAsFixed(2)} KB',
                        Colors.pinkAccent,
                      ),
                      if (query.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 8),
                        const Text(
                          'GraphQL Body:',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            query,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              color: Colors.lightGreenAccent,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: 28),

              // SIMULATED PAYLOAD TRIGGERS
              Text(
                'Simulate API Payload Size',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Test shimmers and latency by changing mock size.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildSimulateButton(
                    context: context,
                    label: 'Load Small Payload (Fast)',
                    subtitle: 'Payload: ~5KB | Latency: 200ms',
                    color: Colors.green,
                    icon: Icons.bolt,
                    onPressed: () => controller.simulateLoad('small'),
                  ),
                  const SizedBox(height: 12),
                  _buildSimulateButton(
                    context: context,
                    label: 'Load Medium Payload',
                    subtitle: 'Payload: ~200KB | Latency: 800ms',
                    color: Colors.orange,
                    icon: Icons.speed,
                    onPressed: () => controller.simulateLoad('medium'),
                  ),
                  const SizedBox(height: 12),
                  _buildSimulateButton(
                    context: context,
                    label: 'Load Large Payload (Heavy)',
                    subtitle: 'Payload: ~1.5MB | Latency: 1500ms',
                    color: Colors.red,
                    icon: Icons.hourglass_bottom,
                    onPressed: () => controller.simulateLoad('large'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryRow(
    BuildContext context,
    String title,
    String value,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Courier',
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Courier',
                color: valueColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulateButton({
    required BuildContext context,
    required String label,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff222222) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.brightness == Brightness.light
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
