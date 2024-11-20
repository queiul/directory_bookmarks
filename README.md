# Directory Bookmarks

A Flutter plugin for cross-platform directory bookmarking and secure file operations. This plugin provides a consistent API for handling directory access and file operations, with special support for platform-specific security features.

## Platform Support

| Platform | Status | Implementation Details |
|----------|--------|----------------------|
| macOS    | Supported | Security-scoped bookmarks for persistent directory access |
| Android  | In Development | Storage Access Framework (partial implementation) |
| iOS      | Planned | Will use security-scoped bookmarks |
| Windows  | Planned | Future implementation |
| Linux    | Planned | Future implementation |

> **Note**: Currently, this package is primarily focused on macOS support. Using it on other platforms will result in unsupported platform errors. We are actively working on expanding platform support.

## Features

- Secure Directory Access: Platform-specific secure directory access mechanisms
  - macOS: Security-scoped bookmarks
  - Android: Storage Access Framework
- Directory Bookmarking: Save and restore access to user-selected directories
- File Operations: Read, write, and list files in bookmarked directories
- Persistent Access: Maintain access to directories across app restarts
- Permission Handling: Built-in permission management and verification
- Resource Management: Automatic cleanup of system resources

## Getting Started

Add the package to your pubspec.yaml:

```yaml
dependencies:
  directory_bookmarks: ^0.1.0
```

### Platform-Specific Setup

#### macOS (Supported)

1. Enable App Sandbox and required entitlements in your macOS app. Add the following to your entitlements files:

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.files.bookmarks.app-scope</key>
<true/>
```

2. Register the plugin in your `AppDelegate.swift`:

```swift
import directory_bookmarks

class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    guard let mainWindow = mainFlutterWindow else { return }
    guard let controller = mainWindow.contentViewController as? FlutterViewController else { return }
    DirectoryBookmarksPlugin.register(with: controller.registrar(forPlugin: "DirectoryBookmarksPlugin"))
    super.applicationDidFinishLaunching(notification)
  }
}
```

#### Android (In Development)

> **Note**: Android support is currently in development. The implementation is partial and may not work as expected.

Add the following permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### Other Platforms (Planned)

Support for iOS, Windows, and Linux is planned for future releases. Using this package on these platforms will currently result in an UnsupportedError.

## API Reference

### Directory Bookmark Operations

- `saveBookmark(String directoryPath, {Map<String, dynamic>? metadata})`: Save a directory bookmark with optional metadata
- `resolveBookmark()`: Resolve and return the current directory bookmark information

### File Operations

- `saveFile(String fileName, List<int> data)`: Save raw data to a file in the bookmarked directory
- `saveStringToFile(String fileName, String content)`: Save text content to a file
- `saveBytesToFile(String fileName, Uint8List bytes)`: Save binary data to a file
- `readFile(String fileName)`: Read raw data from a file
- `readStringFromFile(String fileName)`: Read text content from a file
- `readBytesFromFile(String fileName)`: Read binary data from a file
- `listFiles()`: List all files in the bookmarked directory

### Writing Files

```dart
// Save any type of file (base method)
final fileData = await File('path/to/source/file').readAsBytes();
final success = await DirectoryBookmarkHandler.saveFile(
  'destination.file',
  fileData,
);

// Save text files
final textSuccess = await DirectoryBookmarkHandler.saveStringToFile(
  'example.txt',
  'Hello, World!',
);

// Save binary files (images, PDFs, etc.)
final imageBytes = await File('path/to/image.jpg').readAsBytes();
final imageSuccess = await DirectoryBookmarkHandler.saveBytesToFile(
  'image.jpg',
  imageBytes,
);
```

### Reading Files

```dart
// Read any type of file (base method)
final fileData = await DirectoryBookmarkHandler.readFile('myfile.dat');
if (fileData != null) {
  // Use the file data (List<int>)
}

// Read text files
final textContent = await DirectoryBookmarkHandler.readStringFromFile('example.txt');
if (textContent != null) {
  print('File content: $textContent');
}

// Read binary files
final imageBytes = await DirectoryBookmarkHandler.readBytesFromFile('image.jpg');
if (imageBytes != null) {
  // Use the image bytes (Uint8List)
  final image = Image.memory(imageBytes);
}
```

### Example: Copying a File to Bookmarked Directory

```dart
import 'package:directory_bookmarks/directory_bookmarks.dart';
import 'package:file_picker/file_picker.dart';

Future<void> copyFileToBookmark() async {
  try {
    // Pick a file to copy
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    // Save to bookmarked directory
    final success = await DirectoryBookmarkHandler.saveBytesToFile(
      file.name,
      file.bytes!,
    );

    if (success) {
      print('File copied successfully');
    } else {
      print('Failed to copy file');
    }
  } catch (e) {
    print('Error copying file: $e');
  }
}
```

### Permission Management

- `hasWritePermission()`: Check if write permission is granted for the bookmarked directory
- `requestWritePermission()`: Request write permission for the bookmarked directory

## Usage

### Basic Example

```dart
import 'package:directory_bookmarks/directory_bookmarks.dart';

void main() async {
  // Check platform support
  if (!(defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.android)) {
    print('Platform not supported');
    return;
  }

  try {
    // Select and bookmark a directory
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select a directory to bookmark',
    );
    
    if (path == null) {
      print('No directory selected');
      return;
    }

    // Save the bookmark
    final success = await DirectoryBookmarkHandler.saveBookmark(
      path,
      metadata: {'lastAccessed': DateTime.now().toIso8601String()},
    );

    if (success) {
      print('Directory bookmarked successfully');
    } else {
      print('Failed to bookmark directory');
      return;
    }

    // Resolve the bookmark
    final bookmark = await DirectoryBookmarkHandler.resolveBookmark();
    if (bookmark != null) {
      print('Bookmarked directory: ${bookmark.path}');
      
      // Check write permission
      final hasPermission = await DirectoryBookmarkHandler.hasWritePermission();
      if (!hasPermission) {
        print('No write permission');
        return;
      }

      // List files
      final files = await DirectoryBookmarkHandler.listFiles();
      if (files != null) {
        print('Files in directory: $files');
      }

      // Write a file
      final writeSuccess = await DirectoryBookmarkHandler.saveStringToFile(
        'test.txt',
        'Hello, World!',
      );
      if (writeSuccess) {
        print('File written successfully');
      }

      // Read the file
      final content = await DirectoryBookmarkHandler.readStringFromFile('test.txt');
      if (content != null) {
        print('File content: $content');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Error Handling

The plugin includes comprehensive error handling:

```dart
try {
  // Check platform support first
  if (!(defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.android)) {
    print('Platform ${defaultTargetPlatform.name} is not supported yet');
    return;
  }

  // Try to resolve existing bookmark
  final bookmark = await DirectoryBookmarkHandler.resolveBookmark();
  if (bookmark == null) {
    print('No bookmark found, selecting new directory...');
    
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) {
      print('No directory selected');
      return;
    }
    
    final success = await DirectoryBookmarkHandler.saveBookmark(path);
    if (!success) {
      print('Failed to bookmark directory');
      return;
    }
  }

  // Check permissions
  if (!await DirectoryBookmarkHandler.hasWritePermission()) {
    print('No write permission for bookmarked directory');
    return;
  }

  // Perform file operations...
} on PlatformException catch (e) {
  print('Platform error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/queiul/directory_bookmarks/issues).

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
