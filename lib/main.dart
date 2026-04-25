import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/about_controller.dart';
import 'package:school_management_system/controllers/admit_card_controller.dart';
import 'package:school_management_system/controllers/attendance_controller.dart';
import 'package:school_management_system/controllers/compositeMarksheetController.dart';
import 'package:school_management_system/controllers/notes_controller.dart';
import 'package:school_management_system/controllers/noticeController.dart';
import 'package:school_management_system/controllers/singleMarksheetController.dart';
import 'package:school_management_system/controllers/student_fee_controller.dart';
import 'controllers/theme_controller.dart';
import 'package:school_management_system/splashscreen.dart';
import 'package:school_management_system/authentication_screens/signin.dart'; 
import 'theme/app_theme.dart';
import 'services/auth_service.dart';

void main() async {
  // Required for async calls before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Check login status here to decide the initial screen
  bool loggedIn = await AuthService().isLoggedIn();

  // Theme controller can be registered eagerly
  Get.put(ThemeController());

  // Data controllers registered lazily
  Get.lazyPut(() => AdmitCardController());
  Get.lazyPut(() => AttendanceController());
  Get.lazyPut(() => CompositeMarksheetController());
  Get.lazyPut(() => MarksheetController());
  Get.lazyPut(() => NoticesController());
  Get.lazyPut(() => StudentFeeController());
  Get.lazyPut(() => AboutController());
  Get.lazyPut(() => NotesController());

  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KI SMS',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        home: isLoggedIn ? const SplashScreen() : const SigninScreen(),
      ),
    );
  }
}


