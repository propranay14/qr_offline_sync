import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_offline_sync/core/widgets/custom_cta_button.dart';

import '../../data/local_db/local_db.dart';
import '../../data/model/fetch_candidates_response_model.dart';
import 'face_capture_screen.dart';
import 'fingerprint_capture_screen.dart';

class CandidateDetailsScreen extends StatefulWidget {
  CandidateModel candidate;

  CandidateDetailsScreen({super.key, required this.candidate});

  @override
  State<CandidateDetailsScreen> createState() => _CandidateDetailsScreenState();
}

class _CandidateDetailsScreenState extends State<CandidateDetailsScreen> {
  String? updatedPhotoPath;
  String? updatedBiometric;

  Future<void> refreshCandidate() async {
    final latest = await LocalDb.instance.getCandidateByApplicationID(widget.candidate.applicationNumber);

    if (latest != null) {
      setState(() {
        widget.candidate = latest;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidate;

    return Scaffold(
      appBar: AppBar(title: const Text("Candidate Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Profile Photo
            CircleAvatar(
              radius: 70,
              backgroundImage: updatedPhotoPath != null
                  ? FileImage(File(updatedPhotoPath!))
                  : candidate.photoPath != null && candidate.photoPath!.isNotEmpty
                  ? FileImage(File(candidate.photoPath!))
                  : null,
              child: updatedPhotoPath == null && (candidate.photoPath == null || candidate.photoPath!.isEmpty)
                  ? const Icon(Icons.person, size: 70)
                  : null,
            ),

            const SizedBox(height: 10),

            /// Candidate Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  detailRow("Roll Number", candidate.rollNumber),
                  detailRow("Application Number", candidate.applicationNumber),
                  detailRow("First Name", candidate.candidateName),
                  detailRow("Father Name", candidate.fatherName ?? ""),
                  detailRow("Mother Name", candidate.motherName ?? ""),
                  detailRow("Gender", candidate.gender),
                  detailRow("Mobile No.", candidate.mobileNo ?? ""),
                  detailRow("Email", candidate.email ?? ""),
                  detailRow("Biometric", updatedBiometric ?? (candidate.fingerprintTemplate != null ? "Available" : "Not Available")),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// Update Photo Button
            SizedBox(
              width: double.infinity,
              child: CustomCtaButton(
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => FaceCaptureScreen(candidate: candidate)));

                  if (result != null) {
                    setState(() {
                      updatedPhotoPath = result;
                    });
                    await refreshCandidate();
                  }
                },
                text: "Update Photo",
              ),
            ),

            const SizedBox(height: 16),

            /// Update Biometric Button
            SizedBox(
              width: double.infinity,
              child: CustomCtaButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FingerprintCaptureScreen(candidate: candidate, photoPath: updatedPhotoPath ?? ""),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      updatedBiometric = result;
                    });
                    await refreshCandidate();
                  }
                },
                text: "Update Biometric",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
