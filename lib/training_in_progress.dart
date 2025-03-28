import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swish_app/services/ble_service.dart';
import 'package:swish_app/session_complete.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:swish_app/services/phone_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;
import 'dart:convert'; // Ensure json encoding is available

class TrainingInProgress extends StatefulWidget {
  final BleService bleService;
  final String selectedArm;
  final double heightInCm;

  TrainingInProgress({required this.bleService, required this.heightInCm, required this.selectedArm});

  @override
  _TrainingInProgressState createState() => _TrainingInProgressState();
}

class _TrainingInProgressState extends State<TrainingInProgress> with WidgetsBindingObserver {
  bool _isRecording = false;
  bool _isSessionStarted = false;
  String? _videoPath;
  Timer? _timer;
  int _elapsedSeconds = 0;
  final ImagePicker _picker = ImagePicker();

  List<int> imuData = [];
  StreamSubscription<List<int>>? imuDataSubscription;
  List<Map<String, dynamic>> decodedMatrices = [];

  double? video_start_time;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Connect to IMU on init and update UI when connection status changes
    Future.delayed(Duration(milliseconds: 500), () async {
      await widget.bleService.connectToIMU();
      // Ensure UI updates after connection completes
      setState(() {});
      _waitForStream();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes if needed
    if (state == AppLifecycleState.resumed && _isSessionStarted) {
      // App returned to foreground - check if we need to do anything
    }
  }

  void _waitForStream() async {
    int retryCount = 0;
    final maxRetries = 10;

    // More robust waiting for stream with retry counter
    while (widget.bleService.imuData == null) {
      await Future.delayed(Duration(milliseconds: 300));
      retryCount++;

      if (retryCount > maxRetries) {
        print("Warning: Could not get IMU data stream after multiple attempts");
        // Update UI even if we couldn't get IMU data, to avoid blocking the user
        setState(() {});
        return;
      }
    }

    // Clear any old data before starting new recording
    decodedMatrices.clear();

    imuDataSubscription = widget.bleService.imuData!.listen((data) {
      final timestamp = DateTime.now().millisecondsSinceEpoch / 1000.0;

      try {
        Map<String, dynamic> decodedPacket = decodeExtendedIMUData(data, timestamp);

        // Add to our collection of IMU readings
        setState(() {
          decodedMatrices.add(decodedPacket);
          imuData = data;
        });

        // Optional: Log occasionally to ensure data is flowing
        if (decodedMatrices.length % 100 == 0) {
          print("Collected ${decodedMatrices.length} IMU data points");
        }
      } catch (e) {
        print("Error decoding IMU data: $e");
      }
    }, onError: (e) {
      print("Error in IMU data stream: $e");
    }, onDone: () {
      print("IMU data stream closed");
    });

    print("✅ Subscribed to IMU stream!");

    // Ensure the UI updates once we have the stream
    setState(() {});
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

  Future<void> _startRecordingWithNativeCamera() async {
    try {
      // Clear any previously collected IMU data before starting a new recording
      decodedMatrices.clear();

      setState(() {
        _isSessionStarted = true;
        _isRecording = true;
      });

      // Set the start time for the video
      video_start_time = DateTime.now().millisecondsSinceEpoch / 1000.0;
      print("Recording started at timestamp: $video_start_time");

      // Start the timer
      _startTimer();

      // Launch native camera app to record video
      final XFile? videoFile = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10), // Optional: set max recording duration
      );

      // Check if recording was canceled
      if (videoFile == null) {
        _cancelRecording();
        return;
      }

      // Save the video path
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final savedVideoPath = '${directory.path}/saved_training_$timestamp.mp4';

      print("Copying video from ${videoFile.path} to $savedVideoPath");
      final File tempFile = File(videoFile.path);
      await tempFile.copy(savedVideoPath);

      setState(() {
        _isRecording = false;
        _videoPath = savedVideoPath;
      });

      _timer?.cancel();

      print('Video saved to: $_videoPath ✅');
      print('Collected ${decodedMatrices.length} IMU data points during recording');

      // Process recording and navigate to completion screen
      await _processRecordingAndNavigate(savedVideoPath);

    } catch (e) {
      print("Error recording video: $e");
      _cancelRecording();
    }
  }

  void _cancelRecording() {
    setState(() {
      _isSessionStarted = false;
      _isRecording = false;
    });
    _timer?.cancel();
    _elapsedSeconds = 0;
  }

  Future<void> _processRecordingAndNavigate(String videoPath) async {
    // Make sure we have IMU data to send
    if (decodedMatrices.isEmpty) {
      print("Warning: No IMU data collected!");
    } else {
      print("Collected ${decodedMatrices.length} IMU data packets to upload");
    }

    // Ensure we disconnect from BLE properly
    await widget.bleService.disconnect();

    // Make sure video_start_time has a value
    final videoStartTime = video_start_time ?? (DateTime.now().millisecondsSinceEpoch / 1000.0);

    // Create a deep copy of the IMU data to avoid any potential issues
    final List<Map<String, dynamic>> imuDataCopy = List.from(decodedMatrices);

    // ✅ Add height to uploadTrainingSession
    final Future<void> uploadFuture = uploadTrainingSession(
      videoFile: File(videoPath),
      imuPackets: imuDataCopy,
      handedness: widget.selectedArm.toLowerCase(),
      videoStartTime: videoStartTime,
      userHeightInCm: widget.heightInCm, // ✅ Pass the user's height
    );

    // Add error handling for the upload
    uploadFuture.catchError((error) {
      print("Error uploading training session: $error");
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SessionComplete(
          videoPath: videoPath,
          uploadFuture: uploadFuture,
        ),
      ),
    );
  }


  @override
  void dispose() {
    print("Disposing resources");
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    imuDataSubscription?.cancel();
    super.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildDebugPanel(),
                    Expanded(child: _buildInstructionsOrStatus()),
                    _buildStartRecordingButton(),
                  ],
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
      height: MediaQuery.of(context).padding.top + 40,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 12,
        right: 12,
        bottom: 4,
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

  Widget _buildDebugPanel() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isSessionStarted ? "Time: ${_formatTime(_elapsedSeconds)}" : "Session not started",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("BLE: ${widget.bleService.isConnected ? "Connected ✅" : "Connecting... ⏳"}"),
            ],
          ),
          if (decodedMatrices.isNotEmpty)
            Text("IMU data points: ${decodedMatrices.length}",
                style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInstructionsOrStatus() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF397AC5), width: 4),
      ),
      padding: EdgeInsets.all(16),
      child: Center(
        child: _isRecording
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              "Recording in progress...",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Use your device's camera app to record your training session.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "When finished, tap 'Done' in your camera app.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_basketball, size: 48, color: Color(0xFF397AC5)),
            SizedBox(height: 16),
            Text(
              "Ready to start your training session",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "1. Make sure your device is connected (check indicator above)",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "2. Press the 'Start Recording' button below",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "3. Use your camera app to record your training",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "4. When done, press 'Done' in your camera app",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartRecordingButton() {
    if (_isRecording) {
      return SizedBox.shrink(); // Hide button while recording
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        onPressed: widget.bleService.isConnected && !_isSessionStarted
            ? _startRecordingWithNativeCamera
            : null,
        icon: Icon(Icons.videocam),
        label: Text("Start Recording", style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF397AC5),
          foregroundColor: Colors.white,
          minimumSize: Size(220, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton() {
    return Icon(Icons.sports_basketball, color: Colors.white);
  }
}