import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/ui_style.dart';

/// Soft mist ribbons behind content when Mist UI is on. Classic = transparent.
class MistBackground extends StatelessWidget {
  final AppUiStyle style;
  final Widget child;

  const MistBackground({
    super.key,
    required this.style,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (style != AppUiStyle.mist) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppTheme.mistSurface),
        CustomPaint(painter: _MistRibbonPainter()),
        child,
      ],
    );
  }
}

class _MistRibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final top = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.fill;
    final accent = Paint()
      ..color = AppTheme.mistPrimary.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(-40, size.height * 0.08)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.02,
        size.width * 0.7,
        size.height * 0.14,
      )
      ..quadraticBezierTo(
        size.width * 1.05,
        size.height * 0.22,
        size.width + 40,
        size.height * 0.12,
      )
      ..lineTo(size.width + 40, -20)
      ..lineTo(-40, -20)
      ..close();
    canvas.drawPath(path1, top);

    final path2 = Path()
      ..moveTo(size.width + 20, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.48,
        size.width * 0.4,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.75,
        -30,
        size.height * 0.68,
      )
      ..lineTo(-30, size.height + 20)
      ..lineTo(size.width + 20, size.height + 20)
      ..close();
    canvas.drawPath(path2, accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
