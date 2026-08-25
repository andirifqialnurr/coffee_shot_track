import 'package:coffee_shot_track/app/shot_app.dart';
import 'package:coffee_shot_track/data/shot_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('Shot app boots into empty home state', (tester) async {
    await tester.pumpWidget(ShotApp(controller: _NoopShotController()));
    await tester.pumpAndSettle();

    expect(find.text('Shot', skipOffstage: false), findsOneWidget);
    expect(find.text('No beans yet', skipOffstage: false), findsOneWidget);
    expect(find.text('Home', skipOffstage: false), findsOneWidget);
    expect(find.text('Beans', skipOffstage: false), findsWidgets);
    expect(find.text('New Shot', skipOffstage: false), findsWidgets);
    expect(find.text('History', skipOffstage: false), findsWidgets);
  });
}

class _NoopShotController extends ShotController {
  @override
  Future<void> load() async {}
}
