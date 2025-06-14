import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String name;
  final String email;
  final String role; // admin or applicant
  final String password; // hashed password
  final String field; // applicant's field of expertise (optional for admin)
  final DateTime createdAt;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.password,
    required this.field,
    required this.createdAt,
  });

  // Convert Firestore document to User object
  factory User.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return User(
      userId: data['userId'] ?? doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      password: data['password'] ?? '',
      field: data['field'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert User object to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'password': password, // Store hashed password
      'field': field,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
