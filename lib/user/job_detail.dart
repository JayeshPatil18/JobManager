import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_manager/services/job_service.dart';
import 'package:job_manager/models/job.dart';
import 'job_form.dart';

class JobDetail extends StatefulWidget {
  final Job job;
  final String userId;

  const JobDetail({super.key, required this.job, required this.userId});

  @override
  _JobDetailState createState() => _JobDetailState();
}

class _JobDetailState extends State<JobDetail> {
  bool _hasApplied = false;
  bool _isLoading = true; // Add a loading flag to manage the loading state

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
      _isLoading = false; // Set loading to false after fetching the data
    });
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
                _isLoading
                    ? Container(child: CircularProgressIndicator()) // Show loading spinner while checking
                    : ElevatedButton(
                  onPressed: _hasApplied
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobApplicationForm(
                          job: widget.job,
                          userId: widget.userId,
                        ),
                      ),
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
