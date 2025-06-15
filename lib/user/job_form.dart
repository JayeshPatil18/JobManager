import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_manager/services/job_service.dart';
import 'package:job_manager/models/job.dart';

class JobApplicationForm extends StatefulWidget {
  final Job job;
  final String userId;

  const JobApplicationForm({super.key, required this.job, required this.userId});

  @override
  _JobApplicationFormState createState() => _JobApplicationFormState();
}

class _JobApplicationFormState extends State<JobApplicationForm> {
  final TextEditingController _resumeController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _noticePeriodController = TextEditingController();
  final TextEditingController _counterOfferController = TextEditingController();

  bool _hasApplied = false;
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
    _fetchUserData(); // Fetch user data when the page is initialized
  }

  // Check if the user has already applied
  void _checkIfApplied() async {
    bool hasApplied = await JobService().hasApplied(widget.job.jobId, widget.userId);
    setState(() {
      _hasApplied = hasApplied;
    });
  }

  // Fetch user data from Firestore based on userId and autofill the fields
  void _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;

        setState(() {
          // Autofill all the required fields
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _emailController.text = data['email'] ?? '';
          _homeAddressController.text = data['homeAddress'] ?? '';
          _resumeController.text = data['resumeURL'] ?? '';
          _coverLetterController.text = data['coverLetter'] ?? '';
          _linkedinController.text = data['linkedinURL'] ?? '';
          _githubController.text = data['githubURL'] ?? '';
          _noticePeriodController.text = data['noticePeriod'] ?? '';
          _counterOfferController.text = data['counterOffer'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching user data: $e')));
    }
  }


  // Submit application
  void _applyForJob() async {
    if (_formKey.currentState!.validate()) {
      try {
        await JobService().addApplication({
          'jobId': widget.job.jobId,
          'userId': widget.userId,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'homeAddress': _homeAddressController.text,
          'resumeURL': _resumeController.text,
          'coverLetter': _coverLetterController.text,
          'linkedinURL': _linkedinController.text,
          'githubURL': _githubController.text,
          'noticePeriod': _noticePeriodController.text,
          'counterOffer': _counterOfferController.text,
          'status': 'pending',
          'appliedAt': Timestamp.now(),
        });

        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'homeAddress': _homeAddressController.text,
          'resumeURL': _resumeController.text,
          'coverLetter': _coverLetterController.text,
          'linkedinURL': _linkedinController.text,
          'githubURL': _githubController.text,
          'noticePeriod': _noticePeriodController.text,
          'counterOffer': _counterOfferController.text,
        });

        setState(() {
          _hasApplied = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application submitted')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to apply: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white), // White icon
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 10),
            Text(
              'Job Application Form',
              style: TextStyle(color: Colors.white), // White title text color
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple, // Consistent background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Connect the form key for validation
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter Your Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildTextField(_nameController, 'Name', Icons.person),
                _buildTextField(_phoneController, 'Phone Number', Icons.phone),
                _buildTextField(_emailController, 'Email Address', Icons.email),
                _buildTextField(_homeAddressController, 'Home Address', Icons.home),
                _buildTextField(_resumeController, 'Resume URL', Icons.attach_file),
                _buildTextField(_linkedinController, 'LinkedIn URL', Icons.link),
                _buildTextField(_githubController, 'GitHub URL', Icons.code),
                _buildTextField(_coverLetterController, 'Cover Letter URL', Icons.code),
                _buildTextField(_noticePeriodController, 'Notice Period', Icons.access_time),
                _buildTextField(_counterOfferController, 'Counter Offer (Optional)', Icons.edit),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyForJob,
                    child: const Text('Submit Application'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepPurple, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build text fields
  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }
}
