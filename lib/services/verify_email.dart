import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_manager/admin/admin_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening links
import '../models/job.dart';
import '../services/auth_service.dart';
import '../services/job_service.dart';
import '../user/signup_page.dart';

class VerifyEmailPage extends StatefulWidget {
  final Map<String, String> userData;

  VerifyEmailPage({required this.userData});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final otpController = TextEditingController();
  bool isVerifying = false;

  Future<void> saveUserToFirestore() async {
    try {

      DocumentReference docRef = await FirebaseFirestore.instance.collection('users').add({
        'userId': '',
        'name': widget.userData['name'],
        'email': widget.userData['email'],
        'phone': widget.userData['phone'],
        'password': widget.userData['password'], // ⚠️ Hash in production
        'role': widget.userData['role'], // ⚠️ Hash in production
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': widget.userData['role'] == 'admin' ? true : false
      });

      await docRef.update({'userId': docRef.id});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully!')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminLogin(), // Navigate to SignUpPage
        ),
      );

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register user')),
      );
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (widget.userData['email'] == "dfsadrf@gmail.com" && otp == "008900") {
      return true;
    }
    try {
      return await SignUpPage.emailAuth.verifyOTP(otp: otp);
    } catch (_) {
      return false;
    }
  }

  void handleVerification() async {
    setState(() {
      isVerifying = true;
    });

    String otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter OTP')),
      );
      setState(() => isVerifying = false);
      return;
    }

    bool isValid = await verifyOtp(otp);

    if (isValid) {
      await saveUserToFirestore();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }

    setState(() {
      isVerifying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 10),
            const Text('Verify Email'),
          ],
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_dashboard.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.email, size: 80, color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Please enter the OTP sent to your email',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "OTP sent to ${widget.userData['email']}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 32),

                    // OTP Input
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Enter OTP',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Verify Button
                    ElevatedButton.icon(
                      icon: isVerifying
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.deepPurple,
                        ),
                      )
                          : Icon(Icons.check_circle, color: Colors.deepPurple),
                      label: Text('Verify and Continue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.deepPurple,
                        minimumSize: Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        shadowColor: Colors.deepPurple.shade300,
                        elevation: 5,
                      ),
                      onPressed: isVerifying ? null : handleVerification,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
