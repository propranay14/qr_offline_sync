import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_offline_sync/presentation/screens/student_details_screen.dart';

import '../../data/model/student_model.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Student QR")),
      body: MobileScanner(
        onDetect: (capture) {
          if (isScanned) return;

          final barcode = capture.barcodes.first;
          final qrValue = barcode.rawValue;

          if (qrValue != null) {
            isScanned = true;

            if (kDebugMode) {
              print("QR value: $qrValue");
            }
            final student = StudentModel.fromQr(qrValue);

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StudentDetailsScreen(student: student)));
          }
        },
      ),
    );
  }
}
