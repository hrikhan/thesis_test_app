import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/services/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MedicalApp());
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rural Medical Portal',
      debugShowCheckedModeBanner: false,

      // Theme settings
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Global bindings initialized on startup
      initialBinding: InitialBinding(),

      // Routing configuration
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
