import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String jobId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? deadline;

  Job({
    required this.jobId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.deadline,
  });

  // Convert Firestore document to Job object
  factory Job.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now(); // Fallback to now if no valid date
    }

    DateTime? deadline;
    if (data['deadline'] is Timestamp) {
      deadline = (data['deadline'] as Timestamp).toDate();
    }

    return Job(
      jobId: data['jobId'] ?? doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: createdAt,
      deadline: deadline,
    );
  }

  // Convert Job object to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
    };
  }
}
