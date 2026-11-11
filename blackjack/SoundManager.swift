//
//  SoundManager.swift
//  blackjack
//
//  Created by Alp Rüzgar on 1.07.2026.
//

import Foundation
import AVFoundation

@Observable
class SoundManager {

    // MARK: - Properties

    // All AVAudioSession / AVAudioPlayer work lives on this background actor.
    // AVAudioPlayer implicitly talks to the audio session when preparing and
    // playing, which triggers "AVAudioSession Hang Risk" if done on the main thread.
    @ObservationIgnored private let audio = AudioPlayback()

    // MARK: - Loading

    func load(_ filename: String) {
        Task { await audio.load(filename) }
    }

    // MARK: - Playback

    func play(_ filename: String) {
        Task { await audio.play(filename) }
    }
}

// MARK: - AudioPlayback

/// Owns the audio session and players, keeping them off the main thread.
private actor AudioPlayback {

    private var players: [String: AVAudioPlayer] = [:]
    private var lastPlayTime: [String: TimeInterval] = [:]
    private var isSessionConfigured = false
    // Rapid chip taps can hammer AVAudioPlayer hard enough to freeze the game;
    // skip any duplicate sound triggered within this window.
    private let throttleInterval: TimeInterval = 0.05

    // MARK: - Session

    // .ambient lets the app mix with background media (Music, podcasts, etc.)
    // instead of taking over the audio session on launch.
    private func configureSessionIfNeeded() async {
        guard !isSessionConfigured else { return }
        isSessionConfigured = true

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.ambient, mode: .default)
            if #available(iOS 27.0, *) {
                _ = try await session.activate()
            } else {
                try session.setActive(true)
            }
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Loading

    func load(_ filename: String) async {
        await configureSessionIfNeeded()

        let name = (filename as NSString).deletingPathExtension
        let ext = (filename as NSString).pathExtension

        guard let url = Bundle.main.url(forResource: name, withExtension: ext.isEmpty ? nil : ext) else {
            print("Sound file not found: \(filename)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[filename] = player
        } catch {
            print("Failed to load \(filename): \(error)")
        }
    }

    // MARK: - Playback

    func play(_ filename: String) {
        guard let player = players[filename] else { return }
        let now = Date().timeIntervalSinceReferenceDate
        if let last = lastPlayTime[filename], now - last < throttleInterval {
            return
        }
        lastPlayTime[filename] = now
        player.currentTime = 0
        player.play()
    }
}
