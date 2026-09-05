package com.zuraffa.permissions

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/**
 * The Android implementation of zuraffa_permissions.
 *
 * Scope statuses map onto the wire vocabulary the Dart
 * MethodChannelPermissionAdapter consumes:
 *  - granted      → PackageManager.PERMISSION_GRANTED
 *  - denied       → PERMISSION_DENIED, but a re-request would still show
 *                   a dialog (not permanently denied yet)
 *  - permanentlyDenied → PERMISSION_DENIED *and* the OS will no longer
 *                   show the dialog (shouldShowRequestPermissionRationale
 *                   false after a denial — the standard heuristic)
 *  - undetermined → never requested (rationale not yet consulted)
 */
class ZuraffaPermissionsPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {

    companion object {
        private const val CHANNEL_NAME = "zuraffa_permissions"
        private const val REQUEST_CODE = 40771

        // Wire statuses (mirror of the Dart PermissionWireStatus).
        private const val GRANTED = "granted"
        private const val DENIED = "denied"
        private const val PERMANENTLY_DENIED = "permanentlyDenied"
        private const val UNDETERMINED = "undetermined"
        private const val RESTRICTED = "restricted"
        private const val LIMITED = "limited"
    }

    private var channel: MethodChannel? = null
    private var applicationContext: Context? = null
    private var activity: Activity? = null

    // Pending request bookkeeping: scope → the Android permissions it
    // maps to, and the Result to resolve once the OS dialog answers.
    private var pendingRequestScopes: Map<String, List<String>> = emptyMap()
    private var pendingRequestResult: Result? = null
    private var hasEverRequested: MutableSet<String> = mutableSetOf()

