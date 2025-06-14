import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job.dart';
import '../services/storage_service.dart';

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

  // Method to add a new job
  Future<void> _addJob() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      return; // Validation for empty fields
    }

    try {
      await _firestore.collection('jobs').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'createdAt': Timestamp.now(),
      });
      _clearFields();
    } catch (e) {
      print("Error adding job: $e");
    }
  }

  // Method to update an existing job
  Future<void> _updateJob(String jobId) async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      return; // Validation for empty fields
    }

    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
      });
      _clearFields();
    } catch (e) {
      print("Error updating job: $e");
    }
  }

  // Method to delete a job
  Future<void> _deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      print("Error deleting job: $e");
    }
  }

  // Method to fetch the applicants for a specific job
  Future<List<Map<String, dynamic>>> _fetchApplicants(String jobId) async {
    var snapshot = await _firestore.collection('jobs').doc(jobId).collection('applicants').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Method to clear the text fields
  void _clearFields() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _editingJobId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Jobs')),
      body: Column(
        children: [
          // Job form (Add/Edit)
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _editingJobId = job.id;
                                  _titleController.text = job.title;
                                  _descriptionController.text = job.description;
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
                                      subtitle: Text(applicant['resumeURL']),
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
