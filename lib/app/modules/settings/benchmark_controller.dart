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
    final networks = [
      {'name': '4G (Normal)', 'mult': 1.0},
      {'name': '3G (2x Slow)', 'mult': 2.0},
      {'name': '2G (4x Slow)', 'mult': 4.0},
    ];
    final sizes = ['Small', 'Medium', 'Large'];

    final totalTests = protocols.length * networks.length * sizes.length;
    int completed = 0;

    for (var proto in protocols) {
      for (var net in networks) {
        for (var size in sizes) {
          final testName = '$proto on ${net['name']} [$size Payload]';
          currentTestName.value = testName;

          // Perform measurement using stopwatch
          final sw = Stopwatch()..start();
          double payloadSizeKB = 0.0;

          try {
            if (proto == 'REST') {
              final result = await _restService.fetchPatients(
                size.toLowerCase(),
              );
              // Calculate latency with mock network multiplier
              final baseLatency = result['latencyMs'] as int;
              final simulatedDelay =
                  (baseLatency * ((net['mult'] as double) - 1.0)).round();

              if (simulatedDelay > 0) {
                await Future.delayed(Duration(milliseconds: simulatedDelay));
              }

              payloadSizeKB = result['payloadSizeKB'] as double;
            } else {
              final result = await _graphqlService.fetchPatients(
                size.toLowerCase(),
              );
              final baseLatency = result['latencyMs'] as int;
              final simulatedDelay =
                  (baseLatency * ((net['mult'] as double) - 1.0)).round();

              if (simulatedDelay > 0) {
                await Future.delayed(Duration(milliseconds: simulatedDelay));
              }

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
              network: net['name'] as String,
              size: size,
              payloadKB: payloadSizeKB,
              latencyMs: elapsedMs,
            ),
          );

          completed++;
          progress.value = completed / totalTests;
        }
      }
    }

    currentTestName.value = 'Benchmark Completed Successfully!';
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
