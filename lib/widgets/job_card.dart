import 'package:flutter/material.dart';
import '../models/job.dart';
import '../user/job_detail.dart'; // Assuming your JobDetail page is in this location
import 'package:job_manager/services/job_service.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final String userId; // User ID passed to check if the user has applied

  const JobCard({super.key, required this.job, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          job.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(job.description),
        trailing: FutureBuilder<bool>(
          future: JobService().hasApplied(job.jobId, userId), // Check if user has applied
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            bool hasApplied = snapshot.data ?? false;

            return IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                // If already applied, disable the "Apply" action
                if (!hasApplied) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetail(job: job, userId: userId),
                    ),
                  );
                } else {
                  // If already applied, show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You have already applied for this job')),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
