import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_offline_sync/core/widgets/custom_cta_button.dart';

import '../../core/service/mantra_service.dart';
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
  static const MethodChannel _channel = MethodChannel("mantra_mfs100");

  bool isWaiting = true;
  String status = "Place your finger on the scanner...";
  String? fingerprintTemplate;

  @override
  void initState() {
    super.initState();
    captureFingerprint();
  }

  Future<void> captureFingerprint() async {
    try {
      await MantraService.initialize();

      final result = await MantraService.capture();

      fingerprintTemplate = result["template"];

      final session = await SessionManager.getLoginSession();
      if (session == null) return;

      final username = session.userInfo.username;

      await LocalDb.instance.updateCandidateFingerprint(widget.candidate.id, fingerprintTemplate!, username);

      setState(() {
        isWaiting = false;
        status = "Fingerprint captured successfully";
      });
    } on PlatformException catch (e) {
      if (!mounted) return;

      setState(() {
        isWaiting = false;
        status = e.message ?? "Capture failed";
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isWaiting = false;
        status = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fingerprint Capture", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: isWaiting
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 100),
                  const SizedBox(height: 20),
                  Text(status, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: CustomCtaButton(
                      text: "Done",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
