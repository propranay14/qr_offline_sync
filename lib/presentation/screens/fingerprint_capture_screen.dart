import 'package:flutter/material.dart';
import 'package:qr_offline_sync/core/widgets/custom_cta_button.dart';

import '../../core/storage/session_manager.dart';
import '../../data/local_db/local_db.dart';
import '../../data/model/fetch_candidates_response_model.dart';

class FingerprintCaptureScreen extends StatefulWidget {
  final CandidateModel candidate;
  final String photoPath;

  const FingerprintCaptureScreen({super.key, required this.candidate, required this.photoPath});

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

    final operatorId = await SessionManager.getOperatorId();

    await LocalDb.instance.updateCandidateFingerprint(widget.candidate.id, fingerprintTemplate ?? "", operatorId);
    setState(() {
      isWaiting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fingerprint Capture"), automaticallyImplyLeading: false),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                    child: CustomCtaButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      text: "Done",
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
