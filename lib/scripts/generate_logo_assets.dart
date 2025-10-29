import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

/// Script para gerar os assets do logo do app
/// Execute: flutter run lib/scripts/generate_logo_assets.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🎨 Gerando assets do logo...');
  
  await _generateLogo(1024, 'logo.png');
  await _generateLogo(1024, 'logo_foreground.png', transparent: true);
  await _generateLogo(1024, 'splash_logo.png');
  
  print('✅ Assets gerados com sucesso!');
  print('📁 Copie os arquivos da pasta temporária para assets/images/');
  
  exit(0);
}

Future<void> _generateLogo(int size, String filename, {bool transparent = false}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Background
  if (!transparent) {
    final paint = Paint()..color = const Color(0xFF071127);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), paint);
  }
  
  // Logo container
  final logoSize = size * 0.8;
  final logoOffset = (size - logoSize) / 2;
  
  // Gradient
  final gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
    ],
  );
  
  final rect = Rect.fromLTWH(logoOffset, logoOffset, logoSize, logoSize);
  final paint = Paint()
    ..shader = gradient.createShader(rect)
    ..style = PaintingStyle.fill;
  
  final rrect = RRect.fromRectAndRadius(
    rect,
    Radius.circular(logoSize * 0.25),
  );
  
  canvas.drawRRect(rrect, paint);
  
  // Pattern
  _drawPattern(canvas, rect);
  
  // Icon
  _drawInsightsIcon(canvas, rect);
  
  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();
  
  // Save
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$filename');
  await file.writeAsBytes(buffer);
  
  print('✓ Gerado: ${file.path}');
}

void _drawPattern(Canvas canvas, Rect rect) {
  final paint = Paint()
    ..color = Colors.white.withOpacity(0.1)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;
  
  final center = rect.center;
  final radius = rect.width * 0.3;
  
  // Concentric circles
  for (int i = 1; i <= 3; i++) {
    canvas.drawCircle(center, radius * i / 3, paint);
  }
  
  // Cross lines
  canvas.drawLine(
    Offset(center.dx - radius, center.dy),
    Offset(center.dx + radius, center.dy),
    paint,
  );
  canvas.drawLine(
    Offset(center.dx, center.dy - radius),
    Offset(center.dx, center.dy + radius),
    paint,
  );
}

void _drawInsightsIcon(Canvas canvas, Rect rect) {
  final paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  
  final center = rect.center;
  final iconSize = rect.width * 0.4;
  
  // Simplified insights icon (bars going up)
  final barWidth = iconSize / 5;
  final spacing = barWidth * 0.5;
  
  // Bar 1 (shortest)
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx - iconSize / 2,
        center.dy + iconSize / 6,
        barWidth,
        iconSize / 3,
      ),
      const Radius.circular(4),
    ),
    paint,
  );
  
  // Bar 2 (medium)
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx - iconSize / 2 + barWidth + spacing,
        center.dy,
        barWidth,
        iconSize / 2,
      ),
      const Radius.circular(4),
    ),
    paint,
  );
  
  // Bar 3 (tallest)
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx - iconSize / 2 + (barWidth + spacing) * 2,
        center.dy - iconSize / 4,
        barWidth,
        iconSize * 0.75,
      ),
      const Radius.circular(4),
    ),
    paint,
  );
  
  // Arrow up
  final arrowPaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 6
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  
  final arrowX = center.dx + iconSize / 4;
  final arrowY = center.dy - iconSize / 6;
  
  canvas.drawLine(
    Offset(arrowX, arrowY + iconSize / 8),
    Offset(arrowX, arrowY - iconSize / 8),
    arrowPaint,
  );
  
  canvas.drawLine(
    Offset(arrowX, arrowY - iconSize / 8),
    Offset(arrowX - iconSize / 16, arrowY - iconSize / 16),
    arrowPaint,
  );
  
  canvas.drawLine(
    Offset(arrowX, arrowY - iconSize / 8),
    Offset(arrowX + iconSize / 16, arrowY - iconSize / 16),
    arrowPaint,
  );
}
