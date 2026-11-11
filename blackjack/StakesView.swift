//
//  StakesVİew.swift
//  blackjack
//
//  Created by Alp Rüzgar on 9.11.2026.
//

import SwiftUI

struct StakesView: View {
    @Environment(User.self) private var user
    // Created once so coin updates during play don't rebuild the level out from under LevelView's view model
    @State private var level: Level?

    var body: some View {
        Group {
            if let level {
                StakesGameView(level: level)
            }
        }
        .onAppear {
            if level == nil {
                level = Level(id: Level.stakesID, name: "stakes", startingChips: user.coins, requiredChips: 0, minimumBet: 1, lockDuration: 0)
            }
        }
    }
}
