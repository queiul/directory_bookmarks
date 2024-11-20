package com.example.directory_bookmarks

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import androidx.annotation.NonNull
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.util.*

class DirectoryBookmarksPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private lateinit var preferences: SharedPreferences

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.directory_bookmarks/bookmark")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        preferences = context.getSharedPreferences("directory_bookmarks", Context.MODE_PRIVATE)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "saveDirectoryBookmark" -> {
                val path = call.argument<String>("path")
                if (path == null) {
                    result.error("INVALID_ARGUMENTS", "Path is required", null)
                    return
                }
                
                try {
                    val file = File(path)
                    if (!file.exists() || !file.isDirectory) {
                        result.error("INVALID_PATH", "Path does not exist or is not a directory", null)
                        return
                    }

                    preferences.edit().putString("bookmarked_directory", path).apply()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SAVE_ERROR", e.message, null)
                }
            }
            "resolveDirectoryBookmark" -> {
                val path = preferences.getString("bookmarked_directory", null)
                if (path == null) {
                    result.success(null)
                    return
                }

                try {
                    val file = File(path)
                    if (!file.exists() || !file.isDirectory) {
                        result.success(null)
                        return
                    }

                    result.success(mapOf(
                        "path" to path,
                        "createdAt" to Date().toString(),
                        "metadata" to mapOf<String, Any>()
                    ))
                } catch (e: Exception) {
                    result.error("RESOLVE_ERROR", e.message, null)
                }
            }
            "saveFile" -> {
                val fileName = call.argument<String>("fileName")
                val data = call.argument<ByteArray>("data")
                if (fileName == null || data == null) {
                    result.error("INVALID_ARGUMENTS", "fileName and data are required", null)
                    return
                }

                try {
                    val dirPath = preferences.getString("bookmarked_directory", null)
                    if (dirPath == null) {
                        result.error("NO_DIRECTORY", "No bookmarked directory found", null)
                        return
                    }

                    val dir = File(dirPath)
                    if (!dir.exists() || !dir.isDirectory) {
                        result.error("INVALID_DIRECTORY", "Bookmarked directory is invalid", null)
                        return
                    }

                    val file = File(dir, fileName)
                    file.writeBytes(data)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SAVE_ERROR", e.message, null)
                }
            }
            "readFile" -> {
                val fileName = call.argument<String>("fileName")
                if (fileName == null) {
                    result.error("INVALID_ARGUMENTS", "fileName is required", null)
                    return
                }

                try {
                    val dirPath = preferences.getString("bookmarked_directory", null)
                    if (dirPath == null) {
                        result.error("NO_DIRECTORY", "No bookmarked directory found", null)
                        return
                    }

                    val file = File(File(dirPath), fileName)
                    if (!file.exists() || !file.isFile) {
                        result.error("FILE_NOT_FOUND", "File does not exist", null)
                        return
                    }

                    result.success(file.readBytes())
                } catch (e: Exception) {
                    result.error("READ_ERROR", e.message, null)
                }
            }
            "listFiles" -> {
                try {
                    val dirPath = preferences.getString("bookmarked_directory", null)
                    if (dirPath == null) {
                        result.error("NO_DIRECTORY", "No bookmarked directory found", null)
                        return
                    }

                    val dir = File(dirPath)
                    if (!dir.exists() || !dir.isDirectory) {
                        result.error("INVALID_DIRECTORY", "Bookmarked directory is invalid", null)
                        return
                    }

                    val files = dir.listFiles()
                    if (files == null) {
                        result.success(listOf<String>())
                        return
                    }

                    result.success(files.filter { it.isFile }.map { it.name })
                } catch (e: Exception) {
                    result.error("LIST_ERROR", e.message, null)
                }
            }
            "hasWritePermission" -> {
                try {
                    val dirPath = preferences.getString("bookmarked_directory", null)
                    if (dirPath == null) {
                        result.success(false)
                        return
                    }

                    val dir = File(dirPath)
                    result.success(dir.exists() && dir.isDirectory && dir.canWrite())
                } catch (e: Exception) {
                    result.error("PERMISSION_ERROR", e.message, null)
                }
            }
            "requestWritePermission" -> {
                try {
                    val dirPath = preferences.getString("bookmarked_directory", null)
                    if (dirPath == null) {
                        result.success(false)
                        return
                    }

                    val dir = File(dirPath)
                    result.success(dir.exists() && dir.isDirectory && dir.canWrite())
                } catch (e: Exception) {
                    result.error("PERMISSION_ERROR", e.message, null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
