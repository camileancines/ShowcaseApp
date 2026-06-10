//
//  ITunesResponse.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 09/06/26.
//

// MARK: - Wrapper da resposta
nonisolated struct SearchResponse: Decodable {
    let resultCount: Int
    let results: [Track]
}

// MARK: - Faixa
nonisolated struct Track: Decodable, Identifiable, Hashable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let collectionName: String?
    let artworkUrl100: String?
    let previewUrl: String?
    let trackTimeMillis: Int?
    let primaryGenreName: String?

    // Identifiable: o List/ForEach do SwiftUI precisa de uma identidade estável
    var id: Int { trackId }
}
