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
    @Query private var tails: [Tail]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HomeView(showMap: $showMap)
            .fullScreenCover(isPresented: $showMap) {
                MapNavigationView()
            }
            .onAppear {
                Task {
                    if tails.count == 0 {
                        let fetchedTails = try await NetworkService.fetchTails()
                        for tail in fetchedTails {
                            context.insert(tail)
                        }
                        try context.save()
                    }
                }
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
    @Environment(\.modelContext) private var context

    @Query private var tails: [Tail]
    @State private var userRegion: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    @State private var isLocationAuthDenied = false
    @Binding var path: NavigationPath
    @Binding var tailSelected: Tail?
    @StateObject private var locationManager = LocationManager()
    var body: some View {
        Map(initialPosition: userRegion) {
            ForEach(tails) { tail in
                if tail.latitude != nil && tail.longitude != nil {
                    let newCoord = CLLocationCoordinate2D(latitude: tail.latitude!, longitude: tail.longitude!)
                    Annotation(tail.title, coordinate: newCoord) {
                        Button {
                            tailSelected = tail
                        } label: {
                            VStack {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                            .padding(5)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }.onChange(of: locationManager.location) { _, newValue in
                if let newPositon = newValue {
                    userRegion = .region(MKCoordinateRegion(center: newPositon.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
                    for tail in tails {
                        if tail.latitude == nil || tail.longitude == nil {
                            let (newLatitude, newLongitude) = LocationService.randomCoordinate(near: userRegion.camera!.centerCoordinate, maxDistance: 2)
                            tail.latitude = newLatitude
                            tail.longitude = newLongitude
                            try! context.save()
                        }
                    }
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
            .onAppear {
                locationManager.requestLocation()
            }
    }
}

struct MapNavigationView: View {
    @State private var path = NavigationPath()
    @State private var tailSelected: Tail?
    @Environment(\.modelContext) private var context

    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            MapView(path: $path, tailSelected: $tailSelected)
                .navigationTitle("Map")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Back") {
                            dismiss()
                        }
                    }
                }
                .navigationDestination(isPresented: Binding(
                    get: { tailSelected != nil },
                    set: {if !$0 {tailSelected = nil}}
                )) {
                    if let tailSelected = tailSelected {
                        StoryDetailView(storyId: tailSelected.id)
                    }
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
    let storyId: String
    var body: some View {
        VStack {
            Text("Story ID: \(storyId)")
            Text("This is where the story details go!")
        }
        .navigationTitle("Story Details")
    }
}
