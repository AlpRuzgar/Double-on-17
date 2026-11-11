//
//  ButtonView.swift
//  blackjack
//
//  Created by Alp Rüzgar on 24.02.2026.
//

import Foundation
import SwiftUI
import AVFoundation

// MARK: - ActionButton

struct ActionButton: View {
    enum Layout {
        case standard   // full-width, text and/or icon, height 62
        case compact    // fixed 70×70 square, icon only
    }

    var text: LocalizedStringKey?
    var icon: String?
    var layout: Layout
    var backgroundColor: Color
    var foregroundColor: Color
    var action: () -> Void
    var doesPlaySound: Bool

    init(
        text: LocalizedStringKey? = nil,
        icon: String? = nil,
        layout: Layout = .standard,
        backgroundColor: Color,
        foregroundColor: Color = .ivory,
        action: @escaping () -> Void,
        doesPlaySound: Bool
    ) {
        self.text = text
        self.icon = icon
        self.layout = layout
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
        self.doesPlaySound = doesPlaySound
    }

    var body: some View {
        Button {
            action()
            if doesPlaySound {
                AudioServicesPlaySystemSound(1306)
            }
        } label: {
            switch layout {
            case .standard:
                HStack(spacing: 12) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                    }
                    if let text {
                        Text(text)
                            .font(.system(size:16, weight: .bold))
                            .tracking(1.5)
                    }
                }
                .foregroundStyle(foregroundColor)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(backgroundColor)
                )
//                .overlay(content: {
//                    RoundedRectangle(cornerRadius: 14)
//                        .foregroundStyle(LinearGradient(colors: [.white.opacity(0),.white.opacity(0.25)], startPoint: .leading, endPoint: .trailing))
//                })
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: backgroundColor, radius: 5)

            case .compact:
                Image(systemName: icon ?? "")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(foregroundColor)
                    .frame(width: 70, height: 70)
                    .background(backgroundColor, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                //                .overlay(content: {
                //                    RoundedRectangle(cornerRadius: 14)
                //                        .foregroundStyle(LinearGradient(colors: [.white.opacity(0),.white.opacity(0.25)], startPoint: .leading, endPoint: .trailing))
                //                })
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: backgroundColor.opacity(0.6), radius: 8, x: 0, y: 4)
            }
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - PressableButtonStyle

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .brightness(configuration.isPressed ? -0.06 : 0)
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(
                configuration.isPressed
                    ? .easeIn(duration: 0.08)
                    // Low damping so the button overshoots and bounces back on release
                    : .spring(response: 0.4, dampingFraction: 0.3),
                value: configuration.isPressed
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        ActionButton(text: "TABLES", icon: "rectangle.stack.fill", backgroundColor: .blue, action: {}, doesPlaySound: true)
        ActionButton(icon: "plus", layout: .compact, backgroundColor: .green, action: {}, doesPlaySound: false)
    }
    .padding(20)
    .environment(ThemeManager())
}
