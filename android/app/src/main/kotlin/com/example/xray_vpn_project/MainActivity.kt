package com.example.xray_vpn_project

import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "xray_vpn/device"
    private val PREFS = "xray_vpn_prefs"
    private val BYPASS_KEY = "bypass_apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceData" -> {
                        val androidId = Settings.Secure.getString(
                            contentResolver,
                            Settings.Secure.ANDROID_ID
                        )

                        result.success(
                            mapOf(
                                "android_id" to androidId,
                                "brand" to Build.BRAND,
                                "model" to Build.MODEL,
                                "device" to Build.DEVICE,
                                "hardware" to Build.HARDWARE
                            )
                        )
                    }

                    "getInstalledApps" -> {
                        val pm = packageManager
                        val intent = Intent(Intent.ACTION_MAIN, null)
                        intent.addCategory(Intent.CATEGORY_LAUNCHER)

                        val apps = pm.queryIntentActivities(intent, 0)
                            .map {
                                mapOf(
                                    "name" to it.loadLabel(pm).toString(),
                                    "package" to it.activityInfo.packageName
                                )
                            }
                            .distinctBy { it["package"] }
                            .sortedBy { it["name"] }

                        result.success(apps)
                    }

                    "saveBypassApps" -> {
                        val packages = call.argument<List<String>>("packages") ?: emptyList()
                        getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                            .edit()
                            .putStringSet(BYPASS_KEY, packages.toSet())
                            .apply()

                        result.success(true)
                    }

                    "loadBypassApps" -> {
                        val packages = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                            .getStringSet(BYPASS_KEY, emptySet())
                            ?.toList() ?: emptyList()

                        result.success(packages)
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
