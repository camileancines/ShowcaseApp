//
//  PlayerEngine.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 10/06/26.
//

import AVFoundation
import Combine

@MainActor
final class PlayerEngine: ObservableObject {
    
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var duration: Double = 0
    
    private let player = AVPlayer()
    private var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        configureAudioSession()
        observePlaybackStatus()
        addPeriodicTimeObserver()
    }
    
    func start(url: URL) {
        let item = AVPlayerItem(url: url)
        
        item.publisher(for: \.status)
            .filter { $0 == .readyToPlay }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                let seconds = item.duration.seconds
                if seconds.isFinite { self?.duration = seconds }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: AVPlayerItem.didPlayToEndTimeNotification, object: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.player.seek(to: .zero)
                self?.player.pause()
            }
            .store(in: &cancellables)
        
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    func teardown() {
        player.pause()
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
        cancellables.removeAll()
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func togglePlayPause() {
        player.timeControlStatus == .playing ? player.pause() : player.play()
    }
    
    func seek(to seconds: Double) {
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
        }
    }
    
    private func observePlaybackStatus() {
        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.isPlaying = (status == .playing)
            }
            .store(in: &cancellables)
    }
    
    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.2, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            MainActor.assumeIsolated {
                self?.currentTime = time.seconds
            }
        }
    }
}
