package fl.amap.map

import android.content.Context
import android.view.Surface
import com.amap.api.maps.TextureMapView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class AMapMapMethodCall(
    private val plugin: FlutterPlugin.FlutterPluginBinding, private val channel: MethodChannel
) {
    private lateinit var result: MethodChannel.Result
    private var context: Context = plugin.applicationContext

    fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        this.result = result
        when (call.method) {
            "createMap" -> createMap(call, result)

        }

    }

    private fun createMap(call: MethodCall, result: MethodChannel.Result) {
        val width = call.argument<Int>("width")!!
        val height = call.argument<Int>("height")!!
        val textureEntry = plugin.textureRegistry.createSurfaceTexture()
        val textureId = textureEntry.id()
        val surfaceTexture = textureEntry.surfaceTexture()
        surfaceTexture.setDefaultBufferSize(width, height)
        val surface = Surface(surfaceTexture)
    }
}