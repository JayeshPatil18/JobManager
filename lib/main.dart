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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/admin_login',
      routes: {
        '/admin_login': (context) => const AdminLogin(),
        '/job_listings': (context) => const JobListings(),
      },
    );
  }
}
