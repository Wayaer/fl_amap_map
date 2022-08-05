package fl.amap.map


import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlAMapMapPlugin */
class FlAMapMapPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var location: AMapLocationMethodCall? = null
    private var map: AMapMapMethodCall? = null

    override fun onAttachedToEngine(plugin: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(plugin.binaryMessenger, "fl_amap_map")
        location = AMapLocationMethodCall(plugin.applicationContext, channel)
        map = AMapMapMethodCall(plugin, channel)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        location?.onMethodCall(call, result)
        map?.onMethodCall(call, result)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        map = null
    }
}