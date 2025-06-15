import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_manager/services/auth_service.dart';
import 'package:job_manager/user/job_listings.dart';
import 'package:job_manager/user/signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'job_management.dart'; // Import the job management screen

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedRole = 'admin'; // Default role is admin

  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();  // Check if the user is already logged in
  }

  // Function to handle login
  Future<void> _login(String loginAs) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        final LoginService _loginService = LoginService();

        String result = await _loginService.loginWithEmailPassword(
            _emailController.text, _passwordController.text, loginAs);

        if(result.contains('Login successful')) {

          if(result.contains('admin')) {
            // Navigate to job management screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const JobManagement()),
            );
          } else if (result.contains('applicant')){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const JobListings()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result)),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Check if the user is already logged in
  Future<void> _checkUserLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? role = prefs.getString('role'); // Retrieve the role

    if (userId != null && role != null) {
      // User is already logged in
      // Navigate to the appropriate screen based on the role

      print('###${role}');

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JobManagement()),
        );
      } else if (role == 'applicant') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JobListings()), // Update with the applicant's screen
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.deepPurple, // Consistent background color
          title: const Text('Welcome to Jober')
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_dashboard.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 10,
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey, // Connect the form key here
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Login',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const SizedBox(height: 20),
                            // Dropdown for selecting role (Admin or Applicant)
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              onChanged: (newRole) {
                                setState(() {
                                  _selectedRole = newRole!;
                                });
                              },
                              items: [
                                DropdownMenuItem(
                                  value: 'admin',
                                  child: Text('Login as Admin'),
                                ),
                                DropdownMenuItem(
                                  value: 'applicant',
                                  child: Text('Login as Applicant'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Select Role',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.account_circle),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Email input
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                } else if (!value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Password input
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            // Login button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _login(_selectedRole), // Pass the selected role here
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Login'),
                              ),
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpPage(), // Navigate to SignUpPage
                        ),
                      );
                    },
                    child: Text('Signup as Applicant'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
