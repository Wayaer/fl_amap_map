package fl.amap.map


import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlAMapMapPlugin */
class FlAMapMapPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var methodCall: AMapLocationMethodCall? = null

    override fun onAttachedToEngine(plugin: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(plugin.binaryMessenger, "fl_amap_map")
        methodCall = AMapLocationMethodCall(plugin.applicationContext, channel)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        methodCall?.onMethodCall(call, result)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        methodCall = null
    }
}