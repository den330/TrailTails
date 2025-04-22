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
            VStack(alignment: .center, spacing: 10) {
                if let tail = tails.filter ({$0.id == storyId}).first {
                    Text(tail.title)
                        .font(.largeTitle)
                }
                Divider()
                if let summary = tails.filter ({$0.id == storyId}).first?.summaries.first {
                    Text(summary.text)
                        .font(.body)
                }
            }
            .padding()
            .background(
                Color(.systemBackground).opacity(0.7)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            )
        }
        .padding(20)
        .foregroundStyle(.primary)
        .background {
            Image("basketball")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.3)
                .ignoresSafeArea()
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
