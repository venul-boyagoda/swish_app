import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:swish_app/general_summary.dart';

class IndividualSummary extends StatefulWidget {
  const IndividualSummary({Key? key}) : super(key: key);

  @override
  _IndividualSummaryState createState() => _IndividualSummaryState();
}

class _IndividualSummaryState extends State<IndividualSummary> {
  bool _isDropdownVisible = false;

  void _toggleDropdown() {
    setState(() {
      _isDropdownVisible = !_isDropdownVisible;
    });
  }

 @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double headerHeight = topPadding + 56; // Reduced padding

    return Scaffold(
      backgroundColor: const Color(0xFF66B9FE),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/balls_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverHeaderDelegate(
                  minHeight: headerHeight,
                  maxHeight: headerHeight,
                  child: _TopHeader(
                    topPadding: topPadding,
                    onTap: _toggleDropdown,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                  child: _buildMainContent(context),
                ),
              ),
            ],
          ),
if (_isDropdownVisible)
  Positioned(
    top: headerHeight - 8, // Reduced padding by 8 pixels
    left: (MediaQuery.of(context).size.width - 323) / 2,
    child: _buildDropdownContent(),
  ),
        ],
      ),
    );
  }

  Widget _buildDropdownContent() {
    const List<Color> colors = [
      Color(0xFFDBFFD0), Color(0xFF9BDE87), Color(0xFF9BDE87), Color(0xFF9BDE87),
      Color(0xFF9BDE87), Color(0xFF9BDE87), Color(0xFF9BDE87), Color(0xFFC92121),
      Color(0xFFDC7272), Color(0xFF41AC20), Color(0xFF41AC20), Color(0xFF9BDE87),
      Color(0xFF41AC20), Color(0xFFFFD0D0), Color(0xFF41AC20),
    ];

    return Container(
      width: 323,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: 15,
        itemBuilder: (context, index) {
          final number = (index + 1).toString().padLeft(2, '0');
          return Container(
            decoration: ShapeDecoration(
              color: colors[index],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: index == 0
                    ? BorderSide(width: 4, color: const Color(0xFF66B9FE))
                    : BorderSide.none,
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildPreviousButton(BuildContext context) {
  return Align(
    alignment: Alignment.centerLeft, // ✅ Left align the button
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GeneralSummaryScreen()), // ✅ Replace with your actual screen
        );
      },
      child: Container(
        width: 109, // ✅ Fixed width of 109 pixels
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12), // Adjust padding if needed
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 2, // ✅ Doubled the thickness from 1 to 2
              color: Color(0xFF397AC5),
            ),
            borderRadius: BorderRadius.circular(100),
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
            'Previous',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF397AC5),
              fontSize: 14,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w400,
              height: 1.43,
              letterSpacing: 0.10,
            ),
          ),
        ),
      ),
    ),
  );
}


  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWhiteCard(),
        const SizedBox(height: 24),
        _buildPreviousButton(context),
      ],
    );
  }

  Widget _buildWhiteCard() {
    return Container(
      width: double.infinity,
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVideoReplaySection(),
          const SizedBox(height: 24),
          _buildMistakesSection(),
        ],
      ),
    );
  }

  Widget _buildVideoReplaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video Replay:',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 24,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            height: 1.17,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 8),
        Transform.rotate(
          angle: pi,
          child: Container(
            width: 314,
            height: 457,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://placehold.co/314x457"),
                fit: BoxFit.cover,
              ),
            ),
            child: const FlutterLogo(),
          ),
        ),
      ],
    );
  }

  Widget _buildMistakesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mistakes found in this Shot:',
          style: TextStyle(
            color: Color(0xFF397AC5),
            fontSize: 24,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            height: 1.17,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: const Color(0xFFDBEFFF),
              ),
            ),
          ),
          child: _buildMistakesTable(),
        ),
      ],
    );
  }

  Widget _buildMistakesTable() {
    return Column(
      children: [
        _buildTableRow('Mistake', 'How This Affected Your Shot', isHeader: true),
        _buildTableRow(
          'Elbow Bent to the Right',
          'Caused your shot to veer to the right',
          backgroundColor: const Color(0xFFDBEFFF),
        ),
        _buildTableRow(
          'Early Release Timing',
          'Caused your shot to be weaker than it needed to be',
          backgroundColor: Colors.white,
        ),
        _buildTableRow(
          'Didn’t Hold Follow Through',
          'Caused your shot to be weaker than it needed to be',
          backgroundColor: const Color(0xFFDBEFFF),
        ),
      ],
    );
  }

  Widget _buildTableRow(String col1, String col2,
      {Color backgroundColor = Colors.white, bool isHeader = false}) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontFamily: 'Montserrat',
      fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
      decoration: isHeader ? TextDecoration.none : TextDecoration.underline,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: Text(
              col1,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              col2,
              textAlign: TextAlign.center,
              style: isHeader ? textStyle : textStyle.copyWith(decoration: null),
            ),
          ),
        ],
      ),
    );
  }


  /// Dropdown content using a Wrap (reverting to original element sizes)
  /// arranged in 5 columns and 3 rows.
  Widget _buildDropdownContent() {
    return Container(
    width: 323, // Ensure consistent width
    padding: const EdgeInsets.all(16),
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      shadows: const [
        BoxShadow(
          color: Color(0x3F000000),
          blurRadius: 4,
          offset: Offset(0, 4),
        )
      ],
    ),
    child: GridView.builder(
      shrinkWrap: true, // Ensures it doesn't expand infinitely
      physics: const NeverScrollableScrollPhysics(), // Prevents scrolling inside
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 items per row
        mainAxisSpacing: 12, // Adjust spacing between rows
        crossAxisSpacing: 12, // Adjust spacing between columns
        childAspectRatio: 1, // Ensures uniform circle sizes
      ),
      itemCount: 15, // 5 columns * 3 rows = 15 items
      itemBuilder: (context, index) {
        final number = (index + 1).toString().padLeft(2, '0');
        return Container(
          decoration: ShapeDecoration(
            color: index == 0 ? const Color(0xFFDBFFD0) : const Color(0xFF9BDE87),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: index == 0
                  ? BorderSide(
                      width: 4,
                      color: const Color(0xFF66B9FE),
                    )
                  : BorderSide.none,
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      },
    ),
  );
  }


/// Custom sliver header delegate for a sticky header.
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;
  
  _SliverHeaderDelegate({required this.minHeight, required this.maxHeight, required this.child});
  
  @override
  double get minExtent => minHeight;
  
  @override
  double get maxExtent => max(maxHeight, minHeight);
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }
  
  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
           minHeight != oldDelegate.minHeight ||
           child != oldDelegate.child;
  }
}

/// Top header widget with dropdown toggle callback.
class _TopHeader extends StatelessWidget {
  final VoidCallback onTap;
  final double topPadding;
  const _TopHeader({Key? key, required this.onTap, required this.topPadding}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 411,
      height: topPadding + 64,
      padding: EdgeInsets.only(top: topPadding, left: 12, right: 12, bottom: 8),
      decoration: const BoxDecoration(color: Color(0xFF397AC5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Back arrow button with navigation
          GestureDetector(
            onTap: () {
               Navigator.push(
                context, MaterialPageRoute(builder: (context) => GeneralSummaryScreen()));
            },
            child: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: const Color(0x1EC8C8C8)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Individual Summary - Shot 1',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF397AC5),
                        fontSize: 20,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Chevron down arrow.
                    const Icon(Icons.expand_more, size: 23, color: Color(0xFF397AC5)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Invisible widget for symmetry
          const SizedBox(width: 24, height: 24),
        ],
      ),
    );
  }
}

