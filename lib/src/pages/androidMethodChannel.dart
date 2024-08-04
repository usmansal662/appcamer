// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/services.dart';

class AndroidMethodChannel {
  static const _channel = MethodChannel('media_store');

  Future<void> updateItem({required File file}) async {
    await _channel.invokeMethod('updateItem', {
      'path': file.path,
    });
  }

  Future<void> openItem({
    required File file,
    required String mimeType,
    required bool openInGallery,
  }) async {
    await _channel.invokeMethod('openItem', {
      'path': file.path,
      'mimeType': mimeType,
      'openInGallery': openInGallery,
    });
  }

  Future<void> disableIntentCamera({required bool disable}) async {
    await _channel.invokeMethod('disableIntentCamera', {
      'disable': disable,
    });
  }

  Future<void> shutterSound() async {
    await _channel.invokeMethod('shutterSound', {});
  }

  Future<void> startVideoSound() async {
    await _channel.invokeMethod('startVideoSound', {});
  }
}
