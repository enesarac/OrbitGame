import 'package:flutter/material.dart';

/// Centralized gameplay and visual tuning values for the MVP prototype.
abstract final class GameConstants {
  static const double sunRadius = 34;
  static const double playerRadius = 10;

  static const double minOrbitRadius = 60;
  static const double maxOrbitRadius = 200;
  static const double orbitSpeed = 1.8;
  static const double radiusLerpSpeed = 8;
  static const double idleGravityVeryEasyPullSpeed = 8;
  static const double idleGravityDefaultPullSpeed = 16;
  static const double sunCollisionRadius = 40;
  static const int dualOrbitScoreThreshold = 100;
  static const double dualOrbitAnnouncementDuration = 2;
  static const double dualOrbitAsteroidPauseDuration = 2;
  static const double dualOrbitDifficultyScale = 0.5;
  static const double dualOrbitGraceInvincibilityDuration = 3;
  static const double dualOrbitHitboxScale = 0.55;
  static const double shieldInvincibilityDuration = 1;

  static const double asteroidMinRadius = 8;
  static const double asteroidMaxRadius = 18;
  static const double asteroidVeryEasySpawnInterval = 3;
  static const double asteroidEasySpawnInterval = 2;
  static const double asteroidHardBaseSpawnInterval = 1.8;
  static const double asteroidHardMinSpawnInterval = 0.9;
  static const double asteroidVeryEasySpeed = 60;
  static const double asteroidEasySpeed = 80;
  static const double asteroidHardMaxSpeed = 180;
  static const double asteroidSpawnPadding = 32;
  static const double asteroidCleanupDistance =
      sunRadius + asteroidMaxRadius;
  static const int maxAsteroidsOnScreen = 24;
  static const int asteroidTrailMaxPositions = 10;
  static const int dodgeScoreBonus = 5;
  static const int coinCollectValue = 5;
  static const double coinRadius = 9;
  static const double coinSpawnInterval = 5;
  static const int maxCoinsOnScreen = 3;
  static const double coinSpinSpeed = 7;
  static const double coinFadeSpeed = 5;
  static const double coinBlinkSpeed = 6;
  static const int coinBlinkMinAlpha = 120;
  static const double scoreTopOffset = 50;

  static const Color backgroundColor = Color(0xFF0B0C10);
  static const Color sunColor = Color(0xFFFFD166);
  static const Color playerColor = Color(0xFF45A29E);
  static const Color asteroidColor = Color(0xFFFF4D3D);
  static const Color coinColor = Color(0xFFFFD700);
  static const Color scoreColor = Color(0xFFFFFFFF);
}
