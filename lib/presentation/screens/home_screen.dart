import 'package:flutter/material.dart';
import 'package:qr_offline_sync/core/widgets/custom_cta_button.dart';
import 'package:qr_offline_sync/presentation/screens/qr_scanner_screen.dart';
import 'package:qr_offline_sync/presentation/screens/student_details_screen.dart';

import '../../data/local_db/local_db.dart';
import '../../data/model/student_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StudentModel> students = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initStudents();
  }

  Future<void> initStudents() async {
    await LocalDb.instance.insertDummyStudents();
  }

  Future<void> searchStudent() async {
    final result = await LocalDb.instance.searchStudent(searchController.text);

    setState(() {
      students = result;
    });
  }

  Future<void> scanQr() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => QRScannerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Student")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Enter Application Number",
                suffixIcon: IconButton(onPressed: searchStudent, icon: const Icon(Icons.search)),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text("Or")),
            const SizedBox(height: 20),
            CustomCtaButton(onPressed: scanQr, text: "Scan QR"),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];

                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailsScreen(student: student)));
                      },
                      title: Text("${student.firstName} ${student.lastName}"),
                      subtitle: Text(student.applicationNumber),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
