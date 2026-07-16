import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/services/graphql_service.dart';
import '../../data/services/rest_api_service.dart';

class BenchmarkResult {
  final String protocol;
  final String network;
  final String size;
  final double payloadKB;
  final int latencyMs;

  BenchmarkResult({
    required this.protocol,
    required this.network,
    required this.size,
    required this.payloadKB,
    required this.latencyMs,
  });
}

class BenchmarkController extends GetxController {
  final RestApiService _restService = Get.find<RestApiService>();
  final GraphqlService _graphqlService = Get.find<GraphqlService>();

  final RxList<BenchmarkResult> results = <BenchmarkResult>[].obs;
  final RxBool isBenchmarking = false.obs;
  final RxDouble progress = 0.0.obs;
  final RxString currentTestName = ''.obs;

  Future<void> runFullSuite() async {
    isBenchmarking.value = true;
    progress.value = 0.0;
    results.clear();

    final protocols = ['REST', 'GraphQL'];
    final iterations = 30; // 30 times as required for your thesis experiment!
    final totalTests = protocols.length * iterations;
    int completed = 0;

    for (var proto in protocols) {
      for (int i = 1; i <= iterations; i++) {
        final testName = '$proto - Iteration $i [Small Payload]';
        currentTestName.value = testName;

        final sw = Stopwatch()..start();
        double payloadSizeKB = 0.0;

        try {
          if (proto == 'REST') {
            final result = await _restService.fetchPatients('small');
            // Adding a tiny delay so the UI updates and requests don't overlap too aggressively
            await Future.delayed(const Duration(milliseconds: 50));
            payloadSizeKB = result['payloadSizeKB'] as double;
          } else {
            final result = await _graphqlService.fetchPatients('small');
            await Future.delayed(const Duration(milliseconds: 50));
            payloadSizeKB = result['payloadSizeKB'] as double;
          }
        } catch (e) {
          // Log fallback error
        }

        sw.stop();
        final elapsedMs = sw.elapsedMilliseconds;

        results.add(
          BenchmarkResult(
            protocol: proto,
            network: 'Iteration $i',
            size: 'Small',
            payloadKB: payloadSizeKB,
            latencyMs: elapsedMs,
          ),
        );

        completed++;
        progress.value = completed / totalTests;
      }
    }

    currentTestName.value = 'Experiment Data Collected! (60 total requests)';
    isBenchmarking.value = false;
  }

  String get resultsCsv {
    final buffer = StringBuffer();
    buffer.writeln('Protocol,NetworkType,PayloadClass,PayloadSizeKB,LatencyMs');
    for (var r in results) {
      buffer.writeln(
        '${r.protocol},${r.network},${r.size},${r.payloadKB.toStringAsFixed(2)},${r.latencyMs}',
      );
    }
    return buffer.toString();
  }

  Future<void> copyCsvToClipboard() async {
    await Clipboard.setData(ClipboardData(text: resultsCsv));
    Get.snackbar(
      'Export Completed',
      'Benchmark results copied to clipboard in CSV format!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
