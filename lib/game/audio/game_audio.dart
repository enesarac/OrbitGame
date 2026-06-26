import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Minimal audio facade for the two high-impact feedback events in the MVP.
abstract final class GameAudio {
  static final Stopwatch _clock = Stopwatch()..start();
  static const int _tapCooldownMs = 120;
  static int _lastTapMs = -_tapCooldownMs;
  static AudioPool? _tapPool;
  static AudioPool? _coinPool;
  static AudioPool? _explosionPool;

  static Future<void> preload() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'tap.mp3',
        'coin.mp3',
        'explosion.mp3',
      ]);
      _tapPool = await FlameAudio.createPool(
        'tap.mp3',
        minPlayers: 1,
        maxPlayers: 2,
      );
      _coinPool = await FlameAudio.createPool(
        'coin.mp3',
        minPlayers: 1,
        maxPlayers: 2,
      );
      _explosionPool = await FlameAudio.createPool(
        'explosion.mp3',
        minPlayers: 1,
        maxPlayers: 1,
      );
    } on MissingPluginException catch (error) {
      _logAudioFallback(error);
    } on PlatformException catch (error) {
      _logAudioFallback(error);
    }
  }

  static void playTapSound() {
    final nowMs = _clock.elapsedMilliseconds;
    if (nowMs - _lastTapMs < _tapCooldownMs) {
      return;
    }

    _lastTapMs = nowMs;
    unawaited(_safePoolStart(_tapPool, fallbackFile: 'tap.mp3', volume: 0.28));
  }

  static void playExplosionSound() {
    unawaited(
      _safePoolStart(
        _explosionPool,
        fallbackFile: 'explosion.mp3',
        volume: 0.7,
      ),
    );
  }

  static void playCoinSound() {
    unawaited(_safePoolStart(_coinPool, fallbackFile: 'coin.mp3', volume: 0.5));
  }

  static Future<void> _safePoolStart(
    AudioPool? pool, {
    required String fallbackFile,
    required double volume,
  }) async {
    try {
      if (pool != null) {
        await pool.start(volume: volume);
        return;
      }

      await FlameAudio.play(fallbackFile, volume: volume);
    } on MissingPluginException catch (error) {
      _logAudioFallback(error);
    } on PlatformException catch (error) {
      _logAudioFallback(error);
    }
  }

  static void _logAudioFallback(Object error) {
    debugPrint('Audio disabled on this platform: $error');
  }
}
