import 'dart:async';
import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import 'audio/game_audio.dart';
import 'components/asteroid_component.dart';
import 'components/coin_component.dart';
import 'components/player_component.dart';
import 'components/score_text_component.dart';
import 'components/sun_component.dart';
import 'config/game_constants.dart';
import 'shop/shop_data_store.dart';
import 'shop/shop_item.dart';

/// Main Flame game for Orbital Gravity.
///
/// Owns the orbit mechanics, asteroid spawning, survival scoring, and game over
/// state for the MVP loop.
final class OrbitalGravityGame extends FlameGame
    with HasCollisionDetection, PanDetector {
  late final SunComponent _sun;
  late final PlayerComponent _player;
  PlayerComponent? _player2;
  late final ScoreTextComponent _scoreText;
  late final Timer _spawnTimer;
  late final Timer _coinSpawnTimer;
  final math.Random _random = math.Random();
  final Paint _backgroundDetailPaint = Paint();
  List<Vector2> _stars = [];
  TextComponent? _dualOrbitText;

  double _angle = 0;
  double _currentRadius = GameConstants.maxOrbitRadius;
  double _targetRadius = GameConstants.maxOrbitRadius;
  double _scoreTimer = 0;
  double _invincibilityTimer = 0;
  double _dualOrbitAnnouncementTimer = 0;
  double _asteroidSpawnPauseTimer = 0;
  bool _isTouching = false;

  int score = 0;
  int totalCoins = 0;
  int highScore = 0;
  String selectedPlayerColor = ShopCatalog.defaultBallId;
  String selectedTheme = ShopCatalog.defaultThemeId;
  String selectedTrail = ShopCatalog.defaultTrailId;
  String selectedSunSkin = ShopCatalog.defaultSunSkinId;
  bool hasShieldPurchased = false;
  bool isDualOrbitActive = false;
  bool _shieldActive = false;
  List<String> unlockedItems = [...ShopCatalog.defaultUnlockedItems];
  bool isPlaying = false;
  bool isGameOver = false;
  double elapsedGameTime = 0;

  @override
  Color backgroundColor() {
    if (selectedTheme == 'theme_cyber_grid') {
      return const Color(0xFF151820);
    }

    return GameConstants.backgroundColor;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await GameAudio.preload();
    await loadGameState();

    _sun = SunComponent();
    _player = PlayerComponent();
    _scoreText = ScoreTextComponent();

    addAll([_sun, _player, _scoreText]);
    _recenterComponents();
    _startAsteroidSpawner();
    _startCoinSpawner();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (isLoaded) {
      _recenterComponents();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isPlaying || isGameOver) {
      return;
    }

    _updateAsteroidSpawner(dt);
    _coinSpawnTimer.update(dt);
    elapsedGameTime += dt;
    _updateInvincibility(dt);
    _updateDualOrbitAnnouncement(dt);
    _updateSurvivalScore(dt);
    _angle = (_angle + GameConstants.orbitSpeed * dt) % (math.pi * 2);
    _currentRadius = _lerpRadius(_currentRadius, _targetRadius, dt);
    _applyIdleGravity(dt);
    _checkSunCollision();
    _positionPlayersOnOrbit();
  }

  @override
  void render(Canvas canvas) {
    _renderThemeDetails(canvas);
    super.render(canvas);
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (!isPlaying || isGameOver) {
      return;
    }

    _isTouching = true;
    _targetRadius = GameConstants.minOrbitRadius;
    GameAudio.playTapSound();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!isPlaying || isGameOver) {
      return;
    }

    _isTouching = true;
    _targetRadius = GameConstants.minOrbitRadius;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (!isPlaying || isGameOver) {
      return;
    }

    _isTouching = false;
    _targetRadius = GameConstants.maxOrbitRadius;
  }

  @override
  void onPanCancel() {
    if (!isPlaying || isGameOver) {
      return;
    }

    _isTouching = false;
    _targetRadius = GameConstants.maxOrbitRadius;
  }

  void startGame() {
    overlays.remove('MainMenu');
    _resetGameState();
    isPlaying = true;
    resumeEngine();
  }

  void restartGame() {
    overlays.remove('GameOver');
    _resetGameState();
    isPlaying = true;
    resumeEngine();
  }

  void openShop() {
    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    overlays.remove('ShopMenu');
    overlays.add('AdvancedShop');
  }

  void closeShopToMainMenu() {
    overlays.remove('ShopMenu');
    overlays.remove('AdvancedShop');
    overlays.add('MainMenu');
  }

  Future<void> collectCoin(CoinComponent coin) async {
    if (isGameOver || !isPlaying) {
      return;
    }

    coin.markCollected();
    totalCoins += GameConstants.coinCollectValue;
    GameAudio.playCoinSound();
    await saveGameState();
  }

  bool isUnlocked(String itemId) => unlockedItems.contains(itemId);

  bool isEquipped(String itemId) {
    final item = ShopCatalog.itemById(itemId);

    return switch (item.type) {
      ShopItemType.ball => selectedPlayerColor == itemId,
      ShopItemType.theme => selectedTheme == itemId,
      ShopItemType.skill => itemId == ShopCatalog.energyShieldId &&
          hasShieldPurchased,
      ShopItemType.trail => selectedTrail == itemId,
      ShopItemType.sunSkin => selectedSunSkin == itemId,
    };
  }

  bool canBuy(ShopItem item) {
    if (item.type == ShopItemType.skill) {
      return item.id == ShopCatalog.energyShieldId &&
          !hasShieldPurchased &&
          totalCoins >= item.cost;
    }

    return !isUnlocked(item.id) && totalCoins >= item.cost;
  }

  Future<void> buyOrEquip(ShopItem item) async {
    if (item.type == ShopItemType.skill) {
      if (item.id != ShopCatalog.energyShieldId ||
          hasShieldPurchased ||
          totalCoins < item.cost) {
        return;
      }

      totalCoins -= item.cost;
      hasShieldPurchased = true;
      await saveGameState();
      return;
    }

    if (!isUnlocked(item.id)) {
      if (totalCoins < item.cost) {
        return;
      }

      totalCoins -= item.cost;
      unlockedItems = [...unlockedItems, item.id];
    }

    switch (item.type) {
      case ShopItemType.ball:
        selectedPlayerColor = item.id;
      case ShopItemType.theme:
        selectedTheme = item.id;
      case ShopItemType.trail:
        selectedTrail = item.id;
      case ShopItemType.sunSkin:
        selectedSunSkin = item.id;
      case ShopItemType.skill:
        break;
    }

    await saveGameState();
  }

  void handlePlayerAsteroidCollision(
    PlayerComponent player,
    AsteroidComponent asteroid,
  ) {
    if (isGameOver || _invincibilityTimer > 0) {
      return;
    }

    asteroid.removeSafely();

    if (_shieldActive) {
      _shieldActive = false;
      hasShieldPurchased = false;
      _invincibilityTimer = GameConstants.shieldInvincibilityDuration;
      unawaited(saveGameState());
      return;
    }

    gameOver();
  }

  void gameOver() {
    if (isGameOver) {
      return;
    }

    isGameOver = true;
    isPlaying = false;
    _recordHighScoreIfNeeded();
    unawaited(saveGameState());
    overlays.add('GameOver');
    GameAudio.playExplosionSound();
    debugPrint('Game Over! Final score: $score');
    pauseEngine();
  }

  void _recenterComponents() {
    _sun.position = size / 2;
    _scoreText.position = Vector2(size.x / 2, GameConstants.scoreTopOffset);
    _dualOrbitText?.position = Vector2(size.x / 2, size.y * 0.28);
    _rebuildStars();
    _positionPlayersOnOrbit();
  }

  void _positionPlayersOnOrbit() {
    _player.position = _sun.position + _orbitOffset(_angle);
    _player2?.position = _sun.position + _orbitOffset(_angle + math.pi);
  }

  Vector2 _orbitOffset(double angle) {
    return Vector2(
      _currentRadius * math.cos(angle),
      _currentRadius * math.sin(angle),
    );
  }

  double _lerpRadius(double current, double target, double dt) {
    final t = (GameConstants.radiusLerpSpeed * dt).clamp(0.0, 1.0);
    return current + (target - current) * t;
  }

  void _startAsteroidSpawner() {
    _spawnTimer = Timer(
      _currentSpawnInterval,
      repeat: true,
      onTick: _spawnAsteroid,
    )..start();
  }

  void _startCoinSpawner() {
    _coinSpawnTimer = Timer(
      GameConstants.coinSpawnInterval,
      repeat: true,
      onTick: _spawnCoin,
    )..start();
  }

  void _spawnAsteroid() {
    if (!isPlaying ||
        isGameOver ||
        _asteroidSpawnPauseTimer > 0 ||
        size.x <= 0 ||
        size.y <= 0 ||
        children.whereType<AsteroidComponent>().length >=
            GameConstants.maxAsteroidsOnScreen) {
      return;
    }

    final radius = _randomRange(
      GameConstants.asteroidMinRadius,
      GameConstants.asteroidMaxRadius,
    );

    add(
      AsteroidComponent(
        spawnPosition: _randomSpawnPosition(radius),
        targetPosition: _sun.position,
        radius: radius,
        speed: _currentAsteroidSpeed,
        onReachedTarget: _addAsteroidSurvivalBonus,
      ),
    );
  }

  void _spawnCoin() {
    if (!isPlaying ||
        isGameOver ||
        size.x <= 0 ||
        size.y <= 0 ||
        children.whereType<CoinComponent>().length >=
            GameConstants.maxCoinsOnScreen) {
      return;
    }

    final radius = _randomRange(
      GameConstants.minOrbitRadius,
      GameConstants.maxOrbitRadius,
    );
    final angle = _randomRange(0, math.pi * 2);
    final spawnOffset = Vector2(
      radius * math.cos(angle),
      radius * math.sin(angle),
    );

    add(CoinComponent(position: _sun.position + spawnOffset));
  }

  Vector2 _randomSpawnPosition(double radius) {
    final offscreenOffset = GameConstants.asteroidSpawnPadding + radius;

    switch (_random.nextInt(4)) {
      case 0:
        return Vector2(_random.nextDouble() * size.x, -offscreenOffset);
      case 1:
        return Vector2(
          _random.nextDouble() * size.x,
          size.y + offscreenOffset,
        );
      case 2:
        return Vector2(-offscreenOffset, _random.nextDouble() * size.y);
      default:
        return Vector2(
          size.x + offscreenOffset,
          _random.nextDouble() * size.y,
        );
    }
  }

  double _randomRange(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  void _updateSurvivalScore(double dt) {
    _scoreTimer += dt;

    while (_scoreTimer >= 1) {
      _addScore(1);
      _scoreTimer -= 1;
    }
  }

  void _addAsteroidSurvivalBonus() {
    if (!isGameOver) {
      _addScore(GameConstants.dodgeScoreBonus);
    }
  }

  void _addScore(int amount) {
    score += amount;
    _scoreText.updateScore(score);
    _syncSpawnInterval();
    _engageDualOrbitIfNeeded();
  }

  void _applyIdleGravity(double dt) {
    if (_isTouching) {
      return;
    }

    _targetRadius = math.max(
      0,
      _targetRadius - _currentIdleGravityPullSpeed * dt,
    ).toDouble();
  }

  void _checkSunCollision() {
    if (_currentRadius <= GameConstants.sunCollisionRadius) {
      gameOver();
    }
  }

  void _syncSpawnInterval() {
    _spawnTimer.limit = _currentSpawnInterval;
  }

  double get _currentSpawnInterval {
    final difficultyScore = _effectiveDifficultyScore;

    if (difficultyScore < 15) {
      return GameConstants.asteroidVeryEasySpawnInterval;
    }

    if (difficultyScore <= 40) {
      return GameConstants.asteroidEasySpawnInterval;
    }

    final interval =
        GameConstants.asteroidHardBaseSpawnInterval - difficultyScore * 0.005;

    return math.max(interval, GameConstants.asteroidHardMinSpawnInterval);
  }

  double get _currentAsteroidSpeed {
    final difficultyScore = _effectiveDifficultyScore;

    if (difficultyScore < 15) {
      return GameConstants.asteroidVeryEasySpeed;
    }

    if (difficultyScore <= 40) {
      return GameConstants.asteroidEasySpeed;
    }

    return math.min(
      GameConstants.asteroidHardMaxSpeed,
      GameConstants.asteroidEasySpeed + difficultyScore * 0.5,
    );
  }

  double get _effectiveDifficultyScore {
    if (!isDualOrbitActive) {
      return score.toDouble();
    }

    return math.max(
      0,
      (score - GameConstants.dualOrbitScoreThreshold) *
          GameConstants.dualOrbitDifficultyScale,
    ).toDouble();
  }

  double get _currentIdleGravityPullSpeed {
    if (score < 15) {
      return GameConstants.idleGravityVeryEasyPullSpeed;
    }

    return GameConstants.idleGravityDefaultPullSpeed;
  }

  void _resetGameState() {
    for (final asteroid in children.whereType<AsteroidComponent>().toList()) {
      asteroid.removeSafely();
    }
    for (final coin in children.whereType<CoinComponent>().toList()) {
      coin.removeFromParent();
    }
    _player2?.removeFromParent();
    _player2 = null;
    _dualOrbitText?.removeFromParent();
    _dualOrbitText = null;

    score = 0;
    isGameOver = false;
    isDualOrbitActive = false;
    _shieldActive = hasShieldPurchased;
    _invincibilityTimer = 0;
    _dualOrbitAnnouncementTimer = 0;
    _asteroidSpawnPauseTimer = 0;
    elapsedGameTime = 0;
    _scoreTimer = 0;
    _angle = 0;
    _isTouching = false;
    _currentRadius = GameConstants.maxOrbitRadius;
    _targetRadius = GameConstants.maxOrbitRadius;
    _scoreText.updateScore(score);
    _player.resetTrail();
    _player.setHitboxScale(1);
    _spawnTimer.limit = _currentSpawnInterval;
    _spawnTimer.start();
    _coinSpawnTimer.start();
    _positionPlayersOnOrbit();
  }

  Color get selectedPlayerPaintColor {
    return ShopCatalog.itemById(selectedPlayerColor).color;
  }

  bool get isShieldVisible => _shieldActive;

  bool get isInvincible => _invincibilityTimer > 0;

  Future<void> loadGameState() async {
    final data = await ShopDataStore.load();
    totalCoins = data.totalCoins;
    highScore = data.highScore;
    selectedPlayerColor = data.selectedPlayerColor;
    selectedTheme = data.selectedTheme;
    selectedTrail = data.selectedTrail;
    selectedSunSkin = data.selectedSunSkin;
    if (!ShopCatalog.sunSkins.any((item) => item.id == selectedSunSkin)) {
      selectedSunSkin = ShopCatalog.defaultSunSkinId;
    }
    hasShieldPurchased = data.hasShieldPurchased;
    unlockedItems = data.unlockedItems;
  }

  Future<void> saveGameState() {
    return ShopDataStore.save(
      ShopStateData(
        totalCoins: totalCoins,
        highScore: highScore,
        selectedPlayerColor: selectedPlayerColor,
        selectedTheme: selectedTheme,
        selectedTrail: selectedTrail,
        selectedSunSkin: selectedSunSkin,
        hasShieldPurchased: hasShieldPurchased,
        unlockedItems: unlockedItems,
      ),
    );
  }

  void _engageDualOrbitIfNeeded() {
    if (isDualOrbitActive || score < GameConstants.dualOrbitScoreThreshold) {
      return;
    }

    isDualOrbitActive = true;
    _player.setHitboxScale(GameConstants.dualOrbitHitboxScale);
    _player2 = PlayerComponent();
    add(_player2!);
    _player2!.setHitboxScale(GameConstants.dualOrbitHitboxScale);
    _positionPlayersOnOrbit();
    _invincibilityTimer = GameConstants.dualOrbitGraceInvincibilityDuration;
    _resetAsteroidDifficultyForDualOrbit();
    _showDualOrbitAnnouncement();
  }

  void _showDualOrbitAnnouncement() {
    _dualOrbitText?.removeFromParent();
    _dualOrbitAnnouncementTimer = GameConstants.dualOrbitAnnouncementDuration;
    _dualOrbitText = TextComponent(
      text: 'DUAL ORBIT ENGAGED - GET READY!',
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.28),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF66FCF1),
          fontSize: 24,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Color(0xFF66FCF1), blurRadius: 20),
          ],
        ),
      ),
    );
    add(_dualOrbitText!);
  }

  void _updateDualOrbitAnnouncement(double dt) {
    if (_dualOrbitAnnouncementTimer <= 0) {
      return;
    }

    _dualOrbitAnnouncementTimer -= dt;
    if (_dualOrbitAnnouncementTimer <= 0) {
      _dualOrbitText?.removeFromParent();
      _dualOrbitText = null;
    }
  }

  void _updateInvincibility(double dt) {
    if (_invincibilityTimer > 0) {
      _invincibilityTimer = math.max(0, _invincibilityTimer - dt).toDouble();
    }
  }

  void _updateAsteroidSpawner(double dt) {
    _syncSpawnInterval();

    if (_asteroidSpawnPauseTimer > 0) {
      _asteroidSpawnPauseTimer =
          math.max(0, _asteroidSpawnPauseTimer - dt).toDouble();

      if (_asteroidSpawnPauseTimer == 0) {
        _spawnTimer.start();
      }
      return;
    }

    _spawnTimer.update(dt);
  }

  void _resetAsteroidDifficultyForDualOrbit() {
    _asteroidSpawnPauseTimer = GameConstants.dualOrbitAsteroidPauseDuration;
    _spawnTimer.limit = _currentSpawnInterval;
    _spawnTimer.start();
  }

  void _recordHighScoreIfNeeded() {
    if (score <= highScore) {
      return;
    }

    highScore = score;
  }

  void _renderThemeDetails(Canvas canvas) {
    if (selectedTheme == 'theme_starry_space') {
      _backgroundDetailPaint
        ..color = Colors.white.withAlpha(135)
        ..strokeWidth = 1
        ..style = PaintingStyle.fill;

      for (var i = 0; i < _stars.length; i += 1) {
        final star = _stars[i].toOffset();

        if (i % 9 == 0) {
          _backgroundDetailPaint.color = Colors.white.withAlpha(120);
          canvas
            ..drawLine(
              star.translate(-1.2, 0),
              star.translate(1.2, 0),
              _backgroundDetailPaint,
            )
            ..drawLine(
              star.translate(0, -1.2),
              star.translate(0, 1.2),
              _backgroundDetailPaint,
            );
        } else {
          _backgroundDetailPaint.color = Colors.white.withAlpha(115);
          canvas.drawRect(
            Rect.fromLTWH(star.dx, star.dy, 1, 1),
            _backgroundDetailPaint,
          );
        }
      }
    } else if (selectedTheme == 'theme_cyber_grid') {
      _backgroundDetailPaint
        ..color = const Color(0x3345A29E)
        ..strokeWidth = 1;

      const spacing = 32.0;
      for (var x = 0.0; x <= size.x; x += spacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.y), _backgroundDetailPaint);
      }
      for (var y = 0.0; y <= size.y; y += spacing) {
        canvas.drawLine(Offset(0, y), Offset(size.x, y), _backgroundDetailPaint);
      }
    }
  }

  void _rebuildStars() {
    if (size.x <= 0 || size.y <= 0) {
      _stars = [];
      return;
    }

    final starRandom = math.Random(42);
    _stars = List<Vector2>.generate(70, (_) {
      return Vector2(
        starRandom.nextDouble() * size.x,
        starRandom.nextDouble() * size.y,
      );
    }, growable: false);
  }
}
