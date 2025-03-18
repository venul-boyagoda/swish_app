import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:swish_app/session_complete.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:swish_app/services/ble_service.dart';
import 'package:swish_app/services/phone_service.dart';

class TrainingInProgress extends StatefulWidget {
  final BleService bleService;

  TrainingInProgress({required this.bleService});

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
  List<List<List<double>>> decodedMatrices = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startTimer();
    widget.bleService.connectToIMU();
    _waitForStream();
  }

  void _waitForStream() async {
    while (widget.bleService.imuData == null) {
      await Future.delayed(Duration(milliseconds: 300));
    }

    imuDataSubscription = widget.bleService.imuData!.listen((data) {
      List<List<double>> matrix = decodeIMUDataToMatrix(data);
      decodedMatrices.add(matrix);
      // print("Raw IMU Data received: $data");
      // print("Decoded Matrix: $matrix");

      setState(() {
        imuData = data;
      });
    }, onError: (e) {
      print("Error in IMU data stream: $e");
    });

    print("✅ Subscribed to IMU stream!");
  }

  List<List<double>> decodeIMUDataToMatrix(List<int> rawData) {
    List<double> matrixValues = [];
    for (int i = 0; i < rawData.length; i += 4) {
      if (i + 4 <= rawData.length) {
        ByteData bytes = ByteData.sublistView(Uint8List.fromList(rawData.sublist(i, i + 4)));
        matrixValues.add(bytes.getFloat32(0, Endian.little));
      }
    }
    return [
      matrixValues.sublist(0, 3),
      matrixValues.sublist(3, 6),
      matrixValues.sublist(6, 9),
    ];
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer?.cancel();
    imuDataSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras!.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.medium,
    );
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {});
    }
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

  Future<void> _startRecording() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      _videoPath = '${directory.path}/training_video_$timestamp.mp4';
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
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
      backgroundColor: const Color(0xFF66B9FE),
      body: Column(
        children: [
          const SizedBox(height: 50),
          _buildDebugPanel(),
          Expanded(child: _buildCameraView()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: _buildEndTrainingButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugPanel() {
    List<List<double>>? latestMatrix = decodedMatrices.isNotEmpty ? decodedMatrices.last : null;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
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
            Text("Raw IMU Data: ${imuData.isNotEmpty ? imuData.toString() : "Waiting..."}"),
            const SizedBox(height: 8),
            Text("Decoded Matrix:"),
            if (latestMatrix != null)
              ...latestMatrix.map((row) => Text(row.toString())),
            if (latestMatrix == null)
              Text("Waiting for matrix..."),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: _cameraController != null && _cameraController!.value.isInitialized
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CameraPreview(_cameraController!),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEndTrainingButton() {
    return GestureDetector(
      onTap: () async {
        await uploadIMUData(decodedMatrices);
        final String? savedVideoPath = await _stopRecording();
        if (savedVideoPath != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SessionComplete(videoPath: savedVideoPath),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
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
}
