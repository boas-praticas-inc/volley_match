import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class PlayerPhotoStorage {
  PlayerPhotoStorage({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<String?> pickAndStorePhoto({
    required int playerId,
    required ImageSource source,
  }) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 82,
    );

    if (pickedFile == null) {
      return null;
    }

    final appDirectory = await getApplicationDocumentsDirectory();
    final photosDirectory = Directory(
      path.join(appDirectory.path, 'player_photos'),
    );

    if (!await photosDirectory.exists()) {
      await photosDirectory.create(recursive: true);
    }

    final extension = path.extension(pickedFile.path).isEmpty
        ? '.jpg'
        : path.extension(pickedFile.path);
    final fileName =
        'player_${playerId}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final targetPath = path.join(photosDirectory.path, fileName);

    await File(pickedFile.path).copy(targetPath);
    return targetPath;
  }

  Future<void> deletePhoto(String? photoPath) async {
    if (photoPath == null || photoPath.trim().isEmpty) {
      return;
    }

    final file = File(photoPath);

    if (await file.exists()) {
      await file.delete();
    }
  }
}
