import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:swish_app/home_screen.dart';
import 'package:swish_app/individual_summary.dart';
import 'package:swish_app/symposium_summary_individual.dart';


class SymposiumSummaryGeneralScreen extends StatelessWidget {
    const SymposiumSummaryGeneralScreen({Key? key}) : super(key: key);
  

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
        _buildMistakeRow(context,'Pointing your fingers downward at the end of a shot', Color(0xFFDBEFFF)),
        _buildMistakeRow(context, 'Aligning your elbow with the net', Colors.white),
        _buildMistakeRow(context, 'Reducing the time between extending legs and arms', Color(0xFFDBEFFF)),
      ],
    ),
  );
}

// ✅ Updated Improvement Table with Info Icons
static Widget buildImprovementTable() {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Colors.white),
          child: const Text(
            'Improvements from past sessions',
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
        _buildImprovementRow('Elbow is tucked', Color(0xFFDBEFFF)),
        _buildImprovementRow('Arm extension is more consistent', Colors.white),
        _buildImprovementRow('Knee bend is good', Color(0xFFDBEFFF)),
      ],
    ),
  );
}

/// ✅ Updated Improvement Row to Include an Info Icon
static Widget _buildImprovementRow(String text, Color backgroundColor) {
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
  return Center( // ✅ Ensures the entire frame is centered
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24), // ✅ Equal top & bottom padding
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
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ Ensures center alignment
        children: [
          _buildShotScore(context), // ✅ No extra frame around this

          const SizedBox(height: 24),
          _buildShotsSection(context),

          const SizedBox(height: 24),

          /// ✅ Centering "Biggest things to focus on" Table
          Center(child: buildMistakesTable(context)),

          const SizedBox(height: 24),

          /// ✅ Centering "Improvements from past sessions" Table
          Center(child: buildImprovementTable()),
        ],
      ),
    ),
  );
}

Widget _buildShotScore(BuildContext context) {
  const double shotScore = 83;
  Color progressColor = shotScore > 80
      ? const Color(0xFF41AC20)
      : (shotScore >= 50 ? const Color(0xFFFFC107) : const Color(0xFFC92121));

  return Column( // ✅ Remove extra wrapping Container
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Title + Info Button
      GestureDetector(
        onTap: () => _showScorePopup(context), // ✅ Tap to open popup
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

      // Circular Progress Indicator
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
            'This number is calculated using a weighted average of your session accuracy, '
            'the number of mistakes made, and your consistency. See your scores below:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Sections for Accuracy, Form, and Consistency (Form is centered)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // ✅ Equal spacing
            children: [
              _buildScoreColumn('Accuracy', 88), // Example scores
              _buildScoreColumn('Form', 65), // Centered
              _buildScoreColumn('Consistency', 42),
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



static Widget _buildShotsSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Session shot text with bold formatting
      const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'In this session you made ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: '6/8',  // ✅ Bold 12/15
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700, // Bold
              ),
            ),
            TextSpan(
              text: ' shots. ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Click on any number to view a shot in more detail',  // ✅ Bold full sentence
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700, // Bold
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 8), // ✅ Adds 8 pixels of space before the grid

      // Shot Grid
      _buildBestWorstShotSection(),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero, // Ensures no extra space inside the grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          final colorMap = {
            1: const Color(0xFFDBFFD0),
            2: const Color(0xFF41AC20),
            3: const Color(0xFF41AC20),
            4: const Color(0xFF9BDE87),
            5: const Color(0xFFFFD0D0),
            6: const Color(0xFF9BDE87),
            7: const Color(0xFF9BDE87),
            8: const Color(0xFFDC7272),
          };

          final color = colorMap[index + 1] ?? Colors.grey; // Default color

          // Wrap only the first item in a GestureDetector
          if (index == 0) {
return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SymposiumSummaryIndividualScreen(initialShotIndex: index),
      ),
    );
  },
  child: _buildGridItem(context, index, color),
);
          }

          return _buildGridItem(context, index, color);
        },
      ),
    ],
  );
}

static Widget _buildBestWorstShotSection() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShotDetail('Best Shot:', '3', const Color(0xFF41AC20)),
        _buildShotDetail('Worst Shot:', '8', const Color(0xFFC82020)),
      ],
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


// Updated _buildGridItem to take a single color instead of a list
static Widget _buildGridItem(BuildContext context, int index, Color color) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SymposiumSummaryIndividualScreen(initialShotIndex: index),
        ),
      );
    },
    child: MouseRegion(
      cursor: SystemMouseCursors.click, // Show hand cursor on hover
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: color, // ✅ Solid background color instead of gradient
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // ✅ Reduced shadow for a non-shiny look
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12), // ✅ Ripple effect on tap
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SymposiumSummaryIndividualScreen(initialShotIndex: index),
              ),
            );
          },
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.black, // ✅ Ensuring strong contrast
                fontSize: 18, // ✅ Slightly larger text
                decoration: TextDecoration.underline, // ✅ Underline effect
                decorationColor: Colors.black, // ✅ Force black underline
                decorationThickness: 2, // ✅ Make underline thicker
                fontWeight: FontWeight.normal, // ✅ Remove bold
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}