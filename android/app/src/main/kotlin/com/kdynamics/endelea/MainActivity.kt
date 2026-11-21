package com.kdynamics.endelea

import android.app.Activity
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Hosts the "endelea/files" channel used by the JSON export and import:
 * share a file through the system share sheet, and pick a JSON document.
 */
class MainActivity : FlutterActivity() {
    private var pendingOpen: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareFile" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("bad_args", "path is required", null)
                        } else {
                            shareFile(
                                File(path),
                                call.argument<String>("mimeType") ?: "application/json",
                                call.argument<String>("title"),
                            )
                            result.success(null)
                        }
                    }
                    "openDocument" -> openDocument(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun shareFile(file: File, mimeType: String, title: String?) {
        val uri = FileProvider.getUriForFile(this, "$packageName.files", file)
        val send = Intent(Intent.ACTION_SEND).apply {
            type = mimeType
            putExtra(Intent.EXTRA_STREAM, uri)
            putExtra(Intent.EXTRA_SUBJECT, file.name)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(send, title))
    }

    private fun openDocument(result: MethodChannel.Result) {
        pendingOpen?.success(null)
        pendingOpen = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(
                Intent.EXTRA_MIME_TYPES,
                arrayOf("application/json", "text/plain", "application/octet-stream"),
            )
        }
        startActivityForResult(intent, OPEN_REQUEST)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != OPEN_REQUEST) return
        val result = pendingOpen ?: return
        pendingOpen = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        try {
            val text = contentResolver.openInputStream(uri)?.use {
                it.readBytes().toString(Charsets.UTF_8)
            }
            result.success(text)
        } catch (e: Exception) {
            result.error("read_failed", e.message, null)
        }
    }

    companion object {
        private const val CHANNEL = "endelea/files"
        private const val OPEN_REQUEST = 4210
    }
}
