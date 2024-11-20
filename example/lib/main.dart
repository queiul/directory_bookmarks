import 'package:directory_bookmarks/directory_bookmarks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Directory Bookmarks Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DirectoryBookmarksDemo(),
    );
  }
}

class DirectoryBookmarksDemo extends StatefulWidget {
  const DirectoryBookmarksDemo({super.key});

  @override
  State<DirectoryBookmarksDemo> createState() => _DirectoryBookmarksDemoState();
}

class _DirectoryBookmarksDemoState extends State<DirectoryBookmarksDemo> {
  BookmarkData? _currentBookmark;
  List<String> _files = [];
  bool _hasWritePermission = false;
  String? _errorMessage;
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _fileContentController = TextEditingController();

  bool get _isSupported =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _checkPlatformAndLoadBookmark();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _fileContentController.dispose();
    super.dispose();
  }

  Future<void> _checkPlatformAndLoadBookmark() async {
    if (!_isSupported) {
      setState(() {
        _errorMessage =
            'Platform ${defaultTargetPlatform.name} is not supported yet. '
            'Currently supported platforms: macOS (full support), '
            'Android (partial support).';
      });
      return;
    }

    try {
      await _loadBookmark();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _loadBookmark() async {
    final bookmark = await DirectoryBookmarkHandler.resolveBookmark();
    if (bookmark != null) {
      setState(() {
        _currentBookmark = bookmark;
        _errorMessage = null;
      });
      await _checkPermissionAndLoadFiles();
    }
  }

  Future<void> _checkPermissionAndLoadFiles() async {
    try {
      final hasPermission = await DirectoryBookmarkHandler.hasWritePermission();
      setState(() {
        _hasWritePermission = hasPermission;
        _errorMessage = null;
      });
      if (hasPermission) {
        await _loadFiles();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Permission error: $e';
      });
    }
  }

  Future<void> _loadFiles() async {
    try {
      final files = await DirectoryBookmarkHandler.listFiles();
      if (files != null) {
        setState(() {
          _files = files;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading files: $e';
      });
    }
  }

  Future<void> _selectDirectory() async {
    if (!_isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage ?? 'Platform not supported')),
      );
      return;
    }

    String? path;
    try {
      path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select a directory to bookmark',
      );

      if (path == null) {
        // User canceled the picker
        return;
      }

      final success = await DirectoryBookmarkHandler.saveBookmark(
        path,
        metadata: {'lastAccessed': DateTime.now().toIso8601String()},
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Directory bookmarked successfully')),
        );
        await _loadBookmark();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to bookmark directory')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showCreateFileDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                labelText: 'File Name',
                hintText: 'example.txt',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fileContentController,
              decoration: const InputDecoration(
                labelText: 'File Content',
                hintText: 'Enter text content...',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createFile(
                _fileNameController.text,
                _fileContentController.text,
              );
              _fileNameController.clear();
              _fileContentController.clear();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createFile(String fileName, String content) async {
    if (!_hasWritePermission) {
      final granted = await DirectoryBookmarkHandler.requestWritePermission();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Write permission denied')),
        );
        return;
      }
      setState(() {
        _hasWritePermission = true;
      });
    }

    try {
      final success = await DirectoryBookmarkHandler.saveStringToFile(
        fileName,
        content,
      );
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File created successfully')),
        );
        await _loadFiles();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _viewFile(String fileName) async {
    try {
      final content =
          await DirectoryBookmarkHandler.readStringFromFile(fileName);
      if (!mounted) return;
      if (content != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(fileName),
            content: SingleChildScrollView(
              child: Text(content),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _saveTestFile() async {
    if (_currentBookmark == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a directory first')),
      );
      return;
    }

    try {
      final testContent = 'Hello from Directory Bookmarks! ${DateTime.now()}';
      final success = await DirectoryBookmarkHandler.saveStringToFile(
        'test_file.txt',
        testContent,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test file saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save test file')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving test file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory Bookmarks Demo'),
        actions: [
          if (_isSupported && _currentBookmark != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadFiles,
              tooltip: 'Refresh files',
            ),
        ],
      ),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          : _currentBookmark == null
              ? Center(
                  child: Text(
                    'No directory bookmarked yet.\n'
                    'Click the button below to select a directory.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bookmarked Directory:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(_currentBookmark!.path),
                          if (!_hasWritePermission) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Write permission required to create files',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: _files.isEmpty
                          ? const Center(
                              child: Text('No files in directory'),
                            )
                          : ListView.builder(
                              itemCount: _files.length,
                              itemBuilder: (context, index) {
                                final fileName = _files[index];
                                return ListTile(
                                  leading: const Icon(Icons.description),
                                  title: Text(fileName),
                                  onTap: () => _viewFile(fileName),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isSupported && _currentBookmark != null && _hasWritePermission)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FloatingActionButton(
                onPressed: _showCreateFileDialog,
                heroTag: 'create_file',
                child: const Icon(Icons.note_add),
              ),
            ),
          FloatingActionButton(
            onPressed: _selectDirectory,
            heroTag: 'select_directory',
            child: const Icon(Icons.folder_open),
          ),
        ],
      ),
    );
  }
}
