//
//  ContentView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-05.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showMap: Bool = false
    @Query private var tails: [Tail]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HomeView(showMap: $showMap)
            .fullScreenCover(isPresented: $showMap) {
                MapNavigationView()
            }
            .onAppear {
                Task {
                    if tails.count == 0 {
                        let fetchedTails = try await NetworkService.fetchTails()
                        for tail in fetchedTails {
                            context.insert(tail)
                        }
                        try context.save()
                    }
                }
            }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            ContentView()
        }
    }
    return PreviewWrapper()
}
