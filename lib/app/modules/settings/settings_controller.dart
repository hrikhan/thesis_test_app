import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/app_controller.dart';

class SettingsController extends GetxController {
  final AppController _appController = Get.find<AppController>();

  // Expose fields as reactive or read from AppController
  ApiMode get apiMode => _appController.apiMode.value;
  NetworkType get networkType => _appController.networkType.value;
  bool get isDarkMode => _appController.themeMode.value == ThemeMode.dark;

  void toggleApiMode(bool isGraphQL) {
    _appController.toggleApiMode(isGraphQL);
  }

  void changeNetworkType(NetworkType type) {
    _appController.setNetworkType(type);
  }

  void toggleTheme(bool isDark) {
    _appController.toggleTheme(isDark);
  }
}
