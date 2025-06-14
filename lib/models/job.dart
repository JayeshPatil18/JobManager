import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  // Convert Firestore document to Job object
  factory Job.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    // Handle 'createdAt' field being either Timestamp or String
    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      createdAt = DateTime.tryParse(data['createdAt']) ?? DateTime.now();  // Fallback to now if invalid
    } else {
      createdAt = DateTime.now();  // Default to current date if no valid date
    }

    return Job(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: createdAt,
    );
  }

  // Convert Job object to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),  // Store as Timestamp
    };
  }
}
