import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:job_manager/services/verify_email.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  static EmailOTP emailAuth = EmailOTP();
  static String verify = "";

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isButtonClicked = false;

  Future<bool> sendOtp(String email) async {
    SignUpPage.emailAuth.setConfig(
      appEmail: "jp7470484@gmail.com",
      appName: "Booking",
      userEmail: email,
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );

    return await SignUpPage.emailAuth.sendOTP();
  }

  Future<bool> isEmailAlreadyRegistered(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: 'owner')
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    String email = emailController.text.trim();

    // Check for duplicate account
    if (await isEmailAlreadyRegistered(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email is already registered. Please use another.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool isOtpSent = await sendOtp(email);

    if (isOtpSent) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP has been sent!'),
          backgroundColor: Colors.green,
        ),
      );

      final userData = {
        'name': nameController.text.trim(),
        'email': email,
        'phone': phoneController.text.trim(),
        'password': passwordController.text.trim(),
        'role': 'applicant'
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailPage(userData: userData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oops, OTP send failed!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Set the back button color to white
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(
              'Booking App',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_dashboard.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sign Up',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Please enter your name' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                        value == null || !value.contains('@') ? 'Please enter a valid email' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                        value == null || value.length < 10 ? 'Please enter a valid phone number' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) =>
                        value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!isButtonClicked) {
                              isButtonClicked = true;
                              await handleSignUp();
                              isButtonClicked = false;
                            }
                          },
                          child: Text('Create Account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
