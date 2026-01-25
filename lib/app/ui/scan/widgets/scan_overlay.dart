import 'package:flutter/material.dart';
import 'package:anttec_movil/app/ui/scan/styles/scan_styles.dart';

class ScanOverlay extends StatelessWidget {
  const ScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(
        borderColor: ScanStyles.white,
        borderRadius: ScanStyles.scannerBorderRadius,
        borderLength: ScanStyles.scannerBorderLength,
        borderWidth: ScanStyles.scannerBorderWidth,
        overlayColor: ScanStyles.overlayColor,
        scanWindowSize: ScanStyles.scanWindowSize,
      ),
      child: Container(),
    );
  }
}

// Clase privada (_) porque solo se usa aquí
class _ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final Color overlayColor;
  final Size scanWindowSize;

  _ScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.overlayColor,
    required this.scanWindowSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double windowWidth = scanWindowSize.width;
    final double windowHeight = scanWindowSize.height;

    // Fondo y Hueco
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path windowPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(centerX, centerY),
              width: windowWidth,
              height: windowHeight),
          Radius.circular(borderRadius),
        ),
      );

    final Path overlayPath =
        Path.combine(PathOperation.difference, backgroundPath, windowPath);
    canvas.drawPath(
        overlayPath,
        Paint()
          ..color = overlayColor
          ..style = PaintingStyle.fill);

    // Bordes
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final double halfWidth = windowWidth / 2;
    final double halfHeight = windowHeight / 2;

    // Dibujamos las 4 esquinas manualmente
    final path = Path();
    // Top Left
    path.moveTo(centerX - halfWidth, centerY - halfHeight + borderLength);
    path.lineTo(centerX - halfWidth, centerY - halfHeight);
    path.lineTo(centerX - halfWidth + borderLength, centerY - halfHeight);
    // Top Right
    path.moveTo(centerX + halfWidth - borderLength, centerY - halfHeight);
    path.lineTo(centerX + halfWidth, centerY - halfHeight);
    path.lineTo(centerX + halfWidth, centerY - halfHeight + borderLength);
    // Bottom Right
    path.moveTo(centerX + halfWidth, centerY + halfHeight - borderLength);
    path.lineTo(centerX + halfWidth, centerY + halfHeight);
    path.lineTo(centerX + halfWidth - borderLength, centerY + halfHeight);
    // Bottom Left
    path.moveTo(centerX - halfWidth + borderLength, centerY + halfHeight);
    path.lineTo(centerX - halfWidth, centerY + halfHeight);
    path.lineTo(centerX - halfWidth, centerY + halfHeight - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
