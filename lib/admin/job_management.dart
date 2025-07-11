import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_manager/admin/applicant_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening links
import '../models/job.dart';
import '../services/auth_service.dart';
import '../services/job_service.dart';

class JobManagement extends StatefulWidget {
  const JobManagement({super.key});

  @override
  _JobManagementState createState() => _JobManagementState();
}

class _JobManagementState extends State<JobManagement> {
  final JobService _jobService = JobService();
  final LoginService _loginService = LoginService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _editingJobId;
  DateTime? _jobDeadline;

  Future<void> _addJob() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _jobDeadline == null) {
      _showError('Title, Description, and Deadline are required.');
      return;
    }

    Job job = Job(
      jobId: '',
      title: _titleController.text,
      description: _descriptionController.text,
      createdAt: DateTime.now(),
      deadline: _jobDeadline,
    );

    try {
      await _jobService.addJob(job);
      _clearFields();
    } catch (e) {
      _showError('Error adding job. Please try again later.');
    }
  }

  Future<void> _updateJob(String jobId) async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _jobDeadline == null) {
      _showError('Title, Description, and Deadline are required.');
      return;
    }

    Job job = Job(
      jobId: jobId,
      title: _titleController.text,
      description: _descriptionController.text,
      createdAt: DateTime.now(),
      deadline: _jobDeadline,
    );

    try {
      await _jobService.updateJob(jobId, job);
      _clearFields();
    } catch (e) {
      _showError('Error updating job. Please try again later.');
    }
  }

  Future<void> _deleteJob(String jobId) async {
    try {
      await _jobService.deleteJob(jobId);
    } catch (e) {
      _showError('Error deleting job. Please try again later.');
    }
  }

  Future<void> _selectDeadline() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _jobDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _jobDeadline = selectedDate;
      });
    }
  }

  Future<int> _fetchApplicantsCount(String jobId) async {
    return await _jobService.fetchApplicantsCount(jobId);
  }

  void _clearFields() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _editingJobId = null;
      _jobDeadline = null;
    });
  }

  // Method to open a URL (LinkedIn, GitHub, Resume)
  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showError('Could not open the link');
    }
  }

  void _showApplicantBottomSheet(List<Map<String, dynamic>> applicants) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Applicants:',
                style: Theme.of(context).textTheme.headline6?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),

              // List applicants with better UI
              Expanded(
                child: ListView.builder(
                  itemCount: applicants.length,
                  itemBuilder: (context, index) {
                    var applicant = applicants[index];

                    // Convert appliedAt timestamp to DateTime
                    var appliedAt = (applicant['appliedAt'] as Timestamp).toDate();

                    return GestureDetector(
                      onTap: () {
                        // Navigate to the applicant details page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApplicantDetailsPage(applicant: applicant),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // Border added here
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.deepPurple, // Border color
                              width: 1.5, // Border width
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              applicant['name'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('Phone: ${applicant['phone']}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('Applied At: ${appliedAt.toLocal()}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('Status: ${applicant['status']}'),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.deepPurple),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to show success message
  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Method to show error message
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // Consistent background color
        title: Row(
          children: [
            SizedBox(width: 10),
            Text('Manage Jobs'),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _loginService.handleLogout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_dashboard.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Job title and description inputs
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Job Title',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3), // very light white
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  maxLines: 8,
                  minLines: 2,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Job Description',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3), // very light white
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Select Deadline and buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _selectDeadline,
                      child: Text(_jobDeadline == null
                          ? 'Select Deadline (Required)'
                          : 'Deadline: ${_jobDeadline!.toLocal()}'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_editingJobId == null) {
                          _addJob();
                        } else {
                          _updateJob(_editingJobId!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_editingJobId == null ? 'Add Job' : 'Update Job'),
                    ),
                  ],
                ),
                if (_editingJobId != null)
                  ElevatedButton(
                    onPressed: () => _clearFields(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel Editing'),
                  ),
                const SizedBox(height: 16),
                // Job List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var jobs = snapshot.data!.docs
                          .map((doc) => Job.fromFirestore(doc))
                          .toList();

                      return ListView.builder(
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          var job = jobs[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              subtitle: Text(job.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                              trailing: FutureBuilder<int>(
                                future: _fetchApplicantsCount(job.jobId),
                                builder: (context, applicantSnapshot) {
                                  if (!applicantSnapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }
                                  return Chip(
                                    label: Text('${applicantSnapshot.data} Applicants'),
                                  );
                                },
                              ),
                              onTap: () async {
                                List<Map<String, dynamic>> applicants = await _jobService.fetchApplicants(job.jobId);
                                if (applicants.isNotEmpty) {
                                  // Show Bottom Sheet when an applicant is tapped
                                  _showApplicantBottomSheet(applicants);
                                } else {
                                  _showError('No applicants yet.');
                                }
                              },
                              // Added Edit and Delete Buttons
                              onLongPress: () {
                                // Show options to edit or delete job
                                _showJobOptionsDialog(job);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to show dialog for editing or deleting a job
  void _showJobOptionsDialog(Job job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Job Options'),
          content: const Text('Would you like to edit or delete this job?'),
          actions: [
            TextButton(
              child: const Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop();
                _editingJobId = job.jobId;
                _titleController.text = job.title;
                _descriptionController.text = job.description;
                setState(() {});
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteJob(job.jobId);
                _showSuccess('Job deleted successfully!');
              },
            ),
          ],
        );
      },
    );
  }
}
