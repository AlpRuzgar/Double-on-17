//
//  NewBetSelectionView.swift
//  blackjack
//
//  Created by Alp Rüzgar on 7.06.2026.
//

import SwiftUI

struct BetSelectionView: View {
    @ObservedObject var vm: LevelViewModel
    @Binding var betsPlaced: Bool
    @Environment(ThemeManager.self) var themeManager
    @Environment(SoundManager.self) var soundManager
    @Environment(\.dismiss) private var dismiss
    @State var errorMessage = ""
    @State private var errorVisible = false
    
    @State var chip1BetAmount = 0
    @State var chip5BetAmount = 0
    @State var chip25BetAmount = 0
    @State var chip100BetAmount = 0
    @State var chip500BetAmount = 0
    @State var chip1000BetAmount = 0
    
    @State private var headerVisible = false
    @State private var chipsVisible = false
    @State private var actionsVisible = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                //MARK: Back button & chip amount
                HStack {
                    BackButton()
                    Spacer()
                }
                .padding(.horizontal, 10)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                
                //MARK: Header — balance, title, divider, bet amount
                VStack(spacing: 6) {
                    Text("PLACE YOUR BET")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(themeManager.current.colors.text)
                        .tracking(1)
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
                    .padding(.horizontal, 50)
                    
                    // Stakes mode has no target
                    if vm.level.id != Level.stakesID {
                        Text("TARGET CHIPS: \(vm.level.requiredChips)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(themeManager.current.colors.secondary)
                            .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
                    }
                    
                }
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : -20)
                
