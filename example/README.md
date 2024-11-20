# Directory Bookmarks Example

This example demonstrates how to use the `directory_bookmarks` package to handle directory access and file operations with security-scoped bookmarks.

## Features

- Select and bookmark directories
- Persistent directory access across app restarts
- Create and save text files
- Read file contents
- List files in the bookmarked directory
- Write permission handling
- Error handling and user feedback

## Getting Started

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Usage

1. Click the folder icon in the app bar to select a directory
2. The app will create a security-scoped bookmark for the selected directory
3. Use the floating action button to create new text files
4. Click on any file in the list to view its contents
5. The app will maintain access to the directory even after restart

## Platform Support

Currently supported platforms:
- macOS: Full support with security-scoped bookmarks
- iOS: Coming soon
- Android: Coming soon
- Windows: Coming soon
- Linux: Coming soon

## Notes

- On macOS, the app uses security-scoped bookmarks to maintain persistent access to user-selected directories
- Write permission is requested when needed and the status is displayed in the UI
- The app handles state persistence and error cases
- All file operations are performed asynchronously to maintain UI responsiveness
