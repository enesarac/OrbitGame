import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/game_constants.dart';
import '../orbital_gravity_game.dart';
import 'player_component.dart';

final class CoinComponent extends CircleComponent
    with CollisionCallbacks, HasGameReference<OrbitalGravityGame> {
  CoinComponent({required Vector2 position})
    : super(
        position: position,
        radius: GameConstants.coinRadius,
        anchor: Anchor.center,
        paint: Paint()..color = GameConstants.coinColor,
      );

  bool _isCollected = false;
  double _opacity = 1;
  double _blinkTime = 0;
  final Paint _shinePaint = Paint()..color = Colors.white70;
  late final CircleHitbox _hitbox;
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

    angle += GameConstants.coinSpinSpeed * dt;
    _blinkTime =
        (_blinkTime + dt * GameConstants.coinBlinkSpeed) % (math.pi * 2);

    if (_isCollected) {
      _opacity -= GameConstants.coinFadeSpeed * dt;

      if (_opacity <= 0) {
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final blink = (math.sin(_blinkTime) + 1) * 0.5;
    final blinkAlpha =
        GameConstants.coinBlinkMinAlpha +
        blink * (255 - GameConstants.coinBlinkMinAlpha);
    paint.color = GameConstants.coinColor.withAlpha(
      (blinkAlpha * _opacity).round(),
    );

    super.render(canvas);

    final center = Offset(radius, radius);
    final shineLength = radius * 0.75;
    _shinePaint.strokeWidth = 2;
    _shinePaint.strokeCap = StrokeCap.round;
    _shinePaint.color = Colors.white.withAlpha((120 * _opacity).round());
    canvas.drawLine(
      center.translate(-shineLength / 2, 0),
      center.translate(shineLength / 2, 0),
      _shinePaint,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayerComponent && !_isCollected && !game.isGameOver) {
      game.collectCoin(this);
    }
  }

  void markCollected() {
    if (_isCollected) {
      return;
    }

    _isCollected = true;
    _detachHitbox();
  }

  @override
  void onRemove() {
    _detachHitbox();
    super.onRemove();
  }

  void _detachHitbox() {
    if (!_hitboxLoaded || _hitbox.isRemoving) {
      return;
    }

    _hitbox.removeFromParent();
  }
}
