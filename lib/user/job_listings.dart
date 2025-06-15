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
        backgroundColor: Colors.deepPurple,
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_dashboard.jpg"), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar with styling
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Jobs',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7), // Light background for search bar
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  _searchJobs();
                },
              ),
              const SizedBox(height: 16),
              // Job List with Card Decoration
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
                            title: Text(
                              job.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              job.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54),
                            ),
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
      ),
    );
  }
}
