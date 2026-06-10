//
//  SearchView.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 10/06/26.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Buscar")
                .searchable(text: $viewModel.searchText, prompt: "Músicas, artistas...")
                .navigationDestination(for: Track.self) { track in
                    TrackDetailView(track: track)
                }
        }
        .task { await viewModel.refreshRegion() }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Buscando...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            ContentUnavailableView("Algo deu errado",
                                   systemImage: "exclamationmark.triangle",
                                   description: Text(error))
        } else if viewModel.searchText.isEmpty {
            ContentUnavailableView("Busque uma música",
                                   systemImage: "magnifyingglass",
                                   description: Text("Digite o nome de uma faixa ou artista."))
        } else {
            List(viewModel.tracks) { track in
                NavigationLink(value: track) {
                    TrackRow(track: track)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct TrackRow: View {
    let track: Track
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: track.artworkUrl100 ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Image(systemName: "music.note").foregroundStyle(.secondary)
                default:
                    ProgressView()
                }
            }
            .frame(width: 56, height: 56)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(track.trackName)
                    .lineLimit(1)
                Text(track.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
