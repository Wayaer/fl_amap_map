import Foundation
import AMapLocationKit
import Flutter

class AMapLocationMethodCall: NSObject {
    private var channel: FlutterMethodChannel
    private var locationManager: AMapLocationManager?
    private var geoFenceManager: AMapGeoFenceManager?
    private var locationManagerDelegate: LocationManagerDelegate?
    private var geoFenceManagerDelegate: GeoFenceManagerDelegate?

    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        geoFenceManagerDelegate?.result = result
        switch call.method {
        case "setApiKey":
            let args = call.arguments as! [String: Any?]
            let key = args["key"] as! String
            let isAgree = args["isAgree"] as! Bool
            let isContains = args["isContains"] as! Bool
            let isShow = args["isShow"] as! Bool
            AMapLocationManager.updatePrivacyAgree(isAgree ? .didAgree : .notAgree)
            AMapLocationManager.updatePrivacyShow(isShow ? .didShow : .notShow, privacyInfo: isContains ? .didContain : .notContain)
            AMapServices.shared().apiKey = key
            result(true)
        case "initLocation":
            if locationManager == nil {
                locationManager = AMapLocationManager()
            }
            result(initLocationOption(call))
        case "disposeLocation":
            if locationManager != nil {
                locationManager!.stopUpdatingLocation()
                locationManagerDelegate = nil
                locationManager!.delegate = nil
                locationManager = nil
            }
            result(locationManager == nil)
        case "getLocation":
            getLocation(call.arguments as! Bool, result)
        case "startLocation":
            if locationManager != nil {
                if locationManagerDelegate == nil {
                    locationManagerDelegate = LocationManagerDelegate(channel)
                    locationManager!.delegate = locationManagerDelegate
                }
                locationManager!.startUpdatingLocation()
            }
            result(locationManager != nil)
        case "stopLocation":
            if locationManager != nil {
                locationManagerDelegate = nil
                locationManager!.stopUpdatingLocation()
            }
            result(locationManager == nil)
        case "initGeoFence":
            if geoFenceManager == nil {
                geoFenceManager = AMapGeoFenceManager()
                if geoFenceManagerDelegate == nil {
                    geoFenceManagerDelegate = GeoFenceManagerDelegate(channel)
                    geoFenceManager!.delegate = geoFenceManagerDelegate
                }
            }
            result(initGeoFenceOption(call))
        case "disposeGeoFence":
            if geoFenceManager != nil {
                geoFenceManager!.removeAllGeoFenceRegions()
                geoFenceManagerDelegate = nil
                geoFenceManager!.delegate = nil
                geoFenceManager = nil
            }
            result(geoFenceManager == nil)
        case "getAllGeoFence":
            var list = [[String: Any?]]()
            if geoFenceManager != nil {
                let fences = geoFenceManager!.geoFenceRegions(withCustomID: call.arguments as? String)
                if fences != nil {
                    for item in fences! {
                        let region = item as? AMapGeoFenceRegion
                        if region != nil {
                            list.append(region!.data)
                        }
                    }
                }
            }
            result(list)
        case "addGeoFenceWithPOI":
            let args = call.arguments as! [String: Any?]
            geoFenceManager?.addKeywordPOIRegionForMonitoring(withKeyword: args["keyword"] as? String, poiType: args["type"] as? String, city: args["city"] as? String, size: args["size"] as! Int, customID: args["customID"] as? String)
        case "addAMapGeoFenceWithLatLong":
            let args = call.arguments as! [String: Any?]
            let coordinate = CLLocationCoordinate2DMake(args["latitude"] as! Double, args["longitude"] as! Double)
            geoFenceManager?.addAroundPOIRegionForMonitoring(withLocationPoint: coordinate, aroundRadius: Int(args["aroundRadius"] as! Double), keyword: args["keyword"] as? String, poiType: args["type"] as? String, size: args["size"] as! Int, customID: args["customID"] as? String)
        case "addGeoFenceWithDistrict":
            let args = call.arguments as! [String: Any?]
            geoFenceManager?.addDistrictRegionForMonitoring(withDistrictName: args["keyword"] as? String, customID: args["customID"] as? String)
        case "addCircleGeoFence":
            let args = call.arguments as! [String: Any?]
            let coordinate = CLLocationCoordinate2DMake(args["latitude"] as! Double, args["longitude"] as! Double)
            geoFenceManager?.addCircleRegionForMonitoring(withCenter: coordinate, radius: args["radius"] as! Double, customID: args["customID"] as? String)
        case "addCustomGeoFence":
            let args = call.arguments as! [String: Any?]
            let latLongs = args["latLong"] as! [[String: Double]]
            var coordinates = [CLLocationCoordinate2D]()
            for latLong in latLongs {
                coordinates.append(CLLocationCoordinate2D(
                        latitude: latLong["latitude"]!, longitude: latLong["longitude"]!
                ))
            }
            geoFenceManager?.addPolygonRegionForMonitoring(withCoordinates: &coordinates, count: latLongs.count, customID: args["customID"] as? String)
        case "removeGeoFence":
            let customID = call.arguments as? String
            if customID != nil {
                geoFenceManager?.removeGeoFenceRegions(withCustomID: customID)
            } else {
                geoFenceManager?.removeAllGeoFenceRegions()
            }
            result(geoFenceManager != nil)
        case "startGeoFence":
            geoFenceManager?.startGeoFenceRegions(withCustomID: call.arguments as? String)
            result(true)
        case "pauseGeoFence":
            geoFenceManager?.pauseGeoFenceRegions(withCustomID: call.arguments as? String)
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func getLocation(_ withReGeocode: Bool, _ result: @escaping FlutterResult) {
        locationManager!.requestLocation(withReGeocode: withReGeocode, completionBlock: { location, reGeocode, error in
            if error != nil {
                result([
                    "code": (error! as NSError).code,
                    "description": error!.localizedDescription,
                    "success": false,
                ])
            } else {
                var md = location!.data
                if reGeocode != nil {
                    md.merge(reGeocode!.data)
                    md["code"] = 0
                    md["success"] = true
                } else {
                    md["code"] = (error! as NSError).code
                    md["description"] = error!.localizedDescription
                    md["success"] = true
                }
                result(md)
            }
        })
    }

    func initLocationOption(_ call: FlutterMethodCall) -> Bool {
        if locationManager == nil {
            return false
        }

        let args = call.arguments as! [AnyHashable: Any]
        locationManager!.desiredAccuracy = getDesiredAccuracy(args["desiredAccuracy"] as! String)
        locationManager!.pausesLocationUpdatesAutomatically = args["pausesLocationUpdatesAutomatically"] as! Bool
        locationManager!.distanceFilter = args["distanceFilter"] as! Double
        /// ?????????????????????????????????
        locationManager!.allowsBackgroundLocationUpdates = args["allowsBackgroundLocationUpdates"] as! Bool
        /// ????????????????????????
        locationManager!.locationTimeout = args["locationTimeout"] as! Int
        /// ???????????????????????????
        locationManager!.reGeocodeTimeout = args["reGeocodeTimeout"] as! Int
        /// ?????????????????????????????????
        locationManager!.locatingWithReGeocode = args["locatingWithReGeocode"] as! Bool
        /// ????????????????????????????????????????????????NO???????????????
        /// ??????:?????????YES???????????????????????? AMapLocatingCompletionBlock ???error??????????????????????????????????????????????????? amapLocationManager:didFailWithError: ?????????error?????????????????????????????????error?????????error.domain==AMapLocationErrorDomain; error.code==AMapLocationErrorRiskOfFakeLocation;
        locationManager!.detectRiskOfFakeLocation = args["detectRiskOfFakeLocation"] as! Bool
        return true
    }

    func getDesiredAccuracy(_ str: String) -> CLLocationAccuracy {
        switch str {
        case "kCLLocationAccuracyBest":
            return kCLLocationAccuracyBest
        case "kCLLocationAccuracyNearestTenMeters":
            return kCLLocationAccuracyNearestTenMeters
        case "kCLLocationAccuracyHundredMeters":
            return kCLLocationAccuracyHundredMeters
        case "kCLLocationAccuracyKilometer":
            return kCLLocationAccuracyKilometer
        default:
            return kCLLocationAccuracyThreeKilometers
        }
    }

    func initGeoFenceOption(_ call: FlutterMethodCall) -> Bool {
        if geoFenceManager == nil {
            return false
        }
        let args = call.arguments as! [AnyHashable: Any]
        switch args["action"] as! Int {
        case 0:
            geoFenceManager!.activeAction = .inside
        case 1:
            geoFenceManager!.activeAction = .outside
        case 2:
            geoFenceManager!.activeAction = [.inside, .outside]
        case 3:
            geoFenceManager!.activeAction = [.inside, .outside, .stayed]
        default:
            geoFenceManager!.activeAction = [.inside, .outside, .stayed]
        }
        return true
    }

}

extension Dictionary {
    mutating func merge<S>(_ other: S)
            where S: Sequence, S.Iterator.Element == (key: Key, value: Value) {
        for (k, v) in other {
            self[k] = v
        }
    }
}

extension AMapGeoFenceRegion {
    var data: [String: Any?] {
        [
            "customID": customID,
            "status": fenceStatus.rawValue,
            "type": regionType.rawValue,
            "center": [
                "latitude": currentLocation.coordinate.latitude,
                "longitude": currentLocation.coordinate.longitude,
            ],
            "fenceID": identifier,
        ]
    }
}

class LocationManagerDelegate: NSObject, AMapLocationManagerDelegate {
    var channel: FlutterMethodChannel

    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    /**
     *  @brief ????????????????????????.???????????????????????????????????????????????????????????????amapLocationManager:didUpdateLocation:???????????????
     *  @param manager ?????? AMapLocationManager ??????
     *  @param location ???????????????
     *  @param reGeocode ??????????????????
     */
    public func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode?) {
        var locationMap = location.data
        let reGeocodeMap = reGeocode?.data
        if reGeocodeMap != nil {
            locationMap.merge(reGeocodeMap!)
        }
        locationMap["success"] = true
        channel.invokeMethod("updateLocation", arguments: locationMap)
    }

