import 'package:flutter/material.dart';
import 'package:swish_app/training_in_progress.dart';

class PhoneSetup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/balls_background.png'),
            fit: BoxFit.cover,
          ),
          color: const Color(0xFF66B9FE), // Ensure background color
        ),
        child: Column(
          children: [
            _buildTopBar(topPadding),
            Expanded(
              child: Stack(
                children: [
                  _buildContent(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  /// Covers the status bar + header with the same blue color.
  Widget _buildTopBar(double topPadding) {
    return Container(
      width: double.infinity,
      height: topPadding + 64, // Covers status bar & header
      padding: EdgeInsets.only(top: topPadding),
      decoration: const BoxDecoration(color: Color(0xFF397AC5)),
      child: Row(
        children: [
          _buildIconButton(Icons.menu), // Hamburger Menu Icon
          const Expanded(
            child: Text(
              'S.W.I.S.H',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildIconButton(Icons.account_circle), // Profile Icon
        ],
      ),
    );
  }

  /// Builds the icons in the header (left: menu, right: profile)
  Widget _buildIconButton(IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 28),
      onPressed: () {}, // Add functionality if needed
    );
  }

Widget _buildContent(BuildContext context) {
  return Positioned(
    left: 24,
    top: 24, // Adjusted top margin after adding top bar fix
    right: 24, // Ensures proper layout on both sides
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Allows proper alignment of children
      children: [
        _buildCalibrationCard(),
        const SizedBox(height: 24),
        _buildContinueButton(context), // Now correctly aligned to the right
      ],
    ),
  );
}


  Widget _buildCalibrationCard() {
    return Container(
      width: 363,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'Setup Phone Camera',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 32,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Prop your phone as seen below so the net is visible.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 18,
              fontFamily: 'Open Sans',
            ),
          ),
          const SizedBox(height: 8),
          _buildCalibrationImage(),
        ],
      ),
    );
  }

  /// Reduced height by 34 pixels.
  Widget _buildCalibrationImage() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationZ(3.14),
      child: Container(
        width: 299,
        height: 474, // 508 - 34 pixels
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://placehold.co/299x508"),
            fit: BoxFit.cover,
          ),
        ),
        child: const FlutterLogo(),
      ),
    );
  }

  /// Aligned to the right and navigates to the next screen.
  Widget _buildContinueButton(BuildContext context) {
  return Align(
    alignment: Alignment.centerRight, // Ensures button is aligned to the right
    child: GestureDetector(
      onTap: () {
         Navigator.push(
          context, MaterialPageRoute(builder: (context) => TrainingInProgress()));
      },
      child: Container(
        width: 127,
        height: 40,
        margin: const EdgeInsets.only(right: 24), // Ensures spacing from the right edge
        decoration: BoxDecoration(
          color: const Color(0xFF397AC5),
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}



