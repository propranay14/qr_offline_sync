import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_offline_sync/data/model/student_model.dart';

import 'face_capture_screen.dart';
import 'fingerprint_capture_screen.dart';

class StudentDetailsScreen extends StatefulWidget {
  final StudentModel student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  String? updatedPhotoPath;
  String? updatedBiometric;

  @override
  Widget build(BuildContext context) {
    final student = widget.student;

    return Scaffold(
      appBar: AppBar(title: const Text("Student Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Profile Photo
            CircleAvatar(
              radius: 70,
              backgroundImage: updatedPhotoPath != null
                  ? FileImage(File(updatedPhotoPath!))
                  : student.profilePhoto.isNotEmpty
                  ? FileImage(File(student.profilePhoto))
                  : null,
              child: updatedPhotoPath == null && student.profilePhoto.isEmpty ? const Icon(Icons.person, size: 70) : null,
            ),

            const SizedBox(height: 24),

            /// Student Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    detailRow("First Name", student.firstName),
                    detailRow("Father Name", student.fatherName),
                    detailRow("Last Name", student.lastName),
                    detailRow("Application Number", student.applicationNumber),
                    detailRow("Biometric", updatedBiometric ?? (student.biometricData.isNotEmpty ? "Available" : "Not Available")),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Update Photo Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => FaceCaptureScreen(student: student)));

                  if (result != null) {
                    setState(() {
                      updatedPhotoPath = result;
                    });
                  }
                },
                child: const Text("Update Photo"),
              ),
            ),

            const SizedBox(height: 16),

            /// Update Biometric Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FingerprintCaptureScreen(student: student, photoPath: updatedPhotoPath ?? ""),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      updatedBiometric = result;
                    });
                  }
                },
                child: const Text("Update Biometric"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(flex: 6, child: Text(value)),
        ],
      ),
    );
  }
}
