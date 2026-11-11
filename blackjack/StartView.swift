//
//  StartView.swift
//  blackjack
//
//  Created by Alp Rüzgar on 24.02.2026.
//

import Foundation
import SwiftUI

struct StartView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(User.self) private var user
    
    @State private var showResetAlert = false
    @State private var navigateToLevels = false
    @State private var navigateToEndless = false
    @State private var navigateToThemes = false
    @State private var navigateToStakes = false
    var stakesActive: Bool {
        user.coins > 0
    }
    
    @State private var isInfoPresented  = false
    @State private var endlessGameActive = false

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.current.background
                VStack(spacing: 0) {
                    HStack{
                        Spacer()
                        InfoButton {
                            isInfoPresented = true
                        }
                        .padding()
                    }

                    Spacer()

                    // Title + gold divider
                    VStack(spacing: 14) {
                        Text("Double on 17")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundStyle(themeManager.current.colors.text)
                            .tracking(1)
                            .shadow(color: .black.opacity(0.6), radius: 6, x: 2, y: 3)
                            .shiningEffect()

                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(themeManager.current.colors.secondary)
                            Image(systemName: "square.fill")
                                .font(.system(size: 7))
                                .foregroundStyle(themeManager.current.colors.secondary)
                                .rotationEffect(.degrees(45))
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(themeManager.current.colors.secondary)
                        }
                        .padding(.horizontal, 40)
                    }

                    Spacer()

                    // Main navigation buttons
                    VStack(spacing: 16) {
                        ActionButton(
                            text: "TABLES",
                            icon: "rectangle.stack.fill",
                            backgroundColor: themeManager.current.colors.primary,
                            foregroundColor: themeManager.current.colors.text,
                            action: { navigateToLevels = true },
                            doesPlaySound: true
                        )
                        ActionButton(
                            text: "ENDLESS",
                            icon: "infinity",
                            backgroundColor: themeManager.current.colors.alert,
                            foregroundColor: themeManager.current.colors.text,
                            action: { navigateToEndless = true },
                            doesPlaySound: true
                        )
                        ActionButton(text: "STAKES",
                            icon: "dollarsign.circle.fill",
                            backgroundColor: themeManager.current.colors.extra,
                            foregroundColor: themeManager.current.colors.text,
                            action: {
                                navigateToStakes = true
                            },
                            doesPlaySound: true)
                        .disabled(!stakesActive)
                        .overlay {
                            if !stakesActive {
                                // Compact version of LevelButton's lock overlay, sized for a 56pt button
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(.black.opacity(0.78))
                                    HStack(spacing: 10) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(.green)
                                        Text("NO COINS")
                                            .font(.system(size: 16, weight: .bold))
                                            .tracking(1.5)
                                            .foregroundStyle(themeManager.current.colors.text)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // Theme store link
                    ActionButton(
                        text: "THEMES",
                        icon: "paintpalette.fill",
                        backgroundColor: themeManager.current.colors.secondary,
                        foregroundColor: themeManager.current.colors.text,
                        action: { navigateToThemes = true },
                        doesPlaySound: true
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
                if isInfoPresented {
                    InfoOverlay(isPresented: $isInfoPresented, title: "How to Play") {
                        VStack(spacing: 2) {
                            StartInfoRow(icon: "target", color: themeManager.current.colors.primary,
                                         text: "Get closer to 21 than the dealer without going over.")
                            StartInfoRow(icon: "a.square.fill", color: themeManager.current.colors.secondary,
                                         text: "Aces count as 1 or 11. Face cards (J, Q, K) are worth 10.")
                            StartInfoRow(icon: "xmark.circle.fill", color: themeManager.current.colors.alert,
                                         text: "Go over 21 and you bust. If the dealer busts, you win.")
                            StartInfoRow(icon: "person.fill", color: themeManager.current.colors.extra,
                                         text: "Dealer draws until reaching 17, then must stand.")
                            StartInfoRow(icon: "equal.circle.fill", color: themeManager.current.colors.text.opacity(0.6),
                                         text: "Equal scores are a push — your bet is returned.")
                        }
                        .foregroundStyle(themeManager.current.colors.text)
                        .font(.system(size: 15, weight: .medium))
                    }
                }
                if endlessGameActive {
                    GameView(viewModel: GameViewModel(gameType: .endless), onExit: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            endlessGameActive = false
                        }
                    }, isLevel: false)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                }
            }
            .navigationDestination(isPresented: $navigateToLevels) {
                LevelMenuView()
            }
            .navigationDestination(isPresented: $navigateToEndless) {
                GameView(viewModel: GameViewModel(gameType: .endless), isLevel: false)
            }
            .navigationDestination(isPresented: $navigateToStakes) {
                StakesView()
            }
            .navigationDestination(isPresented: $navigateToThemes) {
                ThemeStoreView()
            }
            .toolbar {
                #if DEBUG
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showResetAlert = true
                    } label: {
                        Image(systemName: "trash.fill")
                            .foregroundStyle(.red)
                    }
                }
                #endif
            }
            #if DEBUG
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    themeManager.reset()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will wipe all progress, chips, and unlocked themes.")
            }
            #endif
        }
    }
}

private struct StartInfoRow: View {
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
        .padding(.vertical, 7)
        .padding(.horizontal, 4)
    }
}

#Preview {
    StartView()
        .environment(ThemeManager())
}



struct ShimmerEffect: ViewModifier {
    @State private var startPoint = UnitPoint(x: -1.8, y: 0)
    @State private var endPoint = UnitPoint(x: -0.2, y: 0)
    
    let duration: Double = 1.5 // Time it takes to sweep across
    let interval: Double = 3.5 // Total loop duration (1.5s sweep + 2s pause)

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.1),
                        .white.opacity(0.8), // The core shine streak
                        .white.opacity(0.1),
                        .clear
                    ],
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                // Blend mode ensures it only illuminates the existing text pixels
                .blendMode(.screen)
                // Mask hides the gradient outside the boundaries of the text letters
                .mask(content)
            )
            .onAppear {
                startShimmerLoop()
            }
    }

    private func startShimmerLoop() {
        // Force an immediate initial run
        runShimmerAnimation()
        
        // Loop the animation at your specific interval
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            runShimmerAnimation()
        }
    }

    private func runShimmerAnimation() {
        // Reset instantly off-screen to the left (leading)
        startPoint = UnitPoint(x: -1.8, y: 0)
        endPoint = UnitPoint(x: -0.2, y: 0)
        
        // Animate smoothly to the right (trailing)
        withAnimation(.linear(duration: duration)) {
            startPoint = UnitPoint(x: 1.2, y: 0)
            endPoint = UnitPoint(x: 2.8, y: 0)
        }
    }
}

// Convenient Extension for cleaner syntax
extension View {
    func shiningEffect() -> some View {
        self.modifier(ShimmerEffect())
    }

    // navigationTransition(_:) requires iOS 18; on older systems the view is returned unchanged
    @ViewBuilder
    func navigationTransitionIfAvailable() -> some View {
        if #available(iOS 18.0, *) {
            self.navigationTransition(.automatic)
        } else {
            self
        }
    }
}
