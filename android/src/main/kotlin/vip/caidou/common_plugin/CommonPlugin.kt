package vip.caidou.common_plugin

import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class CommonPlugin : FlutterPlugin, ActivityAware, EventChannel.StreamHandler {
  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private var activity: Activity? = null
  private var initialLink: String? = null
  private var eventSink: EventChannel.EventSink? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "common_plugin")
    methodChannel.setMethodCallHandler { call, result ->
      if (call.method == "getPlatformVersion") {
        result.success("${android.os.Build.VERSION.RELEASE}")
      } else if (call.method == "getInitialLink") {
        result.success(initialLink)
      } else {
        result.notImplemented()
      }
    }

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "common_plugin/events")
    eventChannel.setStreamHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    // 检查启动 Intent
    val intent = activity?.intent
    if (intent != null && Intent.ACTION_VIEW == intent.action) {
      val data: Uri? = intent.data
      if (data != null) {
        initialLink = data.toString()
        eventSink?.success(initialLink)
      }
    }

    // 监听新的 Intent
    binding.addOnNewIntentListener { intent ->
      if (Intent.ACTION_VIEW == intent.action) {
        val data: Uri? = intent.data
        if (data != null) {
          val pendingLink = data.toString()
          eventSink?.success(pendingLink)
        }
      }
      false
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    // 如果应用已经通过链接启动，发送初始链接
    initialLink?.let {
      events?.success(it)
      initialLink = null
    }
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
}
