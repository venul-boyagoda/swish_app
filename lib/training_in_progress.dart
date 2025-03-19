import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:swish_app/services/ble_service.dart';
import 'package:swish_app/session_complete.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:swish_app/services/phone_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;


class TrainingInProgress extends StatefulWidget {
  final BleService bleService;
  final String selectedArm;

  TrainingInProgress({required this.bleService, required this.selectedArm});

  @override
  _TrainingInProgressState createState() => _TrainingInProgressState();
}

class _TrainingInProgressState extends State<TrainingInProgress> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isRecording = false;
  String? _videoPath;
  Timer? _timer;
  int _elapsedSeconds = 0;

  List<int> imuData = [];
  StreamSubscription<List<int>>? imuDataSubscription;
  List<Map<String, dynamic>> decodedMatrices = [];

@override
void initState() {
  super.initState();
  _lockOrientationToLandscape();
  // Add a short delay before initializing the camera
  // This gives time for the orientation change to take effect
  Future.delayed(Duration(milliseconds: 300), () {
    _initializeCamera();
    _startTimer();
    widget.bleService.connectToIMU();
    _waitForStream();
  });
}

Future<void> _lockOrientationToLandscape() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft, // Allow both landscape orientations
  ]);
  
  // Set the UI to landscape right as the default
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
  ]);
}

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer?.cancel();
    imuDataSubscription?.cancel();
    _resetOrientation();
    super.dispose();
  }

  Future<void> _resetOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _waitForStream() async {
    while (widget.bleService.imuData == null) {
      await Future.delayed(Duration(milliseconds: 300));
    }

    imuDataSubscription = widget.bleService.imuData!.listen((data) {
      final timestamp = DateTime.now().millisecondsSinceEpoch / 1000.0;

      Map<String, dynamic> decodedPacket = decodeExtendedIMUData(data, timestamp);
      decodedMatrices.add(decodedPacket);

      setState(() {
        imuData = data;
      });
    }, onError: (e) {
      print("Error in IMU data stream: $e");
    });

    print("✅ Subscribed to IMU stream!");
  }

  Map<String, dynamic> decodeExtendedIMUData(List<int> rawData, double timestamp) {
    List<double> extractFloats(List<int> slice) {
      List<double> values = [];
      for (int i = 0; i < slice.length; i += 4) {
        ByteData bytes = ByteData.sublistView(Uint8List.fromList(slice.sublist(i, i + 4)));
        values.add(bytes.getFloat32(0, Endian.little));
      }
      return values;
    }

    return {
      'timestamp': timestamp,
      'bno_matrix': extractFloats(rawData.sublist(0, 36)),
      'bmi_matrix': extractFloats(rawData.sublist(36, 72)),
      'bno_gyro': extractFloats(rawData.sublist(72, 84)),
      'bno_accel': extractFloats(rawData.sublist(84, 96)),
      'bmi_gyro': extractFloats(rawData.sublist(96, 108)),
    };
  }

 Future<void> _initializeCamera() async {
  cameras = await availableCameras();
  
  // Get the back camera
  final backCamera = cameras!.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.back,
    orElse: () => cameras!.first
  );
  
  _cameraController = CameraController(
    backCamera,
    ResolutionPreset.medium,
    enableAudio: true,
    imageFormatGroup: ImageFormatGroup.jpeg,
  );
  
  await _cameraController!.initialize();

  // Set video start time here
  video_start_time = DateTime.now().millisecondsSinceEpoch / 1000.0;

  // Don't lock orientation here - we'll handle rotation in the UI
  if (mounted) {
    setState(() {});
  }

  // Start recording
  _startRecording();
}

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  double? video_start_time;

