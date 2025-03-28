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
  //double _shotCount = 5; // Slider initial value

void _onButtonPressed(String text) {
  if (text == 'Start Training') {
    setState(() {
      _showOverlay = true;
    });
  } else if (text == 'Symposium Sample Screens') {
    // Navigate to the pre-existing screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SymposiumSummaryGeneralScreen(), // Replace with actual screen class
      ),
    );
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
        Text(
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
      border: Border.all(width: 1, color: Color(0x3F397AC5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestion(
          'Which arm is the sleeve currently on?',
          _buildArmSelection(),
        ),
        //const SizedBox(height: 24), SLIDER UI
        //_buildQuestion(
          //'Please select how many shots you will be taking during the training session',
          //_buildShotSelection(),
        //),
      ],
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
        style: TextStyle(
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
            color: isSelected ? Color(0xFF397AC5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1, color: Color(0xFF397AC5)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Color(0xFF397AC5),
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),
        ),
      ),
    );
  }

/* slider widget
 Widget _buildShotSelection() {
    return Column(
      children: [
        Slider(
          value: _shotCount,
          min: 5,
          max: 15,
          divisions: 10,
          activeColor: Color(0xFF397AC5), // Blue slider
          inactiveColor: Colors.grey[300],
          onChanged: (value) {
            setState(() {
              _shotCount = value; // Update slider value
            });
          },
        ),
        const SizedBox(height: 16), // Add spacing
        Text(
          _shotCount.toInt().toString(), // Convert to int for display
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 48,
            fontWeight: FontWeight.w600,
            height: 0.5,
          ),
        ),
      ],
    );
  }
*/

Widget _buildFinalButtons() {
  // Determine if Start Training button should be enabled
  bool isStartButtonEnabled = _selectedArm != null;
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildRoundedButton('Cancel', Colors.white, Color(0xFF397AC5), true),
      const SizedBox(width: 8), // Adjust spacing to fit within layout
      _buildRoundedButton(
        'Start Training', 
        isStartButtonEnabled ? Color(0xFF397AC5) : Colors.grey, 
        Colors.white,
        isStartButtonEnabled
      ),
    ],
  );
}

  Widget _buildRoundedButton(String text, Color bgColor, Color textColor, bool isEnabled) {
    return GestureDetector(
      onTap: isEnabled ? () async {
        if (text == 'Cancel') {
          setState(() {
            _showOverlay = false;
          });
        } else if (text == 'Start Training') {
          // Only proceed if an arm is selected
          if (_selectedArm != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrainingInProgress(
                  bleService: bleService,
                  selectedArm: _selectedArm!.toLowerCase(), // Pass the selected arm
                ),
              ),
            );
          }
        }
      } : null, // Disable onTap if button is not enabled
      child: Container(
        width: 130,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: isEnabled ? Color(0xFF397AC5) : Colors.grey),
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using your background with an asset image.
      body: Container(
        width: 411,
        height: 1000,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF66B9FE),
          image: const DecorationImage(
            image: AssetImage('assets/balls_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Header.
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
            // Main card with buttons.
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
                        shadows: [
                          BoxShadow(
                            color: const Color(0x3F000000),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
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
            // Overlay: black rectangle with 70% opacity plus popup.
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