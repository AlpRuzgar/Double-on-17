//
//  StakesGameView.swift
//  blackjack
//
//  Created by Alp Rüzgar on 9.11.2026.
//

import SwiftUI
import AVFoundation

/// Stakes mode: plays with the user's real coins. Every round writes the chip count back to
/// the user; there is no target, and losing them all ends the session.
struct StakesGameView: View {
    @ObservedObject var level: Level
    @State private var betsPlaced = false
    @State private var showIntro = true
    @State private var showOutcomeOverlay = false
    @StateObject private var viewModel: LevelViewModel
    @Environment(ThemeManager.self) private var themeManager
    @Environment(User.self) private var user

    init(level: Level) {
        self.level = level
        self._viewModel = StateObject(wrappedValue: LevelViewModel(level: level))
    }

    var body: some View {
        ZStack {
            if !betsPlaced {
                BetSelectionView(vm: viewModel, betsPlaced: $betsPlaced)
                    .transition(.move(edge: .leading))
            } else {
                GameView(viewModel: viewModel, onRestart: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        betsPlaced = false
                    }
                    syncCoins()
                    if viewModel.checkOutOfChips() {
                        showOutcomeOverlay = true
                    }
                }, isLevel: true)
                .transition(.move(edge: .trailing))
            }

            if showIntro {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture { }
                    .zIndex(1)
                InfoOverlay(isPresented: $showIntro, title: "High Stakes") {
                    VStack(spacing: 4) {
                        StakesInfoRow(icon: "dollarsign.circle.fill",
                                      color: themeManager.current.colors.secondary,
                                      text: "You're playing with your real coins. Every win and loss counts.")
                        StakesInfoRow(icon: "xmark.circle.fill",
                                      color: themeManager.current.colors.alert,
                                      text: "Lose them all and you're out until you win more at the tables.")
                        StakesInfoRow(icon: "door.left.hand.open",
                                      color: themeManager.current.colors.extra,
                                      text: "Leaving mid-hand forfeits your bet.")
                    }
                    .foregroundStyle(themeManager.current.colors.text)
                    .font(.system(size: 16, weight: .medium))
                }
                .zIndex(2)
            }

            if showOutcomeOverlay {
                StakesOutcomeOverlay()
                    .transition(.opacity)
                    .zIndex(3)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showOutcomeOverlay)
        .animation(.easeInOut(duration: 0.2), value: showIntro)
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            syncCoins()
            viewModel.resetGame()
        }
    }

    /// Writes the table's chip count back to the user's coins.
    private func syncCoins() {
        user.coins = level.chipsOwned
    }
}

// MARK: - Outcome Overlay

private struct StakesOutcomeOverlay: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var accentColor: Color { themeManager.current.colors.alert }

    var body: some View {
        ZStack {
            Color.black.opacity(0.75 * opacity)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 22) {
                // Icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 96, height: 96)
                    Circle()
                        .stroke(accentColor, lineWidth: 2)
                        .frame(width: 96, height: 96)
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(accentColor)
                }

                // Title + gold divider + subtitle
                VStack(spacing: 10) {
                    Text("BROKE")
                        .font(.system(size: 30, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(themeManager.current.colors.text)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 1, y: 2)

                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(themeManager.current.colors.secondary.gradient)
                        Image(systemName: "square.fill")
                            .font(.system(size: 7))
                            .foregroundStyle(themeManager.current.colors.secondary.gradient)
                            .rotationEffect(.degrees(45))
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(themeManager.current.colors.secondary.gradient)
                    }
                    .padding(.horizontal, 16)

                    Text("You lost all your coins. Come back once you've won more at the tables.")
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(themeManager.current.colors.text.opacity(0.75))
                        .multilineTextAlignment(.center)
                }

                ActionButton(
                    text: "MAIN MENU",
                    icon: "house.fill",
                    backgroundColor: themeManager.current.colors.secondary,
                    foregroundColor: themeManager.current.colors.text,
                    action: { dismiss() },
                    doesPlaySound: true
                )
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.black.opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(themeManager.current.colors.secondary.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 32)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            AudioServicesPlaySystemSound(1053)
        }
    }
}

private struct StakesInfoRow: View {
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
    StakesGameView(level: Level(id: -1, name: "stakes", startingChips: 1000, requiredChips: 0, minimumBet: 1, lockDuration: 0))
        .environment(ThemeManager())
        .environment(User())
}
