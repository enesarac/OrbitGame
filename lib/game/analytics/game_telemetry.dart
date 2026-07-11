import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Thin Firebase wrapper for crash reporting and low-volume gameplay analytics.
///
/// The game still works if Firebase cannot initialize, which keeps local builds
/// and classroom demos resilient when services are temporarily unavailable.
abstract final class GameTelemetry {
  static bool _enabled = false;

  static Future<void> initialize() async {
    if (_enabled || kIsWeb) {
      return;
    }

    try {
      await Firebase.initializeApp();
      _enabled = true;

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
        );
        return true;
      };
    } catch (error, stack) {
      debugPrint('Firebase initialization skipped: $error');
      debugPrintStack(stackTrace: stack);
    }
  }

  static Future<void> logGameStart() {
    return _logEvent('game_start');
  }

  static Future<void> logGameOver({
    required int score,
    required int highScore,
    required double elapsedSeconds,
    required bool dualOrbitActive,
  }) {
    return _logEvent(
      'game_over',
      parameters: {
        'score': score,
        'high_score': highScore,
        'elapsed_seconds': elapsedSeconds.round(),
        'dual_orbit': dualOrbitActive ? 1 : 0,
      },
    );
  }

  static Future<void> logScoreReached(int score) {
    return _logEvent('score_reached', parameters: {'score': score});
  }

  static Future<void> logCoinCollected({
    required int amount,
    required int totalCoins,
  }) {
    return _logEvent(
      'coin_collected',
      parameters: {'amount': amount, 'total_coins': totalCoins},
    );
  }

  static Future<void> logRewardedCoinClaimed({
    required int amount,
    required int totalCoins,
  }) {
    return _logEvent(
      'rewarded_coin_claimed',
      parameters: {'amount': amount, 'total_coins': totalCoins},
    );
  }

  static Future<void> logRewardedReviveUsed({required int score}) {
    return _logEvent('rewarded_revive_used', parameters: {'score': score});
  }

  static Future<void> logShopItemEquipped(String itemId) {
    return _logEvent('shop_item_equipped', parameters: {'item_id': itemId});
  }

  static Future<void> _logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) {
    if (!_enabled) {
      return Future<void>.value();
    }

    return FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
