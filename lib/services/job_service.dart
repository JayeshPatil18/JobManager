import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Job>> getJobs() async {
    var snapshot = await _firestore.collection('jobs').get();
    return snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
  }

  Future<void> addJob(Job job) async {
    await _firestore.collection('jobs').add(job.toMap());
  }
}
