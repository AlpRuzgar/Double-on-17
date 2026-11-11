//
//  Level.swift
//  blackjack
//
//  Created by Alp Rüzgar on 24.05.2026.
//

import Foundation
import Combine

class Level: Identifiable, ObservableObject {

    // MARK: - Properties

    let id: Int
    let name: String
    let startingChips: Int
    @Published var chipsOwned: Int
    let requiredChips: Int
    let minimumBet: Int
    /// How many seconds the level stays locked after completion.
    let lockDuration: Int

    @Published private(set) var isCompleted: Bool
    @Published var lockTimeLeft: Int

    // Stored as an absolute Date so the countdown survives app restarts.
    private var unlockDate: Date?

    // MARK: - Init

    init(id: Int, name: String, startingChips: Int, requiredChips: Int, minimumBet: Int, lockDuration: Int) {
        self.id = id
        self.name = name
        self.startingChips = startingChips
        self.chipsOwned = startingChips
        self.requiredChips = requiredChips
        self.minimumBet = minimumBet
        self.lockDuration = lockDuration

        // We persist the absolute unlock date (not a remaining-seconds value) so the
        // timer continues counting down even while the app is closed.
        let savedTimestamp = UserDefaults.standard.double(forKey: Self.unlockDateKey(for: id))
        if savedTimestamp > 0 {
            let date = Date(timeIntervalSince1970: savedTimestamp)
            let remaining = Int(date.timeIntervalSinceNow)
            if remaining > 0 {
                self.unlockDate = date
                self.isCompleted = true
                self.lockTimeLeft = remaining
            } else {
                // Lock period already expired while app was closed
                self.unlockDate = nil
                self.isCompleted = false
                self.lockTimeLeft = 0
                UserDefaults.standard.removeObject(forKey: Self.unlockDateKey(for: id))
                UserDefaults.standard.removeObject(forKey: Self.completionDefaultsKey(for: id))
            }
        } else {
            // No unlock timestamp — either never completed, or stale data from before
            // the timestamp system was introduced. Either way, clear any leftover
            // completion flag so the level isn't permanently locked.
            self.isCompleted = false
            self.lockTimeLeft = 0
            UserDefaults.standard.removeObject(forKey: Self.completionDefaultsKey(for: id))
        }
    }

    // MARK: - Lock System

    func markCompleted() {
        let date = Date().addingTimeInterval(TimeInterval(lockDuration))
        unlockDate = date
        isCompleted = true
        lockTimeLeft = lockDuration
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: Self.unlockDateKey(for: id))
        UserDefaults.standard.set(true, forKey: Self.completionDefaultsKey(for: id))
    }

    /// Called every second by LevelButton's timer. Recalculates from the saved
    /// absolute date rather than decrementing, so accuracy survives app restarts.
    func tickLock() {
        guard let date = unlockDate else { return }
        let remaining = Int(date.timeIntervalSinceNow)
        if remaining <= 0 {
            resetCompletion()
        } else {
            lockTimeLeft = remaining
        }
    }

    func resetCompletion() {
        isCompleted = false
        lockTimeLeft = 0
        unlockDate = nil
        UserDefaults.standard.removeObject(forKey: Self.completionDefaultsKey(for: id))
        UserDefaults.standard.removeObject(forKey: Self.unlockDateKey(for: id))
    }

    // MARK: - Chip Management

    func resetChips() {
        chipsOwned = startingChips
    }

    func reset() {
        chipsOwned = startingChips
        resetCompletion()
    }

    // MARK: - Stakes

    /// Stakes mode has no target or lock; requiredChips and lockDuration are unused for it.
    static let stakesID = -1

    // MARK: - UserDefaults Keys

    private static func completionDefaultsKey(for id: Int) -> String {
        "level_\(id)_completed"
    }

    private static func unlockDateKey(for id: Int) -> String {
        "level_\(id)_unlockDate"
    }
}
