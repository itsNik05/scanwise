package com.example.scanwise

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.tom_roush.pdfbox.multipdf.PDFMergerUtility
import java.io.File

class MainActivity : FlutterActivity() {

    private val CHANNEL = "scanwise.native.merge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "mergePdfs") {
                    val inputPaths = call.argument<List<String>>("inputPaths")
                    val outputPath = call.argument<String>("outputPath")

                    if (inputPaths == null || outputPath == null) {
                        result.error("INVALID_ARGS", "Missing arguments", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val merger = PDFMergerUtility()

                        for (path in inputPaths) {
                            merger.addSource(File(path))
                        }

                        merger.destinationFileName = outputPath
                        merger.mergeDocuments(null)

                        result.success(outputPath)

                    } catch (e: Exception) {
                        result.error("MERGE_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}