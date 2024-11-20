import 'package:flutter/material.dart';
import 'package:directory_bookmarks/directory_bookmarks.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

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
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _fileContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBookmark();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _fileContentController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmark() async {
    final bookmark = await DirectoryBookmarkHandler.resolveBookmark();
    if (bookmark != null) {
      setState(() {
        _currentBookmark = bookmark;
      });
      await _checkPermissionAndLoadFiles();
    }
  }

  Future<void> _checkPermissionAndLoadFiles() async {
    final hasPermission = await DirectoryBookmarkHandler.hasWritePermission();
    setState(() {
      _hasWritePermission = hasPermission;
    });
    if (hasPermission) {
      await _loadFiles();
    }
  }

  Future<void> _loadFiles() async {
    final files = await DirectoryBookmarkHandler.listFiles();
    if (files != null) {
      setState(() {
        _files = files;
      });
    }
  }

  Future<void> _selectDirectory() async {
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
      final content = await DirectoryBookmarkHandler.readStringFromFile(fileName);
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
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _selectDirectory,
            tooltip: 'Select Directory',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Directory:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(_currentBookmark?.path ?? 'No directory selected'),
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: _selectDirectory,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Select Directory'),
                    ),
                  ],
                ),
                if (_currentBookmark != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _hasWritePermission ? Icons.check_circle : Icons.error,
                        color: _hasWritePermission ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Write Permission: ${_hasWritePermission ? "Granted" : "Not Granted"}',
                        style: TextStyle(
                          color: _hasWritePermission ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveTestFile,
                    child: const Text('Save Test File'),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _files.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 48,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _currentBookmark == null
                              ? 'Select a directory to start'
                              : 'No files in directory',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
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
      floatingActionButton: _currentBookmark == null
          ? null
          : FloatingActionButton(
              onPressed: _showCreateFileDialog,
              tooltip: 'Create File',
              child: const Icon(Icons.add),
            ),
    );
  }
}
