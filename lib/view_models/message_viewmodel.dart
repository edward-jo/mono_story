import 'dart:async';

import 'package:mono_story/constants.dart';
import 'package:mono_story/services/icloud_storage/icloud_storage_service.dart';
import 'package:mono_story/services/service_locator.dart';
import 'package:mono_story/view_models/message_viewmodel_base.dart';

class MessageViewModel extends MessageViewModelBase {
  final _iStorageService = serviceLocator<IcloudStorageService>();

  Future<void> uploadMessages(
    void Function(Stream<double>) onProgress,
  ) async {
    final path = await dbService.getAppDatabaseFilePath();
    await _iStorageService.uploadFile(
      path,
      appDatabaseBackupFileName,
      onProgress,
    );
  }

  Future<void> downloadMessages(
    void Function(Stream<double>) onProgress,
  ) async {
    final path = await dbService.getAppDatabaseFilePath();

    await dbService.closeAppDatabase();
    await dbService.deleteAppDatabase();

    await _iStorageService.downloadFile(
      appDatabaseBackupFileName,
      path,
      onProgress,
    );

    messages.clear();
    notifyListeners();
  }

  Future<void> deleteMessages() async {
    await dbService.closeAppDatabase();
    await dbService.deleteAppDatabase();
    messages.clear();
    notifyListeners();
  }
}
