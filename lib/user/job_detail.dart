import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_manager/services/job_service.dart';
import 'package:job_manager/models/job.dart';

class JobDetail extends StatefulWidget {
  final Job job;
  final String userId;

  const JobDetail({super.key, required this.job, required this.userId});

  @override
  _JobDetailState createState() => _JobDetailState();
}

class _JobDetailState extends State<JobDetail> {
  final TextEditingController _resumeController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  bool _hasApplied = false;
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
  }

  // Check if the user has already applied
  void _checkIfApplied() async {
    bool hasApplied = await JobService().hasApplied(widget.job.jobId, widget.userId);
    setState(() {
      _hasApplied = hasApplied;
    });
  }

  // Submit application
  void _applyForJob() async {
    if (_formKey.currentState!.validate()) {
      try {
        await JobService().addApplication({
          'jobId': widget.job.jobId,
          'userId': widget.userId,
          'name': _nameController.text,
          'resumeURL': _resumeController.text,
          'coverLetter': _coverLetterController.text,
          'linkedinURL': _linkedinController.text,
          'githubURL': _githubController.text,
          'status': 'pending',
          'appliedAt': Timestamp.now(),
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
              'Job Detail',
              style: TextStyle(color: Colors.white), // White title text color
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple, // Consistent background color
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_dashboard.jpg"), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Details in a Beautiful Card
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.job.description,
                          style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _hasApplied
                      ? null
                      : () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            top: 24,
                            left: 16,
                            right: 16,
                          ),
                          child: Form(
                            key: _formKey, // Connect the form key for validation
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Enter Resume URL, Cover Letter, LinkedIn, and GitHub',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _resumeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Resume URL',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.attach_file),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please provide your resume URL';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _coverLetterController,
                                  decoration: const InputDecoration(
                                    labelText: 'Cover Letter',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.text_fields),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please provide a cover letter';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _linkedinController,
                                  decoration: const InputDecoration(
                                    labelText: 'LinkedIn URL',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.link),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please provide your LinkedIn URL';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _githubController,
                                  decoration: const InputDecoration(
                                    labelText: 'GitHub URL',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.code),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please provide your GitHub URL';
                                    }
                                    return null;
                                  },
                                ),
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
                        );
                      },
                    );
                  },
                  child: _hasApplied ? const Text('You have already applied') : const Text('Apply Now'),
                  style: ElevatedButton.styleFrom(
                    primary: _hasApplied ? Colors.grey : Colors.deepPurple, // Disabled state
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
