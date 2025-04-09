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
                    ForEach(tails, id:\.self) { tail in
                        if let lat = tail.latitude, let longi = tail.longitude {
                            Annotation("\(tail.title)", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: longi)) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.title)
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
            cameraPosition = MapCameraPosition.camera(.init(centerCoordinate: userCoord, distance: 2000))
        }
    }
}

//#Preview {
//    MapView()
//}