                // MARK: - Placed Chips Panel (tap to remove)
                VStack(spacing: 0) {
                    HStack {
                        Text("YOUR BET")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(themeManager.current.colors.secondary)
                            .tracking(2)
                        Text("\(vm.startingBet)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(themeManager.current.colors.text)
                            .tracking(2)
                        Spacer()
                        Text("TAP TO REMOVE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(themeManager.current.colors.text.opacity(0.5))
                            .tracking(1)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(themeManager.current.colors.secondary.opacity(0.3))
                        .padding(.horizontal, 14)
                    
                    VStack(spacing: 15) {
                        HStack {
                            ChipButton(action: {
                                doDecrease(chipAmount: &chip1BetAmount, value: 1)
                            }, image: Image("1-\(themeManager.current.id)"))
                            .opacity(chip1BetAmount > 0 ? 1 : 0)
                            .scaleEffect(chip1BetAmount > 0 ? 1.0 : 0.4)
                            .animation(.spring(response: 0.35, dampingFraction: 0.5), value: chip1BetAmount > 0)
                            .allowsHitTesting(chip1BetAmount > 0)
                            ChipCountDisplay(amount: chip1BetAmount)
                            
                            ChipButton(action: {
                                doDecrease(chipAmount: &chip5BetAmount, value: 5)
                            }, image: Image("5-\(themeManager.current.id)"))
                            .opacity(chip5BetAmount > 0 ? 1 : 0)
                            .scaleEffect(chip5BetAmount > 0 ? 1.0 : 0.4)
                            .animation(.spring(response: 0.35, dampingFraction: 0.5), value: chip5BetAmount > 0)
                            .allowsHitTesting(chip5BetAmount > 0)
                            ChipCountDisplay(amount: chip5BetAmount)
                            
                            
                            ChipButton(action: {
                                doDecrease(chipAmount: &chip25BetAmount, value: 25)
                            }, image: Image("25-\(themeManager.current.id)"))
                            .opacity(chip25BetAmount > 0 ? 1 : 0)
                            .scaleEffect(chip25BetAmount > 0 ? 1.0 : 0.4)
                            .animation(.spring(response: 0.35, dampingFraction: 0.5), value: chip25BetAmount > 0)
                            .allowsHitTesting(chip25BetAmount > 0)
                            ChipCountDisplay(amount: chip25BetAmount)
                        }
                        HStack {
                            ChipButton(action: {
                                doDecrease(chipAmount: &chip100BetAmount, value: 100)
                            }, image: Image("100-\(themeManager.current.id)"))
                            .opacity(chip100BetAmount > 0 ? 1 : 0)
                            .scaleEffect(chip100BetAmount > 0 ? 1.0 : 0.4)
                            .animation(.spring(response: 0.35, dampingFraction: 0.5), value: chip100BetAmount > 0)
                            .allowsHitTesting(chip100BetAmount > 0)
                            ChipCountDisplay(amount: chip100BetAmount)
                            
                            ChipButton(action: {
                                doDecrease(chipAmount: &chip500BetAmount, value: 500)
                            }, image: Image("500-\(themeManager.current.id)"))
                            .opacity(chip500BetAmount > 0 ? 1 : 0)
                            .scaleEffect(chip500BetAmount > 0 ? 1.0 : 0.4)
                            .animation(.spring(response: 0.35, dampingFraction: 0.5), value: chip500BetAmount > 0)
                            .allowsHitTesting(chip500BetAmount > 0)
                            ChipCountDisplay(amount: chip500BetAmount)
                            
                            ChipButton(action: {
                                doDecrease(chipAmount: &chip1000BetAmount, value: 1000)
                            }, image: Image("1000-\(themeManager.current.id)"))
                            .opacity(chip1000BetAmount > 0 ? 1 : 0)
                            .scaleEffect(chip1000BetAmount > 0 ? 1.0 : 0.4)
                            .animation(.spring(response: 0.35, dampingFraction: 0.5), value: chip1000BetAmount > 0)
                            .allowsHitTesting(chip1000BetAmount > 0)
                            ChipCountDisplay(amount: chip1000BetAmount)

                        }
                    }
                    .padding(8)
                }
                .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.current.colors.secondary.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 12)
                .opacity(chipsVisible ? 1 : 0)
                .offset(y: chipsVisible ? 0 : 20)
                
                // MARK: - Chip Tray (tap to add)
                VStack(spacing: 0) {
                    HStack {
                        Text("CHIP TRAY")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(themeManager.current.colors.secondary)
                            .tracking(2)
                        Text("\(vm.level.chipsOwned)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(themeManager.current.colors.text)
                            .tracking(2)
                        Spacer()
                        Text("TAP TO ADD")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.ivory.opacity(0.5))
                            .tracking(1)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(themeManager.current.colors.secondary.opacity(0.3))
                        .padding(.horizontal, 14)
                    
                    VStack(spacing: 4) {
                        HStack {
                            ChipButton(action: {
                                if doIncrease(value: 1) { chip1BetAmount += 1 }
                            }, image: Image("1-\(themeManager.current.id)"))
                            ChipButton(action: {
                                if doIncrease(value: 5) { chip5BetAmount += 1 }
                            }, image: Image("5-\(themeManager.current.id)"))
                            ChipButton(action: {
                                if doIncrease(value: 25) { chip25BetAmount += 1 }
                            }, image: Image("25-\(themeManager.current.id)"))
                        }
                        HStack {
                            ChipButton(action: {
                                if doIncrease(value: 100) { chip100BetAmount += 1 }
                            }, image: Image("100-\(themeManager.current.id)"))
                            ChipButton(action: {
                                if doIncrease(value: 500) { chip500BetAmount += 1 }
                            }, image: Image("500-\(themeManager.current.id)"))
                            ChipButton(action: {
                                if doIncrease(value: 1000) { chip1000BetAmount += 1}
                            }, image: Image("1000-\(themeManager.current.id)"))
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.current.colors.secondary.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 12)
                .opacity(chipsVisible ? 1 : 0)
                .offset(y: chipsVisible ? 0 : 20)
                
                // MARK: - Action Buttons
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ActionButton(
                            text: "MIN BET",
                            icon: "arrow.down.circle.fill",
                            backgroundColor: themeManager.current.colors.primary,
                            foregroundColor: themeManager.current.colors.text,
                            action: {
                                decreaseBet(by: vm.startingBet)
                                calculateBetinChips(bet: vm.level.minimumBet)
                                increaseBet(by: vm.level.minimumBet)
                                soundManager.play("chipPlacingSound.mp3")
                            },
                            doesPlaySound: false
                        )

                        ActionButton(
                            text: "MAX BET",
                            icon: "arrow.up.circle.fill",
                            backgroundColor: themeManager.current.colors.alert,
                            foregroundColor: themeManager.current.colors.text,
                            action: {
                                decreaseBet(by: vm.startingBet)
                                calculateBetinChips(bet: vm.level.chipsOwned)
                                increaseBet(by: vm.level.chipsOwned)
                                soundManager.play("chipPlacingSound.mp3")
                            },
                            doesPlaySound: false
                        )
                    }
                    ActionButton(
                        text: "PLACE BET",
                        icon: "checkmark.circle.fill",
                        backgroundColor: themeManager.current.colors.secondary,
                        foregroundColor: themeManager.current.colors.text,
                        action: {
                            vm.placeBet()
                            withAnimation(.easeInOut(duration: 0.35)) {
                                betsPlaced = true
                            }
                            vm.startingBet = vm.currentBet
                        },
                        doesPlaySound: true
                    )
                    
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .opacity(actionsVisible ? 1 : 0)
                .offset(y: actionsVisible ? 0 : 30)
            }
            .padding(5)
            
            // Error toast
            Text(errorMessage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(themeManager.current.colors.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(red: 0.7, green: 0.05, blue: 0.05), in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.red.opacity(0.4), lineWidth: 1)
                )
                .opacity(errorVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.6), value: errorVisible)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 20)
                .allowsHitTesting(false)
            
        }
        .background(themeManager.current.background)
        .onAppear {
            if vm.level.chipsOwned >= vm.startingBet {
                vm.startingBet = vm.startingBet
                calculateBetinChips(bet: vm.startingBet)
            }
            else {
                vm.startingBet = vm.level.minimumBet
                calculateBetinChips(bet: vm.level.minimumBet)
            }
            withAnimation(.easeOut(duration: 0.4)) {
                headerVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                chipsVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                actionsVisible = true
            }
        }
    }
    
    // MARK: - Helpers

    func showError(_ message: String) {
        errorMessage = message
        errorVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            errorVisible = false
        }
    }
    
    func increaseBet(by bet: Int) {
        vm.startingBet += bet
    }
    func decreaseBet(by bet: Int) {
        vm.startingBet -= bet
    }
    
    @discardableResult
    func doIncrease(value: Int) -> Bool {
        guard vm.level.chipsOwned >= vm.startingBet + value else { showError(String(localized: "You don't have enough chips")); return false }
        increaseBet(by: value)
        soundManager.play("chipPlacingSound.mp3")
        return true
    }
    
    func doDecrease(chipAmount: inout Int, value: Int) {
        guard vm.startingBet - value >= vm.level.minimumBet else { showError(String(localized: "You can't bet less than \(vm.level.minimumBet)")); return }
        decreaseBet(by: value)
        chipAmount -= 1
        soundManager.play("chipPlacingSound.mp3")
    }
    
    /// Converts a chip total into per-denomination counts using greedy decomposition
    /// (largest denomination first), so the chip tray always shows the fewest chips.
    func calculateBetinChips(bet: Int) {
        var betLeft = bet
        chip1000BetAmount = betLeft / 1000; betLeft = betLeft % 1000
        chip500BetAmount  = betLeft / 500;  betLeft = betLeft % 500
        chip100BetAmount  = betLeft / 100;  betLeft = betLeft % 100
        chip25BetAmount   = betLeft / 25;   betLeft = betLeft % 25
        chip5BetAmount    = betLeft / 5;    betLeft = betLeft % 5
        chip1BetAmount    = betLeft / 1
    }
}

// MARK: - Supporting Views

struct ChipCountDisplay: View {
    let amount: Int
    @Environment(ThemeManager.self) var themeManager
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Text("\(amount)")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(themeManager.current.colors.text)
            .frame(width: 30)
            .opacity(amount > 0 ? 1 : 0)
            .scaleEffect(scale)
            .onChange(of: amount) {
                scale = 1.5
                withAnimation(.spring(response: 0.3, dampingFraction: 0.35)) {
                    scale = 1.0
                }
            }
    }
}

struct ChipButton: View {
    var action: () -> Void
    let image: Image?
    
    var body: some View {
        Button {
            action()
        } label: {
            image?
                .resizable()
                .scaledToFit()
                .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 4)
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 8)
        }
        .frame(width: 70, height: 70)
    }
}

#Preview {
    BetSelectionView(
        vm: LevelViewModel(level: Level(id: 1, name: "Preview", startingChips: 100000, requiredChips: 200000, minimumBet: 10, lockDuration: 10)),
        betsPlaced: .constant(false)
    )
    .environment(ThemeManager())
    .environment(SoundManager())
}
