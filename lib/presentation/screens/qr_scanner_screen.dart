import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_offline_sync/presentation/screens/candidate_details_screen.dart';

import '../../data/local_db/local_db.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanned = false;

  Future<void> handleQrScan(String qrValue) async {
    final candidate = await LocalDb.instance.getCandidateByApplicationID(qrValue);

    if (!mounted) return;

    if (candidate != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CandidateDetailsScreen(candidate: candidate)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("candidate not found")));

      setState(() {
        isScanned = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan candidate QR")),
      body: MobileScanner(
        onDetect: (capture) async {
          if (isScanned) return;

          /// Scan a QR which return candidate ID i.e. 1132
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
