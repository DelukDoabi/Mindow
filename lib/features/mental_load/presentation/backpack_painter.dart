import 'package:flutter/material.dart';

/// Draws the Mindow animated backpack.
///
/// [bandValue] drives all heaviness visuals continuously from 0.0 (léger)
/// to 3.0 (très lourd): body squish, shadow depth, and glow intensity all
/// increase proportionally.
///
/// Intended to be used inside a fixed 180×180 dp [SizedBox].
class BackpackPainter extends CustomPainter {
  const BackpackPainter({
    required this.bandValue,
    required this.warmColor,
    required this.glowColor,
  });

  /// Continuous band value in [0.0, 3.0].
  final double bandValue;

  /// Peach warm colour for the body gradient (e.g. `AuroreColors.warm`).
  final Color warmColor;

  /// Translucent warm colour for the radial glow (e.g. warm.withValues(alpha:0.18)).
  final Color glowColor;

  // ---------------------------------------------------------------------------
  // Coordinate helpers (all relative to [size], which equals 180×180 dp)
  // ---------------------------------------------------------------------------

  static const double _bodyWidthFraction = 0.68;
  static const double _bodyTopFraction = 0.22;
  static const double _bodyBaseHeight = 0.62; // fraction at léger (bandValue=0)
  static const double _sagPerBand = 0.06; // fraction subtracted per band unit

  static const double _lidHeightFraction = 0.10;
  static const double _pocketWidthFrac = 0.25;
  static const double _pocketHeightFrac = 0.22;
  static const double _buckleW = 10; // logical dp at 180 size
  static const double _buckleH = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final sag = (_sagPerBand * bandValue).clamp(0.0, 0.24);
    final bodyWidth = size.width * _bodyWidthFraction;
    final bodyTop = size.height * _bodyTopFraction;
    final bodyHeight = size.height * (_bodyBaseHeight - sag);
    final bodyLeft = (size.width - bodyWidth) / 2;

    // 1. Radial warm glow (drawn first, behind everything)
    _drawGlow(canvas, size, bodyTop, bodyHeight, bodyLeft, bodyWidth);

    // 2. Shadow below body
    _drawShadow(canvas, size, bodyTop, bodyHeight, bodyLeft, bodyWidth);

    // 3. Lid
    _drawLid(canvas, size, bodyTop, bodyLeft, bodyWidth);

    // 4. Handle arcs
    _drawHandle(canvas, size, bodyTop, bodyLeft, bodyWidth);

    // 5. Main body
    _drawBody(canvas, size, bodyTop, bodyHeight, bodyLeft, bodyWidth);

    // 6. Pockets
    _drawPockets(canvas, size, bodyTop, bodyHeight, bodyLeft, bodyWidth);

