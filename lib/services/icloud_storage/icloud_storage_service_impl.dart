import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/secure.dart';
import 'package:mono_story/services/icloud_storage/icloud_storage_service.dart';

class IcloudStorageServiceImpl extends IcloudStorageService {
  late ICloudStorage _istorage;

  @override
  Future<IcloudStorageService> init() async {
    _istorage = await ICloudStorage.getInstance(iCloudContainerId);
    return this;
  }

  @override
  Future<List<String>> listFiles() async {
    return await _istorage.listFiles();
  }

  @override
  Future<void> deleteFile(String fileName) async {
    return await _istorage
        .delete(fileName)
        .catchError(_catchIcloudStorageException);
  }

  @override
  Future<void> downloadFile(
    String srcFileName,
    String destFilePath,
    void Function(Stream<double>) onProgress,
  ) async {
    await _istorage
        .startDownload(
          fileName: srcFileName,
          destinationFilePath: destFilePath,
          onProgress: onProgress,
        )
        .catchError(_catchIcloudStorageException);
  }

  @override
  Future<void> uploadFile(
    String srcFilePath,
    String destFileName,
    void Function(Stream<double>) onProgress,
  ) async {
    await _istorage
        .startUpload(
          filePath: srcFilePath,
          destinationFileName: destFileName,
          onProgress: onProgress,
        )
        .catchError(_catchIcloudStorageException);
  }

  void _catchIcloudStorageException(Object exception) {
    if (exception is! PlatformException) {
      throw exception.toString();
    }

    PlatformException e = exception;
    developer.log('[${e.code}] ${e.message}');
    if (e.code == PlatformExceptionCode.iCloudConnectionOrPermission) {
      throw ErrorMessages.iCloudConnectionOrPermissionStr;
    }
    throw e.message ?? 'Empty error message';
  }
}
