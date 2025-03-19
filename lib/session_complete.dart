import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swish_app/symposium_summary_screen.dart';

class SessionComplete extends StatefulWidget {
  final String? videoPath;
  final Future<void> uploadFuture;

  const SessionComplete({Key? key, this.videoPath, required this.uploadFuture}) : super(key: key);

  @override
  _SessionCompleteState createState() => _SessionCompleteState();
}

class _SessionCompleteState extends State<SessionComplete> {
  bool _isUploading = true;

  @override
  void initState() {
    super.initState();
    widget.uploadFuture.then((_) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }).catchError((e) {
      print("Upload error: $e");
      if (mounted) {
        setState(() {
          _isUploading = false; // Optionally handle error UI
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: Stack(
        children: [
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 64,
              color: const Color(0xFF397AC5),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSessionCard(context),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          const SizedBox(height: 24),

          _isUploading
              ? const CircularProgressIndicator()
              : ElevatedButton(
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
                context,
                MaterialPageRoute(
                  builder: (context) => SymposiumSummaryScreen(videoPath: widget.videoPath),
                ),
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
