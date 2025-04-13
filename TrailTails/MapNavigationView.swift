//
//  MapNavigationView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-07.
//

import SwiftUI
import MapKit
import Foundation

struct MapNavigationView: View {
    @State private var path = NavigationPath()
    @Environment(\.modelContext) private var context
    var body: some View {
        NavigationStack(path: $path) {
            MapView(path: $path)
                .navigationDestination(for: Int.self) { storyId in
                    StoryDetailView(path: $path, storyId: storyId)
                }
                .navigationTitle("Map")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//#Preview {
//    MapNavigationView()
//}
