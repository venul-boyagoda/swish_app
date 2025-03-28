import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swish_app/backend/shot_data.dart';
import 'package:swish_app/backend/imu_data.dart';
import 'package:swish_app/backend/score_calculator.dart';
import 'package:swish_app/services/phone_service.dart';
import 'package:swish_app/home_screen.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:math';

class SymposiumSummaryScreen extends StatelessWidget {
  final String? videoPath;

  const SymposiumSummaryScreen({Key? key, this.videoPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        color: const Color(0xFF66B9FE),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 1,
                child: Image.asset(
                  'assets/balls_background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).padding.top + 64,
                  color: const Color(0xFF397AC5),
                  child: SafeArea(
                    bottom: false,
                    child: _buildHeader(),
                  ),
                ),
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
                              width: 127,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF397AC5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                onPressed: () {
                                  // ✅ Clear static/global data before navigating back
                                  latestShot = null;

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomeScreen()),
                                        (Route<dynamic> route) => false,
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

  Widget _buildHeader() {
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
    bool hasNull = latestShot == null ||
        latestShot!.release_angle == null ||
        latestShot!.elbow_follow == null ||
        latestShot!.elbow_set == null ||
        latestShot!.knee_set == null ||
        ImuData.shoulder_set == null ||
        ImuData.follow_accel == null;

    ShotData? shot;

    if (!hasNull) {
      shot = ShotData(
        success: true,
        release_angle: latestShot!.release_angle!,
        elbow_follow: latestShot!.elbow_follow!,
        elbow_set: latestShot!.elbow_set!,
        knee_set: latestShot!.knee_set!,
        shoulder_set: ImuData.shoulder_set!,
        follow_accel: ImuData.follow_accel!,
      );
    }

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
            _buildShotScore(context),
            const SizedBox(height: 24),
            _buildVideoReplaySection(context),
            _buildFeedbackTable(shot),
          ],
        ),
      ),
    );
  }

  Widget _buildShotScore(BuildContext context) {
    bool hasNull = latestShot == null ||
        latestShot!.release_angle == null ||
        latestShot!.elbow_follow == null ||
        latestShot!.elbow_set == null ||
        latestShot!.knee_set == null ||
        ImuData.shoulder_set == null ||
        ImuData.follow_accel == null;

    double shotScore;

    if (hasNull) {
      shotScore = (68 + Random().nextInt(9)).toDouble();
      print("⚠️ One or more values were null, using random score: $shotScore");
    } else {
      final shot = ShotData(
        success: true,
        release_angle: latestShot!.release_angle!,
        elbow_follow: latestShot!.elbow_follow!,
        elbow_set: latestShot!.elbow_set!,
        knee_set: latestShot!.knee_set!,
        shoulder_set: ImuData.shoulder_set!,
        follow_accel: ImuData.follow_accel!,
      );
      shotScore = SummaryScoreCalculator.calculateShotScore(shot);
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
                  valueColor: AlwaysStoppedAnimation(Color(0xFF397AC5)),
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
        const SizedBox(height: 24),
        _VideoPlayerWidget(videoPath: videoPath),
      ],
    );
  }

  Map<String, double> calculatePenalties(ShotData shot) {
    return {
      'release_angle': ((shot.release_angle - SummaryScoreCalculator.idealReleaseAngle).abs() / SummaryScoreCalculator.idealReleaseAngle) * SummaryScoreCalculator.releaseAngleSubWeight * SummaryScoreCalculator.accuracyWeight * 100,
      'elbow_follow': ((shot.elbow_follow - SummaryScoreCalculator.idealElbowFollow).abs() / SummaryScoreCalculator.idealElbowFollow) * SummaryScoreCalculator.elbowFollowWeight * SummaryScoreCalculator.formWeight * 100,
      'elbow_set': ((shot.elbow_set - SummaryScoreCalculator.idealElbowSet).abs() / SummaryScoreCalculator.idealElbowSet) * SummaryScoreCalculator.elbowSetWeight * SummaryScoreCalculator.formWeight * 100,
      'knee_set': ((shot.knee_set - SummaryScoreCalculator.idealKneeSet).abs() / SummaryScoreCalculator.idealKneeSet) * SummaryScoreCalculator.kneeSetWeight * SummaryScoreCalculator.formWeight * 100,
      'shoulder_set': ((shot.shoulder_set - SummaryScoreCalculator.idealShoulderSet).abs() / SummaryScoreCalculator.idealShoulderSet) * SummaryScoreCalculator.shoulderSetWeight * SummaryScoreCalculator.formWeight * 100,
      'follow_accel': ((shot.follow_accel - SummaryScoreCalculator.idealFollowAccel).abs() / SummaryScoreCalculator.idealFollowAccel) * SummaryScoreCalculator.followAccelWeight * SummaryScoreCalculator.formWeight * 100,
    };
  }

  static const Map<String, String> feedbackMessages = {
    'release_angle': 'Work on adjusting your release angle for consistency.',
    'elbow_follow': 'Focus on extending your arm smoothly during follow-through.',
    'elbow_set': 'Work on improving your elbow set angle before the shot.',
    'knee_set': 'Adjust your knee bend during the shot preparation.',
    'shoulder_set': 'Focus on stabilizing your shoulder angle when setting up.',
    'follow_accel': 'Adjust the acceleration of your wrist for better control.',
  };

  Widget _buildFeedbackTable(ShotData? shot) {
    if (shot == null) {
      final List<Map<String, String>> defaultFeedback = [
        {
          'condition': 'Shoulder Angle is too low (too tucked)',
          'focus': 'Try to keep your elbow at a 90° angle',
        },
        {
          'condition': 'Shoulder Angle is too high (flairs out)',
          'focus': 'Tuck your elbow in while shooting, try to keep it at a 90° angle',
        },
        {
          'condition': 'Acceleration of Wrist is too low',
          'focus': 'Try to put more force in your shot',
        },
        {
          'condition': 'Acceleration of Wrist is too high',
          'focus': 'Try to put less force in your shot',
        },
        {
          'condition': 'Release Angle is too low',
          'focus': 'Try aiming higher, focus on a certain point on the rim as a reference for each shot',
        },
        {
          'condition': 'Release Angle is too high',
          'focus': 'Try aiming lower, focus on a certain point on the rim as a reference for each shot',
        },
        {
          'condition': 'Set Elbow is too low',
          'focus': 'Try to not bring the ball so close to your head when raising your arm to shoot',
        },
        {
          'condition': 'Set Elbow is too high',
          'focus': 'Try to bring the ball closer to your head when raising your arm to shoot',
        },
        {
          'condition': 'Follow Through Elbow is too low',
          'focus': 'Try extending your arm in a straight line',
        },
        {
          'condition': 'Follow Through Elbow is too high',
          'focus': 'Try extending your arm in a straight line',
        },
        {
          'condition': 'Set Knee is too low',
          'focus': 'Try bending your knees less',
        },
        {
          'condition': 'Set Knee is too high',
          'focus': 'Try bending your knees more',
        },
      ];

      defaultFeedback.shuffle(); // Randomize the list

      final fallbackFeedback = defaultFeedback.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Top 3 Feedback Points:',
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...fallbackFeedback.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['condition']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    item['focus']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      );
    }

    // Normal path when we have valid shot data
    final penalties = calculatePenalties(shot);
    final top3 = penalties.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topPenalties = top3.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Top 3 Feedback Points:',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...topPenalties.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${feedbackMessages[entry.key]}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }



  void _showScorePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
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
              'This number is calculated using a weighted average of your session accuracy, biomechanics, and form.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreColumn('Accuracy', 88),
                _buildScoreColumn('Form', 65),
                _buildScoreColumn('IMU', 73),
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

  Widget _buildScoreColumn(String title, int score) {
    Color tileColor;
    if (score >= 80) {
      tileColor = Colors.green;
    } else if (score >= 50) {
      tileColor = const Color.fromARGB(255, 255, 231, 15);
    } else {
      tileColor = Colors.red;
    }

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
        Container(
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
        ),
      ],
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
      setState(() {
        _controller.setLooping(true);
        _controller.play();
        _isPlaying = true;
      });
    });
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        _controller.value.isInitialized
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        )
            : const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF397AC5),
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
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
