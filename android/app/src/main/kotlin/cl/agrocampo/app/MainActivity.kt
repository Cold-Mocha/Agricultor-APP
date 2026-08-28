package cl.agrocampo.app

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var pendingResult: MethodChannel.Result? = null
    private var sourcePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cl.agrocampo.app/export")
            .setMethodCallHandler { call, result ->
                if (call.method != "saveXlsx" || pendingResult != null) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                sourcePath = call.argument<String>("sourcePath")
                val suggestedName = call.argument<String>("suggestedName") ?: "AgroCampo.xlsx"
                pendingResult = result
                startActivityForResult(Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                    putExtra(Intent.EXTRA_TITLE, suggestedName)
                }, EXPORT_REQUEST)
            }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != EXPORT_REQUEST) return
        val result = pendingResult
        pendingResult = null
        if (resultCode != Activity.RESULT_OK || data?.data == null || sourcePath == null) {
            result?.success(false)
            return
        }
        try {
            contentResolver.openOutputStream(data.data!!)?.use { output ->
                File(sourcePath!!).inputStream().use { input -> input.copyTo(output) }
            } ?: error("destination_unavailable")
            result?.success(true)
        } catch (error: Exception) {
            result?.error("export_failed", error.message, null)
        } finally {
            sourcePath = null
        }
    }

    companion object {
        private const val EXPORT_REQUEST = 7001
    }
}
