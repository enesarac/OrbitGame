import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/game_constants.dart';

/// Incoming obstacle that travels from an off-screen spawn point toward the sun.
final class AsteroidComponent extends CircleComponent with CollisionCallbacks {
  AsteroidComponent({
    required Vector2 spawnPosition,
    required Vector2 targetPosition,
    required double radius,
    required this.speed,
    this.onReachedTarget,
  })  : _targetPosition = targetPosition.clone(),
        super(
          position: spawnPosition.clone(),
          radius: radius,
          anchor: Anchor.center,
          paint: Paint()..color = GameConstants.asteroidColor,
        ) {
    final directionToTarget = _targetPosition - spawnPosition;
    _direction = directionToTarget.length2 == 0
        ? Vector2.zero()
        : directionToTarget.normalized();
  }

  final double speed;
  final VoidCallback? onReachedTarget;
  final Vector2 _targetPosition;
  late final Vector2 _direction;
  late final CircleHitbox _hitbox;
  final List<Vector2> _trailPositions = [];
  final Paint _trailPaint = Paint();
  bool _hitboxLoaded = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _hitbox = CircleHitbox();
    add(_hitbox);
    _hitboxLoaded = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _trailPositions.add(position.clone());

    while (_trailPositions.length > GameConstants.asteroidTrailMaxPositions) {
      _trailPositions.removeAt(0);
    }

    final cleanupDistance = math.max(
      speed * dt,
      GameConstants.asteroidCleanupDistance,
    );

    if (position.distanceTo(_targetPosition) <= cleanupDistance) {
      onReachedTarget?.call();
      removeSafely();
      return;
    }

    position += _direction * speed * dt;
  }

  @override
  void render(Canvas canvas) {
    _renderDangerTrail(canvas);
    super.render(canvas);
  }

  @override
  void onRemove() {
    _trailPositions.clear();
    _detachHitbox();
    super.onRemove();
  }

  void removeSafely() {
    _detachHitbox();
    removeFromParent();
  }

  void _detachHitbox() {
    if (!_hitboxLoaded || _hitbox.isRemoving) {
      return;
    }

    _hitbox.removeFromParent();
  }

  void _renderDangerTrail(Canvas canvas) {
    final localCenter = size / 2;

    for (var i = 0; i < _trailPositions.length; i += 1) {
      final ageProgress = (i + 1) / _trailPositions.length;
      final opacity = 0.14 + ageProgress * 0.68;
      final trailRadius = radius * (0.3 + ageProgress * 0.55);
      final localPosition = localCenter + (_trailPositions[i] - position);

      _trailPaint
        ..style = PaintingStyle.fill
        ..color = GameConstants.asteroidColor.withAlpha(
          (opacity * 255).round(),
        );
      canvas.drawCircle(localPosition.toOffset(), trailRadius, _trailPaint);
    }
  }
}
