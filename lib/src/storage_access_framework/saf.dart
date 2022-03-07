import 'package:saf/src/storage_access_framework/api.dart';
import 'package:saf/src/channels.dart';

class Saf {
  String? uriString;
  String directoryPath;
  Saf({required this.directoryPath}) {
    uriString = makeUriString(directoryPath, isTreeUri: true);
  }

  Future<bool?> getDirPermission(
      {bool grantWritePermission = true, bool isDynamic = false}) async {
    try {
      // if (initialDirectoryPath != null) {
      //   directoryPath = initialDirectoryPath;
      //   uriString = makeUriString(directoryPath);
      // }
      const kOpenDocumentTree = 'openDocumentTree';
      const kGrantWritePermission = 'grantWritePermission';
      const kInitialUri = 'initialUri';

      String initialUri = makeUriString(directoryPath);

      final args = <String, dynamic>{
        kGrantWritePermission: grantWritePermission,
        kInitialUri: initialUri
      };
      final selectedDirectoryUri = await kDocumentFileChannel
          .invokeMethod<String?>(kOpenDocumentTree, args);
      if (isDynamic) {
        uriString = selectedDirectoryUri;
        directoryPath = makeDirectoryPath(uriString!);
      }
      if (!isDynamic && selectedDirectoryUri != uriString) {
        releasePersistableUriPermission(selectedDirectoryUri);
        return false;
      }

      return true;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>?> getFilesPath(
      {String fileType = "media", String? directory}) async {
    try {
      const kGetFilesPath = "buildChildDocumentsPathUsingTree";
      const kFileType = "fileType";
      const kSourceTreeUriString = "sourceTreeUriString";
      var sourceTreeUriString = uriString;

      if (directory != null) {
        sourceTreeUriString = makeUriString(directory, isTreeUri: true);
      }

      final args = <String, dynamic>{
        kFileType: fileType,
        kSourceTreeUriString: sourceTreeUriString,
      };
      final paths = await kDocumentsContractChannel
          .invokeMethod<List<dynamic>?>(kGetFilesPath, args);
      if (paths == null) return null;
      return List<String>.from(paths);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>?> getCachedFilesPath() async {
    try {
      const kGetFilesPath = "getCachedFilesPath";
      const kCacheDirectoryName = "cacheDirectoryName";

      var cacheDirectoryName = makeDirectoryPathToName(directoryPath);

      final args = <String, dynamic>{
        kCacheDirectoryName: cacheDirectoryName,
      };
      final paths = await kDocumentFileChannel.invokeMethod<List<dynamic>?>(
          kGetFilesPath, args);
      if (paths == null) return null;
      return List<String>.from(paths);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>?> cache() async {
    try {
      const kCacheToExternalFilesDirectory = "cacheToExternalFilesDirectory";
      const kSourceTreeUriString = "sourceTreeUriString";
      const kCacheDirectoryName = "cacheDirectoryName";

      var cacheDirectoryName = makeDirectoryPathToName(directoryPath);

      final args = <String, dynamic>{
        kSourceTreeUriString: uriString,
        kCacheDirectoryName: cacheDirectoryName,
      };
      final paths = await kDocumentFileChannel.invokeMethod<List<dynamic>?>(
          kCacheToExternalFilesDirectory, args);
      if (paths == null) return null;
      return List<String>.from(paths);
    } catch (e) {
      return null;
    }
  }

  Future<String?> singleCache(
      {required String? filePath, String? directory}) async {
    try {
      const kSingleCacheToExternalFilesDirectory =
          "singleCacheToExternalFilesDirectory";
      const kSourceUriString = "sourceUriString";
      const kCacheDirectoryName = "cacheDirectoryName";

      var sourceUriString = makeUriString(filePath as String);
      var cacheDirectoryName = makeDirectoryPathToName(directoryPath);
      if (directory != null) {
        cacheDirectoryName = makeDirectoryPathToName(directory);
      }
      final args = <String, dynamic>{
        kSourceUriString: sourceUriString,
        kCacheDirectoryName: cacheDirectoryName,
      };
      final path = await kDocumentFileChannel.invokeMethod<String?>(
          kSingleCacheToExternalFilesDirectory, args);
      if (path == null) return null;
      return path;
    } catch (e) {
      return null;
    }
  }

  Future<bool?> clearCache() async {
    try {
      const kClearCachedFiles = "clearCachedFiles";
      const kCacheDirectoryName = "cacheDirectoryName";

      var cacheDirectoryName = makeDirectoryPathToName(directoryPath);

      final args = <String, dynamic>{
        kCacheDirectoryName: cacheDirectoryName,
      };
      final cleared = await kDocumentFileChannel.invokeMethod<bool?>(
          kClearCachedFiles, args);
      if (cleared == null) return null;
      return cleared;
    } catch (e) {
      return null;
    }
  }

  Future<bool?> syncWithCacheDir() async {
    try {
      const kSyncWithExternalFilesDirectory = "syncWithExternalFilesDirectory";
      const kSourceTreeUriString = "sourceTreeUriString";
      const kCacheDirectoryName = "cacheDirectoryName";

      var cacheDirectoryName = makeDirectoryPathToName(directoryPath);

      final args = <String, dynamic>{
        kSourceTreeUriString: uriString,
        kCacheDirectoryName: cacheDirectoryName,
      };
      final isSync = await kDocumentFileChannel.invokeMethod<bool?>(
          kSyncWithExternalFilesDirectory, args);
      if (isSync == null) return null;
      return isSync;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>?> getPersistedPermissionDirectories() async {
    var uriPermissions = await persistedUriPermissions();

    if (uriPermissions == null) return null;

    List<String> uriStrings = [];
    for (var uriPermission in uriPermissions) {
      uriStrings.add(makeDirectoryPath(uriPermission.uri.toString()));
    }
    return uriStrings;
  }

  Future<bool?> releasePersistedPermissions(
      {String? newDirectoryPath, bool releaseAll = false}) async {
    try {
      if (releaseAll) {
        var persistedPermissionDirectories =
            await getPersistedPermissionDirectories();
        if (persistedPermissionDirectories != null) {
          for (var directory in persistedPermissionDirectories) {
            releasePersistableUriPermission(
                makeUriString(directory, isTreeUri: true));
          }
        }
        return true;
      }

      if (newDirectoryPath != null) {
        await releasePersistableUriPermission(
            makeUriString(newDirectoryPath, isTreeUri: true));
      } else {
        await releasePersistableUriPermission(
            makeUriString(directoryPath, isTreeUri: true));
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
