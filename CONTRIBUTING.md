# Contributing to Directory Bookmarks

First off, thank you for considering contributing to Directory Bookmarks! It's people like you that make Directory Bookmarks such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Platform Support

We're actively looking for help with implementing support for different platforms:

- iOS: Needs security-scoped bookmarks implementation
- Windows: Needs persistent directory access implementation
- Linux: Needs directory bookmarking implementation

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* Use a clear and descriptive title
* Describe the exact steps which reproduce the problem
* Provide specific examples to demonstrate the steps
* Describe the behavior you observed after following the steps
* Explain which behavior you expected to see instead and why
* Include logs and stack traces if available
* Mention the platform(s) where you encountered the issue

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* A clear and descriptive title
* A step-by-step description of the suggested enhancement
* Specific examples to demonstrate the steps
* A description of the current behavior and why it's insufficient
* An explanation of how this enhancement would be useful

### Pull Requests

Please follow these steps to have your contribution considered:

1. Follow the coding style and conventions used in the project
2. Update the README.md with details of significant changes
3. Update the example app if needed
4. Add or update tests as appropriate
5. Update the documentation to reflect your changes
6. Ensure the test suite passes
7. Make sure your code lints

## Development Process

1. Fork the repo and create your branch from `main`
2. Run `flutter pub get` to install dependencies
3. Make your changes
4. Test your changes:
   ```bash
   flutter test
   cd example
   flutter run
   ```
5. Ensure your code follows our style guidelines:
   ```bash
   flutter analyze
   ```

## Platform-Specific Development

### macOS

1. Ensure you have Xcode installed
2. Add necessary entitlements to your app:
   ```xml
   <key>com.apple.security.app-sandbox</key>
   <true/>
   <key>com.apple.security.files.user-selected.read-write</key>
   <true/>
   <key>com.apple.security.files.bookmarks.app-scope</key>
   <true/>
   ```

### Android

1. Ensure you have Android Studio installed
2. Add necessary permissions to AndroidManifest.xml:
   ```xml
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   ```

## Style Guidelines

### Dart Style Guide

* Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
* Use `dartfmt` to format your code
* Add documentation comments for public APIs
* Keep functions focused and concise
* Use meaningful variable names

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

### Documentation

* Keep README.md up to date
* Document all public APIs
* Include examples in documentation
* Update CHANGELOG.md with notable changes

## Community

* Join our [Discord server](your-discord-link) for discussions
* Follow us on [Twitter](your-twitter-link) for updates
* Read our [blog](your-blog-link) for detailed articles

## Questions?

Feel free to open an issue with the tag `question` if you have any questions about contributing.

Thank you for your contributions! ❤️
