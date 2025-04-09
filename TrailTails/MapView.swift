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
    @State private var startingSpotDetermined: Bool = false
    @StateObject private var locationManager: LocationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition?
    @State private var showLocationDeniedAlert: Bool = false
    @State private var tailToPop: Int?
    @Binding var path: NavigationPath
    var body: some View {
        Group {
            if cameraPosition != nil {
                let cameraBinding = Binding(get: {self.cameraPosition!}, set: {self.cameraPosition = $0})
                Map(position: cameraBinding) {
                    UserAnnotation()
                    ForEach(tails, id:\.self) { tail in
                        if let lat = tail.latitude, let longi = tail.longitude {
                            Annotation("\(tail.title)", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: longi)) {
                                VStack(spacing: 4) {
                                    if let tailToPop = tailToPop, tailToPop == tail.id {
                                        Button {
                                            path.append(tail.id)
                                            tailToPop = nil
                                            locationManager.startUpdatingLocation()
                                        } label: {
                                            Text("Open this story")
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.white.opacity(0.9))
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .shadow(radius: 2)
                                        }
                                        .transition(.opacity)
                                    }
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(.red)
                                        .font(.title)
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea()
            } else {
                ProgressView()
            }
        }
        .onChange(of: locationManager.location) {
            guard let userCoord = locationManager.location?.coordinate else {
                return
            }
            if !startingSpotDetermined {
                for tail in tails {
                    if tail.latitude == nil {
                        let (lat, longi) = LocationService.randomCoordinate(near: userCoord, maxDistance: 5)
                        tail.latitude = lat
                        tail.longitude = longi
                        do {
                            try context.save()
                        } catch {
                            print("Tail coord save fail \(error)")
                        }
                    }
                }
                startingSpotDetermined = true
            } else {
                for tail in tails {
                    guard let lat = tail.latitude, let longi = tail.longitude else {
                        continue
                    }
                    let tailLocation = CLLocation(latitude: lat, longitude: longi)
                    if tailLocation.distance(from: locationManager.location.coordinate) < 50 {
                        tailToPop = tail.id
                        locationManager.stopUpdatingLocation()
                        break
                    }
                }
            }
            cameraPosition = MapCameraPosition.camera(.init(centerCoordinate: userCoord, distance: 2000))
        }
        .onChange(of: locationManager.locationAuthStatus) {
            guard let auth = locationManager.locationAuthStatus else {
                return
            }
            switch auth {
            case .denied:
                showLocationDeniedAlert = true
            default:
                break
            }
        }
        .onAppear {
            locationManager.startUpdatingLocation()
        }
        .alert("Location Access Denied", isPresented: $showLocationDeniedAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable location access in Settings to see nearby tales.")
        }
    }
}

//#Preview {
//    MapView()
//}
