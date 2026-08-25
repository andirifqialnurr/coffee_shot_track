import 'package:coffee_shot_track/app/shot_app.dart';
import 'package:coffee_shot_track/data/shot_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shot app boots without counter demo', (tester) async {
    await tester.pumpWidget(ShotApp(store: _NoopShotStore()));
    await tester.pump();

    expect(find.text('Shot'), findsOneWidget);
    expect(find.text('Coffee Shot Tracker is ready.'), findsOneWidget);
  });
}

class _NoopShotStore extends ShotStore {
  @override
  Future<void> load() async {}
}
