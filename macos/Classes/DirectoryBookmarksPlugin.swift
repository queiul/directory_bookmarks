import Cocoa
import FlutterMacOS

private extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: self)
    }
}

public class DirectoryBookmarksPlugin: NSObject, FlutterPlugin {
    private let bookmarkHandler = DirectoryBookmarkHandler.shared
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.example.directory_bookmarks/bookmark",
            binaryMessenger: registrar.messenger)
        let instance = DirectoryBookmarksPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "saveDirectoryBookmark":
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid arguments for saveDirectoryBookmark",
                    details: "Required arguments: path (String)"
                ))
                return
            }
            
            let success = bookmarkHandler.saveDirectoryBookmark(path: path)
            if success {
                result(true)
            } else {
                result(FlutterError(
                    code: "SAVE_ERROR",
                    message: "Failed to save directory bookmark",
                    details: "Could not create security-scoped bookmark for path: \(path)"
                ))
            }
            
        case "resolveDirectoryBookmark":
            if let url = bookmarkHandler.resolveBookmark() {
                result([
                    "path": url.path,
                    "createdAt": Date().iso8601String,
                    "metadata": [:] as [String: Any]
                ])
            } else {
                result(nil)
            }
            
        case "saveFile":
            guard let args = call.arguments as? [String: Any],
                  let fileName = args["fileName"] as? String,
                  let data = args["data"] as? FlutterStandardTypedData else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid arguments for saveFile",
                    details: "Required arguments: fileName (String), data (Uint8List)"
                ))
                return
            }
            
            let success = bookmarkHandler.saveFile(fileName: fileName, data: data)
            if success {
                result(true)
            } else {
                result(FlutterError(
                    code: "SAVE_ERROR",
                    message: "Failed to save file",
                    details: "Could not write file: \(fileName)"
                ))
            }
            
        case "readFile":
            guard let args = call.arguments as? [String: Any],
                  let fileName = args["fileName"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid arguments for readFile",
                    details: "Required arguments: fileName (String)"
                ))
                return
            }
            
            if let data = bookmarkHandler.readFile(fileName: fileName) {
                result(data)
            } else {
                result(FlutterError(
                    code: "READ_ERROR",
                    message: "Failed to read file",
                    details: "Could not read file: \(fileName)"
                ))
            }
            
        case "listFiles":
            if let files = bookmarkHandler.listFiles() {
                result(files)
            } else {
                result(FlutterError(
                    code: "LIST_ERROR",
                    message: "Failed to list files",
                    details: "Could not list files in bookmarked directory"
                ))
            }
            
        case "hasWritePermission":
            result(bookmarkHandler.hasWritePermission())
            
        case "requestWritePermission":
            result(bookmarkHandler.hasWritePermission())
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
