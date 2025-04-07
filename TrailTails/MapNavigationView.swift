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

//#Preview {
//    MapNavigationView()
//}
