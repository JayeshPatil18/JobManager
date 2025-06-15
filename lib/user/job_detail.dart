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
  bool _hasApplied = false;

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
    if (_resumeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a resume URL')));
      return;
    }

    try {
      await JobService().addApplication({
        'jobId': widget.job.jobId,
        'userId': widget.userId,
        'resumeURL': _resumeController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.job.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(widget.job.description, style: const TextStyle(fontSize: 18)),
            const Spacer(),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Enter Resume URL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _resumeController,
                            decoration: const InputDecoration(
                              labelText: 'Resume URL',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _applyForJob,
                              child: const Text('Submit Application'),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                );
              },
              child: _hasApplied ? const Text('You have already applied') : const Text('Apply Now'),
            ),
          ],
        ),
      ),
    );
  }
}
