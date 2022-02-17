abstract class IcloudStorageService {
  Future<IcloudStorageService> init();

  Future<List<String>> listFiles();

  Future<void> deleteFile(String fileName);

  Future<void> uploadFile(
    String srcFilePath,
    String destFileName,
    void Function(Stream<double>) onProgress,
  );
  Future<void> downloadFile(
    String srcFileName,
    String destFilePath,
    void Function(Stream<double>) onProgress,
  );
}