    // ------------------------------------------------------------------
    // FlutterPlugin
    // ------------------------------------------------------------------

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        applicationContext = null
    }

    // ------------------------------------------------------------------
    // MethodCallHandler
    // ------------------------------------------------------------------

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "checkPermissions" -> {
                @Suppress("UNCHECKED_CAST")
                val scopes = (call.arguments as? List<String>) ?: emptyList()
                result.success(checkAll(scopes))
            }
            "requestPermissions" -> {
                @Suppress("UNCHECKED_CAST")
                val scopes = (call.arguments as? List<String>) ?: emptyList()
                requestAll(scopes, result)
            }
            "openSettings" -> result.success(openAppSettings())
            else -> result.notImplemented()
        }
    }

    // ------------------------------------------------------------------
    // ActivityAware
    // ------------------------------------------------------------------

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    // ------------------------------------------------------------------
    // RequestPermissionsResultListener
    // ------------------------------------------------------------------

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != REQUEST_CODE) return false

        val pending = pendingRequestScopes
        val pendingResult = pendingRequestResult
        pendingRequestScopes = emptyMap()
        pendingRequestResult = null
        if (pendingResult == null) return true

        val context = applicationContext
        if (context == null) {
            pendingResult.success(
                pending.keys.associateWith { UNDETERMINED }
            )
            return true
        }

        // Map every granted Android permission into a set for scope
        // resolution: a scope is granted only when ALL its mapped
        // Android permissions were granted.
        val grantedPermissions = mutableSetOf<String>()
        for ((index, permission) in permissions.withIndex()) {
            if (index < grantResults.size &&
                grantResults[index] == PackageManager.PERMISSION_GRANTED
            ) {
                grantedPermissions.add(permission)
            }
        }

        val statuses = mutableMapOf<String, String>()
        for ((scope, androidPermissions) in pending) {
            hasEverRequested.add(scope)
            statuses[scope] = when {
                androidPermissions.isEmpty() ->
                    // Unknown scope on Android: nothing to request.
                    UNDETERMINED
                androidPermissions.all { it in grantedPermissions } ->
                    GRANTED
                else -> {
                    // Denied. Distinguish "denied once" from "permanently
                    // denied": once the OS stops showing the dialog
                    // (rationale false after a denial), only settings can
                    // change the answer.
                    val shouldShowRationale = activity?.let {
                        ActivityCompat.shouldShowRequestPermissionRationale(
                            it,
                            androidPermissions.first(),
                        )
                    } ?: false
                    if (shouldShowRationale) DENIED else PERMANENTLY_DENIED
                }
            }
        }
        pendingResult.success(statuses)
        return true
    }

    // ------------------------------------------------------------------
    // Internals
    // ------------------------------------------------------------------

    /** The Android permissions a scope maps to (empty = unsupported here). */
    private fun androidPermissionsFor(scope: String): List<String> {
        return when (scope) {
            "camera" -> listOf(Manifest.permission.CAMERA)
            "microphone" -> listOf(Manifest.permission.RECORD_AUDIO)
            "locationWhenInUse" -> listOf(
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION,
            )
            "locationAlways" -> {
                // Background location rides on top of fine location; on
                // Android 10+ it must be requested separately, so this
                // scope resolves via the combined grant.
                listOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_BACKGROUND_LOCATION,
                )
            }
            "storage" -> storagePermissions()
            "contacts" -> listOf(Manifest.permission.READ_CONTACTS)
            "calendar" -> listOf(
                Manifest.permission.READ_CALENDAR,
                Manifest.permission.WRITE_CALENDAR,
            )
            "notifications" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    listOf(Manifest.permission.POST_NOTIFICATIONS)
                } else {
                    // Pre-13: notifications need no runtime permission.
                    emptyList()
                }
            }
            "biometrics" -> listOf(Manifest.permission.USE_BIOMETRIC)
            else -> emptyList()
        }
    }

    /** Storage permissions vary by SDK: scoped storage on 33+. */
    private fun storagePermissions(): List<String> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+: no broad storage permission; app-specific
            // storage needs nothing. Media access uses granular grants an
            // app requests itself (READ_MEDIA_IMAGES etc.).
            emptyList()
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            emptyList() // Android 11-12: scoped storage, nothing runtime.
        } else {
            listOf(
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
            )
        }
    }

    /** Checks every scope without prompting. */
    private fun checkAll(scopes: List<String>): Map<String, String> {
        val context = applicationContext
        val statuses = mutableMapOf<String, String>()
        for (scope in scopes) {
            val androidPermissions = androidPermissionsFor(scope)
            statuses[scope] = when {
                androidPermissions.isEmpty() -> {
                    // Scopes with no runtime permission on this OS version
                    // are granted by construction (notifications pre-13,
                    // storage on scoped builds).
                    if (scope == "notifications" &&
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU
                    ) {
                        GRANTED
                    } else if (scope == "storage" &&
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.R
                    ) {
                        GRANTED
                    } else {
                        UNDETERMINED
                    }
                }
                else -> {
                    if (context == null) {
                        UNDETERMINED
                    } else {
                        checkScope(context, scope, androidPermissions)
                    }
                }
            }
        }
        return statuses
    }

    /** Single-scope check against the context. */
    private fun checkScope(
        context: Context,
        scope: String,
        androidPermissions: List<String>,
    ): String {
        val allGranted = androidPermissions.all {
            ContextCompat.checkSelfPermission(context, it) ==
                PackageManager.PERMISSION_GRANTED
        }
        if (allGranted) return GRANTED

        // Not granted: denied vs permanently denied vs undetermined. The
        // OS heuristic: rationale=true → plain denied (dialog still
        // shows); rationale=false + never requested → undetermined;
        // rationale=false + requested before → permanently denied.
        val activity = this.activity
        val shouldShowRationale = activity != null && ActivityCompat
            .shouldShowRequestPermissionRationale(
                activity,
                androidPermissions.first(),
            )
        return when {
            shouldShowRationale -> DENIED
            hasEverRequested.contains(scope) -> PERMANENTLY_DENIED
            else -> UNDETERMINED
        }
    }

    /** Requests every scope; resolves [result] once the OS answers. */
    private fun requestAll(scopes: List<String>, result: Result) {
        val activity = this.activity
        val context = applicationContext

        // Scopes that need no runtime dialog resolve immediately.
        val immediate = mutableMapOf<String, String>()
        val toRequest = mutableMapOf<String, List<String>>()
        for (scope in scopes) {
            val androidPermissions = androidPermissionsFor(scope)
            when {
                androidPermissions.isEmpty() -> {
                    // Same no-permission semantics as checkAll.
                    if (scope == "notifications" &&
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU
                    ) {
                        immediate[scope] = GRANTED
                    } else if (scope == "storage" &&
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.R
                    ) {
                        immediate[scope] = GRANTED
                    } else {
                        immediate[scope] = UNDETERMINED
                    }
                }
                context != null &&
                    androidPermissions.all {
                        ContextCompat.checkSelfPermission(context, it) ==
                            PackageManager.PERMISSION_GRANTED
                    } ->
                    immediate[scope] = GRANTED
                else -> toRequest[scope] = androidPermissions
            }
        }

        if (toRequest.isEmpty() || activity == null) {
            result.success(immediate)
            return
        }

        // Flatten the distinct Android permissions and launch one dialog.
        val flatPermissions = toRequest.values.flatten().distinct()
        pendingRequestScopes = toRequest
        pendingRequestResult = result

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.requestPermissions(
                activity,
                flatPermissions.toTypedArray(),
                REQUEST_CODE,
            )
        } else {
            // Pre-M: permissions are install-time; resolve from context.
            val statuses = toRequest.keys.associateWith { scope ->
                val perms = toRequest[scope] ?: emptyList()
                if (context != null &&
                    perms.all {
                        ContextCompat.checkSelfPermission(context, it) ==
                            PackageManager.PERMISSION_GRANTED
                    }
                ) {
                    GRANTED
                } else {
                    DENIED
                }
            }
            pendingRequestScopes = emptyMap()
            pendingRequestResult = null
            result.success(statuses)
        }
    }

    /** Opens the app's system settings page. */
    private fun openAppSettings(): Boolean {
        val activity = this.activity ?: return false
        return try {
            val intent = Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.fromParts("package", activity.packageName, null),
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            activity.startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }
}
