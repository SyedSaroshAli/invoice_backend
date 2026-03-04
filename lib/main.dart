import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/admit_card_controller.dart';
import 'package:school_management_system/controllers/attendance_controller.dart';
import 'package:school_management_system/controllers/compositeMarksheetController.dart';
import 'package:school_management_system/controllers/noticeController.dart';
import 'package:school_management_system/controllers/singleMarksheetController.dart';
import 'package:school_management_system/controllers/student_fee_controller.dart';
import 'controllers/theme_controller.dart';
import 'package:school_management_system/splashscreen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Theme controller can be registered eagerly (no API calls)
  Get.put(ThemeController());

  // Data controllers registered lazily — they should NOT auto-fetch on init
  // They will fetch data when the user navigates to them (after login)
  Get.lazyPut(() => AdmitCardController());
  Get.lazyPut(() => AdmitCardController());
  Get.lazyPut(() => AttendanceController());
  Get.lazyPut(() => CompositeMarksheetController());
  Get.lazyPut(() => MarksheetController());
  Get.lazyPut(() => NoticesController());
  Get.lazyPut(() => StudentFeeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'School Management System',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        home: const SplashScreen(),
      ),
    );
  }
}
