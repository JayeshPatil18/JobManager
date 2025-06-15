import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:job_manager/user/job_listings.dart';

import 'admin/admin_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Manager',
      theme: customTheme,
      initialRoute: '/admin_login',
      routes: {
        '/admin_login': (context) => const AdminLogin(),
        '/job_listings': (context) => const JobListings(),
      },
    );
  }
}

final ThemeData customTheme = ThemeData(
  colorScheme: ColorScheme(
    primary: Color(0xFFC26CF3),
    secondary: Color(0xFFF99BFF),
    background: Color(0xFFF5E8FF),
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Color(0xFFF5E8FF),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFFC26CF3),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF8752D1),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFF333333)),
    titleLarge: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
  ),
  useMaterial3: true,
);