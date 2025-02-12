import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snapscore_android/core/themes/colors.dart';
import 'package:snapscore_android/features/camera/services/camera_service.dart';

class Camera extends StatefulWidget {
  final String assessmentName;
  final String assessmentId;

  const Camera(
      {super.key, required this.assessmentName, required this.assessmentId});

  @override
  CameraState createState() => CameraState();
}

class CameraState extends State<Camera> {
  CameraController? _controller;
  File? _capturedImage;
  bool _isProcessing = false;
  bool _isReviewing = false;
  bool _isSaving = false;
  FlashMode _currentFlashMode = FlashMode.off;
  final cameraService = CameraService();

  DeviceOrientation _currentOrientation = DeviceOrientation.portraitUp;
  DeviceOrientation? _photoOrientation;

  double? _cameraAspectRatio;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras[0], ResolutionPreset.high,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off);

      // Set aspect ratio after initialization
      setState(() {
        _cameraAspectRatio = _controller!.value.aspectRatio;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  Future<void> _updateCameraOrientation(DeviceOrientation orientation) async {
    if (_controller == null) return;

    setState(() {
      _currentOrientation = orientation;
    });

    try {
      await _controller!.lockCaptureOrientation(orientation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Error changing orientation: $e')),
        );
      }
    }
  }

  Future<void> _captureImage() async {
    if (!(_controller?.value.isInitialized ?? false)) return;

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
      return;
    }

    try {
      setState(() => _isProcessing = true);

      // Set focus and exposure for best quality
      await _controller!.setExposureMode(ExposureMode.auto);
      await _controller!.setFocusMode(FocusMode.auto);

      _photoOrientation = _currentOrientation;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${appDir.path}/Pictures';
      await Directory(dirPath).create(recursive: true);

      // Use PNG extension for lossless quality
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final String tempImagePath = '$dirPath${Platform.pathSeparator}$fileName';

      // Take picture with maximum quality
      final XFile image = await _controller!.takePicture();

      // Copy to new location as PNG
      final File originalFile = File(image.path);
      await originalFile.copy(tempImagePath);

      setState(() {
        _capturedImage = File(tempImagePath);
        _isProcessing = false;
        _isReviewing = true;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    }
  }

  double _getRotationAngle() {
    switch (_photoOrientation) {
      case DeviceOrientation.landscapeRight:
        return -90 * 3.14159 / 180;
      case DeviceOrientation.landscapeLeft:
        return 90 * 3.14159 / 180;
      case DeviceOrientation.portraitDown:
        return 180 * 3.14159 / 180;
      case DeviceOrientation.portraitUp:
      default:
        return 0.0;
    }
  }

  void _rotateToNext() async {
    final orientations = [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
    ];

    final currentIndex = orientations.indexOf(_currentOrientation);
    final nextOrientation =
        orientations[(currentIndex + 1) % orientations.length];

    await _updateCameraOrientation(nextOrientation);
  }

  void _toggleFlash() async {
    if (_controller == null) return;

    try {
      FlashMode nextMode;
      switch (_currentFlashMode) {
        case FlashMode.off:
          nextMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          nextMode = FlashMode.always;
          break;
        default:
          nextMode = FlashMode.off;
      }

      await _controller!.setFlashMode(nextMode);
      setState(() => _currentFlashMode = nextMode);
    } catch (e) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error changing flash mode: $e')),
      );
    }
  }

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  void _resetCamera() {
    setState(() {
      _isReviewing = false;
      _capturedImage = null;
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _uploadPhoto() async {
    if (_capturedImage == null || !_isReviewing) return;

    try {
      setState(() {
        _isSaving = true;
      });

      await cameraService.uploadIdentificationImage(
        _capturedImage!,
        widget.assessmentId,
      );

      _resetCamera();
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error scanning paper: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildCornerMarker() {
    return Container(
      width: 24,
      height: 24,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green.withOpacity(0.8), width: 3),
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_controller?.value.isInitialized != true) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use full width of the screen
        final width = constraints.maxWidth * 0.8;
        // Calculate height for 16:9 aspect ratio
        final height = width * 16 / 9;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Camera preview
              SizedBox(
                width: width,
                height: height,
                child: CameraPreview(_controller!),
              ),
              // Paper guide overlay
              SizedBox(
                width: width * 0.85,
                height: height * 0.85,
                child: Stack(
                  children: [
                    // Top-left corner
                    Positioned(
                      left: 0,
                      top: 0,
                      child: _buildCornerMarker(),
                    ),
                    // Top-right corner
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Transform.rotate(
                        angle: 90 * 3.14159 / 180,
                        child: _buildCornerMarker(),
                      ),
                    ),
                    // Bottom-left corner
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Transform.rotate(
                        angle: -90 * 3.14159 / 180,
                        child: _buildCornerMarker(),
                      ),
                    ),
                    // Bottom-right corner
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Transform.rotate(
                        angle: 180 * 3.14159 / 180,
                        child: _buildCornerMarker(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final imageWidth = screenWidth * 1.5;
        final imageHeight =
            imageWidth * 1.4; // Adjust this ratio based on your needs

        return Stack(
          children: [
            Positioned(
              top: 0,
              bottom:
                  40, // Adjust this value to position the image where you want vertically
              left: (screenWidth - imageWidth) / 2, // Center horizontally
              child: Container(
                width: imageWidth,
                height: imageHeight,
                color: Colors.transparent,
                child: Transform.rotate(
                  angle: _getRotationAngle(),
                  alignment: Alignment.center,
                  child: ClipRect(
                    child: Image.file(
                      _capturedImage!,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: _resetCamera,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SnapScore',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!_isReviewing) ...[
            IconButton(
              icon: Icon(_getFlashIcon(), color: Colors.black),
              onPressed: _toggleFlash,
            ),
            IconButton(
              icon: const Icon(Icons.screen_rotation, color: Colors.black),
              onPressed: _rotateToNext,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Scan',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_isReviewing && _capturedImage != null)
                        _buildImagePreview()
                      else if (_controller?.value.isInitialized ?? false)
                        _buildCameraPreview(),
                      if (!_isReviewing) ...[
                        Positioned(
                          bottom: 80,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: _captureImage,
                              child: Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          if (_isReviewing)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextButton(
                onPressed: _isSaving ? null : _uploadPhoto,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black54),
                        ),
                      )
                    : const Text(
                        'Upload',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
