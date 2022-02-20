import 'dart:async';
import 'dart:developer' as developer;

import 'package:mono_story/constants.dart';
import 'package:mono_story/services/icloud_storage/icloud_storage_service.dart';
import 'package:mono_story/services/service_locator.dart';
import 'package:mono_story/view_models/message_viewmodel_base.dart';

class MessageViewModel extends MessageViewModelBase {
  final _iStorageService = serviceLocator<IcloudStorageService>();

  Future<List<String>> listBackupFiles() async {
    return await _iStorageService.listFiles();
  }

  Future<void> deleteBackupFile(String fileName) async {
    return await _iStorageService.deleteFile(fileName);
  }

  Future<void> initMessageDatabase() async {
    await dbService.init();
  }

  Future<String> getRestoreFilePath() async {
    return dbService.getAppDatabaseRestoreFilePath();
  }

  Future<void> uploadMessages(
    void Function(Stream<double>) onProgress,
  ) async {
    final path = await dbService.getAppDatabaseFilePath();
    String backupFileName = appDatabaseBackupFileNamePrefix;
    backupFileName += DateTime.now().toUtc().toIso8601String();
    await _iStorageService.uploadFile(
      path,
      backupFileName,
      onProgress,
    );
  }

  Future<void> downloadMessages(
    String fileName,
    String restoreFilePath,
    void Function(Stream<double>) onProgress,
  ) async {
    await _iStorageService.downloadFile(
      fileName,
      restoreFilePath,
      onProgress,
    );
  }

  Future<void> applyRestoreMessages() async {
    await dbService.closeAppDatabase();
    await dbService.deleteAppDatabase();
    await dbService.replaceAppDatabase();
  }

  Future<void> deleteMessages() async {
    await dbService.closeAppDatabase();
    await dbService.deleteAppDatabase();

    initMessages();
    notifyListeners();
  }
}
