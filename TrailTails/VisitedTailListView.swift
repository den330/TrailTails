//
//  VisitedTailListView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-13.
//

import SwiftUI
import SwiftData

struct VisitedTailListView: View {
    @Query(filter: #Predicate<Tail> { $0.visited }) private var tails: [Tail]
    @State private var path = NavigationPath()
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Group {
            if !tails.isEmpty {
                NavigationStack(path: $path) {
                    List {
                        ForEach(tails) { tail in
                            HStack {
                                Text(tail.title)
                                    .onTapGesture {
                                        path.append(tail.id)
                                    }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 14))
                            }
                        }
                        .onDelete(perform: deleteTails)
                    }
                    .padding()
                    .navigationTitle("Visited Tails")
                    .navigationDestination(for: Int.self) { id in
                        StoryDetailView(path: $path, storyId: id)
                    }
                }
            } else {
                Text("You have not visited any tail yet.")
            }
        }
    }
    
    private func deleteTails(at offsets: IndexSet) {
        for index in offsets {
            context.delete(tails[index])
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to delete tail: \(error)")
        }
    }
}

