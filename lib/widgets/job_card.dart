import 'package:flutter/material.dart';
import '../models/job.dart';
import '../user/job_detail.dart';

class JobCard extends StatelessWidget {
  final Job job;

  const JobCard({super.key, required this.job});

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
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetail(job: job),
              ),
            );
          },
        ),
      ),
    );
  }
}
