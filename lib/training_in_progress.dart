import 'package:flutter/services.dart'; // Required for SystemChrome
import 'package:flutter/material.dart';
import 'package:swish_app/session_complete.dart';

class TrainingInProgress extends StatefulWidget {
  @override
  _TrainingInProgressState createState() => _TrainingInProgressState();
}

class _TrainingInProgressState extends State<TrainingInProgress> {
  bool bodyInFrame = false; // Condition to toggle frame detection

  @override
  Widget build(BuildContext context) {
    // Make the status bar overlay match the header color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar background transparent
      statusBarIconBrightness: Brightness.light, // Make status bar icons white
    ));

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF66B9FE),
          image: const DecorationImage(
            image: AssetImage('assets/balls_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildTrainingCard(),
                      ),
                      const SizedBox(height: 24),
                      _buildEndTrainingButton(),
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

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).padding.top + 64, // Extend to the very top
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top, // Align content properly
        left: 12,
        right: 12,
        bottom: 8, // Keep the bottom padding
      ),
      decoration: const BoxDecoration(color: Color(0xFF397AC5)), // Blue background
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(),
          const Text(
            'S.W.I.S.H',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          _buildIconButton(),
        ],
      ),
    );
  }

  Widget _buildIconButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Center(
        child: Icon(Icons.menu, color: Colors.white),
      ),
    );
  }

  Widget _buildTrainingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTrainingStatus(),
          const SizedBox(height: 24),
          _buildBodyFrameAlert(),
        ],
      ),
    );
  }

  Widget _buildTrainingStatus() {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Training in Progress...',
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Time Elapsed: 0m 12s',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildBodyFrameAlert() {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            bodyInFrame ? 'BODY IN FRAME' : 'BODY NOT IN FRAME',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: bodyInFrame ? Colors.white : Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              bodyInFrame = !bodyInFrame;
            });
          },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateZ(3.14),
            child: Container(
              width: 299,
              height: 475,
              decoration: BoxDecoration(
                border: Border.all(
                  color: bodyInFrame ? Color(0xFFDBFFD0) : Color(0xFFFF6060),
                  width: 12,
                ),
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage("https://placehold.co/299x648"),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(child: FlutterLogo()),
            ),
          ),
        ),
      ],
    );
  }

Widget _buildEndTrainingButton() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context, MaterialPageRoute(builder: (context) => SessionComplete()));
        },
        child: Container(
          width: 150,
          height: 48,
          decoration: ShapeDecoration(
            color: const Color(0xFF397AC5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: const Center(
            child: Text(
              'End Training',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}

