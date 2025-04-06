//
//  ContentView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-05.
//

import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    @State private var showMap: Bool = false
    var body: some View {
        HomeView(showMap: $showMap)
            .fullScreenCover(isPresented: $showMap) {
                MapNavigationView()
            }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            ContentView()
        }
    }
    return PreviewWrapper()
}


struct HomeView: View {
    @Binding var showMap: Bool
    var body: some View {
        Button("Start Exploring") {
            showMap = true
        }
    }
}

struct MapView: View {
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.3318, longitude: -122.4483), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    @State private var isLocationAuthDenied = false
    @Binding var path: NavigationPath
    @StateObject private var locationManager = LocationManager()
    var body: some View {
        Map(position: $cameraPosition)
            .onChange(of: locationManager.location) { _, newValue in
                if let newPositon = newValue {
                    cameraPosition = .region(MKCoordinateRegion(center: newPositon.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
                }
            }
            .onChange(of: locationManager.isLocationAuthDenied) { _, newValue in
                isLocationAuthDenied = newValue
            }
            .alert("Location Access Denied", isPresented: $isLocationAuthDenied) {
                Button("Cancel", role: .cancel) { }
                Button("Open Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            } message: {
                Text("Please enable location access in Settings to see nearby stories.")
            }
    }
}

struct MapNavigationView: View {
    @State private var path = NavigationPath()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            MapView(path: $path)
                .navigationTitle("Map")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Back") {
                            dismiss()
                        }
                    }
                }
                .navigationDestination(for: Int.self) { destination in
                    StoryDetailView(storyId: destination)
                }
        }
    }
}

class LocationManager:NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var isLocationAuthDenied = false
    @Published var location: CLLocation?
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.authorizationStatus == .authorizedWhenInUse {
            isLocationAuthDenied = false
            locationManager.requestLocation()
        } else {
            isLocationAuthDenied = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error.localizedDescription)
    }
}

struct StoryDetailView: View {
    let storyId: Int
    var body: some View {
        VStack {
            Text("Story ID: \(storyId)")
            Text("This is where the story details go!")
        }
        .navigationTitle("Story Details")
    }
}
