//
//  RootView.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 10/06/26.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem { Label("Buscar", systemImage: "magnifyingglass") }
            NavigationStack {
                FavoritesView()
            }
            .tabItem { Label("Favoritos", systemImage: "heart") }
        }
    }
}
