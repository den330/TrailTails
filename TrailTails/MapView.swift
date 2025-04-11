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
    @State private var tailToPop = Set<Int>()
    @Binding var path: [Int]
    
    private func detectAuthAndShowAlert(auth: LocationManager.LocationAuthStatus?) {
        if let auth = locationManager.locationAuthStatus {
            switch auth {
            case .denied:
                showLocationDeniedAlert = true
            default:
                break
            }
        }
    }

    var body: some View {
        Group {
            if cameraPosition != nil {
                let cameraBinding = Binding(get: {self.cameraPosition!}, set: {self.cameraPosition = $0})
                VStack{
                    Button {
                        Task {
                            self.detectAuthAndShowAlert(auth: locationManager.locationAuthStatus)
                            self.cameraPosition = nil
                            if tails.count >= 15 {
                                for tail in tails {
                                    context.delete(tail)
                                }
                                try context.save()
                            }
                            let currentList = tails.map {$0.id}
                            let fetchedTails = try await NetworkService.fetchTails(idList: Tail.randomIdGenerator(currentList: currentList))
                            for tail in fetchedTails {
                                context.insert(tail)
                            }
                            try context.save()
                            self.startingSpotDetermined = false
                        }
                    } label: {
                        Text("Get some tails")
                    }
                    Map(position: cameraBinding) {
                        UserAnnotation()
                        ForEach(tails, id:\.self) { tail in
                            if let lat = tail.latitude, let longi = tail.longitude {
                                Annotation("\(tail.title)", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: longi)) {
                                    VStack(spacing: 4) {
                                        if tailToPop.contains(tail.id) {
                                            Button {
                                                print("before: \(path.count)")
                                                path.append(Int(tail.id))
                                                print("after: \(path.count)")
                                            } label: {
                                                Text("Open this story")
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.white.opacity(0.9))
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    .shadow(radius: 2)
                                            }
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
                }
            } else {
                ProgressView()
            }
        }
        .onChange(of: locationManager.location) {
            if let userCoord = locationManager.location?.coordinate {
                if !startingSpotDetermined {
                    for tail in tails {
                        if tail.latitude == nil {
                            let (lat, longi) = LocationService.randomCoordinate(near: userCoord, maxDistance: 0.5)
                            tail.latitude = lat
                            tail.longitude = longi
                            do {
                                try context.save()
                            } catch {
                                print("Tail coord save fail \(error)")
                            }
                        }
                    }
                    cameraPosition = MapCameraPosition.camera(.init(centerCoordinate: userCoord, distance: 2000))
                    startingSpotDetermined = true
                } else {
                    for tail in tails {
                        if let lat = tail.latitude, let longi = tail.longitude {
                            let tailLocation = CLLocation(latitude: lat, longitude: longi)
                            if tailLocation.distance(from: CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)) < 300 {
                                tailToPop.insert(tail.id)
                            } else {
                                tailToPop.remove(tail.id)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: locationManager.locationAuthStatus) {
            self.detectAuthAndShowAlert(auth: locationManager.locationAuthStatus)
        }
        .onAppear {
            self.detectAuthAndShowAlert(auth: locationManager.locationAuthStatus)
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
