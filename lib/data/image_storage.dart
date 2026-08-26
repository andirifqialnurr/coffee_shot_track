import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStorage {
  const ImageStorage._();

  static Future<String?> pickAndStoreImage({required String prefix}) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );
    if (picked == null) {
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory(p.join(directory.path, 'shot_images'));
    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }

    final extension = p.extension(picked.path).isEmpty
        ? '.jpg'
        : p.extension(picked.path);
    final fileName =
        '${_safePrefix(prefix)}_${DateTime.now().microsecondsSinceEpoch}$extension';
    final stored = File(p.join(imageDirectory.path, fileName));
    await File(picked.path).copy(stored.path);
    return stored.path;
  }
}

String _safePrefix(String value) {
  final normalized = value.trim().toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]+'),
        '_',
      );
  return normalized.isEmpty ? 'image' : normalized;
}
