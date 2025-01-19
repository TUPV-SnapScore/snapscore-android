import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math' as math;

import 'package:snapscore_android/core/themes/colors.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _controller = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void toggleFlash() async {
    if (_controller != null) {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  Future<void> takePicture() async {
    if (!_controller!.value.isInitialized) {
      return;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String pictureDirectory = '${appDirectory.path}/Pictures';
    await Directory(pictureDirectory).create(recursive: true);

    final String fileName = '${DateTime.now()}.jpg';
    final String filePath = join(pictureDirectory, fileName);

    try {
      // Set flash mode to auto for capture
      await _controller!.setFlashMode(FlashMode.auto);
      await _controller!.takePicture().then((XFile file) {
        file.saveTo(filePath);
      });
      // Reset flash mode after capture
      await _controller!
          .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      print('Picture saved to: $filePath');
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate the appropriate dimensions
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final previewRatio = _controller!.value.aspectRatio;
    final isLandscape = previewRatio > 1;

    // Calculate the preview scale
    double scale =
        isLandscape ? deviceRatio / previewRatio : previewRatio / deviceRatio;

    // Ensure the scale is never less than 1
    scale = math.max(1, scale);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('SnapScore'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: toggleFlash,
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Scan',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Center(
                    child: CameraPreview(_controller!),
                  ),
                ),
                // Corner markers
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.green[400]!, width: 2),
                        left: BorderSide(color: Colors.green[400]!, width: 2),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.green[400]!, width: 2),
                        right: BorderSide(color: Colors.green[400]!, width: 2),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.green[400]!, width: 2),
                        left: BorderSide(color: Colors.green[400]!, width: 2),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.green[400]!, width: 2),
                        right: BorderSide(color: Colors.green[400]!, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: takePicture,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(24),
                backgroundColor: Colors.white,
              ),
              child: Container(),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle viewing results
            },
            child: const Text(
              'View Results',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
