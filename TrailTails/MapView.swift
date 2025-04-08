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
    @StateObject private var locationManager: LocationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition?
    var body: some View {
        Group {
            if cameraPosition != nil {
                let cameraBinding = Binding(get: {self.cameraPosition!}, set: {self.cameraPosition = $0})
                Map(position: cameraBinding) {
                    UserAnnotation()
                    if let userCoord = locationManager.location?.coordinate {
                        ForEach(tails, id:\.self) { tail in
                            let (lat, longi) = LocationService.randomCoordinate(near: userCoord, maxDistance: 5)
                            Annotation("\(tail.title)", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: longi)) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.title) // Adjust size as needed
//                                Text("Lat is \(lat), longi is \(longi)")
                            }
                        }
                    }
                }
                .scaledToFill()
                .ignoresSafeArea()
            } else {
                ProgressView()
            }
        }
        .onChange(of: locationManager.location) {
            guard let userCoord = locationManager.location?.coordinate else {
                return
            }
            cameraPosition = MapCameraPosition.camera(.init(centerCoordinate: userCoord, distance: 20000))
        }
    }
}

//#Preview {
//    MapView()
//}
