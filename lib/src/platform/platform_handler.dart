import 'dart:io';
import 'package:flutter/services.dart';
import '../models/bookmark_data.dart';

abstract class PlatformHandler {
  static const _channel = MethodChannel('com.example.directory_bookmarks/bookmark');
  
  /// Save a directory bookmark
  static Future<bool> saveDirectoryBookmark(String path, {Map<String, dynamic>? metadata}) async {
    try {
      final result = await _channel.invokeMethod('saveDirectoryBookmark', {
        'path': path,
        'metadata': metadata ?? {},
      });
      if (result == null) {
        throw PlatformException(
          code: 'SAVE_ERROR',
          message: 'Failed to save directory bookmark',
        );
      }
      return result;
    } on PlatformException catch (e) {
      print('Failed to save directory bookmark: ${e.message}');
      rethrow;
    }
  }

  /// Resolve a directory bookmark
  static Future<BookmarkData?> resolveDirectoryBookmark() async {
    try {
      final result = await _channel.invokeMethod('resolveDirectoryBookmark');
      if (result != null) {
        final Map<String, dynamic> bookmarkData;
        if (result is Map<Object?, Object?>) {
          bookmarkData = Map<String, dynamic>.from(
            result.map((key, value) => MapEntry(key.toString(), value))
          );
        } else {
          bookmarkData = Map<String, dynamic>.from(result);
        }
        return BookmarkData.fromJson(bookmarkData);
      }
      return null;
    } on PlatformException catch (e) {
      print('Failed to resolve directory bookmark: ${e.message}');
      return null;
    }
  }

  /// Save file to bookmarked directory
  static Future<bool> saveFile(String fileName, List<int> data) async {
    try {
      final result = await _channel.invokeMethod('saveFile', {
        'fileName': fileName,
        'data': data,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to save file: ${e.message}');
      return false;
    }
  }

  /// Read file from bookmarked directory
  static Future<List<int>?> readFile(String fileName) async {
    try {
      final result = await _channel.invokeMethod('readFile', {
        'fileName': fileName,
      });
      return result != null ? List<int>.from(result) : null;
    } on PlatformException catch (e) {
      print('Failed to read file: ${e.message}');
      return null;
    }
  }

  /// List files in bookmarked directory
  static Future<List<String>?> listFiles() async {
    try {
      final result = await _channel.invokeMethod('listFiles');
      return result != null ? List<String>.from(result) : null;
    } on PlatformException catch (e) {
      print('Failed to list files: ${e.message}');
      return null;
    }
  }

  /// Check write permission
  static Future<bool> hasWritePermission() async {
    try {
      final result = await _channel.invokeMethod('hasWritePermission');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to check write permission: ${e.message}');
      return false;
    }
  }

  /// Request write permission
  static Future<bool> requestWritePermission() async {
    try {
      final result = await _channel.invokeMethod('requestWritePermission');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to request write permission: ${e.message}');
      return false;
    }
  }
}
