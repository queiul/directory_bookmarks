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

## Usage

### Basic Example

```dart
import 'package:directory_bookmarks/directory_bookmarks.dart';

// Save a directory bookmark
final success = await DirectoryBookmarkHandler.saveDirectoryBookmark(
  '/path/to/directory',
  metadata: {'label': 'My Documents'},
);

// Resolve a saved bookmark
final bookmark = await DirectoryBookmarkHandler.resolveDirectoryBookmark();
if (bookmark != null) {
  print('Bookmarked directory: ${bookmark.path}');
  print('Created at: ${bookmark.createdAt}');
  print('Metadata: ${bookmark.metadata}');
}

// Save a file to the bookmarked directory
final fileContent = 'Hello, World!';
final saved = await DirectoryBookmarkHandler.saveStringToFile(
  'test.txt',
  fileContent,
);

// List files in the bookmarked directory
final files = await DirectoryBookmarkHandler.listFiles();
print('Files in directory: $files');

// Check write permission
final hasPermission = await DirectoryBookmarkHandler.hasWritePermission();
print('Has write permission: $hasPermission');
```

### Error Handling

The plugin includes comprehensive error handling:

```dart
try {
  final success = await DirectoryBookmarkHandler.saveDirectoryBookmark('/path/to/dir');
  if (!success) {
    print('Failed to save bookmark');
  }
} catch (e) {
  print('Error saving bookmark: $e');
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/queiul/directory_bookmarks/issues).

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
