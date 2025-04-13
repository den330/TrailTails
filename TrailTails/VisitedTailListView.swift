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
    
    var body: some View {
        Group {
            if !tails.isEmpty {
                NavigationStack(path: $path) {
                    List {
                        ForEach(tails) { tail in
                            Text(tail.title)
                                .onTapGesture {
                                    path.append(tail.id)
                                }
                        }
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
}

