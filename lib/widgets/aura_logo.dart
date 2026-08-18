import 'package:flutter/material.dart';

class AuraLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final TextStyle? textStyle;

  const AuraLogo({
    super.key,
    this.size = 42.0,
    this.showText = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF10141C),
        borderRadius: BorderRadius.circular(size * 0.26),
        border: Border.all(
          color: const Color(0xFF1DB954).withOpacity(0.4),
          width: size * 0.03,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DB954).withOpacity(0.25),
            blurRadius: size * 0.3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.65, size * 0.65),
          painter: _AuraWavePainter(),
        ),
      ),
    );

    if (!showText) return iconWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        SizedBox(width: size * 0.22),
        Flexible(
          child: Text(
            'AuraMusic',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle ??
                TextStyle(
                  fontSize: size * 0.52,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
          ),
        ),
      ],
    );
  }
}

class _AuraWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1DB954), Color(0xFF00E5FF)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 9;
    final r = Radius.circular(barWidth / 2);

    final heights = [0.35, 0.65, 0.90, 1.00, 0.90, 0.65, 0.35];

    for (int i = 0; i < heights.length; i++) {
      final h = size.height * heights[i];
      final x = i * (barWidth + size.width * 0.04);
      final y = (size.height - h) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barWidth, h), r),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
