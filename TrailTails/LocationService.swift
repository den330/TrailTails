//
//  LocationService.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-06.
//
import CoreLocation

struct LocationService {
    static func randomCoordinate(near coordinate: CLLocationCoordinate2D, maxDistance km: Double) -> (Double, Double) {
        // Earth's radius in kilometers
        let earthRadius = 6371.0
        
        // Generate a random distance with uniform distribution over the circle's area.
        // Using sqrt(random) ensures the distribution is uniform.
        let randomDistance = km * sqrt(Double.random(in: 0...1))
        
        // Generate a random bearing (in radians) between 0 and 2π.
        let randomBearing = Double.random(in: 0...(2 * Double.pi))
        
        // Convert the starting latitude and longitude from degrees to radians.
        let lat1 = coordinate.latitude * .pi / 180
        let lon1 = coordinate.longitude * .pi / 180
        
        // Angular distance in radians
        let angularDistance = randomDistance / earthRadius
        
        // Calculate the new latitude.
        let lat2 = asin(sin(lat1) * cos(angularDistance) +
                        cos(lat1) * sin(angularDistance) * cos(randomBearing))
        
        // Calculate the new longitude.
        let lon2 = lon1 + atan2(sin(randomBearing) * sin(angularDistance) * cos(lat1),
                                cos(angularDistance) - sin(lat1) * sin(lat2))
        
        // Convert the new latitude and longitude from radians back to degrees.
        let newLatitude = lat2 * 180 / .pi
        let newLongitude = lon2 * 180 / .pi
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
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
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
