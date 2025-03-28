import 'package:flutter/material.dart';
import 'package:swish_app/calibration.dart';
import 'package:swish_app/symposium_summary_general.dart';
import 'package:swish_app/training_in_progress.dart';
import 'package:swish_app/services/phone_service.dart';
import 'package:swish_app/services/ble_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BleService bleService = BleService();

  bool _showOverlay = false;
  String? _selectedArm; // Track selected button
  final TextEditingController _feetController = TextEditingController(); // Height (feet)
  final TextEditingController _inchesController = TextEditingController(); // Height (inches)

  void _onButtonPressed(String text) {
    if (text == 'Start Training') {
      setState(() {
        _showOverlay = true;
      });
    }
  }

  Widget _buildButton(String text) {
    return GestureDetector(
      onTap: () => _onButtonPressed(text), // ✅ Calls the updated function
      child: Container(
        width: 315,
        height: 88,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: const Color(0xFF397AC5),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: const Color(0x33397AC5)),
            borderRadius: BorderRadius.circular(8),
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
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w700,
              height: 1.50,
              letterSpacing: 0.50,
            ),
          ),
        ),
      ),
    );
  }

  /// Popup menu
  Widget _buildPopupContent() {
    return Container(
      width: 325,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8, // Adaptive height
      ),
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.black.withOpacity(0.12)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Please select the following options before getting started:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildSelectionCard(),
          const SizedBox(height: 24), // Add spacing
          _buildFinalButtons(), // Move buttons outside the card
        ],
      ),
    );
  }

  Widget _buildSelectionCard() {
    return Container(
      width: 277,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: const Color(0x3F397AC5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeightInput(), // ✅ Height input added here
          const SizedBox(height: 24),
          _buildQuestion(
            'Which arm is the sleeve currently on?',
            _buildArmSelection(),
          ),
        ],
      ),
    );
  }

  /// Height input widget
  Widget _buildHeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your height:',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildHeightField('ft', _feetController),
            const SizedBox(width: 12), // Add spacing between fields
            _buildHeightField('in', _inchesController),
          ],
        ),
      ],
    );
  }

  Widget _buildHeightField(String label, TextEditingController controller) {
    return Expanded(
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF397AC5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: label,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(bottom: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(String question, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildArmSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSelectableButton('Left'),
        _buildSelectableButton('Right'),
      ],
    );
  }

  Widget _buildSelectableButton(String text) {
    bool isSelected = _selectedArm == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedArm = text; // Update selected button
          });
        },
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF397AC5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1, color: const Color(0xFF397AC5)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF397AC5),
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),
        ),
      ),
    );
  }

  /// Final buttons (Cancel / Start Training)
  Widget _buildFinalButtons() {
    // Determine if Start Training button should be enabled
    bool isStartButtonEnabled = _selectedArm != null && _isHeightValid();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRoundedButton('Cancel', Colors.white, const Color(0xFF397AC5), true),
        const SizedBox(width: 8), // Adjust spacing to fit within layout
        _buildRoundedButton(
          'Start Training',
          isStartButtonEnabled ? const Color(0xFF397AC5) : Colors.grey,
          Colors.white,
          isStartButtonEnabled,
        ),
      ],
    );
  }

  /// Button with rounded corners
  Widget _buildRoundedButton(String text, Color bgColor, Color textColor, bool isEnabled) {
    return GestureDetector(
      onTap: isEnabled
          ? () async {
        if (text == 'Cancel') {
          setState(() {
            _showOverlay = false;
          });
        } else if (text == 'Start Training') {
          // Validate and parse height input
          if (_selectedArm != null && _isHeightValid()) {
            int feet = int.tryParse(_feetController.text) ?? 0;
            int inches = int.tryParse(_inchesController.text) ?? 0;
            int totalInches = (feet * 12) + inches; // Convert height to inches
            double heightInCm = totalInches * 2.54;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrainingInProgress(
                  bleService: bleService,
                  heightInCm: totalInches, // Pass height in inches
                  selectedArm: _selectedArm!.toLowerCase(),
                ),
              ),
            );
          }
        }
      }
          : null, // Disable onTap if button is not enabled
      child: Container(
        width: 130,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: isEnabled ? const Color(0xFF397AC5) : Colors.grey),
        ),
        child: FittedBox(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Validate height input
  bool _isHeightValid() {
    int feet = int.tryParse(_feetController.text) ?? 0;
    int inches = int.tryParse(_inchesController.text) ?? 0;

    if (feet <= 0 || inches < 0 || inches >= 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid height (e.g., 5 ft 11 in)'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 411,
        height: 1000,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: Color(0xFF66B9FE),
          image: DecorationImage(
            image: AssetImage('assets/balls_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 411,
                height: MediaQuery.of(context).padding.top + 64,
                padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
                decoration: const BoxDecoration(color: Color(0xFF397AC5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(
                      Icons.menu,
                      size: 32,
                      color: Colors.white,
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
                    Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.account_circle,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              top: MediaQuery.of(context).padding.top + 64,
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
                        shadows: const [
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
                          _buildButton('Symposium Sample Screens'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showOverlay)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: _buildPopupContent(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
