//
//  MapNavigationView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-07.
//

import SwiftUI
import MapKit

struct MapNavigationView: View {
    @State private var path = NavigationPath()
    @Environment(\.modelContext) private var context
    
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
                .navigationDestination(for: Int.self) { storyId in
                    StoryDetailView(path: $path, storyId: storyId)
                }
        }
    }
}

//#Preview {
//    MapNavigationView()
//}
