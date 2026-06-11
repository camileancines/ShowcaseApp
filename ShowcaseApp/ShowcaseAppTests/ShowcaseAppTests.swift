//
//  ShowcaseAppTests.swift
//  ShowcaseAppTests
//
//  Created by Camile Alves Ancines on 09/06/26.
//

import Testing
@testable import ShowcaseApp

struct MockTrackSearcher: TrackSearching {
    let result: Result<[Track], Error>
    func searchTracks(term: String, country: String) async throws -> [Track] {
        try result.get()
    }
}

// Fábrica de Track para os testes
extension Track {
    static func stub(id: Int, preview: String? = "https://x/p.m4a") -> Track {
        Track(trackId: id, trackName: "Song \(id)", artistName: "Artist",
              collectionName: nil, artworkUrl100: nil, previewUrl: preview,
              trackTimeMillis: nil, primaryGenreName: nil)
    }
}

@MainActor
struct SearchViewModelTests {

    @Test func retornaFaixasNoSucesso() async {
        let faixas = [Track.stub(id: 1), Track.stub(id: 2)]
        let vm = SearchViewModel(service: MockTrackSearcher(result: .success(faixas)))

        await vm.search(term: "daft punk")

        #expect(vm.tracks.count == 2)
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
    }

    @Test func filtraFaixasSemPreview() async {
        let faixas = [Track.stub(id: 1, preview: "https://x/p.m4a"),
                      Track.stub(id: 2, preview: nil)]
        let vm = SearchViewModel(service: MockTrackSearcher(result: .success(faixas)))

        await vm.search(term: "x")

        #expect(vm.tracks.count == 1)
        #expect(vm.tracks.first?.trackId == 1)
    }

    @Test func defineErroNaFalha() async {
        let vm = SearchViewModel(service: MockTrackSearcher(
            result: .failure(NetworkError.badResponse(statusCode: 500))))

        await vm.search(term: "x")

        #expect(vm.errorMessage != nil)
        #expect(vm.tracks.isEmpty)
        #expect(vm.isLoading == false)
    }

    @Test func termoVazioLimpaResultados() async {
        let vm = SearchViewModel(service: MockTrackSearcher(result: .success([Track.stub(id: 1)])))

        await vm.search(term: "   ")

        #expect(vm.tracks.isEmpty)
    }
}
