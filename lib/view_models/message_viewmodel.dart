import 'dart:async';
import 'dart:developer' as developer;

import 'package:mono_story/constants.dart';
import 'package:mono_story/services/icloud_storage/icloud_storage_service.dart';
import 'package:mono_story/services/service_locator.dart';
import 'package:mono_story/view_models/message_viewmodel_base.dart';
import 'package:path/path.dart';

class StoryViewModel extends StoryViewModelBase {
  final _iStorageService = serviceLocator<IcloudStorageService>();

  Future<List<String>> listBackupFiles() async {
    return await _iStorageService.listFiles();
  }

  void _subscribeDownloadStream(Stream<double> stream, String fileName) {
    stream.listen(
      // onData
      (event) {
        developer.log('Downloading a file: $fileName, onData( $event )');
      },
      onError: (error) {
        developer.log(
          'Failed to download a file: $fileName',
          error: 'onError: ${error.toString()}',
        );
      },
      onDone: () async {
        developer.log('Completed downloading a file: $fileName, onDone()');
        developer.log('Start to delete a file: $fileName');
        await _iStorageService.deleteFile(fileName).then((value) {
          developer.log('Deleted a file: $fileName');
        });
      },
      // the subscription is automatically canceled when the first error event
      // is delivered.
      cancelOnError: true,
    );
  }

  Future<void> deleteBackupFile(String fileName) async {
    final databaseDirPath = await dbService.getAppDatabaseDirPath();
    var backupFilePath = join(databaseDirPath, fileName);

    // Download a backup file and delete it.
    await _iStorageService.downloadFile(
      fileName,
      backupFilePath,
      (stream) => _subscribeDownloadStream(stream, fileName),
    );
  }

  Future<void> initStoryDatabase() async {
    await dbService.init();
  }

  Future<String> getRestoreFilePath() async {
    return dbService.getAppDatabaseRestoreFilePath();
  }

  Future<void> uploadStories(
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

  Future<void> downloadStories(
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

  Future<void> applyRestoreStories() async {
    await dbService.closeAppDatabase();
    await dbService.deleteAppDatabase();
    await dbService.replaceAppDatabase();
  }

  Future<void> deleteStories() async {
    await dbService.closeAppDatabase();
    await dbService.deleteAppDatabase();

    initStories();
    notifyListeners();
  }
}
