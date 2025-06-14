import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';

class JobManagement extends StatefulWidget {
  const JobManagement({super.key});

  @override
  _JobManagementState createState() => _JobManagementState();
}

class _JobManagementState extends State<JobManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add a new job
  Future<void> _addJob() async {
    try {
      await _firestore.collection('jobs').add({
        'title': 'New Job',
        'description': 'Job description...',
        'createdAt': Timestamp.now(),  // Store current timestamp
      });
    } catch (e) {
      print("Error adding job: $e");
      // Optionally, you could show a snackbar or alert here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Jobs')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _addJob,
            child: const Text('Add Job'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('jobs').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Parse the job documents into Job objects
                var jobs = snapshot.data!.docs
                    .map((doc) => Job.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(jobs[index].title),
                      subtitle: Text(jobs[index].description),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
