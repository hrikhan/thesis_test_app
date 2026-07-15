import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/patient_model.dart';

enum ApiMode { rest, graphql }

enum NetworkType { net2G, net3G, net4G }

class AppController extends GetxController {
  final Rx<ApiMode> apiMode = ApiMode.rest.obs;
  final Rx<NetworkType> networkType = NetworkType.net4G.obs;
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  // Thesis Offline-first simulation states
  final RxBool localCacheEnabled = false.obs;
  final RxList<Patient> localDatabase =
      <Patient>[].obs; // Mock local SQLite/Hive DB
  final RxList<Patient> syncQueue =
      <Patient>[].obs; // Patients created while offline waiting to sync

  void toggleLocalCache(bool enabled) {
    localCacheEnabled.value = enabled;
  }

  void toggleApiMode(bool isGraphQL) {
    apiMode.value = isGraphQL ? ApiMode.graphql : ApiMode.rest;
  }

  void setNetworkType(NetworkType type) {
    networkType.value = type;
  }

  void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
  }

  // Get current multiplier for latency based on network speed simulation
  double get latencyMultiplier {
    switch (networkType.value) {
      case NetworkType.net2G:
        return 4.0; // 4x slower
      case NetworkType.net3G:
        return 2.0; // 2x slower
      case NetworkType.net4G:
        return 1.0; // Normal speed
    }
  }

  String get networkName {
    switch (networkType.value) {
      case NetworkType.net2G:
        return '2G (Low Speed)';
      case NetworkType.net3G:
        return '3G (Medium Speed)';
      case NetworkType.net4G:
        return '4G (High Speed)';
    }
  }
}
