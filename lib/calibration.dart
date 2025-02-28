import 'package:flutter/material.dart';

class Calibration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 64;

    return Scaffold(
      body: Container(
        width: 411,
        decoration: BoxDecoration(color: Color(0xFF66B9FE)),
        child: Stack(
          children: [
            _buildHeader(context),
            Positioned(
              left: 24,
              top: topPadding,
              child: Container(
                width: 363,
                height: MediaQuery.of(context).size.height - topPadding,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCalibrationCard(),
                      const SizedBox(height: 48), // Padding before buttons
                      _buildBottomButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        width: 411,
        height: MediaQuery.of(context).padding.top + 64,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
        decoration: BoxDecoration(color: Color(0xFF397AC5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.menu, size: 32, color: Colors.white),
            Text(
              'S.W.I.S.H',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
            Icon(Icons.account_circle, size: 32, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationCard() {
    return Container(
      width: 363,
      padding: const EdgeInsets.all(32),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: [
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
          Text(
            'Calibration',
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 32,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Place the camera where it can view your body from the side as seen in the diagram below',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 18,
              fontFamily: 'Open Sans',
            ),
          ),
          const SizedBox(height: 16),
          _buildImagePlaceholder(),
          const SizedBox(height: 24),
          _buildShotSelector(),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 299,
      height: 399,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://placehold.co/299x399"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildShotSelector() {
    return Column(
      children: [
        Text(
          'Please select how many shots you are going to take in this session:',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 18,
            fontFamily: 'Open Sans',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '5', // Default selected value
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 48,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          value: 5,
          min: 5,
          max: 15,
          divisions: 2,
          label: '5',
          onChanged: (value) {
            // Implement state management to update selected value
          },
          activeColor: Color(0xFF397AC5),
          inactiveColor: Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildButton('Cancel', Colors.white, Color(0xFF397AC5)),
        _buildButton('Start Training', Color(0xFF397AC5), Colors.white),
      ],
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor) {
    return SizedBox(
      width: 150,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: Color(0xFF397AC5)),
          ),
          elevation: 4,
        ),
        onPressed: () {
          // Add navigation or functionality here
        },
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
