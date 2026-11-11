//
//  ContentView.swift
//  blackjack
//
//  Created by Alp Rüzgar on 23.02.2026.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    var onRestart: (() -> Void)?
    /// Called by the back button when the view isn't presented via a navigation push
    var onExit: (() -> Void)?
    @Environment(ThemeManager.self) var themeManager
    @Environment(SoundManager.self) var soundManager
    @State private var dealtCardIDs: Set<UUID> = []
    @State private var dealerFlipAngle: Double = 0
    @Namespace private var splitNamespace
    @State private var chipBarOpacity: Double = 0
    @State private var chipBarOffset: CGFloat = -50
    @State private var buttonsOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 50
    
    @State private var isHowToShowing = false
    let isLevel: Bool
    var isBackButtonActive: Bool { !isLevel }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.current.gameBG
                VStack {
                    HStack {//MARK: toolbar
                        if !isLevel {
                            BackButton(action: onExit)
                        }
                        Spacer()
                        InfoButton {
                            isHowToShowing.toggle()
                        }
                    }
                    .padding()
                    
                    VStack { //MARK: Cards
                        // Dealer Section
                        VStack(spacing: 12) {
                            Text("DEALER")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(themeManager.current.colors.text.opacity(0.8))
                                .tracking(2)
                            
                            // Dealer hand value display
                            ZStack {
                                Capsule()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 80, height: 36)
                                
                                Text(dealerFlipAngle >= 180 ? "\(viewModel.dealersHandValue)" : "?")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(themeManager.current.colors.text)
                            }
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                            
                            HStack(spacing: -35) {
                                ForEach(Array(viewModel.dealersHand.cards.enumerated()), id: \.element.id) { index, card in
                                    dealerCardView(index: index, card: card)
                                }
                            }
                            .frame(height: 165)
                            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        Spacer().frame(height: 30)
                        
                        // Player Section - all hands
                        ZStack {
                            ForEach(Array(viewModel.hands.enumerated()), id: \.offset) { index, hand in
                                PlayerHandView(
                                    cards: hand.cards,
                                    handValue: hand.value,
                                    label: viewModel.hands.count > 1 ? "HAND \(index + 1)" : "PLAYER",
                                    isActive: index == viewModel.targetHandIndex,
                                    handResult: hand.result,
                                    dealtCardIDs: $dealtCardIDs,
                                    splitNamespace: splitNamespace
                                )
                                .scaleEffect(index == viewModel.targetHandIndex ? 1.0 : 0.75)
                                .offset(x: CGFloat(index - viewModel.targetHandIndex) * 160)
                                .opacity(index == viewModel.targetHandIndex ? 1.0 : 0.65)
                                .zIndex(index == viewModel.targetHandIndex ? 1 : 0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.targetHandIndex)
                            }
                        }
                        if !isLevel {
                            HStack {
                                Text("Streak: \(viewModel.streak)")
                                    .font(.system(size: 15,weight: .bold))
                                    .foregroundStyle(themeManager.current.colors.secondary.opacity(0.7))
                                    .tracking(1.5)
                                
                                Text("Record: \(viewModel.record)")
                                    .font(.system(size: 15,weight: .bold))
                                    .foregroundStyle(themeManager.current.colors.secondary.opacity(0.7))
                                    .tracking(1.5)
                            }

                        } else {
                            chipBar
                        }
                    }
                    
                    // Action Buttons (overlay - floats above content without affecting layout)
                    VStack {
                        if !viewModel.isGameOver {
                            HStack(spacing: 20) {
                                ActionButton(icon: "plus", layout: .compact, backgroundColor: themeManager.current.colors.alert, action: {
                                    viewModel.hit()
                                    if viewModel.playersHandValue > 21 {
                                        if let levelVM = viewModel as? LevelViewModel {
                                            let isLastHand = levelVM.targetHandIndex + 1 >= levelVM.hands.count
                                            let hasStoodPriorHands = levelVM.targetHandIndex > 0 && levelVM.hands[0..<levelVM.targetHandIndex].contains { $0.result == nil }
                                            levelVM.playerBust()
                                            if isLastHand && hasStoodPriorHands {
                                                Task {
                                                    withAnimation(.easeInOut(duration: 0.5)) {
                                                        dealerFlipAngle = 180
                                                    }
                                                }
                                            }
                                        } else {
                                            viewModel.playerBust()
                                        }
                                    }
                                }, doesPlaySound: false)
                                ActionButton(icon: "hand.raised.fill", layout: .compact, backgroundColor: themeManager.current.colors.primary, action: {
                                    if let levelVM = viewModel as? LevelViewModel {
                                        let isLastHand = levelVM.targetHandIndex + 1 >= levelVM.hands.count
                                        levelVM.stand()
                                        if isLastHand {
                                            Task {
                                                withAnimation(.easeInOut(duration: 0.5)) {
                                                    dealerFlipAngle = 180
                                                }
                                            }
                                        }
                                    } else {
                                        viewModel.stand()
                                        Task {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                dealerFlipAngle = 180
                                            }
                                        }
                                    }
                                }, doesPlaySound: false)
                                
                                if let levelVM = viewModel as? LevelViewModel,
                                   levelVM.hands.count == 1 && levelVM.currentHand.cards.count == 2,
                                   levelVM.level.chipsOwned >= levelVM.currentBet{
                                    ActionButton(icon: "chevron.up.2", layout: .compact, backgroundColor: themeManager.current.colors.extra, action: {
                                        if levelVM.canDoubleDown {
                                            levelVM.doubleDown()
                                            Task {
                                                withAnimation(.easeInOut(duration: 0.5)) {
                                                    dealerFlipAngle = 180
                                                }
                                            }
                                        }
                                    }, doesPlaySound: false)
                                }
                                if let levelVM = viewModel as? LevelViewModel, levelVM.canSplit() {
                                    ActionButton(icon: "arrow.left.and.right", layout: .compact, backgroundColor: themeManager.current.colors.secondary, action: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                            levelVM.split()
                                        }
                                    }, doesPlaySound: false)
                                }
                                
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 30)
                            .opacity(buttonsOpacity)
                            .offset(y: buttonsOffset)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .disabled(isHowToShowing)
                        }
                    }
                    .animation(.easeInOut(duration: 0.4), value: viewModel.isGameOver)

                    Spacer()
                }
                
                
                if isHowToShowing {
                    InfoOverlay(isPresented: $isHowToShowing, title: "How to Play?", overlayBody: {
                        VStack(spacing: 4) {
                            InfoRow(icon: "plus", color: themeManager.current.colors.alert, text: "Hit: draw a card.")
                            InfoRow(icon: "hand.raised.fill", color: themeManager.current.colors.primary, text: "Stand: end your turn.")
                            if isLevel {
                                InfoRow(icon: "chevron.up.2", color: themeManager.current.colors.extra, text: "Double: double your bet, draw one card.")
                                InfoRow(icon: "arrow.left.and.right", color: themeManager.current.colors.secondary, text: "Split: split a matching pair into two hands.")
                            }
                        }
                        .foregroundStyle(themeManager.current.colors.text)
                        .font(.system(size: 20, weight: .medium))
                    })
                    .padding(10)
                    
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear() {
            viewModel.themeManager = themeManager
            viewModel.soundManager = soundManager
            Task{
                await viewModel.startGame(for: viewModel.playersHand)
                viewModel.isGameOver = false
            }
            withAnimation(.easeOut(duration: 0.5)) {
                chipBarOpacity = 1
                chipBarOffset = 0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                buttonsOpacity = 1
                buttonsOffset = 0
            }
        }
        .onChange(of: viewModel.isRoundComplete) {
            guard viewModel.isRoundComplete else { return }
            isHowToShowing = false
            Task {
                try? await Task.sleep(for: .seconds(2))
                dealtCardIDs.removeAll()
                dealerFlipAngle = 0
                if let onRestart {
                    onRestart()
                    viewModel.resetGame()
                } else {
                    await viewModel.startGame(for: viewModel.playersHand)
                    viewModel.isGameOver = false
                }
            }
        }
    }
    
    @ViewBuilder
    private func dealerCardView(index: Int, card: Card) -> some View {
        if index == 1 {
            ZStack {
                // Front of card
                Image(card.frontImage)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 110, height: 165)
                    .scaleEffect(x: -1, y: 1)
                    .opacity(dealerFlipAngle > 90 ? 1 : 0)
                
                // Back of card
                Image(card.backImage)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 110, height: 165)
                    .opacity(dealerFlipAngle <= 90 ? 1 : 0)
            }
            .cornerRadius(10)
            .rotation3DEffect(
                .degrees(dealerFlipAngle),
                axis: (x: 0, y: 1, z: 0)
            )
            .offset(y: dealtCardIDs.contains(card.id) ? 0 : -1000)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4)) {
                    _ = dealtCardIDs.insert(card.id)
                }
            }
        } else {
            cardImageView(card: card)
        }
    }
    
    private func cardImageView(card: Card) -> some View {
        Image(card.frontImage)
            .resizable()
            .interpolation(.high)
            .antialiased(true)
            .scaledToFit()
            .frame(width: 110, height: 165)
        //            .colorMultiply(themeManager.current.cardTint ?? .white)
            .cornerRadius(10)
            .offset(y: dealtCardIDs.contains(card.id) ? 0 : -1000)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4)) {
                    _ = dealtCardIDs.insert(card.id)
                }
            }
    }
    
    @ViewBuilder
    private var chipBar: some View {
        if let levelVM = viewModel as? LevelViewModel {
            HStack {
                HStack(spacing: 6) {
                    Text("BET")
                        .font(.system(size: 12,weight: .bold))
                        .foregroundStyle(themeManager.current.colors.secondary.opacity(0.7))
                        .tracking(1.5)
                    Text("\(levelVM.currentBet)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(themeManager.current.colors.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(.black.opacity(0.3), in: Capsule())
            }
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
}


private struct InfoRow: View {
    let icon: String
    let color: Color
    let text: LocalizedStringKey
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 28)
            Text(text)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

#Preview {
//    GameView(viewModel: GameViewModel(gameType: .endless), isLevel: false)
//        .environment(ThemeManager())
//        .environment(User())
//        .environment(SoundManager())
            GameView(viewModel: LevelViewModel(level: Level(id: 99, name: "a", startingChips: 10000, requiredChips: 100000, minimumBet: 1, lockDuration: 1)), isLevel: true)
                .environment(ThemeManager())
                .environment(User())
                .environment(SoundManager())
}
