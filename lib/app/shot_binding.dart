import 'package:get/get.dart';

import '../data/shot_store.dart';

class ShotBinding extends Bindings {
  ShotBinding({ShotController? controller}) : _controller = controller;

  final ShotController? _controller;

  @override
  void dependencies() {
    final controller = _controller;
    if (controller != null) {
      Get.put<ShotController>(controller, permanent: true);
      return;
    }

    Get.lazyPut<ShotController>(ShotController.new, fenix: true);
  }
}
