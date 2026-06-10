//
//  SearchViewModel.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 10/06/26.
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    
    @Published var searchText = ""
    @Published private(set) var tracks: [Track] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let service: NetworkService
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private let location = LocationManager()
    
    init(service: NetworkService = NetworkService()) {
        self.service = service
        bindSearch()
    }
    
    private func bindSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] term in
                guard let self = self else { return }
                performSearch(term: term)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(term: String) {
        // Cancela uma busca anterior ainda sendo executada
        searchTask?.cancel()
        
        let trimmed = term.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            tracks = []
            return
        }
        
        searchTask = Task {
            isLoading = true
            do {
                let results = try await service.searchTracks(term: trimmed, country: location.countryCode)
                guard !Task.isCancelled else { return } // Busca substituída
                tracks = results.filter { $0.previewUrl != nil }
                isLoading = false
            } catch {
                guard !Task.isCancelled else { return } // Erro de cancelamento silencioso
                errorMessage = "Não foi possível buscar. Tente novamente."
                isLoading = false
            }
        }
    }
    
    func refreshRegion() async {
        await location.refreshRegion()
    }
}
