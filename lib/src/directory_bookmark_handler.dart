import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'models/bookmark_data.dart';
import 'platform/platform_handler.dart';

class DirectoryBookmarkHandler {
  /// Save a directory bookmark
  static Future<bool> saveBookmark(String directoryPath, {Map<String, dynamic>? metadata}) async {
    if (!await Directory(directoryPath).exists()) {
      throw DirectoryNotFoundException('Directory does not exist: $directoryPath');
    }
    return PlatformHandler.saveDirectoryBookmark(directoryPath, metadata: metadata);
  }

  /// Resolve the current bookmarked directory
  static Future<BookmarkData?> resolveBookmark() async {
    return PlatformHandler.resolveDirectoryBookmark();
  }

  /// Save file to the bookmarked directory
  static Future<bool> saveFile(String fileName, List<int> data) async {
    if (!await PlatformHandler.hasWritePermission()) {
      final hasPermission = await PlatformHandler.requestWritePermission();
      if (!hasPermission) {
        throw PermissionDeniedException('Write permission denied');
      }
    }
    return PlatformHandler.saveFile(fileName, data);
  }

  /// Save string content to a file in the bookmarked directory
  static Future<bool> saveStringToFile(String fileName, String content) async {
    final data = utf8.encode(content);
    return saveFile(fileName, data);
  }

  /// Save bytes to a file in the bookmarked directory
  static Future<bool> saveBytesToFile(String fileName, Uint8List bytes) async {
    return saveFile(fileName, bytes);
  }

  /// Read file from the bookmarked directory
  static Future<List<int>?> readFile(String fileName) async {
    return PlatformHandler.readFile(fileName);
  }

  /// Read string content from a file in the bookmarked directory
  static Future<String?> readStringFromFile(String fileName) async {
    final bytes = await readFile(fileName);
    if (bytes == null) return null;
    return String.fromCharCodes(bytes);
  }

  /// Read bytes from a file in the bookmarked directory
  static Future<Uint8List?> readBytesFromFile(String fileName) async {
    final bytes = await readFile(fileName);
    if (bytes == null) return null;
    return Uint8List.fromList(bytes);
  }

  /// List all files in the bookmarked directory
  static Future<List<String>?> listFiles() async {
    return PlatformHandler.listFiles();
  }

  /// Check if we have write permission
  static Future<bool> hasWritePermission() async {
    return PlatformHandler.hasWritePermission();
  }

  /// Request write permission
  static Future<bool> requestWritePermission() async {
    return PlatformHandler.requestWritePermission();
  }
}

class DirectoryNotFoundException implements Exception {
  final String message;
  DirectoryNotFoundException(this.message);
  @override
  String toString() => 'DirectoryNotFoundException: $message';
}

class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);
  @override
  String toString() => 'PermissionDeniedException: $message';
}
