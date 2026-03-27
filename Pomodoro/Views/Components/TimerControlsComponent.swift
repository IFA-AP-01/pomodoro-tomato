import SwiftUI

struct TimerControlsComponent: View {
    let isRunning: Bool
    let theme: PomodoroTheme
    let onReset: () -> Void
    let onTogglePlayPause: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        HStack(spacing: 35) {
            // Reset
            Button(action: onReset) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(theme.text.opacity(0.3))
            }
            
            // Play / Pause
            Button(action: onTogglePlayPause) {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 40))
                    .foregroundColor(theme.text)
            }
            
            // Skip
            Button(action: onSkip) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(theme.text.opacity(0.3))
            }
        }
        .padding(.bottom, 130)
    }
}

#Preview {
    TimerControlsComponent(
        isRunning: false,
        theme: .defaultTheme,
        onReset: {},
        onTogglePlayPause: {},
        onSkip: {}
    )
}
