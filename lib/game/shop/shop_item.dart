import 'package:flutter/material.dart';

enum ShopItemType {
  ball,
  theme,
  skill,
  trail,
  sunSkin,
}

final class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.type,
    required this.cost,
    required this.color,
  });

  final String id;
  final String name;
  final ShopItemType type;
  final int cost;
  final Color color;

  bool get isFree => cost == 0;
}

abstract final class ShopCatalog {
  static const String defaultBallId = 'ball_cyan';
  static const String defaultThemeId = 'theme_deep_black';
  static const String defaultTrailId = 'trail_cyan';
  static const String defaultSunSkinId = 'sun_standard';
  static const String energyShieldId = 'skill_energy_shield';

  static const List<String> defaultUnlockedItems = [
    defaultBallId,
    defaultThemeId,
    defaultTrailId,
    defaultSunSkinId,
  ];

  static const List<ShopItem> ballSkins = [
    ShopItem(
      id: defaultBallId,
      name: 'Neon Cyan',
      type: ShopItemType.ball,
      cost: 0,
      color: Color(0xFF45A29E),
    ),
    ShopItem(
      id: 'ball_green',
      name: 'Neon Green',
      type: ShopItemType.ball,
      cost: 50,
      color: Color(0xFF39FF14),
    ),
    ShopItem(
      id: 'ball_purple',
      name: 'Neon Purple',
      type: ShopItemType.ball,
      cost: 100,
      color: Color(0xFFB026FF),
    ),
  ];

  static const List<ShopItem> themes = [
    ShopItem(
      id: defaultThemeId,
      name: 'Deep Cosmic Black',
      type: ShopItemType.theme,
      cost: 0,
      color: Color(0xFF0B0C10),
    ),
    ShopItem(
      id: 'theme_starry_space',
      name: 'Starry Space',
      type: ShopItemType.theme,
      cost: 100,
      color: Color(0xFF0B0C10),
    ),
    ShopItem(
      id: 'theme_cyber_grid',
      name: 'Cyberpunk Grid',
      type: ShopItemType.theme,
      cost: 150,
      color: Color(0xFF151820),
    ),
  ];

  static const List<ShopItem> skills = [
    ShopItem(
      id: energyShieldId,
      name: 'Energy Shield',
      type: ShopItemType.skill,
      cost: 200,
      color: Color(0xFFFFFFFF),
    ),
  ];

  static const List<ShopItem> trails = [
    ShopItem(
      id: defaultTrailId,
      name: 'Neon Cyan',
      type: ShopItemType.trail,
      cost: 0,
      color: Color(0xFF45A29E),
    ),
    ShopItem(
      id: 'trail_rainbow',
      name: 'Rainbow Trail',
      type: ShopItemType.trail,
      cost: 150,
      color: Color(0xFFFF4DFF),
    ),
    ShopItem(
      id: 'trail_star_dust',
      name: 'Star Dust Trail',
      type: ShopItemType.trail,
      cost: 250,
      color: Color(0xFFFFD700),
    ),
  ];

  static const List<ShopItem> sunSkins = [
    ShopItem(
      id: defaultSunSkinId,
      name: 'Standard Core',
      type: ShopItemType.sunSkin,
      cost: 0,
      color: Color(0xFFFFD166),
    ),
    ShopItem(
      id: 'sun_black_hole',
      name: 'Black Hole Core',
      type: ShopItemType.sunSkin,
      cost: 300,
      color: Color(0xFF6C4DFF),
    ),
    ShopItem(
      id: 'sun_solar_eclipse',
      name: 'Solar Eclipse',
      type: ShopItemType.sunSkin,
      cost: 400,
      color: Color(0xFFFFB703),
    ),
  ];

  static ShopItem itemById(String id) {
    return [...ballSkins, ...themes, ...skills, ...trails, ...sunSkins]
        .firstWhere(
      (item) => item.id == id,
      orElse: () => ballSkins.first,
    );
  }
}
