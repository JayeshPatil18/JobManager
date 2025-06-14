import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io'; // To use File from dart:io

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload the resume file to Firebase Storage
  Future<String> uploadResume(File file) async {
    try {
      // Create a reference for the file to be stored in Firebase Storage
      final storageRef = _storage.ref().child('resumes/${file.uri.pathSegments.last}');

      // Upload the file
      await storageRef.putFile(file);

      // Get the download URL after the file is uploaded
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception("Failed to upload resume: $e");
    }
  }
}
