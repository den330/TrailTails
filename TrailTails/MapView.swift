//
//  MapView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-07.
//

import SwiftUI
import MapKit
import SwiftData

@MainActor
struct MapView: View {
    @Environment(\.modelContext) private var context
    @Query private var tails: [Tail]
    @Query(filter: #Predicate<Tail> {$0.latitude == nil}) private var unAssignedTails: [Tail]
    @Query(filter: #Predicate<Tail> {$0.visited == false}) private var unVisitedTails: [Tail]
    @State private var startingSpotDetermined: Bool = false
    @StateObject private var locationManager: LocationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition?
    @State private var showLocationDeniedAlert: Bool = false
    @State private var tailToPop = Set<Int>()
    @State private var scale: CGFloat = 1
    @State private var assignInProgress: Bool = false
    @Binding var path: NavigationPath
    @Environment(\.dismiss) private var dismiss

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
            if let cameraPosition = cameraPosition {
                let cameraBinding = Binding(get: {cameraPosition}, set: {self.cameraPosition = $0})
                ZStack(alignment: .topLeading){
                    Map(position: cameraBinding) {
                        UserAnnotation()
                        ForEach(unVisitedTails, id:\.self) { tail in
                            if let lat = tail.latitude, let longi = tail.longitude {
                                Annotation("\(tail.title)", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: longi)) {
                                    VStack(spacing: 4) {
                                        if tailToPop.contains(tail.id) {
                                            Button {
                                                path.append(Int(tail.id))
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
                    Button {
                        Task {
                            do {
                                self.detectAuthAndShowAlert(auth: locationManager.locationAuthStatus)
                                self.cameraPosition = nil
                                if unVisitedTails.count >= 15 {
                                    for tail in unVisitedTails {
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
                            } catch {
                                print("fetch or save error \(error)")
                            }
                        }
                    } label: {
                        Text("Get some tails")
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .background(.yellow)
                            .clipShape(.rect(cornerRadius: 80))
                    }
                    .padding([.top, .leading], 10)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            scale = 1.2
                        }
                    }
                    .onDisappear {
                        scale = 1
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onChange(of: locationManager.location) {
            handleLocationUpdate()
        }
        .onChange(of: locationManager.locationAuthStatus) {
            self.detectAuthAndShowAlert(auth: locationManager.locationAuthStatus)
        }
        .onAppear {
            self.detectAuthAndShowAlert(auth: locationManager.locationAuthStatus)
        }
        .alert("Location Access Denied", isPresented: $showLocationDeniedAlert) {
            Button("Cancel", role: .cancel) {
                dismiss()
            }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("TrailTails needs your location to find and unlock stories near you.")
        }
    }
    
    private func handleLocationUpdate() {
        if let userCoord = locationManager.location?.coordinate {
            if !startingSpotDetermined && !assignInProgress {
                self.assignInProgress = true
                for tail in unAssignedTails {
                    let (lat, longi) = LocationService.randomCoordinate(near: userCoord, maxDistance:1)
                    tail.latitude = lat
                    tail.longitude = longi
                }
                do {
                    try context.save()
                } catch {
                    print("Tail coord save fail \(error)")
                }
                cameraPosition = MapCameraPosition.camera(.init(centerCoordinate: userCoord, distance: 2000))
                startingSpotDetermined = true
                self.assignInProgress = false
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
}
