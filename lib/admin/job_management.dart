import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';
import '../models/user.dart';
import '../services/job_service.dart';

class JobManagement extends StatefulWidget {
  const JobManagement({super.key});

  @override
  _JobManagementState createState() => _JobManagementState();
}

class _JobManagementState extends State<JobManagement> {
  final JobService _jobService = JobService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _editingJobId;
  DateTime? _jobDeadline;

  Future<void> _addJob() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showError('Title and Description cannot be empty.');
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
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showError('Title and Description cannot be empty.');
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

  void _clearFields() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _editingJobId = null;
      _jobDeadline = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Jobs')),
      body: Column(
        children: [
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
                          _addJob();
                        } else {
                          _updateJob(_editingJobId!);
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
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 5,
                      child: ListTile(
                        title: Text(job.title),
                        subtitle: Text(job.description),
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