Future<void> _startRecording() async {
  if (_cameraController != null && _cameraController!.value.isInitialized) {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      _videoPath = '${directory.path}/trainingvideo$timestamp.mp4';

      // For newer camera package versions that support recording options:
      /*
      final videoOptions = VideoRecordingOptions(
        quality: ResolutionPreset.medium,
        fileFormat: VideoFileFormat.mp4,
      );
      await _cameraController!.startVideoRecording(options: videoOptions);
      */
      
      // For older camera package versions:
      await _cameraController!.startVideoRecording();
      
      setState(() {
        _isRecording = true;
      });
      
      print("Video recording started");
    } catch (e) {
      print("Error starting video recording: $e");
    }
  } else {
    print("Camera controller not initialized");
  }
}


  Future<String?> _stopRecording() async {
    if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      _timer?.cancel();

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final savedVideoPath = '${directory.path}/saved_training_$timestamp.mp4';

      final File tempFile = File(videoFile.path);
      await tempFile.copy(savedVideoPath);

      setState(() {
        _isRecording = false;
        _videoPath = savedVideoPath;
      });

      print('Video saved to: $_videoPath');
      return savedVideoPath;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF66B9FE),
          image: const DecorationImage(
            image: AssetImage('assets/balls_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildTrainingCard(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).padding.top + 64,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 12,
        right: 12,
        bottom: 8,
      ),
      decoration: const BoxDecoration(color: Color(0xFF397AC5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(),
          const Text(
            'S.W.I.S.H',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          _buildIconButton(),
        ],
      ),
    );
  }

  Widget _buildTrainingCard() {
    return Column(
      children: [
        _buildDebugPanel(),
        _buildCameraView(),
        const SizedBox(height: 16),
        _buildEndTrainingButton(),
      ],
    );
  }

  Widget _buildDebugPanel() {
    Map<String, dynamic>? latestPacket = decodedMatrices.isNotEmpty ? decodedMatrices.last : null;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("IMU Debug Info", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text("BLE Status: ${widget.bleService.isConnected ? "Connected ✅" : "Connecting... ⏳"}"),
            const SizedBox(height: 8),
            // Text("Raw IMU Data: ${imuData.isNotEmpty ? imuData.toString() : "Waiting..."}"),
            // const SizedBox(height: 8),
          //   if (latestPacket != null) ...[
          //     Text("Timestamp: ${latestPacket['timestamp']}"),
          //     Text("BNO Matrix: ${latestPacket['bno_matrix']}"),
          //     Text("BMI Matrix: ${latestPacket['bmi_matrix']}"),
          //     Text("BNO Gyro: ${latestPacket['bno_gyro']}"),
          //     Text("BNO Accel: ${latestPacket['bno_accel']}"),
          //     Text("BMI Gyro: ${latestPacket['bmi_gyro']}"),
          //   ] else
          //     Text("Waiting for packet..."),
          // ],
        ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
  if (_cameraController == null || !_cameraController!.value.isInitialized) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF397AC5), width: 4),
      ),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  // Get screen size
  final size = MediaQuery.of(context).size;
  
  // Calculate the rotation needed based on device orientation
  // This is the key to fixing the upside-down issue
  final deviceOrientation = MediaQuery.of(context).orientation;
  final isLandscape = deviceOrientation == Orientation.landscape;
  
  // For most devices in landscape mode
  final rotationAngle = isLandscape ? 0.0 : -math.pi / 2;
  
  // Calculate container dimensions for proper aspect ratio
  final containerWidth = size.width - 48; // Account for padding
  final containerHeight = isLandscape 
      ? containerWidth / (16/9) // Use 16:9 aspect ratio for landscape
      : containerWidth * (16/9);
  
  return Container(
    width: containerWidth,
    height: containerHeight,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFF397AC5), width: 4),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Transform.rotate(
        angle: rotationAngle,
        child: CameraPreview(_cameraController!),
      ),
    ),
  );
}

  Widget _buildEndTrainingButton() {
    return GestureDetector(
      onTap: () async {
        await widget.bleService.disconnect();
        final String? savedVideoPath = await _stopRecording();
        if (savedVideoPath != null) {
          final Future<void> uploadFuture = uploadTrainingSession(
            videoFile: File(savedVideoPath),
            imuPackets: decodedMatrices,
            handedness: widget.selectedArm.toLowerCase(),
            videoStartTime: video_start_time!,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SessionComplete(
                videoPath: savedVideoPath,
                uploadFuture: uploadFuture,
              ),
            ),
          );
        }
      },
      child: Container(
        width: 200,
        height: 50,
        decoration: ShapeDecoration(
          color: const Color(0xFF397AC5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: const Center(
          child: Text(
            'End Training',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton() {
    return Icon(Icons.sports_basketball, color: Colors.white);
  }
}
