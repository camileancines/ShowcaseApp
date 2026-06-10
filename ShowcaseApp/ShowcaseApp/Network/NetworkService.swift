//
//  NetworkService.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 09/06/26.
//

import Foundation

nonisolated enum NetworkError: Error {
    case invalidURL
    case badResponse(statusCode: Int)
    case decodingFailed(Error)
}

nonisolated struct NetworkService {
    func searchTracks(term: String, country: String) async throws -> [Track] {
        
        // 1. Montar a URL
        var components = URLComponents(string: "https://itunes.apple.com/search")
        components?.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "25"),
            URLQueryItem(name: "country", value: country)
        ]
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        // 2. Busca. Ponto de suspensão
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // 3. Validar a resposta HTTP
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NetworkError.badResponse(statusCode: code)
        }
        
        // 4. Decodificar
        do {
            let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
            return decoded.results
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
