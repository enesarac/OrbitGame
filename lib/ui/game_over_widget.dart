import 'dart:async';

import 'package:flutter/material.dart';

import '../game/orbital_gravity_game.dart';

class GameOverWidget extends StatefulWidget {
  const GameOverWidget({required this.game, super.key});

  final OrbitalGravityGame game;

  @override
  State<GameOverWidget> createState() => _GameOverWidgetState();
}

class _GameOverWidgetState extends State<GameOverWidget> {
  Timer? _adReadinessTimer;

  @override
  void initState() {
    super.initState();
    _adReadinessTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adReadinessTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final reviveReady = game.isRewardedReviveReady;

    return ColoredBox(
      color: const Color(0xDD0B0C10),
      child: Center(
        child: SafeArea(
          minimum: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFF4D3D),
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  shadows: [
                    Shadow(color: Color(0xFFFF4D3D), blurRadius: 20),
                    Shadow(color: Color(0xFFFF9A3D), blurRadius: 34),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Score: ${game.score}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'High Score: ${game.highScore}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 34),
              if (game.canAttemptRewardedRevive) ...[
                SizedBox(
                  width: 220,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF66FCF1),
                      foregroundColor: const Color(0xFF0B0C10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    onPressed: reviveReady
                        ? () async {
                            final revived = await game.reviveFromRewardedAd();
                            if (!revived && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Ad is not ready yet. Try again soon.',
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        reviveReady ? 'WATCH AD & CONTINUE' : 'AD LOADING...',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              SizedBox(
                width: 220,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D3D),
                    foregroundColor: const Color(0xFF0B0C10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  onPressed: game.restartGame,
                  child: const Text('TRY AGAIN'),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 220,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF0B0C10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  onPressed: game.openShop,
                  child: const Text('SHOP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
