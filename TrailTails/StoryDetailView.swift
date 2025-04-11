//
//  StoryDetailView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-07.
//

import SwiftUI
import SwiftData

struct StoryDetailView: View {
    @Environment(\.modelContext) private var context
    @Query private var tails: [Tail]
    @Binding var path: [Int]
    let storyId: Int
    var body: some View {
        VStack {
            Text("Story ID: \(storyId)")
            if let summary = tails.filter ({$0.id == storyId}).first?.summaries.first {
                Text(summary.text)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Story Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    if let tail = tails.filter ({$0.id == storyId}).first {
                        context.delete(tail)
                        print("tail deleted")
                        do {
                            try context.save()
                        } catch {
                            print("can't properly remove this tail \(error)")
                        }
                    }
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
