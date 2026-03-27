import SwiftUI

struct TimerHeaderComponent: View {
    let sessionType: String
    let showAODButton: Bool
    let theme: PomodoroTheme
    let onAODToggle: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Text(sessionType.uppercased())
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .kerning(1.5)
                .foregroundColor(theme.statusText)
                
            Spacer()
            if showAODButton {
                Button(action: onAODToggle) {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(theme.text.opacity(0.3))
                        .font(.title3)
                }
            } else {
                // Keep the spacer's balance if AOD button is hidden but we want it centered
                // However, the original code had Spacer() on both sides, so it's already centered.
                // If AOD button is present, it's on the right.
                // Let's match the original layout exactly.
                Color.clear.frame(width: 30, height: 30) // Approximate size of the button to keep title centered
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

#Preview {
    TimerHeaderComponent(
        sessionType: "Focus",
        showAODButton: true,
        theme: .defaultTheme,
        onAODToggle: {}
    )
    .background(Color.gray)
}
