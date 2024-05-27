package me.genopets.plugins.panoramic_camera

import android.app.Activity
import android.content.Context
import android.view.View
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

  class PanoramicCameraPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {
      private var activityBinding: ActivityPluginBinding? = null
      private lateinit var channel: MethodChannel
      private var customView: CustomView? = null
      private var outputHeight: Int = 500
      private var showLogo: Boolean = false

      override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
          channel = MethodChannel(binding.binaryMessenger, "panoramic_channel")
          channel.setMethodCallHandler(this)

          binding.platformViewRegistry.registerViewFactory("panoramic_view", CustomViewFactory(this) { activityBinding?.activity })
      }

      override fun onMethodCall(call: MethodCall, result: Result) {
          when (call.method) {
              "onResume" -> customView?.onResume()
              "onPause" -> customView?.onPause()
              "setOutputHeight" -> {
                  outputHeight = call.arguments as Int
                  result.success(null)
              }
              "setShowGuide" -> {
                  showLogo = call.arguments as Boolean
                  result.success(null)
              }
              else -> result.notImplemented()
          }
      }
  
      override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
  
      override fun onAttachedToActivity(binding: ActivityPluginBinding) {
          activityBinding = binding
      }
  
      override fun onDetachedFromActivity() {
          activityBinding = null
      }
  
      override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
          activityBinding = binding
      }
  
      override fun onDetachedFromActivityForConfigChanges() {
          activityBinding = null
      }

      class CustomViewFactory(private val plugin: PanoramicCameraPlugin, private val getActivity: () -> Activity?) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
          override fun create(context: Context?, id: Int, args: Any?): PlatformView {
              val activity = getActivity()
              if (activity != null && context != null) {
                  val view = CustomView(context, null, 0, activity, plugin.channel)
                  view.setOutputHeight(plugin.outputHeight)
                  view.setShowLogo(plugin.showLogo)
                  return CustomPlatformView(plugin, view)
              } else {
                  throw IllegalStateException("Activity context is required to create YourCustomView")
              }
          }
      }

      class CustomPlatformView(
          private val plugin: PanoramicCameraPlugin,
          private val view: CustomView
      ) : PlatformView {
          init {
              plugin.customView = view
          }

          override fun getView(): View {
              return view
          }

          override fun dispose() {
              plugin.customView = null
          }
      }
  }
  
