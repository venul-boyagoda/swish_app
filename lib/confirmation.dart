import 'package:flutter/material.dart';

class Confirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 411,
        height: 1000,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: -482,
              child: Container(
                width: 411,
                height: 1000,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: Color(0xFF66B9FE)),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Opacity(
                opacity: 0.70,
                child: Container(
                  width: 411,
                  height: 1000,
                  decoration: BoxDecoration(color: Colors.black),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 411,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(color: Color(0xFF397AC5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: FlutterLogo(size: 24),
                    ),
                    Text(
                      'S.W.I.S.H',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w700,
                        height: 1.27,
                      ),
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: FlutterLogo(size: 24),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              top: 64,
              child: Container(
                width: 363,
                height: 759,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 363,
                      height: 264,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildButton('Start Training'),
                          const SizedBox(height: 24),
                          _buildButton('Training History'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 43,
              top: 232,
              child: _buildPopup(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return Container(
      width: 315,
      height: 88,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Color(0xFF397AC5),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0x33397AC5)),
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
            height: 1.50,
            letterSpacing: 0.50,
          ),
        ),
      ),
    );
  }

  Widget _buildPopup() {
    return Container(
      width: 324,
      height: 184,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.black.withOpacity(0.12)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Text(
            'To begin training you will need to calibrate your sleeve. Are you ready to proceed?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton('No, Cancel'),
              _buildButton('Yes, Continue'),
            ],
          ),
        ],
      ),
    );
  }
}
