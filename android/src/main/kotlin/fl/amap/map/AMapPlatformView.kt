package fl.amap.map

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.amap.api.maps.AMapOptions
import com.amap.api.maps.TextureMapView
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding.OnSaveInstanceStateListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView

class AMapPlatformView(
    id: Int,
    context: Context,
    binaryMessenger: BinaryMessenger,
    options: AMapOptions
) : DefaultLifecycleObserver, OnSaveInstanceStateListener, MethodCallHandler, PlatformView {
    private val methodChannel: MethodChannel
    private var mapView = TextureMapView(context, options)
    private var disposed = false

    init {
        methodChannel = MethodChannel(binaryMessenger, "amap_flutter_map_$id")
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        result.notImplemented()
    }

    override fun onCreate(owner: LifecycleOwner) {
        if (disposed) return
        mapView.onCreate(null)
    }

    override fun onStart(owner: LifecycleOwner) {
    }

    override fun onResume(owner: LifecycleOwner) {
        if (disposed) return
        mapView.onResume()
    }

    override fun onPause(owner: LifecycleOwner) {
        if (disposed) return
        mapView.onPause()
    }

    override fun onStop(owner: LifecycleOwner) {
    }

    override fun onDestroy(owner: LifecycleOwner) {
        if (disposed) return
        mapView.onDestroy()
    }

    override fun onSaveInstanceState(bundle: Bundle) {
        if (disposed) return
        mapView.onSaveInstanceState(bundle)
    }

    override fun onRestoreInstanceState(bundle: Bundle?) {
        if (disposed) return
        mapView.onCreate(bundle)
    }

    override fun getView(): View {
        return mapView
    }

    override fun dispose() {
        if (disposed) return
        methodChannel.setMethodCallHandler(null)
        mapView.onDestroy()
        disposed = true
    }
}
