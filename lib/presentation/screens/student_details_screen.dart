import 'package:flutter/material.dart';

import '../../data/model/student_model.dart';
import '../../data/service/permission_service.dart';
import 'face_capture_screen.dart';

class StudentDetailsScreen extends StatelessWidget {
  final StudentModel student;

  const StudentDetailsScreen({super.key, required this.student});

  Widget buildTile(String title, String value) {
    return Card(
      child: ListTile(title: Text(title), subtitle: Text(value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildTile("Student ID", student.studentId),
            buildTile("Name", student.name),
            buildTile("Class", student.className),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final granted = await PermissionService.requestCamera(context);

                if (!granted) return;

                Navigator.push(context, MaterialPageRoute(builder: (_) => FaceCaptureScreen(student: student)));
              },
              child: const Text("Proceed"),
            ),
          ],
        ),
      ),
    );
  }
}
