//
//  FavoritesView.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 10/06/26.
//

import SwiftUI
import CoreData

struct FavoritesView: View {
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.dateAdded, order: .reverse)],
        animation: .default
    ) private var favorites: FetchedResults<FavoriteTrack>
    
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        Group {
            if favorites.isEmpty {
                ContentUnavailableView("Sem favoritos", systemImage: "heart",
                                       description: Text("Toque no coração de uma música para salvá-la."))
            } else {
                List {
                    ForEach(favorites) { fav in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: fav.artworkUrl ?? "")) { image in
                                image.resizable().scaledToFill()
                            } placeholder: { Color.secondary.opacity(0.2) }
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(fav.trackName ?? "—").lineLimit(1)
                                Text(fav.artistName ?? "—")
                                    .font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favoritos")
    }
    
    private func delete(at offsets: IndexSet) {
        offsets.map { favorites[$0] }.forEach(context.delete)
        try? context.save()
    }
}
