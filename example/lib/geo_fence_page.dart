import 'package:example/main.dart';
import 'package:fl_amap_map/fl_amap_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

class AMapGeoFencePage extends StatefulWidget {
  const AMapGeoFencePage({Key? key}) : super(key: key);

  @override
  State<AMapGeoFencePage> createState() => _AMapGeoFencePageState();
}

class _AMapGeoFencePageState extends State<AMapGeoFencePage> {
  late ValueNotifier<String> text = ValueNotifier<String>('未初始化');
  String customID = 'TestCustomID';

  ValueNotifier<AMapGeoFenceStatusModel?> geoFenceState =
      ValueNotifier<AMapGeoFenceStatusModel?>(null);

  ValueNotifier<dynamic> json = ValueNotifier<dynamic>(null);

  /// 获取定位权限
  Future<bool> get getPermissions async {
    if (!await getPermission(Permission.location)) {
      show('未获取到定位权限');
      return false;
    }
    return true;
  }

  /// 初始化地理围栏
  Future<void> initGeoFence() async {
    if (!await getPermissions) return;
    final bool data =
        await FlAMapGeoFence().initialize(GeoFenceActivateAction.stayed);
    if (data) {
      show('初始化地理围栏:$data');
    }
  }

  @override
  Widget build(BuildContext context) => ExtendedScaffold(
          appBar: AppBar(title: const Text('高德地理围栏')),
          padding: const EdgeInsets.all(8.0),
          isScroll: true,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10),
            ValueListenableBuilder<String>(
                valueListenable: text,
                builder: (_, String value, __) =>
                    Text(value, style: const TextStyle(fontSize: 20))),
            const SizedBox(height: 20),
            const Text('高德地理围栏', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Wrap(
                runSpacing: 10,
                spacing: 10,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  ElevatedText(onPressed: initGeoFence, text: 'initialize'),
                  ElevatedText(
                      onPressed: () {
                        FlAMapGeoFence().dispose();
                        show('未初始化');
                      },
                      text: 'dispose'),
                  ElevatedText(
                      onPressed: () async {
                        final AMapPoiModel model = AMapPoiModel(
                            keyword: '首开广场',
                            poiType: '写字楼',
                            city: '北京',
                            size: 1,
                            customID: customID);
                        final bool state = await FlAMapGeoFence().addPOI(model);
                        show('addPOI : $state');
                      },
                      text: '添加POI围栏'),
                  ElevatedText(
                      onPressed: () async {
                        final LatLong latLong = LatLong(30.630259, 103.974113);
                        final AMapLatLongModel model = AMapLatLongModel(
                            latLong: latLong,
                            keyword: '西部智谷',
                            poiType: '',
                            customID: customID,
                            size: 20,
                            aroundRadius: 10000);
                        final bool state =
                            await FlAMapGeoFence().addLatLong(model);
                        show('addLatLong : $state');
                      },
                      text: '添加经纬度围栏'),
                  ElevatedText(
                      onPressed: () async {
                        final bool state = await FlAMapGeoFence()
                            .addDistrict(keyword: '海淀区', customID: customID);
                        show('addDistrict : $state');
                      },
                      text: '添加行政区划围栏'),
                  ElevatedText(
                      onPressed: () async {
                        final LatLong latLong = LatLong(30.651411, 103.998638);
                        final bool state = await FlAMapGeoFence().addCircle(
                            latLong: latLong, radius: 10, customID: customID);
                        show('addCircle : $state');
                      },
                      text: '添加圆形围栏'),
                  ElevatedText(
                      onPressed: () async {
                        final bool state = await FlAMapGeoFence()
                            .addCustom(latLongs: <LatLong>[
                          LatLong(39.933921, 116.372927),
                          LatLong(39.907261, 116.376532),
                          LatLong(39.900611, 116.418161),
                          LatLong(39.941949, 116.435497),
                        ], customID: customID);
                        show('addCustom : $state');
                      },
                      text: '添加多边形围栏'),
                  ElevatedText(
                      onPressed: () async {
                        final List<AMapGeoFenceModel> data =
                            await FlAMapGeoFence().getAll();
                        if (data.isEmpty) {
                          json.value = '没有添加围栏信息';
                        } else {
                          json.value = data
                              .map((AMapGeoFenceModel e) => e.toMap())
                              .toList();
                        }
                      },
                      text: '获取所有围栏信息'),
                  ElevatedText(
                      onPressed: () async {
                        final bool state = await FlAMapGeoFence().remove();
                        show('remove : $state');
                        json.value = '没有添加围栏信息';
                      },
                      text: '删除所有地理围栏'),
                ]),
            ElevatedText(
                onPressed: () async {
                  final bool state = await FlAMapGeoFence().start(
                      customID: customID,
                      onGeoFenceChanged: (AMapGeoFenceStatusModel geoFence) {
                        show('围栏状态 : ${getStatus(geoFence.status)}');
                        geoFenceState.value = geoFence;
                      });
                  show('start : $state');
                },
                text: '开始围栏状态监听'),
            ElevatedText(
                onPressed: () async {
                  final bool state =
                      await FlAMapGeoFence().pause(customID: customID);
                  show('pause : $state');
                },
                text: '暂停状态围栏监听'),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: ValueListenableBuilder<AMapGeoFenceStatusModel?>(
                    valueListenable: geoFenceState,
                    builder: (_, AMapGeoFenceStatusModel? value, __) => Text(
                        'customID : ${value?.customID}\n'
                        '围栏类型 type : ${getType(value?.type)}\n'
                        '围栏状态 status : ${getStatus(value?.status)}\n'
                        '围栏ID fenceID : ${value?.fenceID}\n',
                        style: const TextStyle(fontSize: 15)))),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: ValueListenableBuilder<dynamic>(
                    valueListenable: json,
                    builder: (_, dynamic value, __) {
                      if (value is Map) return JsonParse(value);
                      if (value is List) return JsonParse.list(value);
                      return Text(value.toString());
                    }))
          ]);

  String getType(GenFenceType? type) {
    switch (type) {
      case GenFenceType.circle:
        return '圆形地理围栏';
      case GenFenceType.custom:
        return '多边形地理围栏';
      case GenFenceType.poi:
        return '(POI）地理围栏';
      case GenFenceType.district:
        return '行政区划地理围栏';
      default:
        return '未知类型';
    }
  }

  String getStatus(GenFenceStatus? status) {
    switch (status) {
      case GenFenceStatus.inside:
        return '在范围内';
      case GenFenceStatus.outside:
        return '在范围外';
      case GenFenceStatus.stayed:
        return '停留(在范围内超过10分钟)';
      default:
        return '未知状态';
    }
  }

  void show(String str) {
    text.value = str;
  }

  @override
  void dispose() {
    super.dispose();
    FlAMapGeoFence().dispose();
  }
}
