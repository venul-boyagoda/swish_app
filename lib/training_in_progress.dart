import 'package:flutter/services.dart'; // Required for SystemChrome
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:swish_app/services/ble_service.dart';
import 'package:swish_app/session_complete.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:swish_app/services/ble_service.dart';
import 'package:swish_app/services/phone_service.dart';

class TrainingInProgress extends StatefulWidget {
  final BleService bleService; // ✅ Add this parameter

  TrainingInProgress({required this.bleService}); // ✅ Constructor

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
      print("🔴 Raw IMU Data received: $data");
      print("🟢 Decoded Matrix: $matrix");

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
      
      // Save the video file permanently
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final savedVideoPath = '${directory.path}/saved_training_$timestamp.mp4';
      
      // Copy the temporary file to permanent storage
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
  void dispose() {
    _cameraController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make the status bar overlay match the header color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar background transparent
      statusBarIconBrightness: Brightness.light, // Make status bar icons white
    ));

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

  Widget _buildIconButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Center(
        child: Icon(Icons.menu, color: Colors.white),
      ),
    );
  }

  Widget _buildTrainingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTrainingStatus(),
          const SizedBox(height: 24),
          _buildCameraView(),
          const SizedBox(height: 24),
          _buildEndTrainingButton(),
        ],
      ),
    );
  }

  Widget _buildTrainingStatus() {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Training in Progress...',
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Time Elapsed: ${_formatTime(_elapsedSeconds)}',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCameraView() {
    return Container(
      width: 299,
      height: 475,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: _cameraController != null && _cameraController!.value.isInitialized
          ? CameraPreview(_cameraController!)
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
      ),
    );
  }
}