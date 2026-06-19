import 'package:flutter/material.dart';

import '../../data/local_db/local_db.dart';
import '../../data/model/attendance_model.dart';
import '../../data/model/student_model.dart';

class FingerprintCaptureScreen extends StatefulWidget {
  final StudentModel student;
  final String photoPath;

  const FingerprintCaptureScreen({super.key, required this.student, required this.photoPath});

  @override
  State<FingerprintCaptureScreen> createState() => _FingerprintCaptureScreenState();
}

class _FingerprintCaptureScreenState extends State<FingerprintCaptureScreen> {
  bool isWaiting = true;
  String? fingerprintTemplate;

  @override
  void initState() {
    super.initState();
    waitForFingerprint();
  }

  Future<void> waitForFingerprint() async {
    await Future.delayed(const Duration(seconds: 4));

    // Demo SDK response
    fingerprintTemplate = "Rk1SACAyMAAAA_DEMO";

    await saveAttendance();

    setState(() {
      isWaiting = false;
    });
  }

  Future<void> saveAttendance() async {
    final attendance = AttendanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: widget.student.studentId,
      studentName: widget.student.name,
      className: widget.student.className,
      photoPath: widget.photoPath,
      fingerprintTemplate: fingerprintTemplate!,
      synced: false,
    );

    await LocalDb.instance.insertAttendance(attendance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fingerprint Capture")),
      body: Center(
        child: isWaiting
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 100),
                  const SizedBox(height: 20),
                  const Text("Saved Successfully"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text("Back To Home"),
                  ),
                ],
              ),
      ),
    );
  }
}
