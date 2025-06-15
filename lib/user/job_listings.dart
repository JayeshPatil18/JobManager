import 'package:flutter/material.dart';
import 'package:job_manager/services/job_service.dart';
import 'package:job_manager/models/job.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../widgets/job_card.dart';
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
  List<Job> _filteredJobs = [];
  bool _isLoading = true; // Loading state to display loading spinner
  bool _isSortedDescending = true; // Flag to toggle between ascending/descending sort
  String _sortingCriterion = 'Latest Uploaded'; // Default sorting criterion

  // Fetch all jobs initially
  void _fetchJobs() async {
    try {
      var jobs = await _jobService.fetchJobs();
      setState(() {
        _jobs = jobs;
        _filteredJobs = jobs; // Initially show all jobs
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching jobs: $e')));
    }
  }

  // Search jobs by keyword (filtering the already fetched list)
  void _searchJobs(String keyword) {
    setState(() {
      _isLoading = true; // Set loading to true while fetching data
    });

    // If the search field is empty, display all jobs
    if (keyword.isEmpty) {
      setState(() {
        _filteredJobs = _jobs;
        _isLoading = false;
      });
      return;
    }

    // Perform the search in memory (array search)
    var filteredJobs = _jobs.where((job) {
      return job.title.toLowerCase().contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      _filteredJobs = filteredJobs;
      _isLoading = false; // Set loading to false after fetching the data
    });
  }

  // Sort jobs by selected criterion (Latest Uploaded or Deadline)
  void _sortJobs() {
    setState(() {
      if (_sortingCriterion == 'Latest Uploaded') {
        _filteredJobs.sort((a, b) {
          if (_isSortedDescending) {
            return b.createdAt.compareTo(a.createdAt); // Descending
          } else {
            return a.createdAt.compareTo(b.createdAt); // Ascending
          }
        });
      } else if (_sortingCriterion == 'Deadline') {
        _filteredJobs.sort((a, b) {
          if (_isSortedDescending) {
            return (b.deadline ?? DateTime.now()).compareTo(a.deadline ?? DateTime.now()); // Descending
          } else {
            return (a.deadline ?? DateTime.now()).compareTo(b.deadline ?? DateTime.now()); // Ascending
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchJobs(); // Fetch all jobs on initial load
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
          padding: const EdgeInsets.all(6.0),
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
                  _searchJobs(value); // Call searchJobs method when the user types
                },
              ),
              const SizedBox(height: 16),

              // Sorting Label and Buttons
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Sort by: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _sortingCriterion,
                      items: <String>['Latest Uploaded', 'Deadline']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _sortingCriterion = value!;
                          _sortJobs(); // Re-sort the list when a new sorting option is selected
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isSortedDescending
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSortedDescending = !_isSortedDescending; // Toggle sorting order
                          _sortJobs(); // Re-sort the list when order is toggled
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Job List with Card Decoration
              _isLoading
                  ? Center(child: CircularProgressIndicator()) // Show loading spinner while data is being fetched
                  : Expanded(
                child: ListView.builder(
                  itemCount: _filteredJobs.length,
                  itemBuilder: (context, index) {
                    Job job = _filteredJobs[index];
                    return JobCard(
                      job: job,
                      userId: MyApp.loggedInUserId, // Pass userId to the JobCard widget
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
