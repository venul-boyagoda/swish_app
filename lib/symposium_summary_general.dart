import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:swish_app/home_screen.dart';
import 'package:swish_app/individual_summary.dart';
import 'package:swish_app/symposium_summary_individual.dart';
import 'package:swish_app/backend/shot_data.dart';
import 'package:swish_app/backend/shot_data.dart' as backend;
import 'package:swish_app/backend/score_calculator.dart';

class SymposiumSummaryGeneralScreen extends StatelessWidget {
  final String? videoPath;
  final List<backend.ShotData> shots;

  const SymposiumSummaryGeneralScreen({Key? key, this.videoPath, required this.shots}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

  double _calculateAverageScore() {
    final total = shots.fold<double>(
      0,
          (sum, shot) => sum + SummaryScoreCalculator.calculateShotScore(shot),
    );
    return (total / shots.length).clamp(0, 100);
  }

  int _getBestShotIndex() {
    double bestScore = double.negativeInfinity;
    int bestIndex = 0;
    for (int i = 0; i < shots.length; i++) {
      final score = SummaryScoreCalculator.calculateShotScore(shots[i]);
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  int _getWorstShotIndex() {
    double worstScore = double.infinity;
    int worstIndex = 0;
    for (int i = 0; i < shots.length; i++) {
      final score = SummaryScoreCalculator.calculateShotScore(shots[i]);
      if (score < worstScore) {
        worstScore = score;
        worstIndex = i;
      }
    }
    return worstIndex;
  }

  Widget _buildSummaryFrame(BuildContext context) {
    int made = shots.where((s) => s.success).length;
    int total = shots.length;
    int bestIndex = _getBestShotIndex();
    int worstIndex = _getWorstShotIndex();

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
            _buildShotsSection(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildShotsSection(BuildContext context) {
    int made = shots.where((s) => s.success).length;
    int total = shots.length;
    int bestIndex = _getBestShotIndex();
    int worstIndex = _getWorstShotIndex();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'In this session you made ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
              ),
              TextSpan(
                text: '$made/$total',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              const TextSpan(
                text: ' shots. Click on any number to view a shot in more detail',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShotDetail('Best Shot:', '${bestIndex + 1}', const Color(0xFF41AC20)),
              _buildShotDetail('Worst Shot:', '${worstIndex + 1}', const Color(0xFFC82020)),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: shots.length,
          itemBuilder: (context, index) {
            final shot = shots[index];
            final score = SummaryScoreCalculator.calculateShotScore(shot);
            Color color;
            if (score >= 80) {
              color = const Color(0xFF41AC20);
            } else if (score >= 60) {
              color = const Color(0xFF9BDE87);
            } else if (score >= 40) {
              color = const Color(0xFFFFD0D0);
            } else {
              color = const Color(0xFFDC7272);
            }

            return _buildGridItem(context, index, color);
          },
        ),
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, int index, Color color) {
    final shots = (context.findAncestorWidgetOfExactType<SymposiumSummaryGeneralScreen>()!).shots;
    final videoPath = (context.findAncestorWidgetOfExactType<SymposiumSummaryGeneralScreen>()!).videoPath;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SymposiumSummaryIndividualScreen(
              initialShotIndex: index,
              shots: shots,  // ✅ Pass the shots correctly
              videoPath: videoPath ?? '', // ✅ Pass videoPath with fallback
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${index + 1}', // ✅ Show shot number dynamically
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                decoration: TextDecoration.underline,
                decorationColor: Colors.black,
                decorationThickness: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }


  static Widget _buildShotDetail(String label, String value, Color labelColor) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              color: labelColor,
              fontSize: 16,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: ' $value',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
