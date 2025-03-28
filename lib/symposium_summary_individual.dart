import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:swish_app/backend/mistakes.dart';
import 'package:swish_app/backend/shot_data.dart' as backend;

class SymposiumSummaryIndividualScreen extends StatefulWidget {
  final int initialShotIndex;
  final List<backend.ShotData> shots;
  final String videoPath; // New: Pass full video path

  const SymposiumSummaryIndividualScreen({
    Key? key,
    required this.initialShotIndex,
    required this.shots,
    required this.videoPath, // Pass video path to the screen
  }) : super(key: key);

  @override
  _SymposiumSummaryIndividualScreenState createState() => _SymposiumSummaryIndividualScreenState();
}


class _SymposiumSummaryIndividualScreenState extends State<SymposiumSummaryIndividualScreen> {
  late int _currentShotIndex;
  late VideoPlayerController _videoController;
  bool _isPlaying = false;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentShotIndex = widget.initialShotIndex.clamp(0, widget.shots.length - 1);
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    final currentShot = widget.shots[_currentShotIndex];
    _videoController = VideoPlayerController.file(File(widget.videoPath)) // ✅ Use videoPath correctly
      ..initialize().then((_) {
        setState(() {
          _seekToStartFrame(); // ✅ Seek to correct frame
          _videoController.play();
          _isPlaying = true;
        });
      });
  }


  void _seekToStartFrame() {
    final currentShot = widget.shots[_currentShotIndex];
    final frameDuration = _videoController.value.duration.inMilliseconds / (currentShot.end - currentShot.follow_frame);
    final startMillis = (currentShot.follow_frame * frameDuration).toInt();
    _videoController.seekTo(Duration(milliseconds: startMillis));
  }


  void _playTrimmedVideo() {
    final currentShot = widget.shots[_currentShotIndex];
    final frameDuration = _videoController.value.duration.inMilliseconds / (currentShot.end - currentShot.follow_frame);
    final startMillis = (currentShot.follow_frame * frameDuration).toInt();
    final endMillis = (currentShot.end * frameDuration).toInt();

    _videoController.seekTo(Duration(milliseconds: startMillis));
    _videoController.addListener(() {
      if (_videoController.value.position.inMilliseconds >= endMillis) {
        _videoController.seekTo(Duration(milliseconds: startMillis));
      }
    });
  }

  void _navigateToShot(int shotIndex) {
    setState(() {
      _currentShotIndex = shotIndex;
      _videoController.dispose();
      _initializeVideo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentShot = widget.shots[_currentShotIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Shot ${_currentShotIndex + 1} Summary'), // ✅ Use index + 1
        backgroundColor: const Color(0xFF397AC5),
      ),
      body: _isVideoInitialized
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoReplaySection(currentShot),
            const SizedBox(height: 24),
            _buildShotScore(currentShot),
            const SizedBox(height: 24),
            _buildMistakesSection(currentShot),
            const SizedBox(height: 24),
            _buildNavigationButtons(context),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }


  Widget _buildVideoReplaySection(backend.ShotData shot) {
    _playTrimmedVideo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video Replay:',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _videoController.value.isInitialized
              ? AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          )
              : const Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: 8),
        _buildPlayPauseButton(),
      ],
    );
  }

  Widget _buildPlayPauseButton() {
    return IconButton(
      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 32, color: Colors.black),
      onPressed: () {
        setState(() {
          if (_isPlaying) {
            _videoController.pause();
          } else {
            _videoController.play();
          }
          _isPlaying = !_isPlaying;
        });
      },
    );
  }

  Widget _buildShotScore(backend.ShotData shot) {
    Color progressColor = shot.success ? const Color(0xFF41AC20) : const Color(0xFFC82020);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Shot Summary:',
              style: TextStyle(
                color: Color(0xFF397AC5),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              shot.success ? Icons.check_circle : Icons.cancel,
              color: shot.success ? Colors.green : Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: shot.success ? 1.0 : 0.0,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                ),
              ),
              Text(
                shot.success ? 'Success!' : 'Missed!',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildMistakesSection(backend.ShotData shot) {
    List<Mistake> mistakes = generateMistakes(shot);

    if (mistakes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No mistakes found for this shot.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mistakes found in this Shot:',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...mistakes.map((mistake) => _buildMistakeRow(mistake.description, mistake.effect)).toList(),
      ],
    );
  }


  Widget _buildMistakeRow(String mistake, String effect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$mistake: $effect',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPreviousButton(context),
        _buildNextButton(context),
      ],
    );
  }

  Widget _buildPreviousButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _currentShotIndex > 0 ? () => _navigateToShot(_currentShotIndex - 1) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentShotIndex > 0 ? const Color(0xFF397AC5) : Colors.grey,
      ),
      child: const Text('Previous', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _currentShotIndex < widget.shots.length - 1 ? () => _navigateToShot(_currentShotIndex + 1) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentShotIndex < widget.shots.length - 1 ? const Color(0xFF397AC5) : Colors.grey,
      ),
      child: const Text('Next', style: TextStyle(color: Colors.white)),
    );
  }
}
