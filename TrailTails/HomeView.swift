//
//  HomeView.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-07.
//

import SwiftUI

struct HomeView: View {
    @Binding var showMap: Bool
    var body: some View {
        Button("Start Exploring") {
            showMap = true
        }
    }
}

#Preview {
    @Previewable @State var showMap = false
    HomeView(showMap: $showMap)
}
