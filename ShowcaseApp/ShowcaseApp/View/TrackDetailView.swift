//
//  TrackDetailView.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 10/06/26.
//

import SwiftUI

struct TrackDetailView: View {
    
    let track: Track
    @StateObject private var player = PlayerEngine()
    
    var body: some View {
        VStack(spacing: 24) {
            AsyncImage(url: highResArtworkURL) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                RoundedRectangle(cornerRadius: 16).fill(.quaternary)
            }
            .frame(width: 240, height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            EqualizerVisualizer(isPlaying: player.isPlaying)
                .frame(height: 50)
            
            VStack(spacing: 4) {
                Text(track.trackName).font(.title2).bold()
                    .multilineTextAlignment(.center)
                Text(track.artistName).foregroundStyle(.secondary)
            }
            
            VStack(spacing: 4) {
                ProgressView(value: progress)
                HStack {
                    Text(timeString(player.currentTime))
                    Spacer()
                    Text(timeString(player.duration))
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            }
            
            Button {
                player.togglePlayPause()
            } label: {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
            }
        }
        .padding()
        .navigationTitle(track.trackName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let s = track.previewUrl, let url = URL(string: s) {
                player.start(url: url)
            }
        }
        .onDisappear { player.teardown() }
    }
    
    private var progress: Double {
        guard player.duration > 0 else { return 0 }
        let fraction = player.currentTime / player.duration
        return min(max(fraction, 0), 1)
    }
    
    private var highResArtworkURL: URL? {
        guard let s = track.artworkUrl100 else { return nil }
        return URL(string: s.replacingOccurrences(of: "100x100", with: "600x600"))
    }
    
    private func timeString(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
