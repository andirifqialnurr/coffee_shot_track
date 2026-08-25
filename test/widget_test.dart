import 'package:coffee_shot_track/app/shot_app.dart';
import 'package:coffee_shot_track/data/shot_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('Shot app boots into empty home state', (tester) async {
    await tester.pumpWidget(ShotApp(controller: _NoopShotController()));
    await tester.pump();

    expect(find.text('Shot'), findsOneWidget);
    expect(find.text('No beans yet'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Beans'), findsOneWidget);
    expect(find.text('New Shot'), findsWidgets);
    expect(find.text('History'), findsOneWidget);
  });
}

class _NoopShotController extends ShotController {
  @override
  Future<void> load() async {}
}
