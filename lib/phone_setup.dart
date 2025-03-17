import 'package:flutter/material.dart';
import 'package:swish_app/training_in_progress.dart';
import 'package:swish_app/services/ble_service.dart';

class PhoneSetup extends StatelessWidget {
  final BleService bleService = BleService();

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
          color: const Color(0xFF66B9FE),
        ),
        child: Column(
          children: [
            _buildTopBar(topPadding),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double topPadding) {
    return Container(
      width: double.infinity,
      height: topPadding + 64,
      padding: EdgeInsets.only(top: topPadding),
      decoration: const BoxDecoration(color: Color(0xFF397AC5)),
      child: Row(
        children: [
          _buildIconButton(Icons.menu),
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
          _buildIconButton(Icons.account_circle),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 28),
      onPressed: () {},
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCalibrationCard(),
        const SizedBox(height: 24),
        _buildContinueButton(context),
      ],
    );
  }

  Widget _buildCalibrationCard() {
    return Container(
      width: double.infinity,
      height: 650,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Setup Phone Camera',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 28,
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
          const SizedBox(height: 16),
          Expanded(child: _buildCalibrationImage()),
        ],
      ),
    );
  }

  Widget _buildCalibrationImage() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationZ(3.14),
      child: Container(
        width: 299,
        height: 474,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://placehold.co/299x508"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () async {
          bool connected = await bleService.connectToIMU();
          if (connected) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrainingInProgress(bleService: bleService),
              ),
            );
          } else {
            print("Failed to connect to IMU");
          }
        },
        child: Container(
          width: 127,
          height: 40,
          margin: const EdgeInsets.only(right: 24),
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
}
