import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum _RewardedSlot { revive, coins }

abstract final class AdRewardValues {
  static const int rewardedCoinAmount = 25;
}

/// Owns AdMob loading/showing so gameplay code does not depend on ad lifecycle.
///
/// Debug/profile builds always use Google's test ad unit IDs. Live IDs are used
/// only in release builds to avoid accidental policy issues during development.
final class GameAds {
  GameAds._();

  static final GameAds instance = GameAds._();

  static const Duration _interstitialCooldown = Duration(seconds: 90);
  static const int _interstitialEveryNthGameOver = 2;
  static const Duration _adRetryDelay = Duration(seconds: 10);

  InterstitialAd? _gameOverInterstitial;
  RewardedAd? _reviveAd;
  RewardedAd? _coinAd;
  DateTime? _lastInterstitialShownAt;
  int _gameOverCount = 0;
  bool _isInitialized = false;
  bool _isLoadingInterstitial = false;
  bool _isLoadingRevive = false;
  bool _isLoadingCoin = false;
  Timer? _interstitialRetryTimer;
  Timer? _reviveRetryTimer;
  Timer? _coinRetryTimer;

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get isReviveReady => _reviveAd != null;

  bool get isCoinRewardReady => _coinAd != null;

  Future<void> initialize() async {
    if (_isInitialized || !isSupported) {
      return;
    }

    await MobileAds.instance.initialize();
    _isInitialized = true;
    loadAll();
  }

  void loadAll() {
    if (!isSupported || !_isInitialized) {
      return;
    }

    _loadInterstitial();
    _loadRewarded(_RewardedSlot.revive);
    _loadRewarded(_RewardedSlot.coins);
  }

  void maybeShowGameOverInterstitial() {
    if (!isSupported || !_isInitialized) {
      return;
    }

    _gameOverCount += 1;
    final now = DateTime.now();
    final cooldownReady =
        _lastInterstitialShownAt == null ||
        now.difference(_lastInterstitialShownAt!) >= _interstitialCooldown;
    final cadenceReady = _gameOverCount % _interstitialEveryNthGameOver == 0;
    final ad = _gameOverInterstitial;

    if (!cooldownReady || !cadenceReady || ad == null) {
      _loadInterstitial();
      return;
    }

    _gameOverInterstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial failed to show: $error');
        ad.dispose();
        _loadInterstitial();
      },
    );
    _lastInterstitialShownAt = now;
    ad.show();
  }

  Future<bool> showReviveReward() => _showRewarded(_RewardedSlot.revive);

  Future<bool> showCoinReward() => _showRewarded(_RewardedSlot.coins);

  void _loadInterstitial() {
    if (_isLoadingInterstitial || _gameOverInterstitial != null) {
      return;
    }

    _isLoadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: _AdUnitIds.gameOverInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _gameOverInterstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitial = false;
          debugPrint('Interstitial failed to load: $error');
          _scheduleInterstitialRetry();
        },
      ),
    );
  }

  void _loadRewarded(_RewardedSlot slot) {
    if (_isRewardedLoading(slot) || _rewardedAd(slot) != null) {
      return;
    }

    _setRewardedLoading(slot, true);
    RewardedAd.load(
      adUnitId: _AdUnitIds.rewarded(slot),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _setRewardedLoading(slot, false);
          _setRewardedAd(slot, ad);
        },
        onAdFailedToLoad: (error) {
          _setRewardedLoading(slot, false);
          debugPrint('${slot.name} rewarded ad failed to load: $error');
          _scheduleRewardedRetry(slot);
        },
      ),
    );
  }

  void _scheduleInterstitialRetry() {
    _interstitialRetryTimer?.cancel();
    _interstitialRetryTimer = Timer(_adRetryDelay, _loadInterstitial);
  }

  void _scheduleRewardedRetry(_RewardedSlot slot) {
    final timer = Timer(_adRetryDelay, () => _loadRewarded(slot));

    switch (slot) {
      case _RewardedSlot.revive:
        _reviveRetryTimer?.cancel();
        _reviveRetryTimer = timer;
      case _RewardedSlot.coins:
        _coinRetryTimer?.cancel();
        _coinRetryTimer = timer;
    }
  }

  Future<bool> _showRewarded(_RewardedSlot slot) {
    final ad = _rewardedAd(slot);
    if (!isSupported || !_isInitialized || ad == null) {
      _loadRewarded(slot);
      return Future<bool>.value(false);
    }

    final completer = Completer<bool>();
    var earnedReward = false;

    void completeOnce(bool value) {
      if (!completer.isCompleted) {
        completer.complete(value);
      }
    }

    _setRewardedAd(slot, null);
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded(slot);
        completeOnce(earnedReward);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('${slot.name} rewarded ad failed to show: $error');
        ad.dispose();
        _loadRewarded(slot);
        completeOnce(false);
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        earnedReward = true;
      },
    );

    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () => earnedReward,
    );
  }

  RewardedAd? _rewardedAd(_RewardedSlot slot) {
    return switch (slot) {
      _RewardedSlot.revive => _reviveAd,
      _RewardedSlot.coins => _coinAd,
    };
  }

  void _setRewardedAd(_RewardedSlot slot, RewardedAd? ad) {
    switch (slot) {
      case _RewardedSlot.revive:
        _reviveAd = ad;
      case _RewardedSlot.coins:
        _coinAd = ad;
    }
  }

  bool _isRewardedLoading(_RewardedSlot slot) {
    return switch (slot) {
      _RewardedSlot.revive => _isLoadingRevive,
      _RewardedSlot.coins => _isLoadingCoin,
    };
  }

  void _setRewardedLoading(_RewardedSlot slot, bool value) {
    switch (slot) {
      case _RewardedSlot.revive:
        _isLoadingRevive = value;
      case _RewardedSlot.coins:
        _isLoadingCoin = value;
    }
  }
}

abstract final class _AdUnitIds {
  static String get gameOverInterstitial {
    if (!kReleaseMode) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }

    return 'ca-app-pub-5936151123990338/9843625600';
  }

  static String rewarded(_RewardedSlot slot) {
    if (!kReleaseMode) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }

    return switch (slot) {
      _RewardedSlot.revive => 'ca-app-pub-5936151123990338/2867153712',
      _RewardedSlot.coins => 'ca-app-pub-5936151123990338/8663395556',
    };
  }
}
