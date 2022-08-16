import 'package:fl_amap_map/fl_amap_map.dart';
import 'package:fl_amap_map/src/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AMapView extends StatefulWidget {
  const AMapView(this.controller, {Key? key}) : super(key: key);
  final AMapController controller;

  @override
  State<AMapView> createState() => _AMapViewState();
}

class _AMapViewState extends State<AMapView> {
  @override
  Widget build(BuildContext context) {
    return widget.controller.build();
  }
}

class AMapController {
  AMapController(
      {this.initialCameraPosition = const CameraPosition(
          target: LatLong(39.909187, 116.397451), zoom: 10),
      this.gestureRecognizers =
          const <Factory<OneSequenceGestureRecognizer>>{}});

  final CameraPosition initialCameraPosition;

  ///需要应用到地图上的手势集合
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  Widget build() {
    final creationParams = initialCameraPosition.toMap();
    if (defaultTargetPlatform == TargetPlatform.android) {
      creationParams['debugMode'] = kDebugMode;
      return AndroidView(
          viewType: 'com.amap.flutter.map',
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: gestureRecognizers,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec());
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
          viewType: 'com.amap.flutter.map',
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: gestureRecognizers,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec());
    }
    return Text('当前平台:$defaultTargetPlatform, 不支持使用高德地图插件');
  }

  final Map<int, MethodChannel> _channels = {};

  MethodChannel? channel(int mapId) => _channels[mapId];

  Future<void> _onPlatformViewCreated(int mapId) async {
    MethodChannel? channel = _channels[mapId];
    if (channel == null) {
      channel = MethodChannel('fl_amap_map_$mapId');
      channel.setMethodCallHandler((call) => _handleMethodCall(call, mapId));
      _channels[mapId] = channel;
    }
    return channel.invokeMethod<void>('map#waitForMap');
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int mapId) async {
    switch (call.method) {
      case 'location#changed':
        break;
      case 'camera#onMove':
        break;
      case 'camera#onMoveEnd':
        break;
      case 'map#onTap':
        break;
      case 'map#onLongPress':
        break;
      case 'marker#onTap':
        break;
      case 'marker#onDragEnd':
        break;
      case 'polyline#onTap':
        break;
      case 'map#onPoiTouched':
        break;
    }
  }
}
