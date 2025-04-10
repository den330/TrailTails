//
//  StoryDetailView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-07.
//

import SwiftUI
import SwiftData

struct StoryDetailView: View {
    @Query private var tails: [Tail]
    @Binding var path: NavigationPath
    let storyId: Int
    var body: some View {
        VStack {
            Text("Story ID: \(storyId)")
            if let summary = tails.filter ({$0.id == storyId}).first?.summaries.first {
                Text(summary)
            }
        }
        .navigationTitle("Story Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    path.removeLast()
                } label: {
                    Text("Back")
                }
            }
        }
    }
}

//#Preview {
//    StoryDetailView()
//}
