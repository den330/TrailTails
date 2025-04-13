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
    @Binding var path: NavigationPath
    let storyId: Int
    var body: some View {
        ScrollView {
            if let tail = tails.filter ({$0.id == storyId}).first {
                Text(tail.title)
                    .font(.largeTitle)
            }
            if let summary = tails.filter ({$0.id == storyId}).first?.summaries.first {
                Spacer(minLength: 10)
                Text(summary.text)
                    .font(.body)
            }
        }
        .padding(20)
        .background {
            Image("basketball")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Story Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    if let tail = tails.filter ({$0.id == storyId}).first {
                        tail.visited = true
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
