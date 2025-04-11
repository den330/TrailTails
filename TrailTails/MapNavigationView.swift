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
    @State private var path: [Int] = []
    @Environment(\.modelContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack(path: $path) {
            MapView(path: $path)
                .navigationDestination(for: Int.self) { storyId in
                    StoryDetailView(path: $path, storyId: storyId)
                }
                .navigationTitle("Map")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Back") {
                            dismiss()
                        }
                    }
                }
        }
        .onAppear {
            path.append(3)
        }
    }
}

//#Preview {
//    MapNavigationView()
//}
