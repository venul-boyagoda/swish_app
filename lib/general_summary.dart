import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swish_app/home_screen.dart';
import 'package:swish_app/individual_summary.dart';


class GeneralSummaryScreen extends StatelessWidget {
  const GeneralSummaryScreen({Key? key}) : super(key: key);

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

// ✅ Updated Mistakes Table with Info Icons
static Widget buildMistakesTable() {
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
        _buildMistakeRow('Tuck your elbow while shooting', Color(0xFFDBEFFF)),
        _buildMistakeRow('Release the ball slightly earlier', Colors.white),
        _buildMistakeRow('Hold your follow through after shooting', Color(0xFFDBEFFF)),
      ],
    ),
  );
}

/// ✅ Updated Mistake Row to Include an Info Icon
static Widget _buildMistakeRow(String text, Color backgroundColor) {
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
        _buildImprovementRow('Wrist flick is good', Color(0xFFDBEFFF)),
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
                        _buildSummaryFrame(),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
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
                            context, MaterialPageRoute(builder: (context) => HomeScreen()));
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

  static Widget _buildSummaryFrame() {
  return Container(
    padding: const EdgeInsets.all(24),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShotScore(),
        
        const SizedBox(height: 24), // ✅ Adds 24 pixels of space
        _buildShotsSection(),

        const SizedBox(height: 24), // ✅ Keeps spacing consistent

        buildMistakesTable(),

        const SizedBox(height: 24),

        buildImprovementTable(),
          ],
        ),
  );
}


static Widget _buildShotScore() {
  const double shotScore = 84;

  // Determine progress bar color based on shotScore
  Color progressColor;
  if (shotScore > 80) {
    progressColor = const Color(0xFF41AC20); // Green
  } else if (shotScore >= 50) {
    progressColor = const Color(0xFFFFC107); // Yellow
  } else {
    progressColor = const Color(0xFFC92121); // Red
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ✅ Row containing the bold heading and the blue info icon
      Row(
        children: [
          const Text(
            'Overall Session Score:',
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 24,
              fontWeight: FontWeight.w700, // ✅ Bolded text
            ),
          ),
          const SizedBox(width: 8), // ✅ Space between text and icon
          const Icon(
            Icons.info_outline, // ✅ Blue information icon
            size: 24,
            color: Color(0xFF397AC5),
          ),
        ],
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
                valueColor: AlwaysStoppedAnimation(progressColor), // ✅ Dynamic color
              ),
            ),
            // ✅ Dynamically set text based on shotScore
            Text(
              '${shotScore.toStringAsFixed(0)}%', // Converts double to int-like string
              style: const TextStyle(
                color: Colors.black, // ✅ Ensures text stays black
                fontSize: 48,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

static Widget _buildShotsSection() {
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
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: '12/15',  // ✅ Bold 12/15
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w700, // Bold
              ),
            ),
            TextSpan(
              text: ' shots. ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Click on any number to view a shot in more detail',  // ✅ Bold full sentence
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
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
        itemCount: 15,
        itemBuilder: (context, index) {
          final colorMap = {
            1: const Color(0xFFDBFFD0),
            2: const Color(0xFF9BDE87),
            3: const Color(0xFF9BDE87),
            4: const Color(0xFF9BDE87),
            5: const Color(0xFF9BDE87),
            6: const Color(0xFF9BDE87),
            7: const Color(0xFF9BDE87),
            8: const Color(0xFFC92121),
            9: const Color(0xFFDC7272),
            10: const Color(0xFF41AC20),
            11: const Color(0xFF41AC20),
            12: const Color(0xFF9BDE87),
            13: const Color(0xFF41AC20),
            14: const Color(0xFFFFD0D0),
            15: const Color(0xFF41AC20),
          };

          final color = colorMap[index + 1] ?? Colors.grey; // Default color

          // Wrap only the first item in a GestureDetector
          if (index == 0) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IndividualSummary()),
                );
              },
              child: _buildGridItem(index, color),
            );
          }

          return _buildGridItem(index, color);
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
        _buildShotDetail('Best Shot:', '10', const Color(0xFF41AC20)),
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
static Widget _buildGridItem(int index, Color color) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25), // ✅ Drop shadow
          blurRadius: 4,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topRight,  // ✅ White at the top-right
        end: Alignment.center,  // ✅ Color at the bottom-left
        colors: [
          Colors.white, // ✅ Gradient starts as white
          color,        // ✅ Gradient fades into the original color
        ],
      ),
    ),
    child: Center(
      child: Text(
        '${index + 1}',
        style: const TextStyle(
          color: Color(0xFF111111),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  );
}
}