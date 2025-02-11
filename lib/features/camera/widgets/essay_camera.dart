import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snapscore_android/core/themes/colors.dart';
import 'package:snapscore_android/features/camera/services/camera_service.dart';

class EssayCamera extends StatefulWidget {
  final String assessmentName;
  final String assessmentId;

  const EssayCamera(
      {super.key, required this.assessmentName, required this.assessmentId});

  @override
  EssayCameraState createState() => EssayCameraState();
}

class EssayCameraState extends State<EssayCamera> {
  CameraController? _controller;
  File? _capturedImage;
  bool _isProcessing = false;
  bool _isReviewing = false;
  bool _isSaving = false;
  FlashMode _currentFlashMode = FlashMode.off;
  final cameraService = CameraService();

  DeviceOrientation _currentOrientation = DeviceOrientation.portraitUp;
  DeviceOrientation? _photoOrientation;
  Size? _previewSize;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    // Allow all orientations from the start
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

    _controller = CameraController(
        cameras[0], ResolutionPreset.max, // Set to maximum resolution
        enableAudio: false,
        imageFormatGroup:
            ImageFormatGroup.bgra8888 // Use highest quality format
        );

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off);

      _previewSize = _controller!.value.previewSize;
      setState(() {});
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
      _previewSize = _controller!.value.previewSize;
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
      _previewSize = _controller!.value.previewSize;

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

  Widget _buildImagePreview() {
    if (_capturedImage == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context as BuildContext).size.width * 0.8,
        height: MediaQuery.of(context as BuildContext).size.height * 0.70,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Transform.rotate(
            angle: _getRotationAngle(),
            child: Image.file(
              _capturedImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
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

      await cameraService.uploadEssayImage(
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

  // Future<void> _saveToGallery() async {
  //   if (_capturedImage == null || !_isReviewing) return;

  //   try {
  //     setState(() => _isSaving = true);

  //     if (Platform.isAndroid) {
  //       // Request storage permissions
  //       final storageStatus = await Permission.storage.request();
  //       final mediaStatus = await Permission.photos.request();

  //       if (!storageStatus.isGranted || !mediaStatus.isGranted) {
  //         throw Exception('Storage permission is required');
  //       }

  //       // Get the external storage directory
  //       final directory = await getExternalStorageDirectory();
  //       if (directory == null) throw Exception('Could not access storage');

  //       // Create a Pictures directory if it doesn't exist
  //       final picturesDir = Directory('${directory.path}/Pictures/SnapScore');
  //       if (!await picturesDir.exists()) {
  //         await picturesDir.create(recursive: true);
  //       }

  //       // Create unique filename
  //       final fileName =
  //           'SnapScore_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //       final savedImage =
  //           await _capturedImage!.copy('${picturesDir.path}/$fileName');

  //       // Use platform channel to notify media scanner
  //       await const MethodChannel('snapscore_channel').invokeMethod(
  //         'scanFile',
  //         {'path': savedImage.path},
  //       );

  //       if (mounted) {
  //         ScaffoldMessenger.of(context as BuildContext).showSnackBar(
  //           const SnackBar(
  //             content: Text('Image saved successfully!'),
  //             duration: Duration(seconds: 2),
  //           ),
  //         );
  //       }
  //     } else if (Platform.isIOS) {
  //       // For iOS, we'll need to implement PHPhotoLibrary saving
  //       // This is a placeholder for iOS implementation
  //       throw Exception('iOS implementation pending');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context as BuildContext).showSnackBar(
  //         SnackBar(
  //           content: Text('Error saving image: $e'),
  //           duration: const Duration(seconds: 2),
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isSaving = false);
  //     }
  //   }
  // }

  Widget _buildCornerMarker() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        color: Colors.transparent,
      ),
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
            padding: EdgeInsets.symmetric(vertical: 12.0),
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
                : Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.70,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_isReviewing && _capturedImage != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Transform.rotate(
                                angle: _getRotationAngle(),
                                child: Image.file(
                                  _capturedImage!,
                                  fit: BoxFit.fill, // Added this line
                                ),
                              ),
                            )
                          else if (_controller?.value.isInitialized ?? false)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CameraPreview(_controller!),
                            ),
                          if (!_isReviewing) ...[
                            Positioned(
                                top: 60, left: 20, child: _buildCornerMarker()),
                            Positioned(
                                top: 60,
                                right: 20,
                                child: _buildCornerMarker()),
                            Positioned(
                                bottom: 120,
                                left: 20,
                                child: _buildCornerMarker()),
                            Positioned(
                                bottom: 120,
                                right: 20,
                                child: _buildCornerMarker()),
                            Positioned(
                              bottom: 25,
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
                          if (_isReviewing)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: _resetCamera,
                              ),
                            ),
                        ],
                      ),
                    ),
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
                    side: const BorderSide(color: Colors.black12),
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
                        'Save to Gallery',
                        style: TextStyle(
                          color: Colors.black54,
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
