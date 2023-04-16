//
//  CoreLocationManager.swift
//  Common
//
//  Created by 马陈爽 on 2022/5/29.
//

import Foundation
import CoreLocation
import UIKit

public class LocationManager: NSObject {
    public static let shared = LocationManager()
    
    public var location: CLLocation?
    
    var GPS: [String: Any]? {
        guard let location = self.location else {
            return nil
        }
        return LocationManager.getGPSInfo(with: location)
    }
    
    
    public func startUpdatingLocation() {
        self.manager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        self.manager.stopUpdatingLocation()
    }
    
    func latitudeIsLegal(with latitude: Double) -> Bool {
        return latitude <= 90 && latitude >= -90
    }
    
    func longitudeIsLegal(with longitude: Double) -> Bool {
        return longitude <= 180 && longitude >= -180
    }
    
    private lazy var geoCoder: CLGeocoder = {
       return CLGeocoder()
    }()
    
    @available(iOS 11, *)
    func inferPlacemark(withLatitude latitude: Double, longitude: Double, completionHandler: @escaping CLGeocodeCompletionHandler) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        inferPlacemark(with: location, completionHandler: completionHandler)
    }
    
    @available(iOS 11, *)
    func inferPlacemark(with location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
        let geoCoder = CLGeocoder()
        //let preferredLang = Constant.Album.isChinaLanguage ? "zh_CN" : "en_US"
        let locale = Locale(identifier: "en_US")
        geoCoder.reverseGeocodeLocation(location, preferredLocale: locale) { (placemarks, error) in
            DispatchQueue.main.async {
                completionHandler(placemarks, error)
            }
        }
    }
    
    public static func getGPSInfo(with location: CLLocation?) -> [String: Any]? {
        guard let location = location else {
            return nil
        }
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy:MM:dd"
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm:ss"
        
        let infos = [kCGImagePropertyGPSAltitude as String: location.altitude,
                     kCGImagePropertyGPSLatitude as String: location.coordinate.latitude,
                     kCGImagePropertyGPSLatitudeRef as String: location.coordinate.latitude >= 0 ? "N" : "S",
                     kCGImagePropertyGPSLongitude as String: fabs(location.coordinate.longitude),
                     kCGImagePropertyGPSLongitudeRef as String: location.coordinate.longitude >= 0 ? "E" : "W",
                     kCGImagePropertyGPSDateStamp as String: dateFormat.string(from: location.timestamp),
                     kCGImagePropertyGPSTimeStamp  as String: timeFormat.string(from: location.timestamp)
        ] as [String : Any]
        
        return infos
    }
    
    // MARK: - Lazy Init
    
    private lazy var manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100.0
        manager.requestWhenInUseAuthorization()
        return manager
    }()
}

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        self.location = location
        //self.inferPlacemark(with: location)
    }
}
