//
//  MapView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-07.
//

import SwiftUI
import MapKit
import SwiftData

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

//#Preview {
//    MapView()
//}
