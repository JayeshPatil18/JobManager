import 'package:flutter/material.dart';
import 'package:job_manager/services/job_service.dart';
import 'package:job_manager/models/job.dart';
import '../services/auth_service.dart';
import 'job_detail.dart'; // To navigate to job details and apply

class JobListings extends StatefulWidget {
  const JobListings({super.key});

  @override
  _JobListingsState createState() => _JobListingsState();
}

class _JobListingsState extends State<JobListings> {
  final JobService _jobService = JobService();
  final LoginService _loginService = LoginService();

  final TextEditingController _searchController = TextEditingController();
  List<Job> _jobs = [];
  String _userId = 'user_id_123'; // Assume this is fetched from shared preferences or Firebase

  // Search jobs by keyword
  void _searchJobs() async {
    String keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      var jobs = await _jobService.searchJobs(keyword);
      setState(() {
        _jobs = jobs;
      });
    } else {
      // If the search field is empty, fetch all jobs
      var jobs = await _jobService.fetchJobs();
      setState(() {
        _jobs = jobs;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchJobs(); // Load all jobs on initial load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 10),
            Text('Jobs Listing'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Jobs',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Job List
            Expanded(
              child: ListView.builder(
                itemCount: _jobs.length,
                itemBuilder: (context, index) {
                  Job job = _jobs[index];
                  return FutureBuilder<bool>(
                    future: _jobService.hasApplied(job.jobId, _userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      bool hasApplied = snapshot.data ?? false;

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
                          trailing: hasApplied
                              ? const Chip(label: Text('Applied'))
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobDetail(job: job, userId: _userId),
                              ),
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
      ),
    );
  }
}
