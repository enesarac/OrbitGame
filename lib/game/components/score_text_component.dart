import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../config/game_constants.dart';

/// Lightweight HUD component that keeps the current score visible in-game.
final class ScoreTextComponent extends TextComponent {
  ScoreTextComponent()
      : super(
          text: '0',
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: GameConstants.scoreColor,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

  void updateScore(int score) {
    text = score.toString();
  }
}
