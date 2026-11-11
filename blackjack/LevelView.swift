//
//  LevelView.swift
//  blackjack
//
//  Created by Alp Rüzgar on 21.05.2026.
//

import SwiftUI
import AVFoundation

struct LevelView: View {
    @ObservedObject var level: Level
    @State var betsPlaced = false
    @State var showOutcomeOverlay = false
    @State var levelWon = false
    @StateObject var viewModel: LevelViewModel
    @Environment(ThemeManager.self) var themeManager
    @Environment(User.self) var user

    init(level: Level) {
        self.level = level
        self._viewModel = StateObject(wrappedValue: LevelViewModel(level: level))
    }
    
    
    var body: some View {
        ZStack {
            if !betsPlaced {
                BetSelectionView(vm: viewModel, betsPlaced: $betsPlaced)
                    // Slides out toward / back in from the left, like the previous screen in a navigation pop
                    .transition(.move(edge: .leading))
            } else {
                GameView(viewModel: viewModel, onRestart: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        betsPlaced = false
                    }
                    if viewModel.checkLevelPass() {
                        level.markCompleted()
                        levelWon = true
                        showOutcomeOverlay = true
                        user.increaseCoins(by: level.requiredChips/10)
                    } else if viewModel.checkOutOfChips() {
                        levelWon = false
                        showOutcomeOverlay = true
                    }
                }, isLevel: true)
                // Slides in from / back out to the right, like a pushed screen
                .transition(.move(edge: .trailing))
            }

            if showOutcomeOverlay {
                LevelOutcomeOverlay(isWon: levelWon) {
                    level.resetChips()
                    viewModel.resetGame()
                    showOutcomeOverlay = false
                    withAnimation(.easeInOut(duration: 0.35)) {
                        betsPlaced = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showOutcomeOverlay)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear{
            AudioServicesPlaySystemSound(1306)
        }
        .onDisappear {
            viewModel.resetGame()
        }
    }
}

#Preview {
    LevelOutcomeOverlay(isWon: false) {
        
    }
    .environment(ThemeManager())
}
