import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/game_constants.dart';
import '../orbital_gravity_game.dart';

/// Static center body used as the anchor point for orbit calculations.
final class SunComponent extends CircleComponent
    with HasGameReference<OrbitalGravityGame> {
  SunComponent()
      : super(
          radius: GameConstants.sunRadius,
          anchor: Anchor.center,
          paint: Paint()..color = GameConstants.sunColor,
        );

  double _skinAngle = 0;
  final Paint _skinPaint = Paint();

  @override
  void update(double dt) {
    super.update(dt);

    _skinAngle = (_skinAngle + dt * 1.7) % (math.pi * 2);
  }

  @override
  void render(Canvas canvas) {
    switch (game.selectedSunSkin) {
      case 'sun_black_hole':
        _renderBlackHole(canvas);
      case 'sun_solar_eclipse':
        _renderSolarEclipse(canvas);
      default:
        super.render(canvas);
    }
  }

  void _renderBlackHole(Canvas canvas) {
    final center = Offset(radius, radius);
    final rect = Rect.fromCircle(center: center, radius: radius + 4);

    _skinPaint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF05050A);
    canvas.drawCircle(center, radius, _skinPaint);

    _skinPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i += 1) {
      _skinPaint.color = [
        const Color(0xFF6C4DFF),
        const Color(0xFF66FCF1),
        const Color(0xFFFF4DFF),
      ][i]
          .withAlpha(190);
      canvas.drawArc(
        rect.deflate(i * 5),
        _skinAngle + i * math.pi * 0.55,
        math.pi * 0.95,
        false,
        _skinPaint,
      );
    }
  }

  void _renderSolarEclipse(Canvas canvas) {
    final center = Offset(radius, radius);
    final glowRect = Rect.fromCircle(center: center, radius: radius + 5);

    _skinPaint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFB703).withAlpha(90);
    canvas.drawCircle(center, radius + 6, _skinPaint);

    _skinPaint.color = const Color(0xFFFFD166);
    canvas.drawCircle(center, radius, _skinPaint);

    _skinPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFF1A8).withAlpha(220);
    canvas.drawArc(
      glowRect,
      _skinAngle,
      math.pi * 1.25,
      false,
      _skinPaint,
    );

    _skinPaint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF090B10).withAlpha(220);
    canvas.drawCircle(
      center.translate(radius * 0.18, -radius * 0.08),
      radius * 0.78,
      _skinPaint,
    );

    _skinPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFFD166).withAlpha(160);
    canvas.drawCircle(center, radius * 0.68, _skinPaint);
  }
}
