import 'dart:math';
import 'package:flutter/material.dart';
import 'package:swish_app/symposium_summary_general.dart';

class SymposiumSummaryIndividualScreen extends StatefulWidget {
  final int initialShotIndex;
  
  const SymposiumSummaryIndividualScreen({
    Key? key, 
    this.initialShotIndex = 0
  }) : super(key: key);

  @override
  _SymposiumSummaryIndividualScreenState createState() => _SymposiumSummaryIndividualScreenState();
}

class _SymposiumSummaryIndividualScreenState extends State<SymposiumSummaryIndividualScreen> {
  int accuracy = 85; // 🔹 Hardcoded Accuracy Score
  int form = 76;
  bool _isDropdownVisible = false;
late int _currentShotIndex = widget.initialShotIndex;

  // Define the shot data - you'll modify the video paths and mistakes here
final List<ShotData> _shotData = [
  ShotData(
    shotNumber: 1,
    videoPath: 'assets/videos/shot_1.mp4',
    score: 86,  // ✅ Example score
    mistakes: [
      Mistake('Elbow Bent to the Right', 'Caused your shot to veer to the right'),
      Mistake('Early Release Timing', 'Caused your shot to be weaker than it needed to be'),
    ],
  ),
  ShotData(
    shotNumber: 2,
    videoPath: 'assets/videos/shot_2.mp4',
    score: 75,  // ✅ Another example score
    mistakes: [
      Mistake('Wrist not aligned', 'Resulted in less accuracy'),
    ],
  ),
  ShotData(
    shotNumber: 3,
    videoPath: 'assets/videos/shot_3.mp4',
    score: 92,  // ✅ High score
    mistakes: [
      Mistake('Shot released too low', 'Didn\'t clear the defender'),
    ],
  ),
  ShotData(
    shotNumber: 4,
    videoPath: 'assets/videos/shot_4.mp4',
    score: 68,  // ✅ Lower score
    mistakes: [
      Mistake('Imbalanced landing', 'Affected recovery time'),
    ],
  ),
    ShotData(
      shotNumber: 5,
      videoPath: 'assets/videos/shot_5.mp4',
      score: 85,
      mistakes: [
        Mistake('Shoulders not square', 'Reduced accuracy'),
        Mistake('Hesitation before release', 'Allowed defender to contest'),
      ],
    ),
    ShotData(
      shotNumber: 6,
      videoPath: 'assets/videos/shot_6.mp4',
      score: 85,
      mistakes: [
        Mistake('Jumping forward too much', 'Caused shot to be long'),
        Mistake('Eyes not on target', 'Reduced focus on rim'),
      ],
    ),
    ShotData(
      shotNumber: 7,
      videoPath: 'assets/videos/shot_7.mp4',
      score: 85,
      mistakes: [
        Mistake('Elbow flared out', 'Affected shot trajectory'),
        Mistake('Not enough leg power', 'Shot fell short'),
      ],
    ),
    ShotData(
      shotNumber: 8,
      videoPath: 'assets/videos/shot_8.mp4',
      score: 85,
      mistakes: [
        Mistake('Off-balance release', 'Reduced accuracy'),
        Mistake('Grip too tight', 'Affected touch on the ball'),
      ],
    ),
  ];

