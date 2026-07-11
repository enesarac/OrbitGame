import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/analytics/game_telemetry.dart';
import 'game/ads/game_ads.dart';
import 'game/orbital_gravity_game.dart';
import 'ui/advanced_shop_widget.dart';
import 'ui/game_over_widget.dart';
import 'ui/main_menu_widget.dart';
import 'ui/shop_menu_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameTelemetry.initialize();
  await GameAds.instance.initialize();
  runApp(const OrbitalGravityApp());
}

class OrbitalGravityApp extends StatefulWidget {
  const OrbitalGravityApp({super.key});

  @override
  State<OrbitalGravityApp> createState() => _OrbitalGravityAppState();
}

class _OrbitalGravityAppState extends State<OrbitalGravityApp> {
  late final OrbitalGravityGame _game = OrbitalGravityGame();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF45A29E)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: GameWidget<OrbitalGravityGame>(
          game: _game,
          overlayBuilderMap: {
            'MainMenu': (context, game) => MainMenuWidget(game: game),
            'GameOver': (context, game) => GameOverWidget(game: game),
            'ShopMenu': (context, game) => ShopMenuWidget(game: game),
            'AdvancedShop': (context, game) => AdvancedShopWidget(game: game),
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    );
  }
}
