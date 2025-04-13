//
//  TailTabView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-13.
//

import SwiftUI

struct TailTabView: View {
    var body: some View {
        TabView {
            MapNavigationView()
                .tabItem {
                    Image(systemName: "map")
                }
            VisitedTailListView()
                .tabItem {
                    Image(systemName: "bookmark")
                }
        }
    }
}

#Preview {
    TailTabView()
}
