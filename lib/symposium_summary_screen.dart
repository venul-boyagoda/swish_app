import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:swish_app/backend/shot_data.dart';
import 'package:swish_app/home_screen.dart';
import 'package:swish_app/individual_summary.dart';
import 'package:swish_app/services/phone_service.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import 'backend/score_calculator.dart';

class SymposiumSummaryScreen extends StatelessWidget {
  final String? videoPath;

const SymposiumSummaryScreen({Key? key, this.videoPath}) : super(key: key);

  // Helper widget for table header rows
  static Widget tableHeaderRow({
    required String col1,
    required String col2,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Text(
              col1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              col2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper function to create table data rows with an info icon
static Widget tableDataRow({
  required String col1,
  required String col2,
  required Color backgroundColor,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    color: backgroundColor,
    child: Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                col1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.info_outline, // ✅ Added info icon
                size: 12,
                color: Colors.black,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            col2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

static Widget _buildMistakeRow(BuildContext context, text, Color backgroundColor) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(color: backgroundColor),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const Icon(
          Icons.info_outline, // ✅ Added info icon
          size: 12,
          color: Colors.black,
        ),
      ],
    ),
  );
}

// ✅ Updated Mistakes Table with Info Icons
Widget buildMistakesTable(BuildContext context) {
  return Container(
    width: 314,
    decoration: ShapeDecoration(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
          color: Color(0xFFDBEFFF),
        ),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(color: Colors.white),
          child: const Text(
            'Biggest things to focus on',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 13,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // ✅ Rows with Info Icons
        _buildMistakeRow(context,'Tuck your elbow while shooting', Color(0xFFDBEFFF)),
        _buildMistakeRow(context, 'Release the ball slightly earlier', Colors.white),
        _buildMistakeRow(context, 'Hold your follow through after shooting', Color(0xFFDBEFFF)),
      ],
    ),
  );
}


@override
Widget build(BuildContext context) {
  // Ensure the system UI style is set
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Make status bar fully blend with the header
    statusBarIconBrightness: Brightness.light, // White icons for contrast
  ));

  return Scaffold(
    extendBodyBehindAppBar: true, // Extend behind status bar
    body: Container(
      color: const Color(0xFF66B9FE), // Light blue background restored
      child: Stack(
        children: [
          // Background Image Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 1, // Adjust transparency as needed
              child: Image.asset(
                'assets/balls_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              // Header background extending to status bar
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).padding.top + 64, // Extends the header height
                color: const Color(0xFF397AC5), // Blue background for the header
                child: SafeArea(
                  bottom: false, // Ensures content doesn't shift down
                  child: _buildHeader(),
                ),
              ),

              // Rest of the content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildSummaryFrame(context),
                        const SizedBox(height: 24),
                        Align(
  alignment: Alignment.centerRight,
  child: SizedBox(
    width: 127, // ✅ Fixed width of 127 pixels
    height: 40, // Optional: Set height for consistency
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF397AC5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        elevation: 4,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      },
      child: const Text(
        'Finish',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  ),
),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  static Widget _buildHeader() {
  return Container(
    width: double.infinity,
    height: 64,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: const BoxDecoration(color: Color(0xFF397AC5)),
    child: Center(
      child: Container(
        width: 323,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x1EC8C8C8)),
            borderRadius: BorderRadius.circular(8),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'General Summary',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 20,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildSummaryFrame(BuildContext context) {
  return Center(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildShotScore(context), // ✅ Progress bar section
          const SizedBox(height: 24),
          _buildVideoReplaySection(context), // ✅ Add the video replay section here
          const SizedBox(height: 12),
          Center(child: buildMistakesTable(context)), // ✅ Mistakes table
        ],
      ),
    ),
  );
}


  Widget _buildShotScore(BuildContext context) {
    final shot = ShotData(
      success: true,
      release_angle: 36.7,
      elbow_follow: 175,
      elbow_set: 103,
      knee_set: 133,
    );

    // Shot 2
    final shot2 = ShotData(
      success: false,
      release_angle: 36.3,
      elbow_follow: 175,
      elbow_set: 107,
      knee_set: 136,
    );

// Shot 3
    final shot3 = ShotData(
      success: false,
      release_angle: 35.4,
      elbow_follow: 89,
      elbow_set: 115,
      knee_set: 148,
    );

    final double shotScore = SummaryScoreCalculator.calculateShotScore(shot);
    // final double shotScore = SummaryScoreCalculator.calculateShotScore();

    //final double shotScore = 30;

    // Multi-stop gradient colors
    const red = Color(0xFFE53935);        // Soft red
    const orange = Color(0xFFFF7043);     // Soft orange
    const yellow = Color(0xFFFFD740);     // Warm yellow
    const lightGreen = Color(0xFF9CCC65); // Light green
    const green = Color(0xFF43A047);      // Deep green

    // Normalize the score (30 to 100 mapped to 0.0 - 1.0)
    double normalized = ((shotScore - 30) / (100 - 30)).clamp(0.0, 1.0);

    // Smooth color blending
    Color progressColor;
    if (normalized < 0.25) {
      progressColor = Color.lerp(red, orange, normalized * 4)!;
    } else if (normalized < 0.5) {
      progressColor = Color.lerp(orange, yellow, (normalized - 0.25) * 4)!;
    } else if (normalized < 0.75) {
      progressColor = Color.lerp(yellow, lightGreen, (normalized - 0.5) * 4)!;
    } else {
      progressColor = Color.lerp(lightGreen, green, (normalized - 0.75) * 4)!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showScorePopup(context),
          child: Row(
            children: [
              const Text(
                'Overall Session Score:',
                style: TextStyle(
                  color: Color(0xFF397AC5),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.info_outline,
                size: 24,
                color: Color(0xFF397AC5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: shotScore / 100,
                  strokeWidth: 24,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                ),
              ),
              Text(
                '${shotScore.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoReplaySection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Video Replay',
        style: TextStyle(
          color: Color(0xFF397AC5),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 64), // ✅ Increased spacing between "Video Replay" and the video
      _VideoPlayerWidget(videoPath: videoPath),
    ],
  );
}



void _showScorePopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white, // ✅ Set background to white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Overall Session Score',
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This number is calculated using a weighted average of your session accuracy '
            'and shooting form. See your scores below:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Display Accuracy and Form scores only
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ✅ Even spacing
            children: [
              _buildScoreColumn('Accuracy', 88), // Example scores
              _buildScoreColumn('Form', 65),
            ],
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF397AC5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Got it!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Builds a column with a title and a score tile underneath
Widget _buildScoreColumn(String title, int score) {
  return Column(
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFF397AC5),
          fontSize: 16,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
      const SizedBox(height: 8),
      _buildScoreTile(score),
    ],
  );
}

/// Builds a square tile with a score and dynamically changes color
Widget _buildScoreTile(int score) {
  Color tileColor;
  if (score >= 80) {
    tileColor = Colors.green;
  } else if (score >= 50) {
    tileColor = const Color.fromARGB(255, 255, 231, 15);
  } else {
    tileColor = Colors.red;
  }

  return Container(
    width: 50,
    height: 50,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: tileColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      '$score',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
}

class _VideoPlayerWidget extends StatefulWidget {
  final String? videoPath;

  const _VideoPlayerWidget({Key? key, this.videoPath}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    if (widget.videoPath != null && widget.videoPath!.isNotEmpty) {
      _controller = VideoPlayerController.file(File(widget.videoPath!));
    } else {
      _controller = VideoPlayerController.asset('assets/shooting_replay.mp4');
    }

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true); // ✅ Enable looping
          _controller.play(); // ✅ Auto-play video when initialized
          _isPlaying = true;
        });
      }
    }).catchError((error) {
      print('Error initializing video player: $error');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_isInitialized) {
      setState(() {
        if (_isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
        _isPlaying = !_isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.black12,
        child: const Center(
          child: Text(
            'Unable to load video',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 24), // ✅ Ensures spacing before the video
_isInitialized
    ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF397AC5), width: 4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8), // Slightly smaller to account for border
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
      )
    : Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF397AC5), width: 4),
        ),
        child: const Center(child: CircularProgressIndicator())
      ),

        // ✅ Play/Pause Button (Directly Below Video)
        const SizedBox(height: 64), // ✅ Small gap between video and button
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: 60, // ✅ Circular size
            height: 60, // ✅ Circular size
            decoration: BoxDecoration(
              color: const Color(0xFF397AC5), // ✅ Blue background (same as header)
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 32, // ✅ Icon size
                color: Colors.white, // ✅ White icon for contrast
              ),
            ),
          ),
        ),

        const SizedBox(height: 32), // ✅ Ensures spacing after the button
      ],
    );
  }
}



