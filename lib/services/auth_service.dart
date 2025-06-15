import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to login with email and password
  Future<String> loginWithEmailPassword(String email, String password) async {
    try {
      // Get all users and filter by email
      QuerySnapshot snapshot = await _firestore.collection('users').get();

        print('####### ${snapshot.docs}');

      // Iterate through the documents to check the email
      for (var userDoc in snapshot.docs) {


        if (userDoc['email'] == email) {
          String userId = userDoc['userId'];  // Fetch userId from the document
          String role = userDoc['role'];      // Fetch role from the document

          // Store userId and role in SharedPreferences
          await _storeUserData(userId, role);
          return 'Login successful';
        }
      }

      return 'User not found in database';  // If no user with that email exists
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  // Store userId and role in SharedPreferences
  Future<void> _storeUserData(String userId, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('role', role);
  }
}
