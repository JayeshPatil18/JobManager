import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'job_detail.dart';
import '../models/job.dart';

class JobListings extends StatefulWidget {
  const JobListings({super.key});

  @override
  _JobListingsState createState() => _JobListingsState();
}

class _JobListingsState extends State<JobListings> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Listings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('jobs').snapshots(),
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
              return ListTile(
                title: Text(jobs[index].title),
                subtitle: Text(jobs[index].description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetail(job: jobs[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
