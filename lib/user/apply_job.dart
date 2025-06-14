import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';  // Import to use File from dart:io
import '../models/job.dart';
import '../services/storage_service.dart';

class ApplyJob extends StatefulWidget {
  final Job job;

  const ApplyJob({super.key, required this.job});

  @override
  _ApplyJobState createState() => _ApplyJobState();
}

class _ApplyJobState extends State<ApplyJob> {
  final TextEditingController _nameController = TextEditingController();
  late PlatformFile _resumeFile;

  Future<void> _submitApplication() async {
    if (_resumeFile != null) {
      // Convert PlatformFile to File
      File file = File(_resumeFile.path!);

      // Upload resume using the StorageService
      StorageService storageService = StorageService();
      String downloadURL = await storageService.uploadResume(file);

      print("Resume uploaded successfully: $downloadURL");

      // Add application details to Firestore (you can add that functionality here)
      // Example: save the application data in Firestore
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc']);
    if (result != null) {
      setState(() {
        _resumeFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Job')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Your Name')),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Choose Resume'),
            ),
            ElevatedButton(
              onPressed: _submitApplication,
              child: const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }
}
