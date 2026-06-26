import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shop_item.dart';

final class ShopStateData {
  const ShopStateData({
    required this.totalCoins,
    required this.highScore,
    required this.selectedPlayerColor,
    required this.selectedTheme,
    required this.selectedTrail,
    required this.selectedSunSkin,
    required this.hasShieldPurchased,
    required this.unlockedItems,
  });

  factory ShopStateData.defaults() {
    return const ShopStateData(
      totalCoins: 0,
      highScore: 0,
      selectedPlayerColor: ShopCatalog.defaultBallId,
      selectedTheme: ShopCatalog.defaultThemeId,
      selectedTrail: ShopCatalog.defaultTrailId,
      selectedSunSkin: ShopCatalog.defaultSunSkinId,
      hasShieldPurchased: false,
      unlockedItems: ShopCatalog.defaultUnlockedItems,
    );
  }

  final int totalCoins;
  final int highScore;
  final String selectedPlayerColor;
  final String selectedTheme;
  final String selectedTrail;
  final String selectedSunSkin;
  final bool hasShieldPurchased;
  final List<String> unlockedItems;
}

abstract final class ShopDataStore {
  static const String _coinsKey = 'shop.totalCoins';
  static const String _highScoreKey = 'shop.highScore';
  static const String _playerColorKey = 'shop.selectedPlayerColor';
  static const String _themeKey = 'shop.selectedTheme';
  static const String _trailKey = 'shop.selectedTrail';
  static const String _sunSkinKey = 'shop.selectedSunSkin';
  static const String _shieldKey = 'shop.hasShieldPurchased';
  static const String _unlockedKey = 'shop.unlockedItems';

  static Future<ShopStateData> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final defaults = ShopStateData.defaults();
      final unlockedItems =
          prefs.getStringList(_unlockedKey) ?? defaults.unlockedItems;

      return ShopStateData(
        totalCoins: prefs.getInt(_coinsKey) ?? defaults.totalCoins,
        highScore: prefs.getInt(_highScoreKey) ?? defaults.highScore,
        selectedPlayerColor:
            prefs.getString(_playerColorKey) ?? defaults.selectedPlayerColor,
        selectedTheme: prefs.getString(_themeKey) ?? defaults.selectedTheme,
        selectedTrail: prefs.getString(_trailKey) ?? defaults.selectedTrail,
        selectedSunSkin:
            prefs.getString(_sunSkinKey) ?? defaults.selectedSunSkin,
        hasShieldPurchased:
            prefs.getBool(_shieldKey) ?? defaults.hasShieldPurchased,
        unlockedItems: _withDefaultUnlocks(unlockedItems),
      );
    } on MissingPluginException catch (error) {
      _logPersistenceFallback(error);
    } on PlatformException catch (error) {
      _logPersistenceFallback(error);
    }

    return ShopStateData.defaults();
  }

  static Future<void> save(ShopStateData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_coinsKey, data.totalCoins);
      await prefs.setInt(_highScoreKey, data.highScore);
      await prefs.setString(_playerColorKey, data.selectedPlayerColor);
      await prefs.setString(_themeKey, data.selectedTheme);
      await prefs.setString(_trailKey, data.selectedTrail);
      await prefs.setString(_sunSkinKey, data.selectedSunSkin);
      await prefs.setBool(_shieldKey, data.hasShieldPurchased);
      await prefs.setStringList(
        _unlockedKey,
        _withDefaultUnlocks(data.unlockedItems),
      );
    } on MissingPluginException catch (error) {
      _logPersistenceFallback(error);
    } on PlatformException catch (error) {
      _logPersistenceFallback(error);
    }
  }

  static List<String> _withDefaultUnlocks(List<String> unlockedItems) {
    return {
      ...ShopCatalog.defaultUnlockedItems,
      ...unlockedItems,
    }.toList(growable: false);
  }

  static void _logPersistenceFallback(Object error) {
    debugPrint('Shop persistence disabled on this platform: $error');
  }
}