    /**
     *  @brief ???????????????????????????????????????
     *  @param manager ?????? AMapLocationManager ??????
     *  @param status ?????????????????????
     */
    public func amapLocationManager(_ manager: AMapLocationManager!, locationManagerDidChangeAuthorization locationManager: CLLocationManager!) {
    }

    /**
     *  @brief ?????????????????????????????????????????????????????????
     *  @param manager ?????? AMapLocationManager ??????
     *  @param error ???????????????????????? CLError ???
     */
    public func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        channel.invokeMethod("updateLocation", arguments: [
            "description": error!.localizedDescription,
            "success": false,
            "code": (error! as NSError).code,
        ])
    }
}

class GeoFenceManagerDelegate: NSObject, AMapGeoFenceManagerDelegate {
    private var channel: FlutterMethodChannel
    var result: FlutterResult?

    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    /// ????????????????????????
    func amapLocationManager(_ manager: AMapGeoFenceManager!, doRequireTemporaryFullAccuracyAuth locationManager: CLLocationManager!, completion: ((Error?) -> Void)!) {
    }

    /// ??????????????????????????????
    /// ????????????????????????????????????????????????????????????????????????????????????????????????
    public func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didAddRegionForMonitoringFinished regions: [AMapGeoFenceRegion]!, customID: String!, error: Error!) {
        result?(error == nil)
    }

    ///  ??????????????????????????????
    public func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didGeoFencesStatusChangedFor region: AMapGeoFenceRegion!, customID: String!, error: Error!) {
        channel.invokeMethod("updateGeoFence", arguments: region.data)
    }
}

extension CLLocation {
    var data: [String: Any?] {
        ["latitude": coordinate.latitude,
         "longitude": coordinate.longitude,
         "accuracy": (horizontalAccuracy + verticalAccuracy) / 2,
         "altitude": altitude,
         "speed": speed,
         "timestamp": timestamp.timeIntervalSince1970]
    }
}

extension AMapLocationReGeocode {
    var data: [String: Any?] {
        ["formattedAddress": formattedAddress,
         "country": country,
         "province": province,
         "city": city,
         "district": district,
         "cityCode": city,
         "adCode": adcode,
         "street": street,
         "number": number,
         "poiName": poiName,
         "aoiName": aoiName]
    }
}
