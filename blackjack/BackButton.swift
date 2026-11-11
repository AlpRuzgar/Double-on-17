//
//  BackButton.swift
//  blackjack
//
//  Created by Alp Rüzgar on 6.07.2026.
//

import Foundation
import SwiftUI

// MARK: - BackButton

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) var themeManager
    /// Overrides the default dismiss behavior, for views that aren't presented via a navigation push
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            if let action {
                action()
            } else {
                dismiss()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                Text("Back")
                    .font(.system(size: 17, weight: .bold))
            }
            .frame(height: 16)
            .foregroundStyle(themeManager.current.colors.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(themeManager.current.colors.secondary.opacity(0.9), lineWidth: 2)
            )
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.black.opacity(0.7))

            }
            .shadow(color: themeManager.current.colors.secondary.opacity(0.6), radius: 4)

        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - InfoButton

struct InfoButton: View {
    @Environment(ThemeManager.self) var themeManager
    var action: () -> Void
    @State private var isPulsing = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "info")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(themeManager.current.colors.secondary)
                .frame(width: 42, height: 42)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(themeManager.current.colors.secondary.opacity(0.9), lineWidth: 2)
                )
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.black.opacity(0.7))

                }
                .shadow(color: themeManager.current.colors.secondary.opacity(isPulsing ? 0.9 : 0.4), radius: isPulsing ? 10 : 4)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
        }
        .buttonStyle(PressableButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        BackButton()
        InfoButton {

        }
    }
    .environment(ThemeManager())
}
