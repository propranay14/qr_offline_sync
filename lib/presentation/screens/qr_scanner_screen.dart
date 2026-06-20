import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_offline_sync/presentation/screens/student_details_screen.dart';

import '../../data/local_db/local_db.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanned = false;

  Future<void> handleQrScan(String qrValue) async {
    final student = await LocalDb.instance.getStudentByApplicationNumber(qrValue);

    if (!mounted) return;

    if (student != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StudentDetailsScreen(student: student)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student not found")));

      setState(() {
        isScanned = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Student QR")),
      body: MobileScanner(
        onDetect: (capture) async {
          if (isScanned) return;

          final barcode = capture.barcodes.first;
          final qrValue = barcode.rawValue;

          if (qrValue != null) {
            setState(() {
              isScanned = true;
            });

            if (kDebugMode) {
              print("QR value: $qrValue");
            }

            await handleQrScan(qrValue);
          }
        },
      ),
    );
  }
}