  // Global key for detecting taps outside of dropdown
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
  super.initState();
  _currentShotIndex = widget.initialShotIndex.clamp(0, _shotData.length - 1);
}


  void _toggleDropdown() {
    setState(() {
      _isDropdownVisible = !_isDropdownVisible;
    });
  }

  void _navigateToShot(int shotIndex) {
    setState(() {
      _currentShotIndex = shotIndex;
      _isDropdownVisible = false;
    });
  }

  void _navigateToPreviousShot() {
    if (_currentShotIndex > 0) {
      setState(() {
        _currentShotIndex--;
      });
    }
  }

  void _navigateToNextShot() {
    if (_currentShotIndex < _shotData.length - 1) {
      setState(() {
        _currentShotIndex++;
      });
    }
  }

  // Close dropdown if tapped outside
  void _handleTapOutside() {
    if (_isDropdownVisible) {
      setState(() {
        _isDropdownVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double headerHeight = topPadding + 56; // Reduced padding
    final currentShot = _shotData[_currentShotIndex];

    return GestureDetector(
      onTap: _handleTapOutside,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF66B9FE),
        body: Stack(
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
            CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverHeaderDelegate(
                    minHeight: headerHeight,
                    maxHeight: headerHeight,
                    child: _TopHeader(
                      shotNumber: currentShot.shotNumber,
                      topPadding: topPadding,
                      onTap: _toggleDropdown,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                    child: _buildMainContent(context, currentShot),
                  ),
                ),
              ],
            ),
            if (_isDropdownVisible)
              Positioned(
                top: headerHeight - 8, // Reduced padding by 8 pixels
                left: (MediaQuery.of(context).size.width - 323) / 2,
                child: GestureDetector(
                  // This prevents taps on the dropdown from closing it
                  onTap: (){ },
                  child: _buildDropdownContent(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownContent() {
    // Define shot status colors
    const Map<int, Color> shotColors = {
      0: Color(0xFFDBFFD0), // Light green for shot 1
      1: Color(0xFF41AC20), // Regular green
      2: Color(0xFF41AC20),
      3: Color(0xFF9BDE87),
      4: Color(0xFFFFD0D0),
      5: Color(0xFF9BDE87), 
      6: Color(0xFF9BDE87), // Red
      7: Color(0xFFDC7272), // Light red
    };

    // Create a grid layout with 2 rows of 4 shots each
    return Container(
      width: 323,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Shots 1-4
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) => _buildShotItem(index, shotColors[index] ?? const Color(0xFF9BDE87))),
          ),
          const SizedBox(height: 12),
          // Row 2: Shots 5-8
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) => _buildShotItem(index + 4, shotColors[index + 4] ?? const Color(0xFF9BDE87))),
          ),
        ],
      ),
    );
  }

  Widget _buildShotItem(int index, Color color) {
    final shotNumber = index + 1;
    final isSelected = index == _currentShotIndex;
    
    return GestureDetector(
      onTap: () => _navigateToShot(index),
      child: Container(
        width: 60,
        height: 60,
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isSelected
                ? BorderSide(width: 4, color: const Color(0xFF66B9FE))
                : BorderSide.none,
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            shotNumber.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ShotData shot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWhiteCard(shot),
        const SizedBox(height: 24),
        _buildNavigationButtons(context),
      ],
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
    return Opacity(
      opacity: _currentShotIndex > 0 ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: _currentShotIndex > 0 ? _navigateToPreviousShot : null,
        child: Container(
          width: 109,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 2,
                color: Color(0xFF397AC5),
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Previous',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF397AC5),
                fontSize: 14,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: 0.10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Opacity(
      opacity: _currentShotIndex < _shotData.length - 1 ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: _currentShotIndex < _shotData.length - 1 ? _navigateToNextShot : null,
        child: Container(
          width: 109,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: ShapeDecoration(
            color: const Color(0xFF397AC5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Next',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: 0.10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteCard(ShotData shot) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      shadows: const [
        BoxShadow(
          color: Color(0x3F000000),
          blurRadius: 4,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShotScore(shot.score),  // ✅ Show the shot score
        const SizedBox(height: 24),
        _buildVideoReplaySection(shot),
        const SizedBox(height: 24),
        _buildMistakesSection(shot),
      ],
    ),
  );
}

  Widget _buildVideoReplaySection(ShotData shot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video Replay:',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 24,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            height: 1.17,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 8),
        // Video component - replace with actual video player in your implementation
        Container(
          width: 314,
          height: 457,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Video Player: ${shot.videoPath}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMistakesSection(ShotData shot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mistakes found in this Shot:',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 24,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            height: 1.17,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: Color(0xFFDBEFFF),
              ),
            ),
          ),
          child: _buildMistakesTable(shot),
        ),
      ],
    );
  }

  Widget _buildMistakesTable(ShotData shot) {
    return Column(
      children: [
        _buildTableRow('Mistake', 'How This Affected Your Shot', isHeader: true),
        ...shot.mistakes.asMap().entries.map((entry) {
          int index = entry.key;
          Mistake mistake = entry.value;
          
          return _buildTableRow(
            mistake.description,
            mistake.effect,
            backgroundColor: index.isEven
                ? const Color(0xFFDBEFFF)
                : Colors.white,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableRow(String col1, String col2,
      {Color backgroundColor = Colors.white, bool isHeader = false}) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontFamily: 'Montserrat',
      fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
      decoration: isHeader ? TextDecoration.none : TextDecoration.underline,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: Text(
              col1,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              col2,
              textAlign: TextAlign.center,
              style: isHeader ? textStyle : textStyle.copyWith(decoration: null),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildShotScore(int shotScore) {
  Color progressColor = shotScore > 80
      ? const Color(0xFF41AC20)  // ✅ Green for high scores
      : (shotScore >= 50 ? const Color(0xFFFFC107) : const Color(0xFFC92121)); // Yellow/Red for lower scores

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () => _showShotScorePopup(context, 83, accuracy, form),
        child: Row(
          children: [
            const Text(
              'Shot Score:',
              style: TextStyle(
                color: Color(0xFF397AC5),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.info_outline, size: 24, color: Color(0xFF397AC5)),
          ],
        ),
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
                value: shotScore / 100,
                strokeWidth: 20,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
            Text(
              '$shotScore%',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
}

void _showShotScorePopup(BuildContext context, int shotScore, int accuracy, int form) {
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
            'Shot Score',
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This score is based on your shot accuracy and form. See your breakdown below:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Accuracy & Form Scores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreColumn('Accuracy', accuracy),
              _buildScoreColumn('Form', form),
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


/// Custom sliver header delegate for a sticky header.
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;
  
  _SliverHeaderDelegate({required this.minHeight, required this.maxHeight, required this.child});
  
  @override
  double get minExtent => minHeight;
  
  @override
  double get maxExtent => max(maxHeight, minHeight);
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }
  
  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
           minHeight != oldDelegate.minHeight ||
           child != oldDelegate.child;
  }
}

/// Top header widget with dropdown toggle callback.
class _TopHeader extends StatelessWidget {
  final VoidCallback onTap;
  final double topPadding;
  final int shotNumber;
  
  const _TopHeader({
    Key? key, 
    required this.onTap, 
    required this.topPadding,
    required this.shotNumber,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 411,
      height: topPadding + 64,
      padding: EdgeInsets.only(top: topPadding, left: 12, right: 12, bottom: 8),
      decoration: const BoxDecoration(color: Color(0xFF397AC5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Back arrow button with navigation
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: const Color(0x1EC8C8C8)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Individual Summary - Shot ${shotNumber}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF397AC5),
                        fontSize: 20,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Chevron down arrow.
                    const Icon(Icons.expand_more, size: 23, color: Color(0xFF397AC5)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Invisible widget for symmetry
          const SizedBox(width: 24, height: 24),
        ],
      ),
    );
  }
}

/// Data model for shot information
class ShotData {
  final int shotNumber;
  final String videoPath;
  final int score;  // ✅ Added shot score
  final List<Mistake> mistakes;
  
  ShotData({
    required this.shotNumber,
    required this.videoPath,
    required this.score,  // ✅ Initialize shot score
    required this.mistakes,
  });
}


/// Data model for mistake information
class Mistake {
  final String description;
  final String effect;
  
  Mistake(this.description, this.effect);
}