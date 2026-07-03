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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Candidate not found")));

      setState(() {
        isScanned = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const scanSize = 280.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan candidate QR", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          /// Camera Preview
          MobileScanner(
            onDetect: (capture) async {
              if (isScanned) return;

              final barcode = capture.barcodes.first;
              final qrValue = barcode.rawValue;

              if (qrValue != null) {
                setState(() => isScanned = true);

                if (kDebugMode) {
                  print("QR: $qrValue");
                }

                await handleQrScan(qrValue);
              }
            },
          ),

          /// Top Gradient
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 280,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black, Colors.transparent]),
                ),
              ),
            ),
          ),

          /// Bottom Gradient
          IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent]),
                ),
              ),
            ),
          ),

          /// Corner Borders
          Center(
            child: SizedBox(
              width: scanSize,
              height: scanSize,
              child: Stack(
                children: [
                  _corner(top: true, left: true),
                  _corner(top: true, right: true),
                  _corner(bottom: true, left: true),
                  _corner(bottom: true, right: true),
                ],
              ),
            ),
          ),

          /// Instruction
          Positioned(
            bottom: 110,
            left: 24,
            right: 24,
            child: Column(children: const [Icon(Icons.qr_code_scanner, color: Colors.white70, size: 34)]),
          ),
        ],
      ),
    );
  }

  Widget _corner({bool top = false, bool bottom = false, bool left = false, bool right = false}) {
    return Positioned(
      top: top ? 0 : null,
      bottom: bottom ? 0 : null,
      left: left ? 0 : null,
      right: right ? 0 : null,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          border: Border(
            top: top ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 5) : BorderSide.none,
            bottom: bottom ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 5) : BorderSide.none,
            left: left ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 5) : BorderSide.none,
            right: right ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 5) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? const Radius.circular(18) : Radius.zero,
            topRight: top && right ? const Radius.circular(18) : Radius.zero,
            bottomLeft: bottom && left ? const Radius.circular(18) : Radius.zero,
            bottomRight: bottom && right ? const Radius.circular(18) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