    // 7. Buckle (centre, between pockets)
    _drawBuckle(canvas, size, bodyTop, bodyHeight);
  }

  // ---------------------------------------------------------------------------
  // Glow
  // ---------------------------------------------------------------------------

  void _drawGlow(
    Canvas canvas,
    Size size,
    double bodyTop,
    double bodyHeight,
    double bodyLeft,
    double bodyWidth,
  ) {
    final glowRadius = size.width * (0.40 + bandValue * 0.04);
    final glowCenter = Offset(
      size.width / 2,
      bodyTop + bodyHeight * 0.45,
    );
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [glowColor, glowColor.withValues(alpha: 0)],
          ).createShader(
            Rect.fromCircle(center: glowCenter, radius: glowRadius),
          );
    canvas.drawCircle(glowCenter, glowRadius, glowPaint);
  }

  // ---------------------------------------------------------------------------
  // Shadow
  // ---------------------------------------------------------------------------

  void _drawShadow(
    Canvas canvas,
    Size size,
    double bodyTop,
    double bodyHeight,
    double bodyLeft,
    double bodyWidth,
  ) {
    final shadowPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
          const Radius.circular(14),
        ),
      );
    final shadowColor = warmColor.withValues(
      alpha: (0.18 + bandValue * 0.10).clamp(0.0, 1.0),
    );
    canvas.drawShadow(shadowPath, shadowColor, 4 + bandValue * 10, true);
  }

  // ---------------------------------------------------------------------------
  // Lid
  // ---------------------------------------------------------------------------

  void _drawLid(
    Canvas canvas,
    Size size,
    double bodyTop,
    double bodyLeft,
    double bodyWidth,
  ) {
    final lidHeight = size.height * _lidHeightFraction;
    final lidWidth = bodyWidth + 8;
    final lidLeft = bodyLeft - 4;
    final lidTop = bodyTop - lidHeight + 2; // overlaps body top by 2dp

    final lidRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(lidLeft, lidTop, lidWidth, lidHeight),
      const Radius.circular(10),
    );

    final lidColor = Color.lerp(warmColor, Colors.white, 0.50)!;
    final lidGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(lidColor, Colors.white, 0.25)!,
        lidColor,
      ],
    );

    canvas.drawRRect(
      lidRect,
      Paint()..shader = lidGrad.createShader(lidRect.outerRect),
    );
  }

  // ---------------------------------------------------------------------------
  // Handle
  // ---------------------------------------------------------------------------

  void _drawHandle(
    Canvas canvas,
    Size size,
    double bodyTop,
    double bodyLeft,
    double bodyWidth,
  ) {
    final lidHeight = size.height * _lidHeightFraction;
    final handleY = bodyTop - lidHeight - 8;
    final centerX = size.width / 2;
    final handleW = bodyWidth * 0.38;

    final handlePaint = Paint()
      ..color = Color.lerp(warmColor, Colors.black, 0.18)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Two symmetric arcs meeting at the top centre.
    final leftPath = Path()
      ..moveTo(centerX - handleW / 2, bodyTop - lidHeight + 2)
      ..quadraticBezierTo(
        centerX - handleW / 2,
        handleY,
        centerX,
        handleY,
      );

    final rightPath = Path()
      ..moveTo(centerX + handleW / 2, bodyTop - lidHeight + 2)
      ..quadraticBezierTo(
        centerX + handleW / 2,
        handleY,
        centerX,
        handleY,
      );

    canvas
      ..drawPath(leftPath, handlePaint)
      ..drawPath(rightPath, handlePaint);
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  void _drawBody(
    Canvas canvas,
    Size size,
    double bodyTop,
    double bodyHeight,
    double bodyLeft,
    double bodyWidth,
  ) {
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
      const Radius.circular(14),
    );

    final bodyGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        warmColor,
        Color.lerp(warmColor, Colors.white, 0.35)!,
      ],
    );

    canvas.drawRRect(
      bodyRect,
      Paint()..shader = bodyGrad.createShader(bodyRect.outerRect),
    );
  }

  // ---------------------------------------------------------------------------
  // Pockets
  // ---------------------------------------------------------------------------

  void _drawPockets(
    Canvas canvas,
    Size size,
    double bodyTop,
    double bodyHeight,
    double bodyLeft,
    double bodyWidth,
  ) {
    final pocketW = bodyWidth * _pocketWidthFrac;
    final pocketH = bodyHeight * _pocketHeightFrac;
    final pocketY = bodyTop + bodyHeight - pocketH - bodyHeight * 0.08;

    final pocketColor = Color.lerp(warmColor, Colors.black, 0.10)!;
    final pocketPaint = Paint()..color = pocketColor;

    const pocketRadius = Radius.circular(6);

    canvas
      // Left pocket
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bodyLeft + bodyWidth * 0.06, pocketY, pocketW, pocketH),
          pocketRadius,
        ),
        pocketPaint,
      )
      // Right pocket
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bodyLeft + bodyWidth - bodyWidth * 0.06 - pocketW,
            pocketY,
            pocketW,
            pocketH,
          ),
          pocketRadius,
        ),
        pocketPaint,
      );
  }

  // ---------------------------------------------------------------------------
  // Buckle
  // ---------------------------------------------------------------------------

  void _drawBuckle(
    Canvas canvas,
    Size size,
    double bodyTop,
    double bodyHeight,
  ) {
    final buckleW = _buckleW * size.width / 180;
    final buckleH = _buckleH * size.height / 180;
    final buckleX = size.width / 2 - buckleW / 2;
    final buckleY = bodyTop + bodyHeight * 0.50;

    canvas.drawRect(
      Rect.fromLTWH(buckleX, buckleY, buckleW, buckleH),
      Paint()..color = const Color(0xFF8B8499), // AuroreColors.inkMuted
    );
  }

  // ---------------------------------------------------------------------------

  @override
  bool shouldRepaint(BackpackPainter old) => old.bandValue != bandValue;
}
