import 'package:flutter/material.dart';
import '../models/job.dart';
import 'apply_job.dart';

class JobDetail extends StatelessWidget {
  final Job job;

  const JobDetail({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.description, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApplyJob(job: job),
                  ),
                );
              },
              child: const Text('Apply Now'),
            ),
          ],
        ),
      ),
    );
  }
}
