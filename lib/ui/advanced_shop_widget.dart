import 'dart:async';

import 'package:flutter/material.dart';

import '../game/ads/game_ads.dart';
import '../game/orbital_gravity_game.dart';
import '../game/shop/shop_item.dart';

class AdvancedShopWidget extends StatefulWidget {
  const AdvancedShopWidget({required this.game, super.key});

  final OrbitalGravityGame game;

  @override
  State<AdvancedShopWidget> createState() => _AdvancedShopWidgetState();
}

class _AdvancedShopWidgetState extends State<AdvancedShopWidget> {
  _ShopSection? _selectedSection;
  Timer? _adReadinessTimer;

  static final List<_ShopSection> _sections = [
    _ShopSection(
      title: 'Orbit Colors',
      subtitle: 'Player ball skins',
      icon: Icons.trip_origin,
      accent: const Color(0xFF45A29E),
      items: ShopCatalog.ballSkins,
    ),
    _ShopSection(
      title: 'Backgrounds',
      subtitle: 'Space, stars, grid',
      icon: Icons.wallpaper,
      accent: const Color(0xFF66FCF1),
      items: ShopCatalog.themes,
    ),
    _ShopSection(
      title: 'Skills',
      subtitle: 'Run boosters',
      icon: Icons.shield,
      accent: Colors.white,
      items: ShopCatalog.skills,
    ),
    _ShopSection(
      title: 'Trails',
      subtitle: 'Motion effects',
      icon: Icons.auto_awesome,
      accent: const Color(0xFFFF4DFF),
      items: ShopCatalog.trails,
    ),
    _ShopSection(
      title: 'Cosmic Cores',
      subtitle: 'Sun skins',
      icon: Icons.radio_button_checked,
      accent: const Color(0xFFFFD166),
      items: ShopCatalog.sunSkins,
    ),
  ];

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
    return ColoredBox(
      color: const Color(0xF20B0C10),
      child: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF10141D),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x8845A29E)),
                boxShadow: const [
                  BoxShadow(color: Color(0xAA000000), blurRadius: 28),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _ShopHeader(
                      title: _selectedSection?.title ?? 'COSMIC SHOP',
                      coins: widget.game.totalCoins,
                      onBack: _selectedSection == null
                          ? widget.game.closeShopToMainMenu
                          : () => setState(() => _selectedSection = null),
                      onRewardedCoin: () async {
                        final claimed = await widget.game.claimRewardedCoins();
                        if (!context.mounted) {
                          return;
                        }

                        setState(() {});
                        if (!claimed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ad is not ready yet. Try again soon.',
                              ),
                            ),
                          );
                        }
                      },
                      rewardedCoinReady: widget.game.isRewardedCoinReady,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _selectedSection == null
                            ? _SectionGrid(
                                sections: _sections,
                                onSelect: (section) {
                                  setState(() => _selectedSection = section);
                                },
                              )
                            : _ItemGrid(
                                key: ValueKey(_selectedSection!.title),
                                section: _selectedSection!,
                                game: widget.game,
                                onChanged: () => setState(() {}),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _ShopSection {
  const _ShopSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<ShopItem> items;
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({
    required this.title,
    required this.coins,
    required this.onBack,
    required this.onRewardedCoin,
    required this.rewardedCoinReady,
  });

  final String title;
  final int coins;
  final VoidCallback onBack;
  final Future<void> Function() onRewardedCoin;
  final bool rewardedCoinReady;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF66FCF1),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF191D27),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x55FFD700)),
              ),
              child: Text(
                '$coins coins',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0x99FFFFFF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onBack,
              child: const Text('Back'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFFD700),
              side: const BorderSide(color: Color(0x99FFD700)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            onPressed: rewardedCoinReady ? onRewardedCoin : null,
            icon: const Icon(Icons.play_circle_fill, size: 18),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                rewardedCoinReady
                    ? 'WATCH AD +${AdRewardValues.rewardedCoinAmount} COINS'
                    : 'AD LOADING...',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionGrid extends StatelessWidget {
  const _SectionGrid({required this.sections, required this.onSelect});

  final List<_ShopSection> sections;
  final ValueChanged<_ShopSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 460 ? 2 : 1;

        return GridView.builder(
          itemCount: sections.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 118,
          ),
          itemBuilder: (context, index) {
            final section = sections[index];

            return _SectionCard(
              section: section,
              onTap: () => onSelect(section),
            );
          },
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.onTap});

  final _ShopSection section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF171B25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: section.accent.withAlpha(130)),
            boxShadow: [
              BoxShadow(color: section.accent.withAlpha(35), blurRadius: 18),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _RoundIcon(color: section.accent, icon: section.icon),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        section.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${section.items.length} items',
                        style: TextStyle(
                          color: section.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemGrid extends StatelessWidget {
  const _ItemGrid({
    required super.key,
    required this.section,
    required this.game,
    required this.onChanged,
  });

  final _ShopSection section;
  final OrbitalGravityGame game;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 3 : 2;

        return GridView.builder(
          itemCount: section.items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 176,
          ),
          itemBuilder: (context, index) {
            return _ItemCard(
              item: section.items[index],
              game: game,
              onChanged: onChanged,
            );
          },
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.game,
    required this.onChanged,
  });

  final ShopItem item;
  final OrbitalGravityGame game;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final active = game.isEquipped(item.id);
    final label = _buttonLabel();
    final enabled = _isEnabled();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF171B25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? const Color(0xFF66FCF1) : const Color(0x5545A29E),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(child: _PreviewToken(item: item)),
            ),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.isFree ? 'Free' : '${item.cost} coins',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: _buttonColor(),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: active || label == 'READY'
                      ? const Color(0xFF1E3A3F)
                      : const Color(0xFF2A2F3B),
                  disabledForegroundColor: active || label == 'READY'
                      ? const Color(0xFF66FCF1)
                      : Colors.white54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onPressed: enabled
                    ? () async {
                        await game.buyOrEquip(item);
                        onChanged();
                      }
                    : null,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, maxLines: 1, softWrap: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isEnabled() {
    if (item.type == ShopItemType.skill) {
      return !game.hasShieldPurchased && game.canBuy(item);
    }

    return !game.isEquipped(item.id) &&
        (game.isUnlocked(item.id) || game.canBuy(item));
  }

  String _buttonLabel() {
    if (item.type == ShopItemType.skill) {
      return game.hasShieldPurchased ? 'READY' : 'BUY';
    }

    if (game.isEquipped(item.id)) {
      return 'ACTIVE';
    }

    if (game.isUnlocked(item.id)) {
      return 'EQUIP';
    }

    return 'BUY';
  }

  Color _buttonColor() {
    if (item.type == ShopItemType.skill) {
      return const Color(0xFF4F5B72);
    }

    if (game.isUnlocked(item.id)) {
      return const Color(0xFF257179);
    }

    return const Color(0xFF3E465A);
  }
}

class _PreviewToken extends StatelessWidget {
  const _PreviewToken({required this.item});

  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.type) {
      ShopItemType.skill => Icons.shield,
      ShopItemType.theme =>
        item.id == 'theme_cyber_grid'
            ? Icons.grid_4x4
            : item.id == 'theme_starry_space'
            ? Icons.auto_awesome
            : Icons.dark_mode,
      ShopItemType.trail => Icons.auto_awesome,
      ShopItemType.sunSkin => Icons.radio_button_checked,
      ShopItemType.ball => Icons.circle,
    };

    return _RoundIcon(color: item.color, icon: icon, size: 54, iconSize: 24);
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.color,
    required this.icon,
    this.size = 46,
    this.iconSize = 20,
  });

  final Color color;
  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xDDFFFFFF), width: 1.5),
        boxShadow: [BoxShadow(color: color.withAlpha(150), blurRadius: 14)],
      ),
      child: Icon(
        icon,
        color: color.computeLuminance() > 0.7
            ? const Color(0xFF0B0C10)
            : Colors.white,
        size: iconSize,
      ),
    );
  }
}
