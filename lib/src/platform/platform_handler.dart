import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../directory_bookmarks.dart';

abstract class PlatformHandler {
  static const _channel =
      MethodChannel('com.example.directory_bookmarks/bookmark');

  /// Throws an UnsupportedError if the current platform is not supported
  static void _checkPlatformSupport() {
    if (!_isPlatformSupported) {
      throw UnsupportedError(
          'Platform ${defaultTargetPlatform.name} is not supported yet. '
          'Currently supported platforms: macOS (full support), '
          'Android (partial support).');
    }
  }

  /// Check if the current platform is supported
  static bool get _isPlatformSupported {
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  /// Save a directory bookmark
  static Future<bool> saveDirectoryBookmark(String path,
      {Map<String, dynamic>? metadata}) async {
    _checkPlatformSupport();
    try {
      final result = await _channel.invokeMethod('saveDirectoryBookmark', {
        'path': path,
        'metadata': metadata,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Resolve a directory bookmark
  static Future<BookmarkData?> resolveDirectoryBookmark() async {
    _checkPlatformSupport();
    try {
      final result = await _channel.invokeMethod('resolveDirectoryBookmark');
      if (result != null) {
        final Map<String, dynamic> bookmarkData;
        if (result is Map<Object?, Object?>) {
          bookmarkData = Map<String, dynamic>.from(
              result.map((key, value) => MapEntry(key.toString(), value)));
        } else {
          bookmarkData = Map<String, dynamic>.from(result);
        }
        return BookmarkData.fromJson(bookmarkData);
      }
      return null;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Save file to bookmarked directory
  static Future<bool> saveFile(String fileName, List<int> data) async {
    _checkPlatformSupport();
    try {
      final result = await _channel.invokeMethod('saveFile', {
        'fileName': fileName,
        'data': data,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Read file from bookmarked directory
  static Future<List<int>?> readFile(String fileName) async {
    _checkPlatformSupport();
    try {
      final result = await _channel.invokeMethod('readFile', {
        'fileName': fileName,
      });
      return result != null ? List<int>.from(result) : null;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// List files in bookmarked directory
  static Future<List<String>?> listFiles() async {
    _checkPlatformSupport();
    try {
      final result = await _channel.invokeMethod('listFiles');
      return result != null ? List<String>.from(result) : null;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Check write permission
  static Future<bool> hasWritePermission() async {
    _checkPlatformSupport();
    try {
      final result = await _channel.invokeMethod('hasWritePermission');
      return result ?? false;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Request write permission
  static Future<bool> requestWritePermission() async {
    _checkPlatformSupport();
    try {
      final result = await _channel.invokeMethod('requestWritePermission');
      return result ?? false;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Handle platform-specific exceptions
  static Exception _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'DIRECTORY_NOT_FOUND':
        return DirectoryNotFoundException('Directory not found: ${e.message}');
      case 'PERMISSION_DENIED':
        return PermissionDeniedException('Permission denied: ${e.message}');
      default:
        return e;
    }
  }
}
