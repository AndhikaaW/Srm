import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:srm_v1/components/internet.dart';
import 'package:srm_v1/screens/dashboardScreen.dart';

import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Get.put(InternetController(), permanent: true);
    runApp(MyApp());
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SRM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DashboardScreen(),
    );
  }
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'SRM',
  //     theme: ThemeData(
  //       colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  //       useMaterial3: true,
  //     ),
  //     home: DashboardScreen(),
  //   );
  // }
}