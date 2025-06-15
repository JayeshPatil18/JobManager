import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/job.dart';
import '../user/job_detail.dart'; // Assuming your JobDetail page is in this location
import 'package:job_manager/services/job_service.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final String userId; // User ID passed to check if the user has applied

  const JobCard({super.key, required this.job, required this.userId});

  // Function to truncate the description to a specific number of words or lines
  String getTruncatedDescription(String description) {
    // Truncate the description to the first 30 words
    List<String> words = description.split(' ');
    if (words.length > 30) {
      return words.take(30).join(' ') + '...'; // Limit to 30 words and add ellipsis
    }
    return description; // If less than 30 words, return the entire description
  }

  @override
  Widget build(BuildContext context) {
    // Get the truncated description
    String truncatedDescription = getTruncatedDescription(job.description);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          job.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(truncatedDescription), // Display truncated description
            SizedBox(height: 8),
            FutureBuilder<bool>(
              future: JobService().hasApplied(job.jobId, userId), // Check if user has applied
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                bool hasApplied = snapshot.data ?? false;
                return Text(
                  hasApplied ? 'You have already applied' :
                  'Deadline: ${job.deadline != null ? DateFormat('yyyy-MM-dd').format(job.deadline!) : "No deadline"}',
                  style: TextStyle(color: hasApplied ? Colors.grey : Colors.red, fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
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
