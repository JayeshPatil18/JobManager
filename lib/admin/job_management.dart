import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this for opening links
import '../models/job.dart';
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

  // Method to open a URL (LinkedIn, GitHub, Resume)
  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showError('Could not open the link');
    }
  }

  // Bottom sheet to show applicant details
  void _showApplicantBottomSheet(Map<String, dynamic> applicant) {
    // Ensure the applicant's status is one of the valid values
    String applicantStatus = applicant['status'] ?? 'Pending';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(applicant['name'], style: Theme.of(context).textTheme.headline6),
              const SizedBox(height: 12),
              Text('Resume: ${applicant['resumeURL']}',
                  style: Theme.of(context).textTheme.bodyText2),
              const SizedBox(height: 8),
              Text('LinkedIn: ${applicant['linkedinURL']}',
                  style: Theme.of(context).textTheme.bodyText2),
              Text('GitHub: ${applicant['githubURL']}',
                  style: Theme.of(context).textTheme.bodyText2),
              const SizedBox(height: 16),

              // Status dropdown for updating the status
              Text('Update Status:', style: Theme.of(context).textTheme.subtitle1),
              const SizedBox(height: 8),
              // DropdownButton<String>(
              //   value: applicantStatus, // Use the applicant's current status
              //   isExpanded: true,
              //   items: <String>['Pending', 'Interviewed', 'Rejected', 'Hired']
              //       .map((String value) {
              //     return DropdownMenuItem<String>(
              //       value: value,
              //       child: Text(value),
              //     );
              //   }).toList(),
              //   onChanged: (newStatus) async {
              //     if (newStatus != null) {
              //       // Update the status in Firestore
              //       applicant['status'] = newStatus;
              //
              //       try {
              //         await _jobService.updateApplicantStatus(applicant['applicantId'], newStatus);
              //         setState(() {}); // Refresh the UI to reflect the changes
              //       } catch (e) {
              //         _showError('Error updating applicant status.');
              //       }
              //     }
              //   },
              // ),
              const SizedBox(height: 16),

              // Buttons to open LinkedIn, GitHub, and Resume
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _openUrl(applicant['linkedinURL']),
                    child: const Text('Open LinkedIn'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _openUrl(applicant['githubURL']),
                    child: const Text('Open GitHub'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _openUrl(applicant['resumeURL']),
                    child: const Text('Open Resume'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Jobs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Job title and description inputs
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Job Description',
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
                              _showApplicantBottomSheet(applicants[0]);
                            } else {
                              _showError('No applicants yet.');
                            }
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
    );
  }
}
