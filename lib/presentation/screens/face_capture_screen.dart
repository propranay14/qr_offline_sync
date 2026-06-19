import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../data/model/student_model.dart';
import 'fingerprint_capture_screen.dart';

class FaceCaptureScreen extends StatefulWidget {
  final StudentModel student;

  const FaceCaptureScreen({super.key, required this.student});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? controller;
  XFile? capturedImage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);

    controller = CameraController(frontCamera, ResolutionPreset.high, enableAudio: false);

    await controller!.initialize();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> captureImage() async {
    if (controller == null || !controller!.value.isInitialized) return;

    final image = await controller!.takePicture();

    setState(() {
      capturedImage = image;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Capture Face")),
      body: Column(
        children: [
          Expanded(
            child: capturedImage == null
                ? AspectRatio(aspectRatio: controller!.value.aspectRatio, child: CameraPreview(controller!))
                : Image.file(File(capturedImage!.path), fit: BoxFit.cover, width: double.infinity),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (capturedImage == null) {
                      captureImage();
                    } else {
                      setState(() {
                        capturedImage = null;
                      });
                    }
                  },
                  child: Text(capturedImage == null ? "Capture" : "Retake"),
                ),
                const SizedBox(height: 10),
                if (capturedImage != null)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FingerprintCaptureScreen(student: widget.student, photoPath: capturedImage!.path),
                        ),
                      );
                    },
                    child: const Text("Continue"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
