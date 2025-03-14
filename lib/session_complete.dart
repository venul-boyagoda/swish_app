import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swish_app/general_summary.dart';
import 'package:swish_app/symposium_summary_screen.dart'; // Required for SystemChrome

class SessionComplete extends StatelessWidget {
  final String? videoPath;

  const SessionComplete({Key? key, this.videoPath}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Make the status bar blend with the header
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar background transparent
      statusBarIconBrightness: Brightness.light, // White icons for contrast
    ));

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF66B9FE),
              image: DecorationImage(
                image: AssetImage('assets/balls_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Full Blue Header Including Status Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 64, // Covers status bar
              color: const Color(0xFF397AC5), // Blue header background
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(), // The actual header content remains the same
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSessionCard(context), // Pass context here
                  ),
                  const SizedBox(height: 32), // Extra space to avoid overflow
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header Content (Position Unchanged)
  // Header Content (Fixed Width)
Widget _buildHeader() {
  return Container(
    width: double.infinity,
    height: 64,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: const BoxDecoration(color: Color(0xFF397AC5)),
    child: Center(
      child: Container(
        width: 323, // ✅ Set width to match GeneralSummaryScreen
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
            'Thursday, Jan 23 2025',
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

  // Session Complete Card
  Widget _buildSessionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Session Complete',
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 32,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Good work on taking all your shots! Let’s take a look at how it went',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 20,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
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
                context, // Ensure the correct context is passed here
                MaterialPageRoute(builder: (context) => SymposiumSummaryScreen(videoPath: videoPath)),
              );
            },
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
