import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';
import '../models/user.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new job
  Future<void> addJob(Job job) async {
    try {
      DocumentReference docRef = await _firestore.collection('jobs').add(job.toMap());
      await docRef.update({'jobId': docRef.id});
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
      var snapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Error fetching applicants: $e');
    }
  }

  // Fetch the count of applicants for a specific job
  Future<int> fetchApplicantsCount(String jobId) async {
    try {
      var snapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error fetching applicants count: $e');
    }
  }

  // Add a new application
  Future<String> addApplication(Map<String, dynamic> applicationData) async {
    try {
      // Add the application and get the document reference
      var docRef = await _firestore.collection('applications').add(applicationData);

      // Return the document ID
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding application: $e');
    }
  }

  // Add a new user (admin or applicant)
  Future<void> addUser(User user) async {
    try {
      DocumentReference docRef = await _firestore.collection('users').add(user.toMap());
      await docRef.update({'userId': docRef.id});
    } catch (e) {
      throw Exception('Error adding user: $e');
    }
  }

  // Fetch users by role
  Future<List<User>> fetchUsers(String role) async {
    try {
      var snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();
      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // Search jobs by keywords
  Future<List<Job>> searchJobs(String keyword) async {
    try {
      var snapshot = await _firestore.collection('jobs')
          .where('title', isGreaterThanOrEqualTo: keyword)
          .where('title', isLessThanOrEqualTo: keyword + '\uf8ff') // For full-text search like behavior
          .get();
      return snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error searching jobs: $e');
    }
  }

  // Check if the user has already applied for the job
  Future<bool> hasApplied(String jobId, String userId) async {
    try {
      var snapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking if user has applied: $e');
    }
  }

  Future<void> updateApplicantStatus(String applicantId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications') // Assuming you store applications in a collection called 'applications'
          .doc(applicantId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Error updating applicant status: $e');
    }
  }
}
