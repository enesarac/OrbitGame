import 'package:flutter/material.dart';

import '../game/orbital_gravity_game.dart';

class MainMenuWidget extends StatelessWidget {
  const MainMenuWidget({required this.game, super.key});

  final OrbitalGravityGame game;

  @override
  Widget build(BuildContext context) {
    return _OverlayShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ORBIT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF66FCF1),
              fontSize: 44,
              fontWeight: FontWeight.w900,
              height: 0.95,
              letterSpacing: 0,
              shadows: [
                Shadow(color: Color(0xFF45A29E), blurRadius: 18),
                Shadow(color: Color(0xFF66FCF1), blurRadius: 32),
              ],
            ),
          ),
          const SizedBox(height: 36),
          _NeonButton(
            label: 'START GAME',
            color: const Color(0xFF66FCF1),
            onPressed: game.startGame,
          ),
          const SizedBox(height: 14),
          _NeonButton(
            label: 'SHOP',
            color: const Color(0xFFFFD700),
            onPressed: game.openShop,
          ),
        ],
      ),
    );
  }
}

class _OverlayShell extends StatelessWidget {
  const _OverlayShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xCC0B0C10),
      child: Center(
        child: SafeArea(minimum: const EdgeInsets.all(24), child: child),
      ),
    );
  }
}

class _NeonButton extends StatelessWidget {
  const _NeonButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 54,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: const Color(0xFF0B0C10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
