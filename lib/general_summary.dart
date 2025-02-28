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

  // Helper widget for table data rows using RichText so that the info icon is inline and baseline-aligned.
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
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '$col1 ',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
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

  // Builds the repeated mistakes table using the helper widgets.
  static Widget buildMistakesTable() {
    return Center(
      child: Container(
        width: 314,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              strokeAlign: BorderSide.strokeAlignOutside,
              color: Color(0xFFDBEFFF),
            ),
          ),
        ),
        child: Column(
          children: [
            tableHeaderRow(col1: 'Mistake', col2: 'Shots Affected'),
            tableDataRow(
              col1: 'Untucked Elbow',
              col2: '1, 3, 7, 8, 9, 14',
              backgroundColor: const Color(0xFFDBEFFF),
            ),
            tableDataRow(
              col1: 'Poor Release Timing',
              col2: '1, 2, 4, 6, 8, 9, 12, 14',
              backgroundColor: Colors.white,
            ),
            tableDataRow(
              col1: 'Poor Follow Through',
              col2: '1, 5, 8, 9, 14',
              backgroundColor: const Color(0xFFDBEFFF),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the consistency table using the helper widgets.
  static Widget buildConsistencyTable() {
    return Center(
      child: Container(
        width: 314,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              strokeAlign: BorderSide.strokeAlignOutside,
              color: Color(0xFFDBEFFF),
            ),
          ),
        ),
        child: Column(
          children: [
            tableHeaderRow(col1: 'Aspect of Shot', col2: 'Consistency'),
            tableDataRow(
              col1: 'Elbow Alignment with Ball',
              col2: 'High Variation',
              backgroundColor: const Color(0xFFDBEFFF),
            ),
            tableDataRow(
              col1: 'Wrist Position at Release',
              col2: 'Medium Variation',
              backgroundColor: Colors.white,
            ),
            tableDataRow(
              col1: 'Speed throughout Shot',
              col2: 'Low Variation',
              backgroundColor: const Color(0xFFDBEFFF),
            ),
          ],
        ),
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
          _buildAccuracySection(),
          const SizedBox(height: 24),
          _buildShotsSection(),
          const SizedBox(height: 24),
          // Repeated Mistakes Table Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Repeated Mistakes:',
                style: TextStyle(
                  color: Color(0xFF397AC5),
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'These repeated issues are affecting your shooting form.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              buildMistakesTable(),
            ],
          ),
          const SizedBox(height: 24),
          // Consistency Table Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Consistency:',
                style: TextStyle(
                  color: Color(0xFF397AC5),
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The table below shows aspects of your shots that tended to vary in the session.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              buildConsistencyTable(),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildAccuracySection() {
    const double accuracy = 80;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accuracy:',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 24,
            fontWeight: FontWeight.w400,
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
                  value: accuracy / 100,
                  strokeWidth: 24,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF397AC5)),
                ),
              ),
              Text(
                '${accuracy.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Color(0xFF397AC5),
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'In this session you made 12/15 shots',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  static Widget _buildShotsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Your Shots:',
        style: TextStyle(
          color: Color(0xFF397AC5),
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 15,
        itemBuilder: (context, index) {
          // Define color mapping based on index
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

// Updated _buildGridItem to take a single color instead of a list
static Widget _buildGridItem(int index, Color color) {
  return Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
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