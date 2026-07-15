import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/app_controller.dart';
import '../../routes/app_routes.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppController appController = Get.find<AppController>();

    return Scaffold(
      appBar: AppBar(title: const Text('System Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode Section
            Text(
              'Appearance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
              final isDark = appController.themeMode.value == ThemeMode.dark;
              return Card(
                elevation: 0,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.amber : Colors.blueGrey,
                  ),
                  title: const Text('Dark Mode Theme'),
                  subtitle: Text(
                    isDark
                        ? 'Sleek dark hospital workspace theme'
                        : 'Clean white bright clinic theme',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Switch(
                    value: isDark,
                    onChanged: controller.toggleTheme,
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Connection Simulation Section
            Text(
              'API & Networking Simulation',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // API MODE TOGGLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'API Engine Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Obx(() {
                            final isGql =
                                appController.apiMode.value == ApiMode.graphql;
                            return Text(
                              isGql
                                  ? 'GraphQL Query-Mutation Resolvers'
                                  : 'RESTful URL Endpoints',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            );
                          }),
                        ],
                      ),
                      Obx(() {
                        final isGql =
                            appController.apiMode.value == ApiMode.graphql;
                        return Switch(
                          value: isGql,
                          onChanged: controller.toggleApiMode,
                          activeColor: Colors.purpleAccent,
                        );
                      }),
                    ],
                  ),
                  const Divider(height: 32),

                  // NETWORK SPEED TOGGLE
                  Text(
                    'Simulated Network Speed Type',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Scales latency delays: 2G (4x slow) | 3G (2x slow) | 4G (normal)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Segmented control for 2G/3G/4G
                  Obx(() {
                    final currentNet = appController.networkType.value;
                    return SegmentedButton<NetworkType>(
                      segments: const <ButtonSegment<NetworkType>>[
                        ButtonSegment<NetworkType>(
                          value: NetworkType.net2G,
                          label: Text('2G'),
                        ),
                        ButtonSegment<NetworkType>(
                          value: NetworkType.net3G,
                          label: Text('3G'),
                        ),
                        ButtonSegment<NetworkType>(
                          value: NetworkType.net4G,
                          label: Text('4G'),
                        ),
                      ],
                      selected: <NetworkType>{currentNet},
                      onSelectionChanged: (Set<NetworkType> newSelection) {
                        if (newSelection.isNotEmpty) {
                          controller.changeNetworkType(newSelection.first);
                        }
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: theme.primaryColor.withOpacity(
                          0.15,
                        ),
                        selectedForegroundColor: theme.primaryColor,
                      ),
                    );
                  }),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Offline SQLite/Hive Cache',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Obx(() {
                            final cacheEnabled =
                                appController.localCacheEnabled.value;
                            final queueCount = appController.syncQueue.length;
                            return Text(
                              cacheEnabled
                                  ? 'Active (Local DB, $queueCount queued records)'
                                  : 'Inactive (Direct online calls)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            );
                          }),
                        ],
                      ),
                      Obx(() {
                        return Switch(
                          value: appController.localCacheEnabled.value,
                          onChanged: appController.toggleLocalCache,
                          activeColor: Colors.orange,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Thesis Telemetry Tools
            Text(
              'Thesis Performance Analysis',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.analytics_rounded,
                  color: theme.primaryColor,
                ),
                title: const Text('Performance Benchmark Suite'),
                subtitle: const Text(
                  'Automated latency comparison & copy CSV dataset tool',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.toNamed(Routes.BENCHMARK),
              ),
            ),
            const SizedBox(height: 24),

            // Diagnostic System Info
            Text(
              'System Diagnostics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light
                    ? Colors.grey.shade100
                    : const Color(0xff222222),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Environment: Production Simulation',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Framework: Flutter 3.x & GetX 4.x',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    return Text(
                      'API Sync Target: ${appController.apiMode.value == ApiMode.graphql ? "GQL Schema Model" : "REST JSON Endpoint"}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
