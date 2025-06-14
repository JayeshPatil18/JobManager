import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';

class JobManagement extends StatefulWidget {
  const JobManagement({super.key});

  @override
  _JobManagementState createState() => _JobManagementState();
}

class _JobManagementState extends State<JobManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controller for creating or editing job title and description
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Variable to keep track of which job is being edited
  String? _editingJobId;
  DateTime? _jobDeadline;

  // Method to add a new job
  Future<void> _addJob() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showError('Title and Description cannot be empty.');
      return;
    }

    try {
      await _firestore.collection('jobs').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'createdAt': Timestamp.now(),
        'deadline': _jobDeadline != null ? Timestamp.fromDate(_jobDeadline!) : null,
      });
      _clearFields();
    } catch (e) {
      print("Error adding job: $e");
      _showError('Error adding job. Please try again later.');
    }
  }

  // Method to update an existing job
  Future<void> _updateJob(String jobId) async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showError('Title and Description cannot be empty.');
      return;
    }

    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'deadline': _jobDeadline != null ? Timestamp.fromDate(_jobDeadline!) : null,
      });
      _clearFields();
    } catch (e) {
      print("Error updating job: $e");
      _showError('Error updating job. Please try again later.');
    }
  }

  // Method to delete a job
  Future<void> _deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      print("Error deleting job: $e");
      _showError('Error deleting job. Please try again later.');
    }
  }

  // Method to fetch the applicants for a specific job
  Future<List<Map<String, dynamic>>> _fetchApplicants(String jobId) async {
    var snapshot = await _firestore.collection('jobs').doc(jobId).collection('applicants').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Method to fetch the count of applicants for a specific job
  Future<int> _fetchApplicantsCount(String jobId) async {
    try {
      var snapshot = await _firestore.collection('jobs').doc(jobId).collection('applicants').get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error fetching applicants count: $e');
    }
  }

  // Method to show error dialog
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

  // Method to clear the text fields
  void _clearFields() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _editingJobId = null;
      _jobDeadline = null;
    });
  }

  // Show date picker for the job deadline
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Jobs')),
      body: Column(
        children: [
          // Job form (Add/Edit)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Job Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Job Description'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _selectDeadline,
                      child: Text(_jobDeadline == null
                          ? 'Select Deadline'
                          : 'Deadline: ${_jobDeadline!.toLocal()}'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_editingJobId == null) {
                          _addJob();  // Add new job
                        } else {
                          _updateJob(_editingJobId!);  // Update existing job
                        }
                      },
                      child: Text(_editingJobId == null ? 'Add Job' : 'Update Job'),
                    ),
                  ],
                ),
                if (_editingJobId != null)
                  ElevatedButton(
                    onPressed: () => _clearFields(),
                    child: const Text('Cancel Editing'),
                  ),
              ],
            ),
          ),

          // StreamBuilder to display the list of jobs
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('jobs').snapshots(),
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
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 5,
                      child: ListTile(
                        title: Text(job.title),
                        subtitle: Text(job.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FutureBuilder<int>(
                              future: _fetchApplicantsCount(job.id),
                              builder: (context, applicantSnapshot) {
                                if (!applicantSnapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                return Chip(
                                  label: Text('${applicantSnapshot.data} Applicants'),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _editingJobId = job.id;
                                  _titleController.text = job.title;
                                  _descriptionController.text = job.description;
                                  _jobDeadline = job.deadline;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteJob(job.id),
                            ),
                          ],
                        ),
                        onTap: () async {
                          // Fetch and show the applicants when a job is tapped
                          List<Map<String, dynamic>> applicants = await _fetchApplicants(job.id);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Applicants'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: applicants.isNotEmpty
                                      ? applicants.map((applicant) {
                                    return ListTile(
                                      title: Text(applicant['name']),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('LinkedIn: ${applicant['linkedinURL']}'),
                                          Text('GitHub: ${applicant['githubURL']}'),
                                          Text('Status: ${applicant['status']}'),
                                        ],
                                      ),
                                    );
                                  }).toList()
                                      : [const Text('No applicants yet')],
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Close'),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            },
                          );
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
    );
  }
}
