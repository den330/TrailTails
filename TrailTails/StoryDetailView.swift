//
//  StoryDetailView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-07.
//

import SwiftUI

struct StoryDetailView: View {
    let storyId: String
    var body: some View {
        VStack {
            Text("Story ID: \(storyId)")
            Text("This is where the story details go!")
        }
        .navigationTitle("Story Details")
    }
}

//#Preview {
//    StoryDetailView()
//}
