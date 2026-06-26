import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/game_constants.dart';
import '../orbital_gravity_game.dart';
import 'asteroid_component.dart';

/// Player body controlled indirectly by changing its orbit radius.
final class PlayerComponent extends CircleComponent
    with CollisionCallbacks, HasGameReference<OrbitalGravityGame> {
  PlayerComponent()
      : super(
          radius: GameConstants.playerRadius,
          anchor: Anchor.center,
          paint: Paint()..color = GameConstants.playerColor,
        );

  static const int _maxTrailPositions = 6;
  final List<Vector2> _trailPositions = [];
  final Paint _trailPaint = Paint();
  final Paint _shieldPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  late final CircleHitbox _hitbox;
  double _hitboxScale = 1;
  bool _hitboxLoaded = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _hitbox = CircleHitbox();
    add(_hitbox);
    _hitboxLoaded = true;
    _applyHitboxScale();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _trailPositions.add(position.clone());

    while (_trailPositions.length > _maxTrailPositions) {
      _trailPositions.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    paint.color = game.selectedPlayerPaintColor;
    _renderTrail(canvas);
    super.render(canvas);
    _renderShield(canvas);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is AsteroidComponent && !game.isGameOver) {
      game.handlePlayerAsteroidCollision(this, other);
    }
  }

  void resetTrail() {
    _trailPositions.clear();
  }

  void setHitboxScale(double scale) {
    _hitboxScale = scale;

    if (_hitboxLoaded) {
      _applyHitboxScale();
    }
  }

  void _applyHitboxScale() {
    final scaledRadius = radius * _hitboxScale;
    _hitbox
      ..radius = scaledRadius
      ..position = Vector2.all(radius - scaledRadius);
  }

  void _renderTrail(Canvas canvas) {
    if (_trailPositions.isEmpty) {
      return;
    }

    final localCenter = size / 2;

    for (var i = 0; i < _trailPositions.length; i += 1) {
      final ageProgress = (i + 1) / _trailPositions.length;
      final opacity = 0.1 + ageProgress * 0.7;
      final trailRadius = radius * (0.25 + ageProgress * 0.55);
      final localPosition = localCenter + (_trailPositions[i] - position);

      _trailPaint.color = _trailColor(ageProgress, opacity);

      if (game.selectedTrail == 'trail_star_dust') {
        _drawStarDust(canvas, localPosition.toOffset(), trailRadius);
      } else {
        canvas.drawCircle(localPosition.toOffset(), trailRadius, _trailPaint);
      }
    }
  }

  Color _trailColor(double ageProgress, double opacity) {
    if (game.selectedTrail == 'trail_rainbow') {
      return HSVColor.fromAHSV(
        opacity,
        (ageProgress * 300 + game.elapsedGameTime * 90) % 360,
        0.9,
        1,
      ).toColor();
    }

    if (game.selectedTrail == 'trail_star_dust') {
      return const Color(0xFFFFF1A8).withAlpha((opacity * 255).round());
    }

    return game.selectedPlayerPaintColor.withAlpha((opacity * 255).round());
  }

  void _drawStarDust(Canvas canvas, Offset center, double size) {
    canvas
      ..drawLine(
        center.translate(-size, 0),
        center.translate(size, 0),
        _trailPaint,
      )
      ..drawLine(
        center.translate(0, -size),
        center.translate(0, size),
        _trailPaint,
      );
  }

  void _renderShield(Canvas canvas) {
    if (!game.isShieldVisible) {
      return;
    }

    _shieldPaint.color = Colors.white.withAlpha(
      game.isInvincible ? 130 : 230,
    );
    canvas.drawCircle(
      Offset(radius, radius),
      radius + 5,
      _shieldPaint,
    );
  }
}
