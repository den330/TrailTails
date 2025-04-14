//
//  LocationService.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-06.
//
import CoreLocation

struct LocationService {
    static func randomCoordinate(near coordinate: CLLocationCoordinate2D, maxDistance km: Double) -> (Double, Double) {
        // Convert maxDistance from km to meters
        let maxDistanceMeters = km * 1000.0
        
        // Generate a random distance with uniform distribution over the circle's area
        let randomDistance = maxDistanceMeters * sqrt(Double.random(in: 0...1))
        
        // Generate a random bearing (in radians) between 0 and 2π
        let randomBearing = Double.random(in: 0...(2 * Double.pi))
        
        // Calculate x, y offsets in meters
        let x = randomDistance * cos(randomBearing) // East-West offset
        let y = randomDistance * sin(randomBearing) // North-South offset
        
        // Approximate meters per degree at this latitude
        // 1 degree of latitude = ~111,111 meters (constant)
        // 1 degree of longitude = ~111,111 * cos(latitude) meters (varies with latitude)
        let metersPerDegreeLat = 111_111.0
        let metersPerDegreeLon = 111_111.0 * cos(coordinate.latitude * .pi / 180)
        
        // Convert offsets to degrees
        let deltaLat = y / metersPerDegreeLat // North-South change in degrees
        let deltaLon = x / metersPerDegreeLon // East-West change in degrees
        
        // Calculate new coordinates
        let newLatitude = coordinate.latitude + deltaLat
        let newLongitude = coordinate.longitude + deltaLon
        
        return (newLatitude, newLongitude)
    }
}

class LocationManager:NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locationAuthStatus: LocationAuthStatus?
    @Published var location: CLLocation?
    
    enum LocationAuthStatus {
        case approved
        case denied
        case undetermined
    }
    
    private func updateLocationAuth(manager: CLLocationManager) {
        switch locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways: locationAuthStatus = .approved
            case .notDetermined: locationAuthStatus = .undetermined
            default: locationAuthStatus = .denied
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        updateLocationAuth(manager: locationManager)
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocationAuth(manager: manager)
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error.localizedDescription)
    }
}
