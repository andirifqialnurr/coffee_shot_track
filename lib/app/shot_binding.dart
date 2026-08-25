import 'package:get/get.dart';

import '../data/shot_store.dart';

class ShotBinding extends Bindings {
  ShotBinding({ShotStore? store}) : _store = store;

  final ShotStore? _store;

  @override
  void dependencies() {
    final store = _store;
    if (store != null) {
      Get.put<ShotStore>(store, permanent: true);
      return;
    }

    Get.lazyPut<ShotStore>(ShotStore.new, fenix: true);
  }
}
