package com.example.xray_vpn_project

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.view.WindowManager
import android.net.Uri
import android.content.Intent
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
                        val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                        result.success(mapOf(
                            "android_id" to androidId,
                            "brand" to Build.BRAND,
                            "model" to Build.MODEL,
                            "device" to Build.DEVICE,
                            "hardware" to Build.HARDWARE
                        ))
                    
    private fun isUnsafeDevice(): Boolean {
        val suspiciousPaths = arrayOf(
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/su/bin/su",
            "/data/adb/magisk",
            "/data/adb/modules",
            "/system/app/Superuser.apk"
        )

        for (path in suspiciousPaths) {
            if (java.io.File(path).exists()) return true
        }

        val suspiciousPackages = arrayOf(
            "com.topjohnwu.magisk",
            "eu.chainfire.supersu",
            "com.koushikdutta.superuser",
            "com.noshufou.android.su",
            "de.robv.android.xposed.installer",
            "org.lsposed.manager"
        )

        for (pkg in suspiciousPackages) {
            try {
                packageManager.getPackageInfo(pkg, 0)
                return true
            } catch (_: Exception) {}
        }

        return false
    }
}

                    "getInstalledApps" -> {
                        val pm = packageManager
                        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            PackageManager.MATCH_DISABLED_COMPONENTS or PackageManager.MATCH_UNINSTALLED_PACKAGES
                        } else {
                            PackageManager.GET_META_DATA
                        }

                        val apps = pm.getInstalledApplications(flags)
                            .map {
                                mapOf(
                                    "name" to pm.getApplicationLabel(it).toString(),
                                    "package" to it.packageName
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

                    "openBatterySettings" -> {
                        try {
                            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                            intent.data = Uri.parse("package:$packageName")
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                            intent.data = Uri.parse("package:$packageName")
                            startActivity(intent)
                            result.success(true)
                        }
                    }

                    "securityCheck" -> {
                        result.success(isUnsafeDevice())
                    }

                    "enableScreenProtection" -> {
                        window.setFlags(
                            WindowManager.LayoutParams.FLAG_SECURE,
                            WindowManager.LayoutParams.FLAG_SECURE
                        )
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
