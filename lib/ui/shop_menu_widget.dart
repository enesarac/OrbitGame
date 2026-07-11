import 'package:flutter/material.dart';

import '../game/orbital_gravity_game.dart';
import '../game/shop/shop_item.dart';

class ShopMenuWidget extends StatefulWidget {
  const ShopMenuWidget({required this.game, super.key});

  final OrbitalGravityGame game;

  @override
  State<ShopMenuWidget> createState() => _ShopMenuWidgetState();
}

class _ShopMenuWidgetState extends State<ShopMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xF20B0C10),
      child: SafeArea(
        minimum: const EdgeInsets.all(14),
        child: DefaultTabController(
          length: 2,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF11141C),
                  border: Border.all(color: const Color(0x8845A29E)),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Color(0xAA000000), blurRadius: 28),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _Header(
                        coins: widget.game.totalCoins,
                        onBack: widget.game.closeShopToMainMenu,
                      ),
                      const SizedBox(height: 12),
                      const TabBar(
                        indicatorColor: Color(0xFF66FCF1),
                        labelColor: Color(0xFFFFFFFF),
                        unselectedLabelColor: Color(0xCCFFFFFF),
                        labelStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        tabs: [
                          Tab(text: 'Ball Skins'),
                          Tab(text: 'Themes'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _ItemList(
                              items: ShopCatalog.ballSkins,
                              game: widget.game,
                              onChanged: () => setState(() {}),
                            ),
                            _ItemList(
                              items: ShopCatalog.themes,
                              game: widget.game,
                              onChanged: () => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.coins, required this.onBack});

  final int coins;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'SHOP',
            style: TextStyle(
              color: Color(0xFF66FCF1),
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        Text(
          '$coins coins',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
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
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({
    required this.items,
    required this.game,
    required this.onChanged,
  });

  final List<ShopItem> items;
  final OrbitalGravityGame game;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ShopItemTile(item: item, game: game, onChanged: onChanged);
      },
    );
  }
}

class _ShopItemTile extends StatelessWidget {
  const _ShopItemTile({
    required this.item,
    required this.game,
    required this.onChanged,
  });

  final ShopItem item;
  final OrbitalGravityGame game;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = game.isUnlocked(item.id);
    final isEquipped = game.isEquipped(item.id);
    final canBuy = game.canBuy(item);
    final isDisabled = isEquipped || (!isUnlocked && !canBuy);
    final label = _buttonLabel(isUnlocked: isUnlocked, isEquipped: isEquipped);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF171B25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEquipped ? const Color(0xFF66FCF1) : const Color(0x5545A29E),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _ItemSwatch(item: item),
            const SizedBox(width: 12),
            Expanded(child: _ItemText(item: item)),
            const SizedBox(width: 12),
            SizedBox(
              width: 104,
              height: 40,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: _buttonColor(
                    item: item,
                    isUnlocked: isUnlocked,
                  ),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isEquipped
                      ? const Color(0xFF1E3A3F)
                      : const Color(0xFF2A2F3B),
                  disabledForegroundColor: isEquipped
                      ? const Color(0xFF66FCF1)
                      : Colors.white54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                onPressed: isDisabled
                    ? null
                    : () async {
                        await game.buyOrEquip(item);
                        onChanged();
                      },
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

  String _buttonLabel({required bool isUnlocked, required bool isEquipped}) {
    if (isEquipped) {
      return 'ACTIVE';
    }

    if (isUnlocked) {
      return 'EQUIP';
    }

    return 'BUY';
  }

  Color _buttonColor({required ShopItem item, required bool isUnlocked}) {
    if (isUnlocked) {
      return const Color(0xFF257179);
    }

    return item.type == ShopItemType.theme
        ? const Color(0xFF3E465A)
        : item.color.withAlpha(220);
  }
}

class _ItemSwatch extends StatelessWidget {
  const _ItemSwatch({required this.item});

  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: item.color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xDDFFFFFF), width: 1.5),
        boxShadow: [
          BoxShadow(color: item.color.withAlpha(150), blurRadius: 14),
        ],
      ),
      child: item.id == 'theme_starry_space'
          ? const Center(
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 17),
            )
          : item.id == 'theme_cyber_grid'
          ? const Center(
              child: Icon(Icons.grid_4x4, color: Color(0xFF66FCF1), size: 17),
            )
          : null,
    );
  }
}

class _ItemText extends StatelessWidget {
  const _ItemText({required this.item});

  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.isFree ? 'Free' : '${item.cost} coins',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xCCFFFFFF),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
