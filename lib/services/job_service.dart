import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new job
  Future<void> addJob(Job job) async {
    try {
      await _firestore.collection('jobs').add(job.toMap());
    } catch (e) {
      throw Exception('Error adding job: $e');
    }
  }

  // Update an existing job
  Future<void> updateJob(String jobId, Job job) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update(job.toMap());
    } catch (e) {
      throw Exception('Error updating job: $e');
    }
  }

  // Delete a job
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      throw Exception('Error deleting job: $e');
    }
  }

  // Fetch all jobs
  Future<List<Job>> fetchJobs() async {
    try {
      var snapshot = await _firestore.collection('jobs').get();
      return snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching jobs: $e');
    }
  }

  // Fetch applicants for a specific job
  Future<List<Map<String, dynamic>>> fetchApplicants(String jobId) async {
    try {
      var snapshot = await _firestore.collection('jobs').doc(jobId).collection('applicants').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Error fetching applicants: $e');
    }
  }

  // Fetch the count of applicants for a specific job
  Future<int> fetchApplicantsCount(String jobId) async {
    try {
      var snapshot = await _firestore.collection('jobs').doc(jobId).collection('applicants').get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error fetching applicants count: $e');
    }
  }
}
