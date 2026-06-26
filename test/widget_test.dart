import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oyun_prog/game/orbital_gravity_game.dart';
import 'package:oyun_prog/main.dart';

void main() {
  testWidgets('Orbital Gravity boots into a Flame game', (tester) async {
    await tester.pumpWidget(const OrbitalGravityApp());

    expect(
      find.byWidgetPredicate(
        (widget) => widget is GameWidget<OrbitalGravityGame>,
      ),
      findsOneWidget,
    );
  });
}
